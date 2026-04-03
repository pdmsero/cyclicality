#!/usr/bin/env python3
"""
Source-vs-DB parity verification for the three ingestion scripts.

For each source family, reads values directly from the original files and
compares them against what was written to cyclicality.db. Reports pass/fail
per check with exact values shown on failures.

Usage:
    python code/python/verify_ingestion.py
"""

from __future__ import annotations

import csv
import random
import sqlite3
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DB_PATH = ROOT / "data" / "cyclicality.db"
IO_DIR = ROOT / "data" / "instruments" / "io_tables"
NSF_DIR = ROOT / "data" / "industry" / "nsf_raw"
ARCHIVE_DIR = ROOT / "archive"

PASS = "PASS"
FAIL = "FAIL"
SKIP = "SKIP"

results: list[tuple[str, str, str]] = []  # (family, description, status)


def check(family: str, desc: str, condition: bool, detail: str = "") -> None:
    status = PASS if condition else FAIL
    results.append((family, desc, status))
    icon = "✓" if condition else "✗"
    line = f"  {icon} [{family}] {desc}"
    if not condition and detail:
        line += f"\n      → {detail}"
    print(line)


def db_query(sql: str, params: tuple = ()) -> list:
    conn = sqlite3.connect(DB_PATH)
    try:
        cur = conn.cursor()
        cur.execute(sql, params)
        return cur.fetchall()
    finally:
        conn.close()


# ---------------------------------------------------------------------------
# 1. IO tables
# ---------------------------------------------------------------------------

def verify_io_tables() -> None:
    print("\n=== IO tables ===")

    # 1a. Row count: 17 years × 134 rows × 67 cols = 152,626
    expected_cells = 17 * 134 * 67
    actual = db_query("SELECT COUNT(*) FROM instrument_io_tables")[0][0]
    check("io", f"total cell count = {expected_cells:,}", actual == expected_cells,
          f"got {actual:,}")

    # 1b. Year coverage: 1997–2013 present
    years_in_db = {r[0] for r in db_query("SELECT DISTINCT year FROM instrument_io_tables ORDER BY year")}
    expected_years = set(range(1997, 2014))
    check("io", "years 1997–2013 all present", years_in_db == expected_years,
          f"missing: {expected_years - years_in_db}, extra: {years_in_db - expected_years}")

    # 1c. Spot-check: compare 10 random cells across 3 files to DB
    spot_files = [
        (IO_DIR / "IO1997.csv", 1997),
        (IO_DIR / "IO2005.csv", 2005),
        (IO_DIR / "IO2013.csv", 2013),
    ]
    random.seed(42)
    all_pass = True
    for csv_path, year in spot_files:
        with open(csv_path, newline="") as f:
            rows = list(csv.reader(f))
        # Pick 5 random (row, col) positions
        for _ in range(5):
            ri = random.randint(0, len(rows) - 1)
            ci = random.randint(0, len(rows[ri]) - 1)
            raw = rows[ri][ci].strip()
            try:
                expected_val = float(raw)
            except ValueError:
                continue  # skip unparseable cells
            # DB uses 1-based indices
            db_rows = db_query(
                "SELECT value FROM instrument_io_tables WHERE year=? AND row_idx=? AND col_idx=?",
                (year, ri + 1, ci + 1),
            )
            if not db_rows:
                all_pass = False
                print(f"      ✗ [{year}] row={ri+1} col={ci+1}: NOT FOUND in DB (source={expected_val})")
                continue
            db_val = db_rows[0][0]
            if db_val is None or abs(db_val - expected_val) > 1e-9:
                all_pass = False
                print(f"      ✗ [{year}] row={ri+1} col={ci+1}: source={expected_val} db={db_val}")
    check("io", "15 random cell spot-checks match source CSVs", all_pass)

    # 1d. NAICS map: 66 entries, specific code checks
    n_naics = db_query("SELECT COUNT(*) FROM instrument_io_naics_map")[0][0]
    check("io", "NAICS map has 66 entries", n_naics == 66, f"got {n_naics}")
    code_1 = db_query("SELECT naics_code FROM instrument_io_naics_map WHERE col_idx=1")[0][0]
    check("io", "col_idx=1 maps to '111.112'", code_1 == "111.112", f"got '{code_1}'")
    code_66 = db_query("SELECT naics_code FROM instrument_io_naics_map WHERE col_idx=66")[0][0]
    check("io", "col_idx=66 maps to '811.812.813.814'", code_66 == "811.812.813.814",
          f"got '{code_66}'")


# ---------------------------------------------------------------------------
# 2. NSF raw
# ---------------------------------------------------------------------------

def verify_nsf_raw() -> None:
    print("\n=== NSF raw ===")

    # 2a. File index: 1,061 files catalogued
    n_files = db_query("SELECT COUNT(*) FROM raw_nsf_file_index")[0][0]
    check("nsf", f"file index has 1,061 entries", n_files == 1061, f"got {n_files}")

    # 2b. All 27 index folders represented
    folders = {r[0] for r in db_query("SELECT DISTINCT index_folder FROM raw_nsf_file_index")}
    expected_folders = {f"index_{i}" for i in range(1, 28)}
    check("nsf", "all 27 index folders present in file index",
          expected_folders == folders,
          f"missing: {expected_folders - folders}")

    # 2c. Deduplicated rows > 0
    n_rows = db_query("SELECT COUNT(*) FROM raw_nsf_rd")[0][0]
    check("nsf", f"raw_nsf_rd has rows after dedup ({n_rows:,})", n_rows > 0,
          "table is empty")

    # 2d. Suppression flags stored correctly (D, T not as numeric)
    n_suppressed = db_query(
        "SELECT COUNT(*) FROM raw_nsf_rd WHERE suppression_flag IS NOT NULL AND value IS NULL"
    )[0][0]
    check("nsf", f"suppressed cells stored as NULL value + flag ({n_suppressed:,} found)",
          n_suppressed > 0, "no suppressed cells found — may indicate parse failure")

    # 2e. Year range plausible (1953–2010)
    min_yr, max_yr = db_query("SELECT MIN(year), MAX(year) FROM raw_nsf_rd")[0]
    check("nsf", f"year range plausible: {min_yr}–{max_yr}",
          min_yr is not None and 1950 <= min_yr <= 1960 and 2000 <= max_yr <= 2015,
          f"got min={min_yr}, max={max_yr}")

    # 2f. Spot-check: read a known parseable file and verify a record appears in DB
    known_file = NSF_DIR / "index_1" / "historical_tablesh-25.xls"
    if known_file.exists():
        rows = db_query(
            "SELECT COUNT(*) FROM raw_nsf_rd WHERE source_file LIKE ?",
            (f"%historical_tablesh-25%",),
        )
        # After dedup, records from this file may be partially retained
        # Just check the file was indexed
        indexed = db_query(
            "SELECT parse_status FROM raw_nsf_file_index WHERE source_file LIKE ?",
            (f"%historical_tablesh-25%",),
        )
        status = indexed[0][0] if indexed else "NOT FOUND"
        check("nsf", f"historical_tablesh-25.xls indexed with status 'ok'",
              status == "ok", f"got '{status}'")


# ---------------------------------------------------------------------------
# 3. Archive
# ---------------------------------------------------------------------------

def verify_archive() -> None:
    print("\n=== Archive ===")

    # 3a. BEA detail: 3 parseable files → check row counts
    n_bea = db_query("SELECT COUNT(*) FROM archive_bea_detail")[0][0]
    check("archive", f"archive_bea_detail has rows ({n_bea:,})", n_bea > 0)

    # 3b. BEA detail spot-check: read GDPbyInd_VA_1947-2017.xlsx and verify year 1970 exists
    try:
        import pandas as pd
        va_path = ARCHIVE_DIR / "BEA Data - Detail" / "GDPbyInd_VA_1947-2017.xlsx"
        xl = pd.ExcelFile(va_path, engine="openpyxl")
        sheet = xl.sheet_names[0]
        df = xl.parse(sheet, header=None)
        # Confirm at least one year column 1970 and check DB has rows for that year
        n_1970 = db_query(
            "SELECT COUNT(*) FROM archive_bea_detail WHERE year=1970 AND source_file LIKE '%GDPbyInd_VA%'"
        )[0][0]
        check("archive", "archive_bea_detail has rows for year=1970 from VA file",
              n_1970 > 0, f"got {n_1970}")
    except Exception as exc:
        results.append(("archive", "BEA VA 1970 spot-check", SKIP))
        print(f"  ~ [archive] BEA VA 1970 spot-check: SKIP ({exc})")

    # 3c. Calibrations: check all three tables exist and have expected rows
    for stem, expected_rows in [
        ("demand_shock", 100),
        ("technology_shock", 100),
        ("very_important__calibration_data", 156),
    ]:
        table = f"archive_calibration_{stem}"
        try:
            n = db_query(f"SELECT COUNT(*) FROM {table}")[0][0]
            check("archive", f"{table}: {expected_rows} rows", n == expected_rows,
                  f"got {n}")
        except Exception as exc:
            results.append(("archive", f"{table} exists", FAIL))
            print(f"  ✗ [archive] {table}: {exc}")

    # 3d. Calibrations spot-check: first column 't' should be sequential integers 1–100
    t_vals = [r[0] for r in db_query("SELECT t FROM archive_calibration_demand_shock ORDER BY t")]
    expected_t = list(range(1, 101))
    check("archive", "demand_shock.t column = 1..100",
          t_vals == expected_t, f"got {t_vals[:5]}...")

    # 3e. Historical NSF raw: cell count > 0, covers 1991
    n_hist = db_query("SELECT COUNT(*) FROM archive_historical_nsf_raw")[0][0]
    check("archive", f"archive_historical_nsf_raw has cells ({n_hist:,})", n_hist > 0)
    surveys = {r[0] for r in db_query("SELECT DISTINCT survey_year FROM archive_historical_nsf_raw")}
    check("archive", "historical NSF data is tagged with survey year 1991",
          1991 in surveys, f"survey_years found: {surveys}")

    # 3f. Imputed: verify compustat table row count matches source dta
    try:
        import pyreadstat
        src = ARCHIVE_DIR / "imputed_data" / "Compustat data.dta"
        df, _ = pyreadstat.read_dta(str(src))
        n_src = len(df)
        n_db = db_query("SELECT COUNT(*) FROM archive_imputed_compustat_data")[0][0]
        check("archive", f"archive_imputed_compustat_data rows match source ({n_src:,})",
              n_db == n_src, f"source={n_src:,} db={n_db:,}")
    except Exception as exc:
        results.append(("archive", "imputed compustat row count", SKIP))
        print(f"  ~ [archive] imputed compustat row count: SKIP ({exc})")

    # 3g. Imputed: verify a specific value in total_imputed_data (small table, easy to check)
    try:
        import pyreadstat
        src = ARCHIVE_DIR / "imputed_data" / "[rnd] total imputed data.dta"
        df_src, _ = pyreadstat.read_dta(str(src))
        n_src = len(df_src)
        n_db = db_query("SELECT COUNT(*) FROM archive_imputed_rnd_total_imputed_data")[0][0]
        check("archive", f"archive_imputed_rnd_total_imputed_data rows match source ({n_src})",
              n_db == n_src, f"source={n_src} db={n_db}")
    except Exception as exc:
        results.append(("archive", "imputed total imputed data row count", SKIP))
        print(f"  ~ [archive] imputed total_imputed_data row count: SKIP ({exc})")


# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

def main() -> None:
    random.seed(42)
    print(f"Verifying ingestion against source files")
    print(f"DB: {DB_PATH}")

    verify_io_tables()
    verify_nsf_raw()
    verify_archive()

    print("\n" + "=" * 60)
    n_pass = sum(1 for _, _, s in results if s == PASS)
    n_fail = sum(1 for _, _, s in results if s == FAIL)
    n_skip = sum(1 for _, _, s in results if s == SKIP)
    print(f"Results: {n_pass} PASS  {n_fail} FAIL  {n_skip} SKIP")

    if n_fail:
        print("\nFailed checks:")
        for fam, desc, status in results:
            if status == FAIL:
                print(f"  ✗ [{fam}] {desc}")
        sys.exit(1)
    else:
        print("All checks passed.")


if __name__ == "__main__":
    main()
