#!/usr/bin/env python3
"""
Fetch BLS QCEW average annual pay by NAICS industry and store in cyclicality.db.

Data sources:
  2015–2023: BLS QCEW flat-file API (per-area CSV, small)
             https://data.bls.gov/cew/data/api/{year}/a/area/US000.csv
  2001–2014: BLS QCEW annual zip file (national singlefile, ~40-80 MB each)
             https://data.bls.gov/cew/data/files/{year}/csv/{year}_annual_singlefile.zip

Stores table bls_qcew_wages in cyclicality.db:
    year            INTEGER
    naics_code      TEXT       (as published by BLS)
    naics_digits    INTEGER    (0=all-private, 2, 3, 4, 5, or 6)
    agglvl_code     INTEGER    (11=all-private, 14=2-digit … 18=6-digit)
    avg_annual_pay  REAL
    disclosure_code TEXT       ('' = clean; non-empty = suppressed)
    ingested_at     TEXT

Usage:
    python code/python/fetch_bls_qcew_wages.py
    python code/python/fetch_bls_qcew_wages.py --dry-run
    python code/python/fetch_bls_qcew_wages.py --start-year 2010 --end-year 2015
"""

from __future__ import annotations

import argparse
import datetime as dt
import io
import sqlite3
import time
import zipfile
from pathlib import Path

import pandas as pd
import requests

ROOT = Path(__file__).resolve().parents[2]
DB_PATH = ROOT / "data" / "cyclicality.db"

# agglvl_code values to retain (private sector, national)
AGGLVL_KEEP = {11, 14, 15, 16, 17, 18}

AGGLVL_TO_DIGITS = {
    11: 0,   # all-private aggregate
    14: 2,
    15: 3,
    16: 4,
    17: 5,
    18: 6,
}

# First year where the per-area flat-file API works
FLATFILE_API_FROM = 2015


def create_table(cur: sqlite3.Cursor) -> None:
    cur.executescript("""
        CREATE TABLE IF NOT EXISTS bls_qcew_wages (
            id              INTEGER PRIMARY KEY AUTOINCREMENT,
            year            INTEGER NOT NULL,
            naics_code      TEXT    NOT NULL,
            naics_digits    INTEGER NOT NULL,
            agglvl_code     INTEGER NOT NULL,
            avg_annual_pay  REAL,
            disclosure_code TEXT    NOT NULL DEFAULT '',
            ingested_at     TEXT    NOT NULL DEFAULT (datetime('now'))
        );

        CREATE UNIQUE INDEX IF NOT EXISTS idx_qcew_year_naics_lvl
            ON bls_qcew_wages (year, naics_code, agglvl_code);

        CREATE INDEX IF NOT EXISTS idx_qcew_year_naics
            ON bls_qcew_wages (year, naics_code);
    """)


def _parse_df(df: pd.DataFrame) -> pd.DataFrame:
    """Normalise a raw QCEW DataFrame to the columns we need."""
    df.columns = [c.strip().strip('"') for c in df.columns]
    df["own_code"] = pd.to_numeric(df["own_code"], errors="coerce")
    df["agglvl_code"] = pd.to_numeric(df["agglvl_code"], errors="coerce")
    df["avg_annual_pay"] = pd.to_numeric(df["avg_annual_pay"], errors="coerce")
    mask = (df["own_code"] == 5) & (df["agglvl_code"].isin(AGGLVL_KEEP))
    df = df.loc[mask, ["industry_code", "agglvl_code", "avg_annual_pay",
                        "disclosure_code"]].copy()
    df["industry_code"] = df["industry_code"].astype(str).str.strip().str.strip('"')
    df["disclosure_code"] = (
        df["disclosure_code"].fillna("").astype(str).str.strip().str.strip('"')
    )
    return df


def fetch_year_flatfile(year: int, session: requests.Session) -> pd.DataFrame:
    """Download via per-area flat-file API (2015+)."""
    url = f"https://data.bls.gov/cew/data/api/{year}/a/area/US000.csv"
    resp = session.get(url, timeout=60)
    resp.raise_for_status()
    df = pd.read_csv(io.StringIO(resp.text), dtype=str)
    return _parse_df(df)


def fetch_year_zip(year: int, session: requests.Session) -> pd.DataFrame:
    """Download via annual singlefile zip (2001–2014)."""
    url = f"https://data.bls.gov/cew/data/files/{year}/csv/{year}_annual_singlefile.zip"
    resp = session.get(url, timeout=300)
    resp.raise_for_status()
    # The zip contains one CSV named e.g. "2013.annual.singlefile.csv"
    with zipfile.ZipFile(io.BytesIO(resp.content)) as zf:
        csv_name = zf.namelist()[0]
        with zf.open(csv_name) as f:
            # Read only national rows (area_fips == US000) to save memory
            chunks = []
            for chunk in pd.read_csv(f, dtype=str, chunksize=50_000):
                chunk.columns = [c.strip().strip('"') for c in chunk.columns]
                national = chunk[chunk["area_fips"].str.strip().str.strip('"') == "US000"]
                if not national.empty:
                    chunks.append(national)
            df = pd.concat(chunks, ignore_index=True) if chunks else pd.DataFrame()
    return _parse_df(df)


def ingest_year(
    cur: sqlite3.Cursor,
    year: int,
    df: pd.DataFrame,
    dry_run: bool,
) -> int:
    now = dt.datetime.now().isoformat()
    records: list[tuple] = []
    for _, row in df.iterrows():
        agglvl = int(row["agglvl_code"])
        naics_digits = AGGLVL_TO_DIGITS.get(agglvl, 0)
        pay = None if pd.isna(row["avg_annual_pay"]) else float(row["avg_annual_pay"])
        records.append((
            year,
            str(row["industry_code"]),
            naics_digits,
            agglvl,
            pay,
            str(row["disclosure_code"]),
            now,
        ))
    if not dry_run and records:
        cur.executemany(
            """
            INSERT OR REPLACE INTO bls_qcew_wages
                (year, naics_code, naics_digits, agglvl_code, avg_annual_pay,
                 disclosure_code, ingested_at)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            records,
        )
    return len(records)


def main() -> None:
    parser = argparse.ArgumentParser(description="Fetch BLS QCEW wages into cyclicality.db")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--resume", action="store_true",
                        help="Skip years already present in the table")
    parser.add_argument("--start-year", type=int, default=2001)
    parser.add_argument("--end-year", type=int, default=2023)
    args = parser.parse_args()

    years = list(range(args.start_year, args.end_year + 1))
    n_zip = sum(1 for y in years if y < FLATFILE_API_FROM)
    n_api = sum(1 for y in years if y >= FLATFILE_API_FROM)
    print(
        f"Fetching QCEW for {len(years)} years "
        f"({n_zip} via zip, {n_api} via flat-file API)"
    )

    session = requests.Session()
    session.headers.update({
        "User-Agent": (
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
            "AppleWebKit/537.36 (KHTML, like Gecko) "
            "Chrome/122.0.0.0 Safari/537.36"
        )
    })

    conn = sqlite3.connect(DB_PATH)
    try:
        cur = conn.cursor()
        create_table(cur)

        if not args.dry_run and not args.resume:
            cur.execute(
                "DELETE FROM bls_qcew_wages WHERE year BETWEEN ? AND ?",
                (args.start_year, args.end_year),
            )
            conn.commit()
            print(f"Cleared existing rows for {args.start_year}–{args.end_year}")

        # Find already-ingested years when resuming
        done_years: set[int] = set()
        if args.resume and not args.dry_run:
            rows_done = cur.execute(
                "SELECT DISTINCT year FROM bls_qcew_wages WHERE year BETWEEN ? AND ?",
                (args.start_year, args.end_year),
            ).fetchall()
            done_years = {r[0] for r in rows_done}
            if done_years:
                print(f"Resuming — skipping already-ingested years: {sorted(done_years)}")

        total = 0
        for i, year in enumerate(years):
            if year in done_years:
                print(f"  {year}: already ingested, skipping")
                continue
            method = "api" if year >= FLATFILE_API_FROM else "zip"
            try:
                if method == "api":
                    df = fetch_year_flatfile(year, session)
                else:
                    print(f"  {year}: downloading zip (~50-80 MB)…", end="", flush=True)
                    df = fetch_year_zip(year, session)
                n = ingest_year(cur, year, df, args.dry_run)
                total += n
                clean = (df["disclosure_code"] == "").sum()
                supp = (df["disclosure_code"] != "").sum()
                print(f"  {year} [{method}]: {n} rows ({clean} clean, {supp} suppressed)")
            except requests.HTTPError as e:
                print(f"  {year}: HTTP {e.response.status_code} — {e}")
            except Exception as e:
                print(f"  {year}: Error — {e}")
                raise
            # Commit after each year so partial progress is preserved
            if not args.dry_run:
                conn.commit()
            # Polite delay
            if i < len(years) - 1:
                time.sleep(0.5)

        if not args.dry_run:
            print(f"\nDone. Total rows ingested: {total:,}")
        else:
            print(f"\nDry run. Would ingest {total:,} rows.")

    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()

    if not args.dry_run:
        conn2 = sqlite3.connect(DB_PATH)
        rows = conn2.execute("""
            SELECT naics_digits, COUNT(*) as n, MIN(year), MAX(year)
            FROM bls_qcew_wages
            WHERE disclosure_code = ''
            GROUP BY naics_digits ORDER BY naics_digits
        """).fetchall()
        conn2.close()
        print("\nClean rows by NAICS digit level:")
        for r in rows:
            label = "all-private" if r[0] == 0 else f"{r[0]}-digit"
            print(f"  {r[1]:7,} rows  {label:<12}  years {r[2]}–{r[3]}")


if __name__ == "__main__":
    main()
