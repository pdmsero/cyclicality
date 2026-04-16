#!/usr/bin/env python3
"""
Patch the NSF ingestion for the 823 files marked 'empty' by ingest_nsf_raw.py,
and populate archive_historical_nsf from archive_historical_nsf_raw.

Root causes of the original failures
--------------------------------------
1. Year-footnote suffixes: years like "19883" or "1999 1" (footnote number appended)
   do not match the strict regex ^(1[89]\d{2}|20\d{2})(?:\.0)?$.
2. NAICS codes: post-1997 surveys use "NAICS codes" instead of "SIC code" as the
   code column header.  The original header-finder required "sic".
3. Split headers: some files place year column headers on a different row from the
   Industry / SIC-code header row.

What this script does
---------------------
* Re-processes only files currently marked 'empty' in raw_nsf_file_index.
* Writes newly recovered records into raw_nsf_rd with an 'ingestion_v2' batch tag.
* Updates raw_nsf_file_index parse_status for each re-processed file.
* Parses archive_historical_nsf_raw (raw cell grid from 1991-1993 historical XLS
  files) into archive_historical_nsf.

Usage:
    python code/python/ingest_nsf_improved.py [--dry-run] [--verbose]
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

# ---------------------------------------------------------------------------
# Shared helpers
# ---------------------------------------------------------------------------

SUPPRESSION_CODES = {"(D)", "(T)", "(NA)", "(S)", "(Z)", "D", "T", "NA", "S"}

# Strict: original parser (4-digit year, optional .0)
YEAR_STRICT = re.compile(r"^(1[89]\d{2}|20\d{2})(?:\.0)?$")
# Fuzzy: 4-digit year, optionally followed by at most 3 footnote chars
# (space/digit/comma/dot).  Total length capped at 8 chars to exclude large
# numbers like "18044" (R&D spending in millions) that happen to start with
# 18xx digits.
YEAR_FUZZY = re.compile(r"^(1[89]\d{2}|20\d{2})([\s\d,./]{0,3})?$")


_NSF_YEAR_MIN = 1953   # first NSF industrial R&D survey
_NSF_YEAR_MAX = 2015   # last year in the data archive


def _extract_year(val: str) -> int | None:
    """Return integer year if val looks like an NSF survey year label, else None."""
    s = val.strip()
    if len(s) > 8:           # too long to be a year+footnote
        return None
    m = YEAR_FUZZY.match(s)
    if not m:
        return None
    y = int(m.group(1))
    if y < _NSF_YEAR_MIN or y > _NSF_YEAR_MAX:
        return None
    return y


def _has_year_row(row: list[str], min_years: int = 2) -> bool:
    """True only if the row contains at least min_years year-like cells."""
    return len(_year_cols_in_row(row)) >= min_years


def _parse_value(raw: str) -> tuple[float | None, str | None]:
    """Return (numeric_value, suppression_flag)."""
    s = str(raw).strip()
    if not s or s.lower() in ("nan", "none", ""):
        return None, None
    upper = s.upper().replace(" ", "")
    if upper in {f"({c})" for c in ["D", "T", "NA", "S", "Z"]} or upper in SUPPRESSION_CODES:
        return None, upper.strip("()")
    cleaned = s.replace(",", "").replace(" ", "")
    try:
        return float(cleaned), None
    except ValueError:
        return None, "UNPARSED"


def _normalise_name(name: str) -> str:
    s = str(name).strip()
    s = re.sub(r"[…\.]{2,}", "", s)
    s = re.sub(r"\s+", " ", s)
    return s.strip().lower()


# ---------------------------------------------------------------------------
# Improved file parser
# ---------------------------------------------------------------------------

def _is_code_header(cell: str) -> bool:
    """True if cell looks like a SIC/NAICS code column header."""
    c = cell.lower()
    return "sic" in c or "naics" in c or c == "code"


def _find_header_row(rows: list[list[str]]) -> int | None:
    """
    Find a row that has 'industry' AND a SIC/NAICS/code indicator.
    More permissive than the original (accepts NAICS, loose 'code').
    """
    for i, row in enumerate(rows):
        txt = " ".join(str(c) for c in row if str(c).strip() and str(c).lower() != "nan").lower()
        if "industry" in txt and ("sic" in txt or "naics" in txt or "code" in txt):
            return i
    return None


def _year_cols_in_row(row: list[str]) -> list[tuple[int, int]]:
    """Return list of (col_idx, year_int) for all year cells in a row."""
    result = []
    for c, val in enumerate(row):
        y = _extract_year(str(val))
        if y is not None:
            result.append((c, y))
    return result


def _extract_pages(rows: list[list[str]], header_row: int,
                   year_row: int) -> list[dict]:
    """
    Identify side-by-side panels on a sheet.
    header_row: row containing 'Industry' and SIC/NAICS column headers.
    year_row:   row containing the year column values (may equal header_row
                or be ±N rows away in split-header layouts).
    """
    header = [str(c).strip() for c in rows[header_row]]
    pages: list[dict] = []

    page_starts = [i for i, h in enumerate(header) if "industry" in h.lower()]
    year_row_cells = [str(c).strip() for c in rows[year_row]]

    for p_idx, col_start in enumerate(page_starts):
        col_end = page_starts[p_idx + 1] if p_idx + 1 < len(page_starts) else len(header)

        sic_col = col_start + 1

        year_cols: list[tuple[int, int]] = []
        for c in range(sic_col + 1, col_end):
            if c >= len(year_row_cells):
                break
            y = _extract_year(year_row_cells[c])
            if y is not None:
                year_cols.append((c, y))

        if year_cols:
            pages.append({
                "col_industry": col_start,
                "col_sic": sic_col,
                "year_cols": year_cols,
                "data_start_row": max(header_row, year_row) + 1,
            })

    return pages


def _parse_file_improved(xls_path: Path) -> tuple[list[dict], str]:
    """
    Improved parser: tries the original logic first, then relaxed fallbacks.
    Returns (records, status_string).
    """
    try:
        import pandas as pd
    except ImportError:
        raise RuntimeError("pandas required")

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

        rows = [
            [str(v).strip() for v in row]
            for row in df.values.tolist()
        ]

        header_row = _find_header_row(rows)
        if header_row is None:
            continue

        # Check if years are on the header row itself
        if _has_year_row(rows[header_row]):
            year_row = header_row
        else:
            # Split-header: search adjacent rows (±4) for a row with ≥2 year cells
            year_row = None
            for offset in range(1, 5):
                for sign in (+1, -1):
                    ri = header_row + sign * offset
                    if 0 <= ri < len(rows) and _has_year_row(rows[ri]):
                        year_row = ri
                        break
                if year_row is not None:
                    break
            if year_row is None:
                continue

        pages = _extract_pages(rows, header_row, year_row)
        if not pages:
            continue

        for page in pages:
            col_ind = page["col_industry"]
            col_sic = page["col_sic"]
            year_cols = page["year_cols"]
            data_start = page["data_start_row"]

            for row in rows[data_start:]:
                ind_val = row[col_ind] if col_ind < len(row) else ""
                if not ind_val or ind_val.lower() in ("nan", "none", ""):
                    continue
                if "industry" in ind_val.lower() and "size" in ind_val.lower():
                    continue

                sic_val = row[col_sic] if col_sic < len(row) else ""
                if sic_val.lower() in ("nan", "none"):
                    sic_val = ""

                ind_norm = _normalise_name(ind_val)
                if not ind_norm:
                    continue

                for col_idx, year in year_cols:
                    raw = row[col_idx] if col_idx < len(row) else ""
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
        return [], "no_industry_format"

    return records, "ok_v2"


# ---------------------------------------------------------------------------
# archive_historical_nsf parser
# ---------------------------------------------------------------------------

def _reconstruct_sheet(cells: list[tuple[int, int, str]]) -> list[list[str]]:
    """Convert (row_idx, col_idx, value_raw) triples into a 2-D list."""
    if not cells:
        return []
    max_row = max(r for r, c, v in cells)
    max_col = max(c for r, c, v in cells)
    grid: list[list[str]] = [[""] * (max_col + 1) for _ in range(max_row + 1)]
    for r, c, v in cells:
        grid[r][c] = str(v).strip() if v is not None else ""
    return grid


def parse_archive_sheets(
    con: sqlite3.Connection,
    verbose: bool = False,
) -> list[dict]:
    """
    Parse every sheet in archive_historical_nsf_raw into structured records.
    Returns list of dicts matching the archive_historical_nsf schema:
        industry_name, sic_code, year, value, suppression_flag,
        source_file, survey_year, sheet_name
    """
    cur = con.cursor()
    cur.execute(
        "SELECT DISTINCT survey_year, sheet_name, source_file "
        "FROM archive_historical_nsf_raw ORDER BY survey_year, sheet_name"
    )
    sheets = cur.fetchall()

    all_records: list[dict] = []

    for survey_year, sheet_name, source_file in sheets:
        cur.execute(
            "SELECT row_idx, col_idx, value_raw "
            "FROM archive_historical_nsf_raw "
            "WHERE survey_year = ? AND sheet_name = ?",
            (survey_year, sheet_name),
        )
        cells = cur.fetchall()
        grid = _reconstruct_sheet(cells)
        if not grid:
            continue

        # Apply the same improved parser
        header_row = _find_header_row(grid)
        if header_row is None:
            if verbose:
                print(f"  [archive] {survey_year}/{sheet_name}: no header found")
            continue

        if _has_year_row(grid[header_row]):
            year_row = header_row
        else:
            year_row = None
            for offset in range(1, 5):
                for sign in (+1, -1):
                    ri = header_row + sign * offset
                    if 0 <= ri < len(grid) and _has_year_row(grid[ri]):
                        year_row = ri
                        break
                if year_row is not None:
                    break
            if year_row is None:
                if verbose:
                    print(f"  [archive] {survey_year}/{sheet_name}: no year row found")
                continue

        pages = _extract_pages(grid, header_row, year_row)
        if not pages:
            if verbose:
                print(f"  [archive] {survey_year}/{sheet_name}: no pages extracted")
            continue

        sheet_records = 0
        for page in pages:
            col_ind = page["col_industry"]
            col_sic = page["col_sic"]
            year_cols = page["year_cols"]
            data_start = page["data_start_row"]

            for row in grid[data_start:]:
                ind_val = row[col_ind] if col_ind < len(row) else ""
                if not ind_val or ind_val.lower() in ("nan", "none", ""):
                    continue
                if "industry" in ind_val.lower() and "size" in ind_val.lower():
                    continue

                sic_val = row[col_sic] if col_sic < len(row) else ""
                if sic_val.lower() in ("nan", "none"):
                    sic_val = ""

                ind_norm = _normalise_name(ind_val)
                if not ind_norm:
                    continue

                for col_idx, year in year_cols:
                    raw = row[col_idx] if col_idx < len(row) else ""
                    if raw.lower() in ("nan", "none", ""):
                        continue
                    value, flag = _parse_value(raw)
                    all_records.append({
                        "industry_name": ind_val[:500],
                        "sic_code": sic_val[:50],
                        "year": year,
                        "value": value,
                        "suppression_flag": flag,
                        "source_file": source_file[:500],
                        "survey_year": survey_year,
                        "sheet_name": sheet_name[:100],
                    })
                    sheet_records += 1

        if verbose and sheet_records > 0:
            print(f"  [archive] {survey_year}/{sheet_name}: {sheet_records} records")

    return all_records


def ensure_archive_table(cur: sqlite3.Cursor) -> None:
    cur.execute("""
        CREATE TABLE IF NOT EXISTS archive_historical_nsf (
            id               INTEGER PRIMARY KEY AUTOINCREMENT,
            industry_name    TEXT,
            sic_code         TEXT,
            year             INTEGER,
            value            REAL,
            suppression_flag TEXT,
            source_file      TEXT,
            survey_year      INTEGER,
            ingested_at      TEXT NOT NULL DEFAULT (datetime('now'))
        )
    """)
    # Add sheet_name column if the table was created without it
    cur.execute("PRAGMA table_info(archive_historical_nsf)")
    existing_cols = {row[1] for row in cur.fetchall()}
    if "sheet_name" not in existing_cols:
        cur.execute("ALTER TABLE archive_historical_nsf ADD COLUMN sheet_name TEXT")
    cur.execute("""
        CREATE INDEX IF NOT EXISTS idx_archive_nsf_sic_year
        ON archive_historical_nsf (sic_code, year)
    """)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(description="Improved NSF ingestion patch")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--verbose", action="store_true")
    args = parser.parse_args()

    now = dt.datetime.now().isoformat()
    batch_id = f"nsf_v2_{dt.datetime.now().strftime('%Y%m%d_%H%M%S')}"

    con = sqlite3.connect(DB_PATH)
    try:
        cur = con.cursor()
        ensure_archive_table(cur)

        # ---------------------------------------------------------------
        # Part 1: Re-process 'empty' files from raw_nsf_file_index
        # ---------------------------------------------------------------
        cur.execute(
            "SELECT source_file, index_folder FROM raw_nsf_file_index "
            "WHERE parse_status = 'empty' ORDER BY source_file"
        )
        empty_files = cur.fetchall()
        print(f"Re-processing {len(empty_files)} 'empty' files …")

        recovered = 0
        still_empty = 0
        total_new_records = 0

        for source_file, index_folder in empty_files:
            path = Path(source_file)
            if not path.exists():
                if args.verbose:
                    print(f"  MISSING: {path.name}")
                continue

            records, status = _parse_file_improved(path)

            if args.verbose or (records and not args.verbose):
                tag = "✓" if records else "·"
                print(f"  {tag} [{index_folder}] {path.name}: {status} ({len(records)} records)")

            if not args.dry_run:
                cur.execute(
                    "UPDATE raw_nsf_file_index "
                    "SET parse_status = ?, records_found = ?, ingested_at = ? "
                    "WHERE source_file = ?",
                    (status, len(records), now, source_file),
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
                        [{**r, "source_file": source_file, "ingested_at": now}
                         for r in records],
                    )

            if records:
                recovered += 1
                total_new_records += len(records)
            else:
                still_empty += 1

        print(f"\nRecovered: {recovered} files ({total_new_records} new records)")
        print(f"Confirmed non-industry-format: {still_empty} files")

        # ---------------------------------------------------------------
        # Part 2: Populate archive_historical_nsf
        # ---------------------------------------------------------------
        print("\nParsing archive_historical_nsf_raw …")
        archive_records = parse_archive_sheets(con, verbose=args.verbose)
        print(f"Archive records extracted: {len(archive_records)}")

        if not args.dry_run and archive_records:
            cur.execute("DELETE FROM archive_historical_nsf")
            cur.executemany(
                """
                INSERT INTO archive_historical_nsf
                    (industry_name, sic_code, year, value, suppression_flag,
                     source_file, survey_year, sheet_name, ingested_at)
                VALUES
                    (:industry_name, :sic_code, :year, :value, :suppression_flag,
                     :source_file, :survey_year, :sheet_name, :ingested_at)
                """,
                [{**r, "ingested_at": now} for r in archive_records],
            )

        # ---------------------------------------------------------------
        # Part 3: Dedup raw_nsf_rd (preserve earliest id per key)
        # ---------------------------------------------------------------
        if not args.dry_run and total_new_records > 0:
            print("\nDeduplicating raw_nsf_rd …")
            cur.execute("""
                DELETE FROM raw_nsf_rd
                WHERE id NOT IN (
                    SELECT MIN(id)
                    FROM raw_nsf_rd
                    GROUP BY industry_name_norm, sic_code, year
                )
            """)
            print(f"  Rows removed: {con.total_changes}")

        if not args.dry_run:
            con.commit()

        # Summary
        cur.execute("SELECT COUNT(*) FROM raw_nsf_rd")
        n_rd = cur.fetchone()[0]
        cur.execute("SELECT MIN(year), MAX(year) FROM raw_nsf_rd")
        y_range = cur.fetchone()
        cur.execute("SELECT COUNT(*) FROM archive_historical_nsf")
        n_archive = cur.fetchone()[0]
        cur.execute("SELECT COUNT(*), SUM(CASE WHEN parse_status='ok' THEN 1 ELSE 0 END), "
                    "SUM(CASE WHEN parse_status='ok_v2' THEN 1 ELSE 0 END) "
                    "FROM raw_nsf_file_index")
        idx = cur.fetchone()

        print(f"\n{'[DRY RUN] ' if args.dry_run else ''}Final state:")
        print(f"  raw_nsf_rd:              {n_rd:,} rows, years {y_range[0]}–{y_range[1]}")
        print(f"  archive_historical_nsf:  {n_archive:,} rows")
        print(f"  file index:              {idx[0]} total | {idx[1]} ok (v1) | {idx[2]} ok_v2")

    except Exception:
        con.rollback()
        traceback.print_exc()
        raise
    finally:
        con.close()


if __name__ == "__main__":
    main()
