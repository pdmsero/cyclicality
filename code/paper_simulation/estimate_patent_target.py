#!/usr/bin/env python3
"""Estimate the reduced-form annual innovation-event target from patent data.

The model's latent quality innovations are not directly observed. This uses a
matched patent event as an empirical proxy: at least one USPTO patent assigned
to a Compustat firm, by ultimate owner at filing, with application year t.
The target sample is firm-years in the paper's Compustat panel with positive
R&D and manufacturing SIC codes (2000--3999), 1976--2014.

Patent CSVs are downloaded into generated/patent_data/ on first use. The source
revision is pinned for reproducibility; raw downloads stay out of version control.
"""

from __future__ import annotations

import argparse
import csv
import sqlite3
import urllib.request
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SOURCE_REVISION = "a6f39b77e3a1c81348c2075a8c1fba501f536332"
SOURCE_URL = (
    "https://raw.githubusercontent.com/arnauddyevre/compustat-patents/"
    f"{SOURCE_REVISION}/data/staticTranche{{}}.csv"
)


def patent_file(directory: Path, tranche: int) -> Path:
    path = directory / f"staticTranche{tranche}.csv"
    if path.exists() and path.stat().st_size > 1_000_000:
        return path
    directory.mkdir(parents=True, exist_ok=True)
    request = urllib.request.Request(
        SOURCE_URL.format(tranche), headers={"User-Agent": "cyclicality-calibration/1.0"}
    )
    with urllib.request.urlopen(request, timeout=180) as response, path.open("wb") as out:
        while chunk := response.read(1024 * 1024):
            out.write(chunk)
    return path


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--database", type=Path, default=ROOT.parent.parent / "data/cyclicality.db")
    parser.add_argument("--patent-dir", type=Path, default=ROOT / "generated/patent_data")
    args = parser.parse_args()

    with sqlite3.connect(args.database) as con:
        rows = con.execute(
            """SELECT gvkey, CAST(year AS INTEGER), sic
               FROM processed_alldata_stage4
               WHERE year BETWEEN 1976 AND 2014 AND r_xrd > 0 AND gvkey IS NOT NULL"""
        ).fetchall()
    sample = {
        (str(gvkey).zfill(6), year)
        for gvkey, year, sic in rows
        if sic is not None and 2000 <= int(sic) < 4000
    }
    events: set[tuple[str, int]] = set()
    for tranche in range(1, 9):
        path = patent_file(args.patent_dir, tranche)
        with path.open(newline="", encoding="utf-8") as csvfile:
            for row in csv.DictReader(csvfile):
                try:
                    year = int(row["appYear"])
                except (KeyError, TypeError, ValueError):
                    continue
                gvkey = row.get("gvkeyUO", "")
                key = (gvkey.zfill(6), year)
                if 1976 <= year <= 2014 and gvkey and key in sample:
                    events.add(key)

    hit = len(sample & events)
    p_hat = hit / len(sample)
    print(f"Manufacturing R&D-positive firm-years: {len(sample):,}")
    print(f"Firm-years with >=1 matched patent event: {hit:,}")
    print(f"Reduced-form event-rate target: {p_hat:.4%} (rounded calibration: 0.45)")
    for start, end in ((1976, 1989), (1990, 1999), (2000, 2014)):
        period = {key for key in sample if start <= key[1] <= end}
        period_hit = len(period & events)
        print(f"{start}-{end}: {period_hit:,}/{len(period):,} = {period_hit/len(period):.2%}")
    print(f"Patent-link source revision: {SOURCE_REVISION}")
    print("Proxy only: patent events do not map one-for-one to latent quality steps.")


if __name__ == "__main__":
    main()
