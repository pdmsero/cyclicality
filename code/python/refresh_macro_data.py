#!/usr/bin/env python3
"""
Refresh BEA/NIPA and FRED macro data to extend year coverage.

Sources refreshed
-----------------
1. GDPData          1929–2024   BEA clean CSVs (already local, no API needed)
2. BEA_ValueAdded   1997–2023   BEA_All_Ind.csv (already local, no API needed)
3. BondYields       1954–2024   FRED API  (requires FRED_API_KEY env var)
4. SocialSecWages   1951–2023   SSA website scrape (no key needed)

After running this script, re-run convert_to_sqlite.py to reload the
updated tables into cyclicality.db, then re-run the pipeline stages.

Usage
-----
    python code/python/refresh_macro_data.py              # update all sources
    python code/python/refresh_macro_data.py --dry-run    # print summary only
    python code/python/refresh_macro_data.py --skip-fred  # skip bond yields

FRED API key
------------
    Register free at: https://fred.stlouisfed.org/docs/api/api_key.html
    Then: export FRED_API_KEY="your_key_here"
"""

from __future__ import annotations

import argparse
import csv
import os
import sys
import warnings
from pathlib import Path

import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[2]
DATA = ROOT / "data"
BEA_DIR = DATA / "industry" / "bea"
PROC_DIR = DATA / "processed"

warnings.filterwarnings("ignore", category=pd.errors.PerformanceWarning)


# ---------------------------------------------------------------------------
# BEA_All_Ind.csv parser
# ---------------------------------------------------------------------------

# Maps NAICS code → list of GO line numbers to sum from BEA_All_Ind.csv.
# Validated against existing BEA_ValueAdded_RawFile.dta (1997 overlap).
# Line offset convention: each industry block = GO(L), VA(L+1), COMP(L+2),
#   TAX(L+3), SURPLUS(L+4), INPUTS(L+5), ENER(L+6), MAT(L+7), SERVICE(L+8).
BEA_INDUSTRY_MAP: dict[str, list[int]] = {
    "111.112":         [28],
    "113.114.115":     [37],
    "211":             [55],
    "212":             [64],
    "213":             [73],
    "221":             [82],
    "233":             [91],
    "311.312":         [226],
    "313.314":         [235],
    "315.316":         [244],
    "321":             [118],
    "322":             [253],
    "323":             [262],
    "324":             [271],
    "325":             [280],
    "326":             [289],
    "327":             [127],
    "331":             [136],
    "332":             [145],
    "333":             [154],
    "334":             [163],
    "335":             [172],
    "336":             [181, 190],   # motor vehicles + other transportation
    "337":             [199],
    "339":             [208],
    "441":             [316],
    "445":             [325],
    "452":             [334],
    "481":             [361],
    "482":             [370],
    "483":             [379],
    "484":             [388],
    "485":             [397],
    "486":             [406],
    "487.488.492":     [415],
    "493":             [424],
    "511":             [442],
    "512":             [451],
    "513":             [460],
    "514":             [469],
    "521.522":         [496],         # Federal Reserve banks + credit intermediation
    "523":             [505],
    "524":             [514],
    "525":             [523],
    "531":             [541],
    "532.533":         [568],
    "541":             [586],
    "561":             [640],
    "562":             [649],
    "611":             [667],
    "621":             [685],
    "622":             [694],
    "623":             [703],
    "624":             [712],
    "711.712":         [739],         # performing arts, spectator sports, museums
    "713":             [748],         # amusements, gambling, recreation
    "721":             [766],
    "722":             [775],
    "811.812.813.814": [784],
}

# Sub-row offsets within each 9-row industry block
SUBROW = {
    "GO":      0,
    "VA":      1,
    "COMP":    2,
    "TAX":     3,
    "SURPLUS": 4,
    "INPUTS":  5,
    "ENER":    6,
    "MAT":     7,
    "SERVICE": 8,
}


def parse_bea_all_ind(csv_path: Path) -> dict[int, dict[int, float | None]]:
    """Return {line_no: {year: value}} parsed from BEA_All_Ind.csv."""
    with open(csv_path, newline="") as f:
        reader = csv.reader(f)
        all_rows = list(reader)

    years_map: dict[int, int] = {}
    for row in all_rows:
        if len(row) > 2 and "1997" in row:
            for j, cell in enumerate(row):
                c = cell.strip()
                if c.isdigit() and 1990 <= int(c) <= 2030:
                    years_map[int(c)] = j
            break

    line_data: dict[int, dict[int, float | None]] = {}
    for row in all_rows:
        if len(row) > 1 and row[0].strip().isdigit():
            ln = int(row[0].strip())
            vals: dict[int, float | None] = {}
            for yr, idx in years_map.items():
                if idx < len(row):
                    try:
                        vals[yr] = float(row[idx])
                    except (ValueError, TypeError):
                        vals[yr] = None
            line_data[ln] = vals
    return line_data, sorted(years_map.keys())


def extract_industry_series(
    line_data: dict[int, dict[int, float | None]],
    years: list[int],
    go_lines: list[int],
    field_offset: int,
) -> dict[int, float | None]:
    """Sum field across GO lines (offset applied) for each year."""
    result: dict[int, float | None] = {}
    for yr in years:
        total = 0.0
        any_non_null = False
        for gl in go_lines:
            row_line = gl + field_offset
            v = line_data.get(row_line, {}).get(yr)
            if v is not None:
                total += v
                any_non_null = True
        result[yr] = total if any_non_null else None
    return result


# ---------------------------------------------------------------------------
# 1. GDPData rebuild from BEA clean CSVs
# ---------------------------------------------------------------------------

# Maps raw file column name → clean CSV column name
GDP_LEVEL_MAP: dict[str, str] = {
    "GDP":                  "Gross domestic product",
    "Consumption":          "Personal consumption expenditures",
    "Goods":                "Goods",
    "Durables":             "Durable goods",
    "Services":             "Services",
    "TotalInvestment":      "Gross private domestic investment",
    "FixedInvestment":      "Fixed investment",
    "NonResidential":       "Nonresidential",
    "Structures":           "Structures",
    "Equipment":            "Equipment",
    "IPR":                  "Intellectual property products",
    "Residential":          "Residential",
    "ChangeInventories":    "Change in private inventories",
    "NetExports":           "Net exports of goods and services",
    "Exports":              "Exports",
    "Imports":              "Imports",
    "Government":           "Government consumption expenditures and gross investment",
}

GDP_PRICE_MAP: dict[str, str] = {
    "P_GDP":              "Gross domestic product",
    "P_NonResidential":   "Nonresidential",
    "P_IPR":              "Intellectual property products",
    "P_Residential":      "Residential",
    "P_Consumption":      "Personal consumption expenditures",
    "P_Government":       "Government consumption expenditures and gross investment",
}

# Base year for price normalisation (so P_GDP = 1.0 in BASE_YEAR)
GDP_PRICE_BASE_YEAR = 2009


def rebuild_gdp_data(dry_run: bool = False) -> pd.DataFrame:
    """Rebuild GDPData from BEA_GDP_Detail_clean.csv and BEA_GDP_Prices_Detail_clean.csv."""
    level_path  = BEA_DIR / "BEA_GDP_Detail_clean.csv"
    prices_path = BEA_DIR / "BEA_GDP_Prices_Detail_clean.csv"

    lvl = pd.read_csv(level_path)
    prc = pd.read_csv(prices_path)

    lvl["year"] = lvl["year"].astype(int)
    prc["year"] = prc["year"].astype(int)

    df = pd.DataFrame({"year": lvl["year"]})

    # Level variables
    for out_col, src_col in GDP_LEVEL_MAP.items():
        if src_col in lvl.columns:
            df[out_col] = pd.to_numeric(lvl[src_col], errors="coerce")

    # Price variables — normalise to BASE_YEAR = 1.0
    for out_col, src_col in GDP_PRICE_MAP.items():
        if src_col in prc.columns:
            series = pd.to_numeric(prc[src_col], errors="coerce")
            base_val = series[prc["year"] == GDP_PRICE_BASE_YEAR].values
            if len(base_val) > 0 and not np.isnan(base_val[0]):
                df[out_col] = series / base_val[0]
            else:
                df[out_col] = series

    # d_gdp = log change in real GDP
    if "GDP" in df.columns and "P_GDP" in df.columns:
        real_gdp = df["GDP"] / df["P_GDP"]
        df["d_gdp"] = np.log(real_gdp) - np.log(real_gdp.shift(1))

    df = df.sort_values("year").reset_index(drop=True)

    # Validate overlap with existing data
    existing_path = PROC_DIR / "GDPData_RawFile.dta"
    if existing_path.exists():
        existing = pd.read_stata(existing_path)
        overlap = df[df["year"].isin(existing["year"])]
        ex_overlap = existing[existing["year"].isin(df["year"])].sort_values("year")
        ol = overlap.sort_values("year")
        for col in ["GDP", "P_GDP"]:
            if col in ol.columns and col in ex_overlap.columns:
                corr = ol[col].corr(ex_overlap[col])
                max_pct_diff = ((ol[col] - ex_overlap[col].values).abs() /
                                ex_overlap[col].abs().values).max() * 100
                print(f"    GDP overlap check {col}: r={corr:.4f}, max_pct_diff={max_pct_diff:.1f}%")

    print(f"  GDPData: {int(df.year.min())}–{int(df.year.max())} ({len(df)} rows)")
    return df


# ---------------------------------------------------------------------------
# 2. BEA ValueAdded rebuild from BEA_All_Ind.csv
# ---------------------------------------------------------------------------

def rebuild_bea_value_added(dry_run: bool = False) -> pd.DataFrame:
    """Rebuild BEA_ValueAdded_RawFile from BEA_All_Ind.csv and BEA_All_Ind_Prices.csv."""
    ind_path = BEA_DIR / "BEA_All_Ind.csv"
    prc_path = BEA_DIR / "BEA_All_Ind_Prices.csv"

    print("  Parsing BEA_All_Ind.csv ...")
    line_data, years = parse_bea_all_ind(ind_path)
    print(f"  Parsed {len(line_data)} lines, years {years[0]}–{years[-1]}")

    print("  Parsing BEA_All_Ind_Prices.csv ...")
    price_data, price_years = parse_bea_all_ind(prc_path)

    # All-industry GO (line 1) for *_GDP normalisation
    all_ind_go = {yr: line_data.get(1, {}).get(yr) for yr in years}

    records = []
    for naics, go_lines in sorted(BEA_INDUSTRY_MAP.items()):
        for yr in years:
            row: dict = {"NAICS": naics, "year": yr}
            # Level variables
            for field, offset in SUBROW.items():
                vals = [
                    line_data.get(gl + offset, {}).get(yr)
                    for gl in go_lines
                ]
                vals_clean = [v for v in vals if v is not None]
                row[field] = sum(vals_clean) if vals_clean else None

            # GDP-relative variables
            total_go = all_ind_go.get(yr)
            for field in SUBROW:
                row[f"{field}_GDP"] = (
                    row[field] / total_go
                    if row[field] is not None and total_go
                    else None
                )

            # Price variables from BEA_All_Ind_Prices.csv
            for price_field, prefix in [("GO", "PGO"), ("VA", "PVA"),
                                         ("INPUTS", "PINPUTS"),
                                         ("ENER", "PENER"),
                                         ("MAT", "PMAT"),
                                         ("SERVICE", "PSERVICE")]:
                offset = SUBROW[price_field]
                p_vals = [
                    price_data.get(gl + offset, {}).get(yr)
                    for gl in go_lines
                ]
                p_vals_clean = [v for v in p_vals if v is not None]
                # For combined industries, use first available price
                row[prefix] = p_vals_clean[0] if p_vals_clean else None

            # GDP-relative prices
            for price_field, prefix in [("GO", "PGO"), ("VA", "PVA"),
                                         ("INPUTS", "PINPUTS"),
                                         ("ENER", "PENER"),
                                         ("MAT", "PMAT"),
                                         ("SERVICE", "PSERVICE")]:
                total_p = price_data.get(1 + SUBROW[price_field], {}).get(yr)
                row[f"{prefix}_GDP"] = (
                    row[prefix] / total_p
                    if row.get(prefix) is not None and total_p
                    else None
                )

            # Instrument: leave NULL for extended years — reconstructed separately
            row["Instrument"] = None

            records.append(row)

    df = pd.DataFrame(records)

    # Add code column (integer identifier matching existing data)
    existing_path = BEA_DIR / "BEA_ValueAdded_RawFile.dta"
    if existing_path.exists():
        existing = pd.read_stata(existing_path)
        naics_to_code = (
            existing[["NAICS", "code"]].drop_duplicates()
            .set_index("NAICS")["code"].to_dict()
        )
        df["code"] = df["NAICS"].map(naics_to_code)
    else:
        df["code"] = pd.factorize(df["NAICS"])[0] + 1

    # Validate overlap
    if existing_path.exists():
        existing = pd.read_stata(existing_path)
        overlap_years = set(df["year"]).intersection(set(existing["year"]))
        overlap = df[df["year"].isin(overlap_years)].copy()
        ex_ov = existing[existing["year"].isin(overlap_years)].copy()
        # Check GO correlation
        ov_merged = overlap.merge(
            ex_ov[["NAICS", "year", "GO"]].rename(columns={"GO": "GO_ex"}),
            on=["NAICS", "year"], how="inner"
        )
        if len(ov_merged) > 0:
            corr = ov_merged["GO"].corr(ov_merged["GO_ex"])
            print(f"  BEA_ValueAdded overlap GO correlation: r={corr:.4f} (n={len(ov_merged)})")

    col_order = [
        "NAICS", "code", "year",
        "GO", "VA", "COMP", "TAX", "SURPLUS", "INPUTS", "ENER", "MAT", "SERVICE",
        "GO_GDP", "VA_GDP", "COMP_GDP", "TAX_GDP", "SURPLUS_GDP",
        "INPUTS_GDP", "ENER_GDP", "MAT_GDP", "SERVICE_GDP",
        "PGO", "PVA", "PINPUTS", "PENER", "PMAT", "PSERVICE",
        "PGO_GDP", "PVA_GDP", "PINPUTS_GDP", "PENER_GDP", "PMAT_GDP", "PSERVICE_GDP",
        "Instrument",
    ]
    df = df[[c for c in col_order if c in df.columns]]
    df = df.sort_values(["NAICS", "year"]).reset_index(drop=True)

    print(f"  BEA_ValueAdded: {int(df.year.min())}–{int(df.year.max())} "
          f"({len(df)} rows, {df.NAICS.nunique()} industries)")
    return df


# ---------------------------------------------------------------------------
# 3. Bond yields from FRED
# ---------------------------------------------------------------------------

FRED_SERIES = {
    "gov_b": "GS10",   # 10-year treasury constant maturity
    "aaa":   "AAA",    # Moody's Aaa seasoned corporate bond
    "baa":   "BAA",    # Moody's Baa seasoned corporate bond
}


def rebuild_bond_yields(dry_run: bool = False) -> pd.DataFrame | None:
    """Fetch annual bond yields from FRED."""
    api_key = os.environ.get("FRED_API_KEY", "")
    if not api_key:
        print("  SKIP BondYields: FRED_API_KEY not set.")
        print("  → Get a free key at https://fred.stlouisfed.org/docs/api/api_key.html")
        print("  → Then: export FRED_API_KEY='your_key_here'")
        return None

    try:
        from fredapi import Fred  # type: ignore
    except ImportError:
        print("  SKIP BondYields: fredapi not installed.")
        print("  → pip install fredapi --break-system-packages")
        return None

    fred = Fred(api_key=api_key)
    series: dict[str, pd.Series] = {}
    for col, fred_id in FRED_SERIES.items():
        raw = fred.get_series(fred_id, observation_start="1950-01-01")
        # Convert to annual averages
        annual = raw.resample("YE").mean()
        annual.index = annual.index.year
        series[col] = annual
        print(f"    FRED {fred_id}: {int(annual.index.min())}–{int(annual.index.max())}")

    df = pd.DataFrame(series)
    df.index.name = "year"
    df = df.reset_index()
    df = df.dropna(subset=["gov_b", "aaa", "baa"], how="all")

    # Derived spread variables
    df["aaa_g"]   = df["aaa"]   - df["gov_b"]
    df["baa_g"]   = df["baa"]   - df["gov_b"]
    df["baa_aaa"] = df["baa"]   - df["aaa"]

    # Log changes and growth rates
    df = df.sort_values("year").reset_index(drop=True)
    df["d_y"] = np.log(df["gov_b"]) - np.log(df["gov_b"].shift(1))
    df["ag"]  = df["aaa_g"]   - df["aaa_g"].shift(1)
    df["bg"]  = df["baa_g"]   - df["baa_g"].shift(1)
    df["ba"]  = df["baa_aaa"] - df["baa_aaa"].shift(1)

    print(f"  BondYields: {int(df.year.min())}–{int(df.year.max())} ({len(df)} rows)")
    return df


# ---------------------------------------------------------------------------
# 4. SSA Average Wage Index from SSA website
# ---------------------------------------------------------------------------

SSA_AWI_URL = "https://www.ssa.gov/oact/cola/AWI.html"


def rebuild_ssa_wages(dry_run: bool = False) -> pd.DataFrame | None:
    """Scrape SSA average wage index from SSA website."""
    try:
        from bs4 import BeautifulSoup
        import urllib.request
    except ImportError:
        print("  SKIP SocialSecWages: beautifulsoup4 not installed.")
        print("  → pip install beautifulsoup4 --break-system-packages")
        return None

    print(f"  Fetching SSA AWI from {SSA_AWI_URL} ...")
    try:
        req = urllib.request.Request(
            SSA_AWI_URL,
            headers={
                "User-Agent": (
                    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                    "AppleWebKit/537.36 (KHTML, like Gecko) "
                    "Chrome/120.0.0.0 Safari/537.36"
                ),
                "Accept": "text/html,application/xhtml+xml",
                "Accept-Language": "en-US,en;q=0.9",
            }
        )
        with urllib.request.urlopen(req, timeout=30) as resp:
            html = resp.read()
    except Exception as e:
        print(f"  SKIP SocialSecWages: fetch failed ({e})")
        return None

    soup = BeautifulSoup(html, "html.parser")
    # SSA splits the table into three sub-tables; parse all and deduplicate
    tables = soup.find_all("table")
    records = []
    for tbl in tables:
        rows = tbl.find_all("tr")
        for row in rows:
            cells = [td.get_text(strip=True).replace(",", "") for td in row.find_all("td")]
            if len(cells) >= 2:
                try:
                    year = int(cells[0])
                    awi  = float(cells[1])
                    if 1950 <= year <= 2030:
                        records.append({"year": year, "awi": awi, "averagewage": awi})
                except (ValueError, IndexError):
                    continue

    if not records:
        print("  SKIP SocialSecWages: no data parsed from SSA page.")
        return None

    df = pd.DataFrame(records).drop_duplicates("year").sort_values("year")
    print(f"  SocialSecWages: {int(df.year.min())}–{int(df.year.max())} ({len(df)} rows)")
    return df


# ---------------------------------------------------------------------------
# Save helpers
# ---------------------------------------------------------------------------

def save_dta(df: pd.DataFrame, path: Path, label: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    df = df.copy()
    # Convert year col to int if needed
    if "year" in df.columns:
        df["year"] = df["year"].astype(int)
    # Replace all-null object columns with float NaN (pandas stata writer rejects them)
    for col in df.select_dtypes(include="object").columns:
        if df[col].isna().all():
            df[col] = np.nan
    df.to_stata(path, write_index=False, version=117)
    print(f"  Saved {label}: {path.relative_to(ROOT)} ({len(df)} rows)")


def save_companion_processed(
    raw: pd.DataFrame,
    proc_path: Path,
    keep_cols: list[str],
    label: str
) -> None:
    """Save a processed (subset) .dta alongside the raw file."""
    available = [c for c in keep_cols if c in raw.columns]
    proc = raw[available].copy()
    save_dta(proc, proc_path, label + " (processed)")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(description="Refresh BEA/NIPA and FRED macro data")
    parser.add_argument("--dry-run",    action="store_true", help="Print summary only, no writes")
    parser.add_argument("--skip-fred",  action="store_true", help="Skip FRED bond yield fetch")
    parser.add_argument("--skip-bea",   action="store_true", help="Skip BEA value-added rebuild")
    parser.add_argument("--skip-wages", action="store_true", help="Skip SSA wage scrape")
    args = parser.parse_args()

    print(f"Mode: {'DRY RUN' if args.dry_run else 'WRITE'}\n")

    # ---- 1. GDPData ----
    print("[1] Rebuilding GDPData from BEA clean CSVs ...")
    gdp = rebuild_gdp_data(dry_run=args.dry_run)
    if not args.dry_run:
        save_dta(gdp, PROC_DIR / "GDPData_RawFile.dta", "GDPData_RawFile")
        save_companion_processed(
            gdp,
            PROC_DIR / "GDPData.dta",
            ["year", "GDP", "P_GDP", "P_NonResidential", "P_IPR", "d_gdp"],
            "GDPData"
        )

    # ---- 2. BEA Value Added ----
    if not args.skip_bea:
        print("\n[2] Rebuilding BEA_ValueAdded from BEA_All_Ind.csv ...")
        bea_va = rebuild_bea_value_added(dry_run=args.dry_run)
        if not args.dry_run:
            save_dta(bea_va, BEA_DIR / "BEA_ValueAdded_RawFile.dta", "BEA_ValueAdded_RawFile")
            save_companion_processed(
                bea_va,
                BEA_DIR / "BEA_ValueAdded.dta",
                ["NAICS", "code", "year", "GO", "VA", "PGO", "PVA",
                 "d_go", "d_va_ind", "d_instrument"],
                "BEA_ValueAdded"
            )

    # ---- 3. Bond Yields ----
    if not args.skip_fred:
        print("\n[3] Fetching bond yields from FRED ...")
        bonds = rebuild_bond_yields(dry_run=args.dry_run)
        if bonds is not None and not args.dry_run:
            save_dta(bonds, PROC_DIR / "BondYields.dta", "BondYields")

    # ---- 4. SSA Wages ----
    if not args.skip_wages:
        print("\n[4] Fetching SSA wages from SSA website ...")
        wages = rebuild_ssa_wages(dry_run=args.dry_run)
        if wages is not None and not args.dry_run:
            save_dta(wages, PROC_DIR / "SocialSecurityWageData.dta", "SocialSecurityWageData")

    # ---- Summary ----
    print("\n=== Next steps ===")
    print("1. Run convert_to_sqlite.py to reload updated tables into cyclicality.db")
    print("2. Re-run pipeline stages: build_alldata_transform_stage1..4.py")
    print("3. Re-run parity checks to confirm extended coverage is clean")


if __name__ == "__main__":
    main()
