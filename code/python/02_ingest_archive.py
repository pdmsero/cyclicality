#!/usr/bin/env python3
"""
Ingest archive/ content into cyclicality.db.

Handles four archive sub-collections:

  archive/BEA Data - Detail/   → archive_bea_detail        (5 xlsx files)
  archive/calibrations/        → archive_calibrations       (3 dta files)
  archive/historical/          → archive_historical_nsf     (200+ xls files, 1991 NSF survey)
  archive/imputed_data/        → archive_imputed            (dta files by SIC industry)

Usage:
    python code/python/ingest_archive.py
    python code/python/ingest_archive.py --dry-run
    python code/python/ingest_archive.py --only bea_detail
    python code/python/ingest_archive.py --only calibrations
    python code/python/ingest_archive.py --only historical_nsf
    python code/python/ingest_archive.py --only imputed
"""

from __future__ import annotations

import argparse
import datetime as dt
import re
import sqlite3
import traceback
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DB_PATH = ROOT / "data" / "cyclicality.db"
ARCHIVE_DIR = ROOT / "archive"

SUPPRESSION_CODES = {"(D)", "(T)", "(NA)", "(S)", "(Z)", "D", "T", "NA", "S"}


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _log(cur: sqlite3.Cursor, batch_id: str, source_file: str, rows: int, notes: str = "") -> None:
    cur.execute(
        """
        INSERT INTO ingestion_log (batch_id, source_file, rows_loaded, ingested_at, notes)
        VALUES (?, ?, ?, datetime('now'), ?)
        """,
        (batch_id, source_file, rows, notes),
    )


def _ensure_ingestion_log(cur: sqlite3.Cursor) -> None:
    cur.execute("""
        CREATE TABLE IF NOT EXISTS ingestion_log (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            batch_id    TEXT    NOT NULL,
            source_file TEXT    NOT NULL,
            rows_loaded INTEGER,
            ingested_at TEXT    NOT NULL DEFAULT (datetime('now')),
            notes       TEXT
        )
    """)


def _read_dta(path: Path) -> "pd.DataFrame":
    import pandas as pd
    try:
        import pyreadstat
        df, meta = pyreadstat.read_dta(str(path))
    except Exception:
        df = pd.read_stata(str(path))
    # SQLite is case-insensitive for column names; deduplicate by lowering and suffixing
    seen: dict[str, int] = {}
    new_cols = []
    for col in df.columns:
        key = col.lower()
        if key in seen:
            seen[key] += 1
            new_cols.append(f"{col}_{seen[key]}")
        else:
            seen[key] = 0
            new_cols.append(col)
    df.columns = new_cols
    return df


def _parse_nsf_suppression(raw: str) -> tuple[float | None, str | None]:
    s = str(raw).strip()
    if not s or s.lower() in ("nan", "none", ""):
        return None, None
    upper = s.upper().replace(" ", "")
    if upper in {f"({c})" for c in ["D", "T", "NA", "S", "Z"]} or upper in SUPPRESSION_CODES:
        return None, upper.strip("()")
    try:
        return float(s.replace(",", "")), None
    except ValueError:
        return None, "UNPARSED"


# ---------------------------------------------------------------------------
# BEA Detail (archive/BEA Data - Detail/)
# ---------------------------------------------------------------------------

def ingest_bea_detail(cur: sqlite3.Cursor, batch_id: str, dry_run: bool) -> None:
    import pandas as pd

    bea_dir = ARCHIVE_DIR / "BEA Data - Detail"
    xlsx_files = sorted(bea_dir.glob("*.xlsx"))
    print(f"BEA Detail: {len(xlsx_files)} files")

    cur.execute("DROP TABLE IF EXISTS archive_bea_detail")
    cur.execute("""
        CREATE TABLE IF NOT EXISTS archive_bea_detail (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            table_name  TEXT,
            series_code TEXT,
            industry    TEXT,
            year        INTEGER,
            value       REAL,
            source_file TEXT    NOT NULL,
            sheet_name  TEXT,
            ingested_at TEXT    NOT NULL DEFAULT (datetime('now'))
        )
    """)
    cur.execute("CREATE INDEX IF NOT EXISTS idx_bea_detail_year ON archive_bea_detail (year)")

    for xlsx_path in xlsx_files:
        print(f"  {xlsx_path.name} ...", end=" ", flush=True)
        try:
            xl = pd.ExcelFile(xlsx_path, engine="openpyxl")
            total_rows = 0
            for sheet in xl.sheet_names:
                try:
                    df = xl.parse(sheet, header=None)
                except Exception:
                    continue

                # BEA industry files: skip if tiny
                if df.shape[0] < 3:
                    continue

                # Find header row: look for a row containing year-like integers
                header_row = None
                for i, row in enumerate(df.values.tolist()[:10]):
                    row_strs = [str(c).strip() for c in row]
                    years = [int(float(c)) for c in row_strs if re.match(r"^1[89]\d{2}$|^20\d{2}$", c)]
                    if len(years) >= 3:
                        header_row = i
                        break

                if header_row is None:
                    continue

                header = [str(c).strip() for c in df.values[header_row]]
                year_cols = [
                    (ci, int(float(h)))
                    for ci, h in enumerate(header)
                    if re.match(r"^1[89]\d{2}$|^20\d{2}$", h)
                ]

                # Industry/series columns assumed to be first two
                records = []
                for row in df.values[header_row + 1:]:
                    row_s = [str(c).strip() for c in row]
                    ind_val = row_s[0] if row_s else ""
                    if not ind_val or ind_val.lower() in ("nan", "none"):
                        continue
                    series_val = row_s[1] if len(row_s) > 1 else ""
                    for ci, year in year_cols:
                        raw = row_s[ci] if ci < len(row_s) else ""
                        if raw.lower() in ("nan", "none", ""):
                            continue
                        try:
                            value: float | None = float(raw.replace(",", ""))
                        except ValueError:
                            value = None
                        records.append((
                            xlsx_path.stem, series_val, ind_val,
                            year, value, str(xlsx_path), sheet,
                        ))

                if not dry_run and records:
                    cur.executemany(
                        """
                        INSERT INTO archive_bea_detail
                            (table_name, series_code, industry, year, value, source_file, sheet_name)
                        VALUES (?, ?, ?, ?, ?, ?, ?)
                        """,
                        records,
                    )
                total_rows += len(records)

            print(f"{total_rows} rows")
            if not dry_run:
                _log(cur, batch_id, str(xlsx_path), total_rows)

        except Exception as exc:
            print(f"ERROR: {exc}")


# ---------------------------------------------------------------------------
# Calibrations (archive/calibrations/)
# ---------------------------------------------------------------------------

def ingest_calibrations(cur: sqlite3.Cursor, batch_id: str, dry_run: bool) -> None:
    cal_dir = ARCHIVE_DIR / "calibrations"
    dta_files = sorted(cal_dir.glob("*.dta"))
    print(f"Calibrations: {len(dta_files)} dta files")

    for dta_path in dta_files:
        # Sanitise table name
        stem = re.sub(r"[^a-zA-Z0-9]", "_", dta_path.stem).lower().strip("_")
        table_name = f"archive_calibration_{stem}"
        print(f"  {dta_path.name} → {table_name} ...", end=" ", flush=True)
        try:
            df = _read_dta(dta_path)
            if not dry_run:
                cur.execute(f"DROP TABLE IF EXISTS {table_name}")
                df["source_file"] = str(dta_path)
                df["ingested_at"] = dt.datetime.now().isoformat()
                df.to_sql(table_name, cur.connection, if_exists="replace", index=False)
                _log(cur, batch_id, str(dta_path), len(df))
            print(f"{len(df)} rows")
        except Exception as exc:
            print(f"ERROR: {exc}")


# ---------------------------------------------------------------------------
# Historical NSF (archive/historical/)
# ---------------------------------------------------------------------------

def ingest_historical_nsf(cur: sqlite3.Cursor, batch_id: str, dry_run: bool) -> None:
    """
    Historical NSF files (archive/historical/) are 1991 cross-sectional concentration
    tables, not time-series panels. They have multi-level headers describing company-size
    tiers rather than year columns. We store them as a raw cell dump:
    (source_file, sheet, row_idx, col_idx, value_raw) — preserving everything without
    imposing a structure that doesn't fit.
    """
    import pandas as pd

    hist_dir = ARCHIVE_DIR / "historical"
    xls_files = sorted(hist_dir.rglob("*.xls"))
    # Filter duplicate (1) files — keep canonical version only
    xls_files = [f for f in xls_files if "(1)" not in f.name]
    print(f"Historical NSF: {len(xls_files)} files (duplicates excluded)")

    cur.execute("DROP TABLE IF EXISTS archive_historical_nsf_raw")
    cur.execute("""
        CREATE TABLE IF NOT EXISTS archive_historical_nsf_raw (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            source_file TEXT    NOT NULL,
            survey_year INTEGER,
            sheet_name  TEXT,
            row_idx     INTEGER,
            col_idx     INTEGER,
            value_raw   TEXT,
            ingested_at TEXT    NOT NULL DEFAULT (datetime('now'))
        )
    """)

    total = 0
    for xls_path in xls_files:
        m = re.search(r"(\d{4})", xls_path.parent.name)
        survey_year = int(m.group(1)) if m else None
        now = dt.datetime.now().isoformat()

        try:
            xl = pd.ExcelFile(xls_path, engine="xlrd")
        except Exception as exc:
            print(f"  {xls_path.name}: OPEN ERROR {exc}")
            continue

        file_cells = []
        for sheet_name in xl.sheet_names:
            try:
                df = xl.parse(sheet_name, header=None)
            except Exception:
                continue
            for ri, row in enumerate(df.values.tolist()):
                for ci, cell in enumerate(row):
                    raw = str(cell).strip()
                    if raw and raw.lower() not in ("nan", "none"):
                        file_cells.append((
                            str(xls_path), survey_year, str(sheet_name),
                            ri, ci, raw[:1000], now,
                        ))

        if not dry_run and file_cells:
            cur.executemany(
                """
                INSERT INTO archive_historical_nsf_raw
                    (source_file, survey_year, sheet_name, row_idx, col_idx, value_raw, ingested_at)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """,
                file_cells,
            )
            _log(cur, batch_id, str(xls_path), len(file_cells))
        total += len(file_cells)

    print(f"  Total historical NSF cells: {total}")


# ---------------------------------------------------------------------------
# Imputed data (archive/imputed_data/)
# ---------------------------------------------------------------------------

def ingest_imputed(cur: sqlite3.Cursor, batch_id: str, dry_run: bool) -> None:
    """
    Write each imputed .dta file to its own table (archive_imputed_<stem>).
    Files span too many heterogeneous columns to combine into one table.
    Deduplicates paths to avoid re-processing files that appear in subdirectories.
    """
    imp_dir = ARCHIVE_DIR / "imputed_data"
    # rglob finds files in nested subdirs; deduplicate by resolved path
    seen_paths: set[Path] = set()
    dta_files: list[Path] = []
    for p in sorted(imp_dir.rglob("*.dta")):
        rp = p.resolve()
        if rp not in seen_paths:
            seen_paths.add(rp)
            dta_files.append(p)

    print(f"Imputed data: {len(dta_files)} unique dta files")

    for dta_path in dta_files:
        # Sanitise table name: keep letters, digits, underscores; max 60 chars
        stem = re.sub(r"[^a-zA-Z0-9]+", "_", dta_path.stem).strip("_").lower()[:60]
        table_name = f"archive_imputed_{stem}"
        print(f"  {dta_path.name} → {table_name} ...", end=" ", flush=True)
        try:
            df = _read_dta(dta_path)
            df["source_file"] = str(dta_path)
            df["ingested_at"] = dt.datetime.now().isoformat()
            print(f"{len(df)} rows, {len(df.columns)} cols")
            if not dry_run:
                cur.execute(f"DROP TABLE IF EXISTS {table_name}")
                df.to_sql(table_name, cur.connection, if_exists="replace", index=False)
                _log(cur, batch_id, str(dta_path), len(df))
        except Exception as exc:
            print(f"ERROR: {exc}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

SECTIONS = {
    "bea_detail":    ingest_bea_detail,
    "calibrations":  ingest_calibrations,
    "historical_nsf": ingest_historical_nsf,
    "imputed":       ingest_imputed,
}


def main() -> None:
    parser = argparse.ArgumentParser(description="Ingest archive/ content into cyclicality.db")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--only", choices=list(SECTIONS.keys()), default=None,
                        help="Run only one sub-collection")
    args = parser.parse_args()

    batch_id = f"archive_{dt.datetime.now().strftime('%Y%m%d_%H%M%S')}"

    conn = sqlite3.connect(DB_PATH)
    try:
        cur = conn.cursor()
        _ensure_ingestion_log(cur)

        to_run = {args.only: SECTIONS[args.only]} if args.only else SECTIONS
        for name, fn in to_run.items():
            print(f"\n=== {name} ===")
            try:
                fn(cur, batch_id, args.dry_run)
            except Exception:
                print(f"  FAILED: {name}")
                traceback.print_exc()

        if not args.dry_run:
            conn.commit()
            print("\nAll committed.")
        else:
            print("\nDry run — nothing written.")

    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


if __name__ == "__main__":
    main()
