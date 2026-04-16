#!/usr/bin/env python3
"""
Ingest IO coefficient matrices into cyclicality.db.

Two data sources are supported:

1. Legacy CSV files (1997–2013)
   Location: data/instruments/io_tables/IO{year}.csv
   Format:   headerless 134×67 floating-point matrices (Leontief inverse
             coefficients), indexed via NAICS_MAP below.
   Tables:   instrument_io_naics_map, instrument_io_tables

2. BEA API (2014–present)
   Endpoint: InputOutput / TableID=59 (Total Requirements,
             Commodity-by-Commodity – Summary level, 73×73 NAICS matrix)
   Tables:   instrument_io_tables_api
   Requires: BEA_API_KEY in .env or environment

The two schemas are intentionally separate because the BEA revised its IO
industry classification between the legacy and API-era tables. Downstream
instrument-construction scripts should map between the two as needed.

Usage:
    python code/python/04_ingest_io_tables.py              # legacy CSVs only
    python code/python/04_ingest_io_tables.py --dry-run
    python code/python/04_ingest_io_tables.py --api-years 2014-2024
    python code/python/04_ingest_io_tables.py --api-years 2017,2022
    python code/python/04_ingest_io_tables.py --api-years all
"""

from __future__ import annotations

import argparse
import csv
import datetime as dt
import json
import os
import sqlite3
import time
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DB_PATH = ROOT / "data" / "cyclicality.db"
IO_DIR = ROOT / "data" / "instruments" / "io_tables"

# ---------------------------------------------------------------------------
# .env auto-load (mirrors 08_refresh_macro_data.py)
# ---------------------------------------------------------------------------
_env_path = ROOT / ".env"
if _env_path.exists():
    try:
        from dotenv import load_dotenv
        load_dotenv(_env_path, override=False)
    except ImportError:
        with open(_env_path) as _f:
            for _line in _f:
                _line = _line.strip()
                if _line and not _line.startswith("#") and "=" in _line:
                    _k, _, _v = _line.partition("=")
                    os.environ.setdefault(_k.strip(), _v.strip())

# ---------------------------------------------------------------------------
# BEA API constants
# ---------------------------------------------------------------------------
BEA_API_BASE = "https://apps.bea.gov/api/data"
BEA_IO_TABLE_ID = 59          # Total Requirements, Commodity-by-Commodity (Summary)
BEA_API_YEARS_AVAILABLE = list(range(1997, 2025))  # 1997–2024

# ---------------------------------------------------------------------------
# NAICS code mapping for legacy CSV format (from data/instruments/InputOutputCode.do)
# Maps integer index (1-based) → NAICS code string
# ---------------------------------------------------------------------------
NAICS_MAP: dict[int, str] = {
    1:  "111.112",
    2:  "113.114.115",
    3:  "211",
    4:  "212",
    5:  "213",
    6:  "22",
    7:  "23",
    8:  "321",
    9:  "327",
    10: "331",
    11: "332",
    12: "333",
    13: "334",
    14: "335",
    15: "336.1",
    16: "336.4",
    17: "337",
    18: "339",
    19: "311",
    20: "313",
    21: "315",
    22: "322",
    23: "323",
    24: "324",
    25: "325",
    26: "326",
    27: "42",
    28: "441",
    29: "445",
    30: "452",
    31: "442-4.446-8.451.453-4",
    32: "481",
    33: "482",
    34: "483",
    35: "484",
    36: "485",
    37: "486",
    38: "487.488.492",
    39: "493",
    40: "511",
    41: "512",
    42: "513",
    43: "514",
    44: "521.522",
    45: "523",
    46: "524",
    47: "525",
    48: "531a",
    49: "531b",
    50: "532.533",
    51: "541.1",
    52: "541.5",
    53: "541.2",
    54: "55",
    55: "561",
    56: "562",
    57: "61",
    58: "621",
    59: "622",
    60: "623",
    61: "624",
    62: "711",
    63: "713",
    64: "721",
    65: "722",
    66: "811.812.813.814",
}


# ---------------------------------------------------------------------------
# DB schema helpers
# ---------------------------------------------------------------------------

def create_tables(cur: sqlite3.Cursor) -> None:
    cur.executescript("""
        -- Legacy CSV tables (134×67, dot-notation NAICS, 1997–2013)
        CREATE TABLE IF NOT EXISTS instrument_io_naics_map (
            col_idx     INTEGER PRIMARY KEY,
            naics_code  TEXT    NOT NULL
        );

        CREATE TABLE IF NOT EXISTS instrument_io_tables (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            year        INTEGER NOT NULL,
            row_idx     INTEGER NOT NULL,
            col_idx     INTEGER NOT NULL,
            value       REAL,
            source_file TEXT    NOT NULL,
            ingested_at TEXT    NOT NULL DEFAULT (datetime('now'))
        );

        CREATE INDEX IF NOT EXISTS idx_io_year_row_col
            ON instrument_io_tables (year, row_idx, col_idx);

        -- BEA API tables (73×73, standard NAICS codes, 2014+)
        CREATE TABLE IF NOT EXISTS instrument_io_tables_api (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            year        INTEGER NOT NULL,
            table_id    INTEGER NOT NULL DEFAULT 59,
            row_code    TEXT    NOT NULL,
            row_descr   TEXT,
            col_code    TEXT    NOT NULL,
            col_descr   TEXT,
            value       REAL,
            ingested_at TEXT    NOT NULL DEFAULT (datetime('now'))
        );

        CREATE INDEX IF NOT EXISTS idx_io_api_year_row_col
            ON instrument_io_tables_api (year, row_code, col_code);

        -- Shared ingestion log
        CREATE TABLE IF NOT EXISTS ingestion_log (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            batch_id    TEXT    NOT NULL,
            source_file TEXT    NOT NULL,
            rows_loaded INTEGER,
            ingested_at TEXT    NOT NULL DEFAULT (datetime('now')),
            notes       TEXT
        );
    """)


# ---------------------------------------------------------------------------
# Legacy CSV ingestion (unchanged from original)
# ---------------------------------------------------------------------------

def load_naics_map(cur: sqlite3.Cursor) -> None:
    cur.execute("DELETE FROM instrument_io_naics_map")
    cur.executemany(
        "INSERT INTO instrument_io_naics_map (col_idx, naics_code) VALUES (?, ?)",
        NAICS_MAP.items(),
    )


def ingest_year_csv(
    cur: sqlite3.Cursor,
    year: int,
    csv_path: Path,
    batch_id: str,
    dry_run: bool,
) -> int:
    records: list[tuple] = []
    now = dt.datetime.now().isoformat()

    with open(csv_path, newline="") as f:
        reader = csv.reader(f)
        for row_idx, row in enumerate(reader, start=1):
            for col_idx, cell in enumerate(row, start=1):
                cell = cell.strip()
                value: float | None
                try:
                    value = float(cell)
                except ValueError:
                    value = None
                records.append((year, row_idx, col_idx, value, str(csv_path), now))

    if not dry_run:
        cur.executemany(
            """
            INSERT INTO instrument_io_tables
                (year, row_idx, col_idx, value, source_file, ingested_at)
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            records,
        )
        cur.execute(
            """
            INSERT INTO ingestion_log (batch_id, source_file, rows_loaded, ingested_at)
            VALUES (?, ?, ?, ?)
            """,
            (batch_id, str(csv_path), len(records), now),
        )
    print(f"  {csv_path.name}: {len(records)} cells")
    return len(records)


# ---------------------------------------------------------------------------
# BEA API ingestion (new)
# ---------------------------------------------------------------------------

def _bea_fetch(api_key: str, year: int, table_id: int = BEA_IO_TABLE_ID,
               retries: int = 3) -> list[dict]:
    """Download one year of IO data from the BEA API. Returns list of row dicts."""
    url = (
        f"{BEA_API_BASE}/?UserID={api_key}"
        f"&method=GETDATA&DatasetName=InputOutput"
        f"&TableID={table_id}&Year={year}&ResultFormat=JSON"
    )
    for attempt in range(1, retries + 1):
        try:
            with urllib.request.urlopen(url, timeout=60) as resp:
                payload = json.loads(resp.read())
            results = payload["BEAAPI"]["Results"]
            if isinstance(results, list):
                return results[0]["Data"]
            # Error result
            raise ValueError(f"BEA API error for {year}: {results}")
        except (urllib.error.URLError, TimeoutError) as exc:
            if attempt == retries:
                raise
            print(f"    Retry {attempt}/{retries} for {year}: {exc}")
            time.sleep(2 ** attempt)
    return []


def ingest_year_api(
    cur: sqlite3.Cursor,
    year: int,
    api_key: str,
    batch_id: str,
    dry_run: bool,
    save_csv: bool = True,
) -> int:
    """Fetch one year from BEA API and insert into instrument_io_tables_api."""
    print(f"  API fetch: {year} ... ", end="", flush=True)
    data = _bea_fetch(api_key, year)

    now = dt.datetime.now().isoformat()
    records = [
        (year, BEA_IO_TABLE_ID,
         row["RowCode"], row.get("RowDescr", ""),
         row["ColCode"], row.get("ColDescr", ""),
         float(row["DataValue"]) if row["DataValue"] not in ("", None) else None,
         now)
        for row in data
    ]

    # Optionally persist a CSV alongside the legacy files for portability
    if save_csv and not dry_run:
        _save_api_csv(year, data)

    if not dry_run:
        # Remove existing rows for this year before re-inserting
        cur.execute("DELETE FROM instrument_io_tables_api WHERE year = ?", (year,))
        cur.executemany(
            """
            INSERT INTO instrument_io_tables_api
                (year, table_id, row_code, row_descr, col_code, col_descr, value, ingested_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """,
            records,
        )
        cur.execute(
            """
            INSERT INTO ingestion_log (batch_id, source_file, rows_loaded, ingested_at, notes)
            VALUES (?, ?, ?, ?, ?)
            """,
            (batch_id, f"BEA_API:InputOutput:TableID={BEA_IO_TABLE_ID}:Year={year}",
             len(records), now, "BEA API download"),
        )

    print(f"{len(records)} records")
    return len(records)


def _save_api_csv(year: int, data: list[dict]) -> None:
    """Save BEA API data as a headed CSV in the io_tables directory.

    File name: IO{year}_api.csv
    Columns:   RowCode, ColCode, DataValue
    """
    out_path = IO_DIR / f"IO{year}_api.csv"
    with open(out_path, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["RowCode", "ColCode", "DataValue"])
        for row in data:
            writer.writerow([row["RowCode"], row["ColCode"], row.get("DataValue", "")])


def parse_api_years(spec: str) -> list[int]:
    """Parse --api-years argument into a sorted list of years.

    Accepts:
      'all'         → all available years (1997–2024)
      '2014-2024'   → range inclusive
      '2017,2022'   → comma-separated list
    """
    spec = spec.strip().lower()
    if spec == "all":
        return list(BEA_API_YEARS_AVAILABLE)
    if "-" in spec and "," not in spec:
        parts = spec.split("-")
        start, end = int(parts[0]), int(parts[1])
        return list(range(start, end + 1))
    return sorted(int(y.strip()) for y in spec.split(","))


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(description="Ingest IO coefficient matrices")
    parser.add_argument("--dry-run", action="store_true",
                        help="Parse / fetch without writing to DB")
    parser.add_argument("--api-years", metavar="SPEC", default=None,
                        help=(
                            "Download additional years from the BEA API. "
                            "Examples: '2014-2024', '2017,2022', 'all'. "
                            "Requires BEA_API_KEY in .env or environment."
                        ))
    parser.add_argument("--no-csv-save", action="store_true",
                        help="Skip saving per-year API CSVs to io_tables/")
    args = parser.parse_args()

    conn = sqlite3.connect(DB_PATH)
    try:
        cur = conn.cursor()
        create_tables(cur)
        batch_id = f"io_tables_{dt.datetime.now().strftime('%Y%m%d_%H%M%S')}"
        total = 0

        # ------------------------------------------------------------------
        # 1. Legacy CSV ingestion
        # ------------------------------------------------------------------
        csv_files = sorted(f for f in IO_DIR.glob("IO*.csv")
                           if "_api" not in f.stem)
        if csv_files:
            print(f"Found {len(csv_files)} legacy IO CSV files")
            if not args.dry_run:
                cur.execute("DELETE FROM instrument_io_tables")
                cur.execute(
                    "DELETE FROM ingestion_log WHERE source_file LIKE '%IO%.csv' "
                    "AND (notes IS NULL OR notes != 'BEA API download')"
                )
                load_naics_map(cur)
                print(f"Loaded {len(NAICS_MAP)} NAICS mappings into instrument_io_naics_map")

            for csv_path in csv_files:
                stem = csv_path.stem  # "IO1997"
                try:
                    year = int(stem.replace("IO", ""))
                except ValueError:
                    print(f"  Skipping unrecognised filename: {csv_path.name}")
                    continue
                n = ingest_year_csv(cur, year, csv_path, batch_id, args.dry_run)
                total += n
        else:
            print("No legacy CSV files found — skipping CSV ingestion.")

        # ------------------------------------------------------------------
        # 2. BEA API ingestion (optional)
        # ------------------------------------------------------------------
        if args.api_years is not None:
            api_key = os.environ.get("BEA_API_KEY", "")
            if not api_key:
                raise EnvironmentError(
                    "BEA_API_KEY not set. Add it to .env or export it."
                )
            years = parse_api_years(args.api_years)
            invalid = [y for y in years if y not in BEA_API_YEARS_AVAILABLE]
            if invalid:
                print(f"Warning: years {invalid} not in known range "
                      f"{BEA_API_YEARS_AVAILABLE[0]}–{BEA_API_YEARS_AVAILABLE[-1]}, skipping.")
                years = [y for y in years if y in BEA_API_YEARS_AVAILABLE]

            print(f"\nBEA API: fetching {len(years)} year(s): {years}")
            api_total = 0
            for year in years:
                n = ingest_year_api(
                    cur, year, api_key, batch_id, args.dry_run,
                    save_csv=not args.no_csv_save,
                )
                api_total += n
            total += api_total
            print(f"BEA API total: {api_total} records across {len(years)} year(s)")

        # ------------------------------------------------------------------
        # 3. Commit
        # ------------------------------------------------------------------
        if not args.dry_run:
            conn.commit()
            print(f"\nCommitted. Total records ingested: {total}")
        else:
            print(f"\nDry run complete. Would ingest {total} records.")

    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


if __name__ == "__main__":
    main()
