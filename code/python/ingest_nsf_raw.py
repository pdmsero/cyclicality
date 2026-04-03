#!/usr/bin/env python3
"""
Ingest NSF R&D survey Excel files into cyclicality.db.

Reads all .xls files under data/industry/nsf_raw/ (1,061 files across 27
index folders). Each file contains one or more "pages" laid out side-by-side,
with columns: industry name | SIC code | year values...

Outputs two tables:
  raw_nsf_file_index  -- one row per source file with parse status
  raw_nsf_rd          -- long-format (source_file, industry_name, sic_code,
                         year, value, suppression_flag)

Deduplication key: (industry_name_norm, sic_code, year)
Suppression codes stored as NULL with suppression_flag column:
  (D) = withheld to avoid disclosure
  (T) = rounds to less than unit shown
  (NA) = not available
  (S) = withheld, not elsewhere classified

Usage:
    python code/python/ingest_nsf_raw.py
    python code/python/ingest_nsf_raw.py --dry-run
    python code/python/ingest_nsf_raw.py --limit 50    # first N files only
    python code/python/ingest_nsf_raw.py --index index_1  # single index folder
"""

from __future__ import annotations

import argparse
import datetime as dt
import re
import sqlite3
import traceback
from pathlib import Path
from typing import Iterator

ROOT = Path(__file__).resolve().parents[2]
DB_PATH = ROOT / "data" / "cyclicality.db"
NSF_DIR = ROOT / "data" / "industry" / "nsf_raw"

# Known suppression codes → stored as NULL with flag
SUPPRESSION_CODES = {"(D)", "(T)", "(NA)", "(S)", "(Z)", "D", "T", "NA", "S"}

# Regex: matches a year cell (4-digit year, possibly as float like 1997.0)
YEAR_RE = re.compile(r"^(1[89]\d{2}|20\d{2})(?:\.0)?$")


def _is_year(val: str) -> bool:
    return bool(YEAR_RE.match(val.strip()))


def _parse_value(raw: str) -> tuple[float | None, str | None]:
    """Return (numeric_value, suppression_flag). None value means suppressed or missing."""
    s = str(raw).strip()
    if not s or s.lower() in ("nan", "none", ""):
        return None, None
    upper = s.upper().replace(" ", "")
    # Parenthesised suppression codes
    if upper in {f"({c})" for c in ["D", "T", "NA", "S", "Z"]} or upper in SUPPRESSION_CODES:
        flag = upper.strip("()")
        return None, flag
    # Try numeric (strip commas, spaces)
    cleaned = s.replace(",", "").replace(" ", "")
    try:
        return float(cleaned), None
    except ValueError:
        return None, "UNPARSED"


def _normalise_name(name: str) -> str:
    """Normalise industry name for deduplication."""
    s = str(name).strip()
    # Remove ellipsis filler characters
    s = re.sub(r"[…\.]{2,}", "", s)
    s = re.sub(r"\s+", " ", s)
    return s.strip().lower()


def _find_header_row(sheet_rows: list[list]) -> int | None:
    """Find the row index that contains the column header (has 'industry' in it)."""
    for i, row in enumerate(sheet_rows):
        row_text = " ".join(str(c) for c in row if str(c).strip() and str(c).lower() != "nan")
        if "industry" in row_text.lower() and ("sic" in row_text.lower() or "code" in row_text.lower()):
            return i
    return None


def _extract_pages(sheet_rows: list[list], header_row: int) -> list[dict]:
    """
    NSF files lay out multiple page panels side-by-side.
    Each panel has: [industry_name | SIC_code | year1 | year2 | ...]
    Returns list of pages, each with keys:
        'col_start', 'col_end', 'years', 'data_start_row'
    """
    header = [str(c).strip() for c in sheet_rows[header_row]]
    pages: list[dict] = []

    # A new page starts when we see "Industry" (case-insensitive) in the header
    page_starts = [
        i for i, h in enumerate(header)
        if "industry" in h.lower()
    ]

    for p_idx, col_start in enumerate(page_starts):
        col_end = page_starts[p_idx + 1] if p_idx + 1 < len(page_starts) else len(header)

        # SIC code column is expected right after industry name column
        sic_col = col_start + 1

        # Year columns: everything after SIC up to the next page (or end)
        year_cols: list[tuple[int, int]] = []  # (col_idx, year_int)
        for c in range(sic_col + 1, col_end):
            hval = str(sheet_rows[header_row][c]).strip() if c < len(header) else ""
            if _is_year(hval):
                year_cols.append((c, int(float(hval))))

        if year_cols:
            pages.append({
                "col_industry": col_start,
                "col_sic": sic_col,
                "year_cols": year_cols,
                "data_start_row": header_row + 1,
            })

    return pages


def _parse_file(xls_path: Path) -> tuple[list[dict], str]:
    """
    Parse one NSF Excel file. Returns (records, status).
    status is 'ok', 'no_header', 'empty', or 'error:<msg>'
    """
    try:
        import pandas as pd  # noqa: PLC0415
    except ImportError:
        raise RuntimeError("pandas required: pip install pandas")

    try:
        xl = pd.ExcelFile(xls_path, engine="xlrd")
    except Exception as exc:
        return [], f"error:open:{exc}"

    records: list[dict] = []

    for sheet_name in xl.sheet_names:
        try:
            df = xl.parse(sheet_name, header=None)
        except Exception:
            continue

        if df.empty:
            continue

        sheet_rows = df.values.tolist()

        header_row = _find_header_row(sheet_rows)
        if header_row is None:
            continue

        pages = _extract_pages(sheet_rows, header_row)
        if not pages:
            continue

        for page in pages:
            col_ind = page["col_industry"]
            col_sic = page["col_sic"]
            year_cols = page["year_cols"]
            data_start = page["data_start_row"]

            for row in sheet_rows[data_start:]:
                # Skip if no industry name in expected column
                ind_val = str(row[col_ind]).strip() if col_ind < len(row) else ""
                if not ind_val or ind_val.lower() in ("nan", "none", ""):
                    continue
                # Skip total/header rows masquerading as data
                if "industry" in ind_val.lower() and "size" in ind_val.lower():
                    continue

                sic_val = str(row[col_sic]).strip() if col_sic < len(row) else ""
                if sic_val.lower() in ("nan", "none"):
                    sic_val = ""

                ind_norm = _normalise_name(ind_val)
                if not ind_norm:
                    continue

                for col_idx, year in year_cols:
                    raw = str(row[col_idx]).strip() if col_idx < len(row) else ""
                    if raw.lower() in ("nan", "none", ""):
                        continue
                    value, flag = _parse_value(raw)
                    records.append({
                        "industry_name": ind_val[:500],
                        "industry_name_norm": ind_norm[:500],
                        "sic_code": sic_val[:50],
                        "year": year,
                        "value": value,
                        "suppression_flag": flag,
                        "sheet": str(sheet_name)[:100],
                    })

    if not records:
        return [], "empty"

    return records, "ok"


def create_tables(cur: sqlite3.Cursor) -> None:
    cur.executescript("""
        CREATE TABLE IF NOT EXISTS raw_nsf_file_index (
            id              INTEGER PRIMARY KEY AUTOINCREMENT,
            source_file     TEXT    NOT NULL UNIQUE,
            index_folder    TEXT,
            parse_status    TEXT,
            records_found   INTEGER,
            ingested_at     TEXT    NOT NULL DEFAULT (datetime('now'))
        );

        CREATE TABLE IF NOT EXISTS raw_nsf_rd (
            id                   INTEGER PRIMARY KEY AUTOINCREMENT,
            industry_name        TEXT,
            industry_name_norm   TEXT,
            sic_code             TEXT,
            year                 INTEGER,
            value                REAL,
            suppression_flag     TEXT,
            source_file          TEXT    NOT NULL,
            sheet                TEXT,
            ingested_at          TEXT    NOT NULL DEFAULT (datetime('now'))
        );

        CREATE INDEX IF NOT EXISTS idx_nsf_industry_sic_year
            ON raw_nsf_rd (industry_name_norm, sic_code, year);

        CREATE INDEX IF NOT EXISTS idx_nsf_year
            ON raw_nsf_rd (year);

        CREATE TABLE IF NOT EXISTS ingestion_log (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            batch_id    TEXT    NOT NULL,
            source_file TEXT    NOT NULL,
            rows_loaded INTEGER,
            ingested_at TEXT    NOT NULL DEFAULT (datetime('now')),
            notes       TEXT
        );
    """)


def iter_xls_files(index_filter: str | None = None) -> Iterator[Path]:
    """Yield all .xls paths under NSF_DIR, optionally filtered to one index folder."""
    for index_dir in sorted(NSF_DIR.iterdir()):
        if not index_dir.is_dir():
            continue
        if index_filter and index_dir.name != index_filter:
            continue
        for f in sorted(index_dir.glob("*.xls")):
            yield f


def main() -> None:
    parser = argparse.ArgumentParser(description="Ingest NSF R&D Excel files")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--limit", type=int, default=0, help="Process only first N files")
    parser.add_argument("--index", type=str, default=None, help="Restrict to one index folder")
    parser.add_argument("--no-dedup", action="store_true", help="Skip deduplication step")
    args = parser.parse_args()

    all_files = list(iter_xls_files(args.index))
    if args.limit:
        all_files = all_files[: args.limit]

    print(f"Files to process: {len(all_files)}")
    batch_id = f"nsf_raw_{dt.datetime.now().strftime('%Y%m%d_%H%M%S')}"
    now = dt.datetime.now().isoformat()

    conn = sqlite3.connect(DB_PATH)
    try:
        cur = conn.cursor()
        create_tables(cur)

        if not args.dry_run:
            if args.index:
                # Partial re-run: remove only records from this index folder
                cur.execute(
                    "DELETE FROM raw_nsf_rd WHERE source_file LIKE ?",
                    (f"%{args.index}%",),
                )
                cur.execute(
                    "DELETE FROM raw_nsf_file_index WHERE source_file LIKE ?",
                    (f"%{args.index}%",),
                )
            else:
                cur.execute("DELETE FROM raw_nsf_rd")
                cur.execute("DELETE FROM raw_nsf_file_index")

        total_records = 0
        ok_count = 0
        err_count = 0

        for xls_path in all_files:
            index_folder = xls_path.parent.name
            print(f"  [{index_folder}] {xls_path.name} ...", end=" ", flush=True)

            records, status = _parse_file(xls_path)
            print(f"{status} ({len(records)} records)")

            if status.startswith("error"):
                err_count += 1
            else:
                ok_count += 1

            if not args.dry_run:
                cur.execute(
                    """
                    INSERT OR REPLACE INTO raw_nsf_file_index
                        (source_file, index_folder, parse_status, records_found, ingested_at)
                    VALUES (?, ?, ?, ?, ?)
                    """,
                    (str(xls_path), index_folder, status, len(records), now),
                )

                if records:
                    cur.executemany(
                        """
                        INSERT INTO raw_nsf_rd
                            (industry_name, industry_name_norm, sic_code, year,
                             value, suppression_flag, source_file, sheet, ingested_at)
                        VALUES
                            (:industry_name, :industry_name_norm, :sic_code, :year,
                             :value, :suppression_flag, :source_file, :sheet, :ingested_at)
                        """,
                        [{**r, "source_file": str(xls_path), "ingested_at": now} for r in records],
                    )

                cur.execute(
                    """
                    INSERT INTO ingestion_log (batch_id, source_file, rows_loaded, ingested_at, notes)
                    VALUES (?, ?, ?, ?, ?)
                    """,
                    (batch_id, str(xls_path), len(records), now, status),
                )

            total_records += len(records)

        if not args.dry_run and not args.no_dedup:
            print("\nRunning deduplication (keeping first occurrence per industry/sic/year)...")
            cur.execute("""
                DELETE FROM raw_nsf_rd
                WHERE id NOT IN (
                    SELECT MIN(id)
                    FROM raw_nsf_rd
                    GROUP BY industry_name_norm, sic_code, year
                )
            """)
            rows_removed = conn.total_changes
            print(f"  Removed {rows_removed} duplicate rows")

        if not args.dry_run:
            conn.commit()

        print(f"\nDone. Files parsed: {ok_count} ok, {err_count} errors")
        print(f"Total records ingested: {total_records}")
        if not args.dry_run and not args.no_dedup:
            cur.execute("SELECT COUNT(*) FROM raw_nsf_rd")
            deduped = cur.fetchone()[0]
            print(f"Unique rows after dedup: {deduped}")

    except Exception:
        conn.rollback()
        traceback.print_exc()
        raise
    finally:
        conn.close()


if __name__ == "__main__":
    main()
