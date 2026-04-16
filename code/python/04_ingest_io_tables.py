#!/usr/bin/env python3
"""
Ingest IO coefficient matrices into cyclicality.db.

Reads data/instruments/io_tables/IO{year}.csv (1997-2013), which are
headerless 134×67 floating-point matrices representing Leontief inverse
coefficients. Stores two tables:

  instrument_io_naics_map  -- integer index → NAICS code (from InputOutputCode.do)
  instrument_io_tables     -- long-format (year, row_idx, col_idx, value)

Usage:
    python code/python/ingest_io_tables.py
    python code/python/ingest_io_tables.py --dry-run
"""

from __future__ import annotations

import argparse
import csv
import datetime as dt
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DB_PATH = ROOT / "data" / "cyclicality.db"
IO_DIR = ROOT / "data" / "instruments" / "io_tables"

# NAICS code mapping extracted from data/instruments/InputOutputCode.do
# Maps integer index (1-based) → NAICS code string
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


def create_tables(cur: sqlite3.Cursor) -> None:
    cur.executescript("""
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

        CREATE TABLE IF NOT EXISTS ingestion_log (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            batch_id    TEXT    NOT NULL,
            source_file TEXT    NOT NULL,
            rows_loaded INTEGER,
            ingested_at TEXT    NOT NULL DEFAULT (datetime('now')),
            notes       TEXT
        );
    """)


def load_naics_map(cur: sqlite3.Cursor) -> None:
    cur.execute("DELETE FROM instrument_io_naics_map")
    cur.executemany(
        "INSERT INTO instrument_io_naics_map (col_idx, naics_code) VALUES (?, ?)",
        NAICS_MAP.items(),
    )


def ingest_year(
    cur: sqlite3.Cursor,
    year: int,
    csv_path: Path,
    batch_id: str,
    dry_run: bool,
) -> int:
    rows_loaded = 0
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
    rows_loaded = len(records)
    print(f"  {csv_path.name}: {rows_loaded} cells")
    return rows_loaded


def main() -> None:
    parser = argparse.ArgumentParser(description="Ingest IO coefficient matrices")
    parser.add_argument("--dry-run", action="store_true", help="Parse without writing")
    args = parser.parse_args()

    csv_files = sorted(IO_DIR.glob("IO*.csv"))
    if not csv_files:
        raise FileNotFoundError(f"No IO CSV files found in {IO_DIR}")

    print(f"Found {len(csv_files)} IO CSV files")
    batch_id = f"io_tables_{dt.datetime.now().strftime('%Y%m%d_%H%M%S')}"
    total = 0

    conn = sqlite3.connect(DB_PATH)
    try:
        cur = conn.cursor()
        create_tables(cur)

        if not args.dry_run:
            # Clear existing IO data before re-ingesting
            cur.execute("DELETE FROM instrument_io_tables")
            cur.execute(
                "DELETE FROM ingestion_log WHERE source_file LIKE '%IO%.csv'"
            )
            load_naics_map(cur)
            print(f"Loaded {len(NAICS_MAP)} NAICS mappings into instrument_io_naics_map")

        for csv_path in csv_files:
            # Extract year from filename: IO1997.csv → 1997
            stem = csv_path.stem  # "IO1997"
            try:
                year = int(stem.replace("IO", ""))
            except ValueError:
                print(f"  Skipping unrecognised filename: {csv_path.name}")
                continue

            n = ingest_year(cur, year, csv_path, batch_id, args.dry_run)
            total += n

        if not args.dry_run:
            conn.commit()
            print(f"\nCommitted. Total cells ingested: {total}")
        else:
            print(f"\nDry run complete. Would ingest {total} cells.")
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


if __name__ == "__main__":
    main()
