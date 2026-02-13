#!/usr/bin/env python3
"""
Convert cyclicality project datasets into a unified SQLite database.

Usage examples:
  python code/python/convert_to_sqlite.py
  python code/python/convert_to_sqlite.py --dry-run
  python code/python/convert_to_sqlite.py --skip-large
  python code/python/convert_to_sqlite.py --only processed_alldata
  python code/python/convert_to_sqlite.py --verify-only
"""

from __future__ import annotations

import argparse
import datetime as dt
import math
import re
import sqlite3
import sys
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Callable, Dict, Iterable, Iterator, List, Optional

import numpy as np
import pandas as pd
from pandas.errors import ParserError

ROOT = Path(__file__).resolve().parents[2]
DATA_DIR = ROOT / "data"
DB_PATH = DATA_DIR / "cyclicality.db"
CHUNK_SIZE = 50_000
LARGE_FILE_BYTES = 100 * 1024 * 1024
VERIFY_TOL = 1e-6


def get_pyreadstat():
    try:
        import pyreadstat  # type: ignore
    except ImportError as exc:  # pragma: no cover - runtime dependency guard
        raise RuntimeError(
            "pyreadstat is required for .dta conversion. Install with: pip install pyreadstat"
        ) from exc
    return pyreadstat


@dataclass
class NumericAccumulator:
    count: int = 0
    sum_: float = 0.0
    sumsq: float = 0.0
    min_: Optional[float] = None
    max_: Optional[float] = None

    def update(self, values: np.ndarray) -> None:
        if values.size == 0:
            return
        arr = values.astype(float)
        self.count += int(arr.size)
        self.sum_ += float(arr.sum())
        self.sumsq += float(np.square(arr).sum())
        mn = float(arr.min())
        mx = float(arr.max())
        self.min_ = mn if self.min_ is None else min(self.min_, mn)
        self.max_ = mx if self.max_ is None else max(self.max_, mx)

    def to_stats(self) -> Dict[str, Optional[float]]:
        if self.count == 0:
            return {
                "n": 0,
                "mean": None,
                "std": None,
                "min": None,
                "max": None,
            }
        mean = self.sum_ / self.count
        if self.count > 1:
            variance = (self.sumsq - self.count * mean * mean) / (self.count - 1)
            variance = max(variance, 0.0)
            std = math.sqrt(variance)
        else:
            std = 0.0
        return {
            "n": self.count,
            "mean": mean,
            "std": std,
            "min": self.min_,
            "max": self.max_,
        }


@dataclass
class TableProfile:
    row_count: int
    col_count: int
    null_counts: Dict[str, int] = field(default_factory=dict)
    numeric_stats: Dict[str, Dict[str, Optional[float]]] = field(default_factory=dict)


@dataclass
class Task:
    table_name: str
    source_path: Optional[Path]
    source_format: str
    converter: Callable[[sqlite3.Connection, "Task", argparse.Namespace], None]
    kwargs: Dict[str, Any] = field(default_factory=dict)


def utc_now() -> str:
    return dt.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"


def file_size(path: Path) -> int:
    return path.stat().st_size if path.exists() else 0


def sanitize_name(value: str) -> str:
    value = value.strip().lower()
    value = re.sub(r"[^a-z0-9]+", "_", value)
    value = re.sub(r"_+", "_", value).strip("_")
    if not value:
        value = "unnamed"
    if value[0].isdigit():
        value = f"t_{value}"
    return value


def q(name: str) -> str:
    return '"' + name.replace('"', '""') + '"'


def ensure_unique_columns(columns: Iterable[str]) -> List[str]:
    seen: Dict[str, int] = {}
    out: List[str] = []
    for col in columns:
        base = sanitize_name(str(col))
        idx = seen.get(base, 0)
        if idx == 0:
            out.append(base)
        else:
            out.append(f"{base}_{idx}")
        seen[base] = idx + 1
    return out


def create_connection(db_path: Path) -> sqlite3.Connection:
    db_path.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(str(db_path))
    conn.execute("PRAGMA journal_mode=WAL;")
    conn.execute("PRAGMA foreign_keys=ON;")
    conn.execute("PRAGMA synchronous=NORMAL;")
    conn.execute("PRAGMA temp_store=MEMORY;")
    return conn


def sqlite_max_variables(conn: sqlite3.Connection) -> int:
    default_max = 999
    try:
        rows = conn.execute("PRAGMA compile_options;").fetchall()
    except Exception:
        return default_max
    for (opt,) in rows:
        if isinstance(opt, str) and opt.startswith("MAX_VARIABLE_NUMBER="):
            try:
                return int(opt.split("=", 1)[1])
            except ValueError:
                return default_max
    return default_max


def safe_to_sql_chunksize(conn: sqlite3.Connection, n_columns: int) -> int:
    max_vars = sqlite_max_variables(conn)
    if n_columns <= 0:
        return CHUNK_SIZE
    return max(1, min(CHUNK_SIZE, max_vars // n_columns))


def detect_delimiter_and_skiprows(path: Path, max_lines: int = 120) -> tuple[str, int]:
    candidates = [",", "\t", ";", "|"]
    lines: List[str] = []
    with path.open("r", encoding="utf-8", errors="ignore") as f:
        for _ in range(max_lines):
            line = f.readline()
            if not line:
                break
            lines.append(line.rstrip("\n"))

    best_delim = ","
    best_count = -1
    best_row = 0
    for delim in candidates:
        counts = [ln.count(delim) for ln in lines]
        max_count = max(counts) if counts else -1
        if max_count > best_count:
            best_count = max_count
            best_delim = delim
            best_row = counts.index(max_count) if max_count >= 0 else 0

    if best_count <= 0:
        return ",", 0
    return best_delim, best_row


def robust_read_csv(path: Path, read_kwargs: Dict[str, Any]) -> tuple[pd.DataFrame, str]:
    try:
        return pd.read_csv(path, **read_kwargs), "default"
    except ParserError:
        pass

    # Pandas python engine can recover some malformed records.
    try_kwargs = dict(read_kwargs)
    try_kwargs.setdefault("engine", "python")
    try_kwargs.setdefault("sep", None)
    try:
        return pd.read_csv(path, **try_kwargs), "python_engine_auto_sep"
    except Exception:
        pass

    delim, skiprows = detect_delimiter_and_skiprows(path)
    retry_kwargs = dict(read_kwargs)
    retry_kwargs.setdefault("sep", delim)
    retry_kwargs.setdefault("skiprows", skiprows)
    retry_kwargs.setdefault("engine", "python")
    return pd.read_csv(path, **retry_kwargs), f"detected_delim={repr(delim)} skiprows={skiprows}"


def init_metadata_tables(conn: sqlite3.Connection) -> None:
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS meta_sources (
            table_name TEXT PRIMARY KEY,
            source_path TEXT,
            source_format TEXT,
            source_file_size_bytes INTEGER,
            source_row_count INTEGER,
            source_col_count INTEGER,
            converted_at TEXT,
            notes TEXT
        )
        """
    )
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS meta_variables (
            table_name TEXT,
            column_name TEXT,
            original_column_name TEXT,
            variable_label TEXT,
            dtype TEXT,
            PRIMARY KEY (table_name, column_name)
        )
        """
    )
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS meta_verification_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            table_name TEXT,
            check_type TEXT,
            metric_name TEXT,
            metric_scope TEXT,
            source_value REAL,
            db_value REAL,
            tolerance REAL,
            passed INTEGER,
            run_mode TEXT,
            checked_at TEXT,
            notes TEXT
        )
        """
    )
    conn.commit()


def clear_metadata_for_table(conn: sqlite3.Connection, table_name: str, keep_verification: bool) -> None:
    conn.execute("DELETE FROM meta_sources WHERE table_name = ?", (table_name,))
    conn.execute("DELETE FROM meta_variables WHERE table_name = ?", (table_name,))
    if not keep_verification:
        conn.execute("DELETE FROM meta_verification_log WHERE table_name = ?", (table_name,))


def log_source(
    conn: sqlite3.Connection,
    table_name: str,
    source_path: Optional[Path],
    source_format: str,
    row_count: int,
    col_count: int,
    notes: str = "",
) -> None:
    source_size = file_size(source_path) if source_path else 0
    conn.execute(
        """
        INSERT INTO meta_sources (
            table_name, source_path, source_format, source_file_size_bytes,
            source_row_count, source_col_count, converted_at, notes
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(table_name) DO UPDATE SET
            source_path=excluded.source_path,
            source_format=excluded.source_format,
            source_file_size_bytes=excluded.source_file_size_bytes,
            source_row_count=excluded.source_row_count,
            source_col_count=excluded.source_col_count,
            converted_at=excluded.converted_at,
            notes=excluded.notes
        """,
        (
            table_name,
            str(source_path) if source_path else None,
            source_format,
            source_size,
            row_count,
            col_count,
            utc_now(),
            notes,
        ),
    )


def log_variables(
    conn: sqlite3.Connection,
    table_name: str,
    original_cols: List[str],
    final_cols: List[str],
    labels: Dict[str, str],
    dtypes: Dict[str, str],
) -> None:
    rows = []
    for original, final in zip(original_cols, final_cols):
        rows.append(
            (
                table_name,
                final,
                original,
                labels.get(original),
                dtypes.get(final),
            )
        )
    conn.executemany(
        """
        INSERT INTO meta_variables (table_name, column_name, original_column_name, variable_label, dtype)
        VALUES (?, ?, ?, ?, ?)
        ON CONFLICT(table_name, column_name) DO UPDATE SET
            original_column_name=excluded.original_column_name,
            variable_label=excluded.variable_label,
            dtype=excluded.dtype
        """,
        rows,
    )


def log_check(
    conn: sqlite3.Connection,
    table_name: str,
    check_type: str,
    metric_name: str,
    metric_scope: str,
    source_value: Optional[float],
    db_value: Optional[float],
    tolerance: float,
    passed: bool,
    run_mode: str,
    notes: str = "",
) -> None:
    conn.execute(
        """
        INSERT INTO meta_verification_log (
            table_name, check_type, metric_name, metric_scope,
            source_value, db_value, tolerance, passed, run_mode, checked_at, notes
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        (
            table_name,
            check_type,
            metric_name,
            metric_scope,
            source_value,
            db_value,
            tolerance,
            int(passed),
            run_mode,
            utc_now(),
            notes,
        ),
    )


def apply_indices(
    conn: sqlite3.Connection,
    table_name: str,
    primary_key: Optional[List[str]],
    indices: Optional[List[List[str]]],
) -> None:
    columns = {row[1] for row in conn.execute(f"PRAGMA table_info({q(table_name)})")}
    if primary_key:
        valid_pk = [c for c in primary_key if c in columns]
        if valid_pk:
            idx_name = f"idx_{table_name}_pk"
            cols = ", ".join(q(c) for c in valid_pk)
            conn.execute(f"CREATE INDEX IF NOT EXISTS {q(idx_name)} ON {q(table_name)} ({cols})")
    for idx_cols in indices or []:
        valid_idx = [c for c in idx_cols if c in columns]
        if not valid_idx:
            continue
        idx_name = f"idx_{table_name}_{'_'.join(valid_idx)}"
        cols = ", ".join(q(c) for c in valid_idx)
        conn.execute(f"CREATE INDEX IF NOT EXISTS {q(idx_name)} ON {q(table_name)} ({cols})")


def numeric_profile_from_df(df: pd.DataFrame) -> TableProfile:
    numeric_cols = [
        c
        for c in df.columns
        if pd.api.types.is_numeric_dtype(df[c]) and not pd.api.types.is_bool_dtype(df[c])
    ]
    null_counts = {str(c): int(df[c].isna().sum()) for c in df.columns}
    stats: Dict[str, Dict[str, Optional[float]]] = {}
    for col in numeric_cols:
        s = pd.to_numeric(df[col], errors="coerce")
        n = int(s.notna().sum())
        if n == 0:
            stats[str(col)] = {"n": 0, "mean": None, "std": None, "min": None, "max": None}
            continue
        stats[str(col)] = {
            "n": n,
            "mean": float(s.mean()),
            "std": float(s.std(ddof=1)) if n > 1 else 0.0,
            "min": float(s.min()),
            "max": float(s.max()),
        }
    return TableProfile(
        row_count=int(len(df)),
        col_count=int(df.shape[1]),
        null_counts=null_counts,
        numeric_stats=stats,
    )


def db_profile(conn: sqlite3.Connection, table_name: str, numeric_cols: List[str]) -> TableProfile:
    row_count = int(conn.execute(f"SELECT COUNT(*) FROM {q(table_name)}").fetchone()[0])
    cols = [row[1] for row in conn.execute(f"PRAGMA table_info({q(table_name)})")]
    col_count = len(cols)
    null_counts: Dict[str, int] = {}
    for col in cols:
        nn = int(conn.execute(f"SELECT COUNT({q(col)}) FROM {q(table_name)}").fetchone()[0])
        null_counts[col] = row_count - nn

    stats: Dict[str, Dict[str, Optional[float]]] = {}
    for col in numeric_cols:
        query = (
            f"SELECT COUNT({q(col)}), AVG(CAST({q(col)} AS REAL)), "
            f"MIN({q(col)}), MAX({q(col)}), "
            f"AVG(CAST({q(col)} AS REAL) * CAST({q(col)} AS REAL)) "
            f"FROM {q(table_name)} WHERE {q(col)} IS NOT NULL"
        )
        n, mean, minv, maxv, avg_sq = conn.execute(query).fetchone()
        n = int(n)
        if n == 0:
            stats[col] = {"n": 0, "mean": None, "std": None, "min": None, "max": None}
            continue
        mean = float(mean)
        minv = float(minv)
        maxv = float(maxv)
        if n > 1 and avg_sq is not None:
            variance = (n * (float(avg_sq) - mean * mean)) / (n - 1)
            variance = max(variance, 0.0)
            std = math.sqrt(variance)
        else:
            std = 0.0
        stats[col] = {"n": n, "mean": mean, "std": std, "min": minv, "max": maxv}

    return TableProfile(
        row_count=row_count,
        col_count=col_count,
        null_counts=null_counts,
        numeric_stats=stats,
    )


def compare_values(source_val: Optional[float], db_val: Optional[float], tol: float) -> bool:
    if source_val is None and db_val is None:
        return True
    if source_val is None or db_val is None:
        return False
    if isinstance(source_val, float) and isinstance(db_val, float):
        if math.isnan(source_val) and math.isnan(db_val):
            return True
    return abs(float(source_val) - float(db_val)) <= tol


def verify_table(
    conn: sqlite3.Connection,
    table_name: str,
    source_profile: TableProfile,
    run_mode: str = "convert",
    tolerance: float = VERIFY_TOL,
) -> bool:
    db_prof = db_profile(conn, table_name, list(source_profile.numeric_stats.keys()))
    passed_all = True

    row_ok = source_profile.row_count == db_prof.row_count
    passed_all &= row_ok
    log_check(
        conn,
        table_name,
        "shape",
        "row_count",
        "table",
        float(source_profile.row_count),
        float(db_prof.row_count),
        0.0,
        row_ok,
        run_mode,
    )

    col_ok = source_profile.col_count == db_prof.col_count
    passed_all &= col_ok
    log_check(
        conn,
        table_name,
        "shape",
        "col_count",
        "table",
        float(source_profile.col_count),
        float(db_prof.col_count),
        0.0,
        col_ok,
        run_mode,
    )

    for col, src_null in source_profile.null_counts.items():
        db_null = db_prof.null_counts.get(col)
        ok = db_null == src_null
        passed_all &= ok
        log_check(
            conn,
            table_name,
            "null_count",
            "nulls",
            col,
            float(src_null),
            float(db_null) if db_null is not None else None,
            0.0,
            ok,
            run_mode,
        )

    for col, src_stats in source_profile.numeric_stats.items():
        db_stats = db_prof.numeric_stats.get(col, {})
        for metric in ("mean", "std", "min", "max"):
            src_val = src_stats.get(metric)
            db_val = db_stats.get(metric)
            ok = compare_values(src_val, db_val, tolerance)
            passed_all &= ok
            log_check(
                conn,
                table_name,
                "numeric_summary",
                metric,
                col,
                src_val,
                db_val,
                tolerance,
                ok,
                run_mode,
            )

    return passed_all


def build_profile_from_chunks(
    chunks: Iterator[pd.DataFrame],
    final_cols: Optional[List[str]] = None,
) -> tuple[TableProfile, List[pd.DataFrame], List[str], Dict[str, str]]:
    row_count = 0
    col_count = 0
    null_counts: Dict[str, int] = {}
    accum: Dict[str, NumericAccumulator] = {}
    numeric_cols: List[str] = []
    buffered: List[pd.DataFrame] = []
    dtypes: Dict[str, str] = {}

    for i, chunk in enumerate(chunks):
        if i == 0:
            if final_cols is None:
                final_cols = ensure_unique_columns(chunk.columns)
            chunk = chunk.copy()
            chunk.columns = final_cols
            col_count = len(final_cols)
            numeric_cols = [
                c
                for c in final_cols
                if pd.api.types.is_numeric_dtype(chunk[c]) and not pd.api.types.is_bool_dtype(chunk[c])
            ]
            for col in final_cols:
                null_counts[col] = 0
                dtypes[col] = str(chunk[col].dtype)
                if col in numeric_cols:
                    accum[col] = NumericAccumulator()
        else:
            chunk = chunk.copy()
            chunk.columns = final_cols

        row_count += len(chunk)
        for col in final_cols:
            null_counts[col] += int(chunk[col].isna().sum())
        for col in numeric_cols:
            vals = pd.to_numeric(chunk[col], errors="coerce")
            arr = vals.dropna().to_numpy()
            accum[col].update(arr)

        buffered.append(chunk)

    stats = {col: acc.to_stats() for col, acc in accum.items()}
    profile = TableProfile(
        row_count=int(row_count),
        col_count=int(col_count),
        null_counts=null_counts,
        numeric_stats=stats,
    )
    return profile, buffered, final_cols or [], dtypes


def convert_dta_to_table(conn: sqlite3.Connection, task: Task, args: argparse.Namespace) -> None:
    source_path = task.source_path
    assert source_path is not None

    if args.skip_large and file_size(source_path) > LARGE_FILE_BYTES:
        print(f"[skip-large] {task.table_name} <- {source_path}")
        return

    print(f"[dta] {task.table_name} <- {source_path}")
    if args.dry_run:
        return
    pyreadstat = get_pyreadstat()

    meta_df, meta = pyreadstat.read_dta(str(source_path), metadataonly=True)
    _ = meta_df  # silence lint for older pyreadstat return signature

    labels = {
        name: label
        for name, label in zip(meta.column_names or [], meta.column_labels or [])
        if label is not None
    }

    chunk_iter = pyreadstat.read_file_in_chunks(
        pyreadstat.read_dta,
        str(source_path),
        chunksize=CHUNK_SIZE,
        apply_value_formats=False,
        formats_as_category=False,
    )
    chunks = (df for df, _meta in chunk_iter)
    profile, buffered_chunks, final_cols, dtypes = build_profile_from_chunks(chunks)

    conn.execute(f"DROP TABLE IF EXISTS {q(task.table_name)}")
    clear_metadata_for_table(conn, task.table_name, keep_verification=False)

    first = True
    for chunk in buffered_chunks:
        sql_chunk = safe_to_sql_chunksize(conn, len(chunk.columns))
        chunk.to_sql(
            task.table_name,
            conn,
            if_exists="replace" if first else "append",
            index=False,
            method="multi",
            chunksize=sql_chunk,
        )
        first = False

    apply_indices(
        conn,
        task.table_name,
        task.kwargs.get("primary_key"),
        task.kwargs.get("indices"),
    )

    log_variables(
        conn,
        task.table_name,
        meta.column_names or final_cols,
        final_cols,
        labels,
        dtypes,
    )
    log_source(
        conn,
        task.table_name,
        source_path,
        "dta",
        profile.row_count,
        profile.col_count,
    )
    ok = verify_table(conn, task.table_name, profile, run_mode="convert")
    print(f"  -> rows={profile.row_count:,} cols={profile.col_count} verified={ok}")
    conn.commit()


def convert_csv_to_table(conn: sqlite3.Connection, task: Task, args: argparse.Namespace) -> None:
    source_path = task.source_path
    assert source_path is not None

    if args.skip_large and file_size(source_path) > LARGE_FILE_BYTES:
        print(f"[skip-large] {task.table_name} <- {source_path}")
        return

    print(f"[csv] {task.table_name} <- {source_path}")
    if args.dry_run:
        return

    read_kwargs = dict(task.kwargs.get("read_kwargs", {}))
    df, parser_mode = robust_read_csv(source_path, read_kwargs)
    original_cols = [str(c) for c in df.columns]
    final_cols = ensure_unique_columns(original_cols)
    df.columns = final_cols

    profile = numeric_profile_from_df(df)
    conn.execute(f"DROP TABLE IF EXISTS {q(task.table_name)}")
    clear_metadata_for_table(conn, task.table_name, keep_verification=False)

    df.to_sql(
        task.table_name,
        conn,
        if_exists="replace",
        index=False,
        method="multi",
        chunksize=safe_to_sql_chunksize(conn, len(df.columns)),
    )

    apply_indices(
        conn,
        task.table_name,
        task.kwargs.get("primary_key"),
        task.kwargs.get("indices"),
    )

    dtypes = {c: str(df[c].dtype) for c in final_cols}
    log_variables(conn, task.table_name, original_cols, final_cols, {}, dtypes)
    log_source(
        conn,
        task.table_name,
        source_path,
        "csv",
        profile.row_count,
        profile.col_count,
        notes=f"parser_mode={parser_mode}",
    )
    ok = verify_table(conn, task.table_name, profile, run_mode="convert")
    print(f"  -> rows={profile.row_count:,} cols={profile.col_count} verified={ok}")
    conn.commit()


def convert_excel_to_table(conn: sqlite3.Connection, task: Task, args: argparse.Namespace) -> None:
    source_path = task.source_path
    assert source_path is not None

    if args.skip_large and file_size(source_path) > LARGE_FILE_BYTES:
        print(f"[skip-large] {task.table_name} <- {source_path}")
        return

    print(f"[excel] {task.table_name} <- {source_path}")
    if args.dry_run:
        return

    read_kwargs = dict(task.kwargs.get("read_kwargs", {}))
    df = pd.read_excel(source_path, **read_kwargs)
    original_cols = [str(c) for c in df.columns]
    final_cols = ensure_unique_columns(original_cols)
    df.columns = final_cols

    profile = numeric_profile_from_df(df)
    conn.execute(f"DROP TABLE IF EXISTS {q(task.table_name)}")
    clear_metadata_for_table(conn, task.table_name, keep_verification=False)

    df.to_sql(
        task.table_name,
        conn,
        if_exists="replace",
        index=False,
        method="multi",
        chunksize=safe_to_sql_chunksize(conn, len(df.columns)),
    )
    apply_indices(
        conn,
        task.table_name,
        task.kwargs.get("primary_key"),
        task.kwargs.get("indices"),
    )

    dtypes = {c: str(df[c].dtype) for c in final_cols}
    notes = ""
    if "sheet_name" in read_kwargs:
        notes = f"sheet_name={read_kwargs['sheet_name']}"

    log_variables(conn, task.table_name, original_cols, final_cols, {}, dtypes)
    log_source(conn, task.table_name, source_path, "excel", profile.row_count, profile.col_count, notes=notes)
    ok = verify_table(conn, task.table_name, profile, run_mode="convert")
    print(f"  -> rows={profile.row_count:,} cols={profile.col_count} verified={ok}")
    conn.commit()


def parse_numbers_document(path: Path) -> pd.DataFrame:
    try:
        from numbers_parser import Document
    except Exception as exc:
        raise RuntimeError(
            "numbers-parser is required for .numbers files. Install with: pip install numbers-parser"
        ) from exc

    doc = Document(str(path))
    rows_out: List[Dict[str, Any]] = []

    for sheet in getattr(doc, "sheets", []):
        for table in getattr(sheet, "tables", []):
            extracted = None
            if hasattr(table, "rows"):
                try:
                    extracted = table.rows(values_only=True)
                except TypeError:
                    extracted = table.rows()
            if extracted is None:
                continue
            extracted = list(extracted)
            if not extracted:
                continue

            header = [str(c).strip() if c is not None else "" for c in extracted[0]]
            if not any(header):
                max_len = max(len(r) for r in extracted)
                header = [f"col_{i+1}" for i in range(max_len)]
                data_rows = extracted
            else:
                data_rows = extracted[1:]

            final_header = ensure_unique_columns(
                h if h else f"col_{i+1}" for i, h in enumerate(header)
            )

            for r in data_rows:
                if not any(v is not None and str(v).strip() != "" for v in r):
                    continue
                rec: Dict[str, Any] = {
                    "source_file": path.name,
                    "sheet_name": getattr(sheet, "name", None),
                    "table_name_in_sheet": getattr(table, "name", None),
                }
                for i, key in enumerate(final_header):
                    rec[key] = r[i] if i < len(r) else None
                rows_out.append(rec)

    if not rows_out:
        raise RuntimeError(f"No tabular data extracted from {path}")
    return pd.DataFrame(rows_out)


def convert_io_numbers_stacked(conn: sqlite3.Connection, task: Task, args: argparse.Namespace) -> None:
    source_dir = task.source_path
    assert source_dir is not None

    numbers_files = sorted(source_dir.glob("IO*.numbers"))
    print(f"[numbers] {task.table_name} <- {len(numbers_files)} files in {source_dir}")
    if args.dry_run:
        return

    if not numbers_files:
        print("  -> no .numbers files found; skipping")
        return

    all_dfs: List[pd.DataFrame] = []
    failures: List[str] = []
    for npath in numbers_files:
        try:
            df = parse_numbers_document(npath)
            all_dfs.append(df)
        except Exception as exc:
            failures.append(f"{npath.name}: {exc}")

    if not all_dfs:
        note = "numbers parse failed for all files: " + " | ".join(failures)
        log_source(conn, task.table_name, source_dir, "numbers", 0, 0, notes=note)
        conn.commit()
        print(f"  -> skipped; {note}")
        return

    df_all = pd.concat(all_dfs, ignore_index=True)
    original_cols = [str(c) for c in df_all.columns]
    final_cols = ensure_unique_columns(original_cols)
    df_all.columns = final_cols

    profile = numeric_profile_from_df(df_all)
    conn.execute(f"DROP TABLE IF EXISTS {q(task.table_name)}")
    clear_metadata_for_table(conn, task.table_name, keep_verification=False)

    df_all.to_sql(
        task.table_name,
        conn,
        if_exists="replace",
        index=False,
        method="multi",
        chunksize=safe_to_sql_chunksize(conn, len(df_all.columns)),
    )
    apply_indices(conn, task.table_name, None, [["source_file"]])

    dtypes = {c: str(df_all[c].dtype) for c in final_cols}
    notes = ""
    if failures:
        notes = "partial parse failures: " + " | ".join(failures)

    log_variables(conn, task.table_name, original_cols, final_cols, {}, dtypes)
    log_source(conn, task.table_name, source_dir, "numbers", profile.row_count, profile.col_count, notes=notes)
    ok = verify_table(conn, task.table_name, profile, run_mode="convert")
    print(f"  -> rows={profile.row_count:,} cols={profile.col_count} verified={ok}")
    conn.commit()


def convert_exports_stacked(conn: sqlite3.Connection, task: Task, args: argparse.Namespace) -> None:
    source_dir = task.source_path
    assert source_dir is not None

    csvs = sorted(source_dir.glob("Exports*.csv"))
    print(f"[csv-stack] {task.table_name} <- {len(csvs)} files in {source_dir}")
    if args.dry_run:
        return

    frames: List[pd.DataFrame] = []
    for csv_path in csvs:
        df = pd.read_csv(csv_path)
        df["source_file"] = csv_path.name
        frames.append(df)

    if not frames:
        print("  -> no export CSV files found; skipping")
        return

    all_df = pd.concat(frames, ignore_index=True)
    original_cols = [str(c) for c in all_df.columns]
    final_cols = ensure_unique_columns(original_cols)
    all_df.columns = final_cols
    profile = numeric_profile_from_df(all_df)

    conn.execute(f"DROP TABLE IF EXISTS {q(task.table_name)}")
    clear_metadata_for_table(conn, task.table_name, keep_verification=False)

    all_df.to_sql(
        task.table_name,
        conn,
        if_exists="replace",
        index=False,
        method="multi",
        chunksize=safe_to_sql_chunksize(conn, len(all_df.columns)),
    )
    apply_indices(conn, task.table_name, None, [["source_file"], ["year"], ["sic"], ["naics"]])

    dtypes = {c: str(all_df[c].dtype) for c in final_cols}
    log_variables(conn, task.table_name, original_cols, final_cols, {}, dtypes)
    log_source(conn, task.table_name, source_dir, "csv_stacked", profile.row_count, profile.col_count)
    ok = verify_table(conn, task.table_name, profile, run_mode="convert")
    print(f"  -> rows={profile.row_count:,} cols={profile.col_count} verified={ok}")
    conn.commit()


def convert_mat_to_table(conn: sqlite3.Connection, task: Task, args: argparse.Namespace) -> None:
    source_path = task.source_path
    assert source_path is not None

    print(f"[mat] {task.table_name} <- {source_path}")
    if args.dry_run:
        return

    try:
        from scipy.io import loadmat
    except Exception as exc:
        raise RuntimeError("scipy is required for .mat conversion: pip install scipy") from exc

    mat = loadmat(source_path)
    rows: List[Dict[str, Any]] = []
    for key, value in mat.items():
        if key.startswith("__"):
            continue
        if isinstance(value, np.ndarray):
            arr = np.asarray(value)
            if arr.ndim == 0:
                rows.append({"variable": key, "row": 0, "col": 0, "value": float(arr.item())})
            elif arr.ndim == 1:
                for i, v in enumerate(arr):
                    rows.append({"variable": key, "row": int(i), "col": 0, "value": float(v) if np.isscalar(v) else str(v)})
            else:
                for r in range(arr.shape[0]):
                    for c in range(arr.shape[1]):
                        v = arr[r, c]
                        rows.append(
                            {
                                "variable": key,
                                "row": int(r),
                                "col": int(c),
                                "value": float(v) if np.isscalar(v) and np.isreal(v) else str(v),
                            }
                        )
        else:
            rows.append({"variable": key, "row": 0, "col": 0, "value": str(value)})

    df = pd.DataFrame(rows)
    original_cols = [str(c) for c in df.columns]
    final_cols = ensure_unique_columns(original_cols)
    df.columns = final_cols

    profile = numeric_profile_from_df(df)
    conn.execute(f"DROP TABLE IF EXISTS {q(task.table_name)}")
    clear_metadata_for_table(conn, task.table_name, keep_verification=False)

    df.to_sql(
        task.table_name,
        conn,
        if_exists="replace",
        index=False,
        method="multi",
        chunksize=safe_to_sql_chunksize(conn, len(df.columns)),
    )
    apply_indices(conn, task.table_name, None, [["variable"], ["row"], ["col"]])

    dtypes = {c: str(df[c].dtype) for c in final_cols}
    log_variables(conn, task.table_name, original_cols, final_cols, {}, dtypes)
    log_source(conn, task.table_name, source_path, "mat", profile.row_count, profile.col_count)
    ok = verify_table(conn, task.table_name, profile, run_mode="convert")
    print(f"  -> rows={profile.row_count:,} cols={profile.col_count} verified={ok}")
    conn.commit()


def verify_only(conn: sqlite3.Connection, only_table: Optional[str] = None) -> int:
    where = "WHERE 1=1"
    params: List[Any] = []
    if only_table:
        where += " AND table_name = ?"
        params.append(only_table)

    table_rows = conn.execute(
        f"SELECT table_name, source_row_count, source_col_count FROM meta_sources {where}", params
    ).fetchall()

    if not table_rows:
        print("No tables found in meta_sources for verify-only mode.")
        return 1

    failures = 0
    for table_name, src_rows, src_cols in table_rows:
        if conn.execute(
            "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name=?", (table_name,)
        ).fetchone()[0] == 0:
            log_check(
                conn,
                table_name,
                "table_exists",
                "exists",
                "table",
                1.0,
                0.0,
                0.0,
                False,
                "verify_only",
                notes="table missing",
            )
            failures += 1
            continue

        cols = [row[1] for row in conn.execute(f"PRAGMA table_info({q(table_name)})")]
        row_count = int(conn.execute(f"SELECT COUNT(*) FROM {q(table_name)}").fetchone()[0])
        row_ok = row_count == int(src_rows)
        col_ok = len(cols) == int(src_cols)

        log_check(
            conn,
            table_name,
            "shape",
            "row_count",
            "table",
            float(src_rows),
            float(row_count),
            0.0,
            row_ok,
            "verify_only",
        )
        log_check(
            conn,
            table_name,
            "shape",
            "col_count",
            "table",
            float(src_cols),
            float(len(cols)),
            0.0,
            col_ok,
            "verify_only",
        )
        if not (row_ok and col_ok):
            failures += 1

        # Recompute numeric metrics and compare with latest conversion baseline.
        baselines = conn.execute(
            """
            SELECT metric_scope, metric_name, source_value
            FROM meta_verification_log
            WHERE table_name = ? AND check_type = 'numeric_summary' AND run_mode = 'convert'
              AND id IN (
                SELECT MAX(id) FROM meta_verification_log
                WHERE table_name = ? AND check_type = 'numeric_summary' AND run_mode = 'convert'
                GROUP BY metric_scope, metric_name
              )
            """,
            (table_name, table_name),
        ).fetchall()

        by_col: Dict[str, Dict[str, float]] = {}
        for metric_scope, metric_name, source_value in baselines:
            by_col.setdefault(metric_scope, {})[metric_name] = source_value

        prof = db_profile(conn, table_name, list(by_col.keys()))
        for col, metric_map in by_col.items():
            for metric_name, source_value in metric_map.items():
                db_value = prof.numeric_stats.get(col, {}).get(metric_name)
                ok = compare_values(source_value, db_value, VERIFY_TOL)
                log_check(
                    conn,
                    table_name,
                    "numeric_summary",
                    metric_name,
                    col,
                    source_value,
                    db_value,
                    VERIFY_TOL,
                    ok,
                    "verify_only",
                )
                if not ok:
                    failures += 1

    conn.commit()
    return failures


def build_tasks() -> List[Task]:
    tasks: List[Task] = []
    def add_dta(table_name: str, rel_path: str, indices: Optional[List[List[str]]] = None, primary_key: Optional[List[str]] = None) -> None:
        kwargs: Dict[str, Any] = {}
        if primary_key:
            kwargs["primary_key"] = primary_key
        if indices:
            kwargs["indices"] = indices
        tasks.append(
            Task(table_name, DATA_DIR / rel_path, "dta", convert_dta_to_table, kwargs=kwargs)
        )

    # Raw source tables.
    raw_dta_map = [
        ("raw_compustat", "compustat/AllCompustat.dta", [["key", "year"], ["sic"], ["naics"]], ["gvkey", "year"]),
        ("raw_sic5809", "compustat/sic5809.dta", None, None),
        ("raw_bea_value_added", "industry/bea/BEA_ValueAdded_RawFile.dta", [["code"], ["year"]], None),
        ("raw_nber_exports", "industry/nber/NBER_EXPORTS_RawFile.dta", [["sic"], ["year"]], None),
        ("raw_nber_mp_naics", "industry/nber/NBER_MP_NAICS.dta", [["naics"], ["year"]], None),
        ("raw_nber_mp_sic", "industry/nber/NBER_MP_SIC.dta", [["sic"], ["year"]], None),
        ("raw_gdp", "processed/GDPData_RawFile.dta", [["year"]], None),
        ("raw_bond_yields", "processed/BondYields.dta", [["year"]], None),
        ("raw_social_security_wage", "processed/SocialSecurityWageData.dta", [["year"]], None),
        ("raw_stock_market", "processed/StockMarketData.dta", [["key", "year"], ["sic"], ["naics"]], None),
        ("raw_nber_ces", "processed/nberces5818v1_n2012.dta", [["naics"], ["year"]], None),
    ]
    for table_name, rel_path, indices, primary_key in raw_dta_map:
        add_dta(table_name, rel_path, indices=indices, primary_key=primary_key)

    # BEA CSV files.
    for filename, table_name in {
        "BEA_All_Ind.csv": "raw_bea_csv_all_ind",
        "BEA_All_Ind_Prices.csv": "raw_bea_csv_all_ind_prices",
        "BEA_GDP_Detail.csv": "raw_bea_csv_gdp_detail",
        "BEA_GDP_Detail_clean.csv": "raw_bea_csv_gdp_detail_clean",
        "BEA_GDP_Prices_Detail.csv": "raw_bea_csv_gdp_prices_detail",
        "BEA_GDP_Prices_Detail_clean.csv": "raw_bea_csv_gdp_prices_detail_clean",
    }.items():
        tasks.append(Task(table_name, DATA_DIR / "industry" / "bea" / filename, "csv", convert_csv_to_table))

    section1_path = DATA_DIR / "industry" / "Section1All_xls.xlsx"
    if section1_path.exists():
        for sname in pd.ExcelFile(section1_path).sheet_names:
            tasks.append(
                Task(
                    f"raw_bea_section1_{sanitize_name(sname)}",
                    section1_path,
                    "xlsx",
                    convert_excel_to_table,
                    kwargs={"read_kwargs": {"sheet_name": sname}},
                )
            )

    # Instrument tables.
    tasks.extend(
        [
            Task("instrument_exports", DATA_DIR / "instruments" / "exports", "csv_stacked", convert_exports_stacked),
            Task("instrument_io_tables", DATA_DIR / "instruments" / "io_tables", "numbers_stacked", convert_io_numbers_stacked),
            Task("instrument_bea", DATA_DIR / "instruments" / "BEA.csv", "csv", convert_csv_to_table),
            Task("instrument_bea_gdp", DATA_DIR / "instruments" / "BEA_GDP.xls", "xls", convert_excel_to_table),
            Task("instrument_bea_deflators_gdp", DATA_DIR / "instruments" / "BEA_Deflators_GDP.xls", "xls", convert_excel_to_table),
            Task("instrument_value_added_mat", DATA_DIR / "instruments" / "ValueAddedInstrument.mat", "mat", convert_mat_to_table),
        ]
    )

    for dta_path in sorted((DATA_DIR / "instruments" / "klems").glob("*.dta")):
        tasks.append(
            Task(
                f"instrument_klems_{sanitize_name(dta_path.stem)}",
                dta_path,
                "dta",
                convert_dta_to_table,
            )
        )

    processed_dta_map = [
        ("processed_alldata", "processed/AllData.dta", [["gvkey"], ["key", "year"], ["sic"], ["naics"]]),
        ("processed_compustat", "processed/compustat.dta", [["key", "year"], ["sic"], ["naics"]]),
        ("processed_compustat_nber", "processed/[2]_final_data_compustat_NBER.dta", [["key", "year"], ["sic"], ["naics"]]),
        ("processed_compustat_bea_3digit", "processed/[3]_compustat_BEA_3digits.dta", [["key", "year"], ["sic"], ["naics"]]),
        ("processed_compustat_bea_2digit", "processed/[4]_compustat_BEA_2digits.dta", [["key", "year"], ["sic"], ["naics"]]),
        ("processed_financial_constraints", "processed/[5]_data_financial_constraints.dta", [["key", "year"], ["sic"], ["naics"]]),
        ("processed_bea_value_added", "industry/bea/BEA_ValueAdded.dta", [["code"], ["year"]]),
        ("processed_nber_exports", "industry/nber/NBER_EXPORTS.dta", [["sic"], ["year"]]),
        ("processed_gdp", "processed/GDPData.dta", [["year"]]),
        ("processed_rnd_industry", "processed/[1]_RND_Industry_data_final.dta", None),
        ("processed_bea_va_step3", "processed/[3]_BEA_ Value_Added.dta", None),
        ("processed_deflator", "processed/deflator.dta", None),
        ("processed_hib", "processed/hib.dta", None),
        ("processed_industrysales", "processed/industrysales.dta", None),
        ("processed_exports", "processed/Exports.dta", [["sic"], ["year"]]),
        ("processed_all_data_macro", "processed/all_data.dta", None),
        ("processed_va_vship_gdp_p", "processed/va.vship.gdp.p.dta", None),
        ("lookup_sic5805", "processed/sic5805.dta", None),
        ("processed_sic_manufacturing_2digit", "processed/SIC.manufacturing.2digit.dta", None),
        ("processed_sic_manufacturing_3digit", "processed/SIC.manufacturing.3digit.dta", None),
        ("processed_sic_manufacturing_4digit", "processed/SIC.manufacturing.4digit.dta", None),
        ("processed_solow_residual_1939", "processed/1939-2011_solowresidual.dta", None),
        ("processed_solow_residual_1960", "processed/1960-2002_estimatesolowresidual.dta", None),
        ("processed_averagewage", "processed/averagewage.dta", None),
        ("processed_obsdistribution", "processed/obsdistribution.dta", None),
        ("processed_outputdata", "processed/outputdata.dta", None),
        ("processed_outputdatawithrnd", "processed/outputdatawithrnd.dta", None),
        ("processed_volatilitytfe", "processed/volatilitytfe.dta", None),
        ("lookup_naics_to_sic", "processed/naics_to_sic.dta", None),
        ("lookup_codes_naics_sic", "processed/codes_naics_sic.dta", None),
        ("lookup_bea_naics_two_digit", "processed/bea_naics_two_digit.dta", None),
        ("lookup_bea_naics_three_digit", "processed/bea_naics_three_digit.dta", None),
        ("lookup_two_digit_bea_naics", "processed/two_digit_bea_naics.dta", None),
    ]
    for table_name, rel_path, indices in processed_dta_map:
        add_dta(table_name, rel_path, indices=indices)
    tasks.append(
        Task(
            "processed_country_rd_gdp",
            DATA_DIR / "processed" / "Country_RD_GDP_Clean.csv",
            "csv",
            convert_csv_to_table,
        )
    )

    # De-duplicate table names while preserving order.
    deduped: List[Task] = []
    seen = set()
    for task in tasks:
        if task.table_name in seen:
            continue
        seen.add(task.table_name)
        deduped.append(task)
    return deduped


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Convert cyclicality data sources to SQLite")
    parser.add_argument("--dry-run", action="store_true", help="Print conversion plan without writing")
    parser.add_argument("--skip-large", action="store_true", help="Skip files larger than 100MB")
    parser.add_argument("--only", type=str, help="Convert only one table name")
    parser.add_argument(
        "--mode",
        choices=["raw", "processed", "all"],
        default="raw",
        help="Conversion mode: raw (default), processed, or all",
    )
    parser.add_argument("--verify-only", action="store_true", help="Re-run verification checks on existing DB")
    return parser.parse_args()


def print_summary(conn: sqlite3.Connection, started_at: float) -> None:
    total_tables = conn.execute(
        "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
    ).fetchone()[0]
    source_tables = conn.execute("SELECT COUNT(*) FROM meta_sources").fetchone()[0]
    total_rows = conn.execute("SELECT COALESCE(SUM(source_row_count),0) FROM meta_sources").fetchone()[0]
    failed = conn.execute(
        "SELECT COUNT(*) FROM meta_verification_log WHERE passed = 0"
    ).fetchone()[0]

    elapsed = time.time() - started_at
    db_size_mb = DB_PATH.stat().st_size / (1024 * 1024) if DB_PATH.exists() else 0.0

    print("\n=== Conversion Summary ===")
    print(f"Tables in DB: {int(total_tables):,}")
    print(f"Tables in meta_sources: {int(source_tables):,}")
    print(f"Total rows logged: {int(total_rows):,}")
    print(f"Verification failures logged: {int(failed):,}")
    print(f"Elapsed seconds: {elapsed:,.1f}")
    print(f"DB size: {db_size_mb:,.1f} MB")


def print_size_comparison(conn: sqlite3.Connection) -> None:
    src_bytes = conn.execute(
        "SELECT COALESCE(SUM(source_file_size_bytes),0) FROM meta_sources"
    ).fetchone()[0]
    db_bytes = DB_PATH.stat().st_size if DB_PATH.exists() else 0
    print("\n=== Size Comparison ===")
    print(f"Source files tracked: {src_bytes / (1024 * 1024):,.1f} MB")
    print(f"SQLite database: {db_bytes / (1024 * 1024):,.1f} MB")


def main() -> int:
    args = parse_args()
    started = time.time()

    tasks = build_tasks()
    if args.mode == "raw":
        tasks = [
            t
            for t in tasks
            if t.table_name.startswith("raw_")
            or t.table_name.startswith("lookup_")
            or t.table_name.startswith("instrument_")
        ]
    elif args.mode == "processed":
        tasks = [t for t in tasks if t.table_name.startswith("processed_")]

    if args.only:
        tasks = [t for t in tasks if t.table_name == args.only]
        if not tasks:
            print(f"Table not found in task map: {args.only}")
            return 2

    conn = create_connection(DB_PATH)
    init_metadata_tables(conn)

    if args.verify_only:
        failures = verify_only(conn, only_table=args.only)
        print(f"verify-only failures: {failures}")
        print_summary(conn, started)
        return 1 if failures else 0

    print(f"Planned conversions: {len(tasks)} tables")
    for task in tasks:
        if task.source_path is not None and not task.source_path.exists():
            print(f"[missing] {task.table_name}: {task.source_path}")
            continue
        task.converter(conn, task, args)

    if not args.dry_run:
        failed = conn.execute(
            "SELECT COUNT(*) FROM meta_verification_log WHERE passed = 0"
        ).fetchone()[0]
        if failed > 0:
            print(f"\n[warning] Verification failures detected: {failed}")
        else:
            print("\nAll verification checks passed.")

        print("Running VACUUM...")
        conn.execute("VACUUM")
        conn.commit()

        print_summary(conn, started)
        print_size_comparison(conn)
    else:
        print("Dry-run complete. No changes written.")

    return 0


if __name__ == "__main__":
    sys.exit(main())
