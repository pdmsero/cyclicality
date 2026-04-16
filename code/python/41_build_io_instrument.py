#!/usr/bin/env python3
"""
41_build_io_instrument.py

Extends the Bartik shift-share IO instrument (d_instrument in
processed_bea_value_added) to cover 2014–2024, using BEA API IO tables
(Table 59, Total Requirements — Leontief inverse) ingested by script 04.

Construction
------------
The legacy instrument was constructed in BEA.do as:

    gen d_instrument = ln(Instrument) - ln(l.Instrument)

where Instrument_i,t = IO-exposure-weighted demand index for BEA industry i.

This script replicates that logic for the post-2013 period:

  1. Fetch annual gross output (GO) by NAICS summary industry from the
     BEA GDPbyIndustry API (TableName=GO, current dollars) for 2013–2024.
     Year 2013 is included to anchor the first log-difference.

  2. Map the 73 BEA API NAICS codes to the 66 BEA integer codes used in
     processed_bea_value_added (many-to-one where API codes aggregate legacy).

  3. For each benchmark year's IO table (Table 59, Leontief inverse L_ij),
     interpolate weights linearly between benchmarks.

  4. Compute:
         Instrument_i,t  =  sum_j ( L_ij,t0 * GO_j,t )
         d_instrument_i,t =  ln(Instrument_i,t) - ln(Instrument_i,t-1)

  5. Write results to processed_bea_io_instrument_api (new table) and
     patch processed_bea_value_added with d_instrument for years 2014–2024.

Gross output source
-------------------
BEA GDPbyIndustry dataset, Table GO (Annual gross output, current dollars).
URL: https://apps.bea.gov/api/data?UserID=KEY&method=GetData
     &datasetname=GDPbyIndustry&TableName=GO&Frequency=A
     &Year=ALL&Industry=ALL&ResultFormat=JSON

Requires BEA_API_KEY in .env or environment.

IO weight interpolation
-----------------------
The API tables in instrument_io_tables_api cover every year 2014–2024.
For each year we use the same-year's Table 59 weights (no interpolation needed).

NAICS API code → BEA c code crosswalk
--------------------------------------
Derived from instrument_bea (legacy dot-notation → c) and BEA documentation.
Government codes (GFE, GFGD, GFGN, GSLE, GSLG, HS, ORE, Other, Used) are
excluded — they do not appear in processed_bea_value_added.
"""
from __future__ import annotations

import json
import os
import sqlite3
import warnings
from pathlib import Path

import numpy as np
import pandas as pd
import requests
from dotenv import load_dotenv

ROOT = Path(__file__).resolve().parents[2]
DB_PATH = ROOT / "data" / "cyclicality.db"
OUT_TABLE = "processed_bea_io_instrument_api"

BEA_API_BASE = "https://apps.bea.gov/api/data"


# ---------------------------------------------------------------------------
# NAICS API code → BEA c code (integer in processed_bea_value_added)
# ---------------------------------------------------------------------------
# Many-to-one: some API summary codes aggregate multiple BEA legacy codes.
# Where an API code spans multiple legacy c-codes, the first (primary) is used.
# Codes with no private-industry equivalent (government, housing, etc.) are None.

API_TO_BEA_C: dict[str, int | None] = {
    "111CA": 1,   # Farms (NAICS 111+112 → legacy '111.112')
    "113FF": 2,   # Forestry, fishing, agriculture support (113+114+115)
    "211":   3,   # Oil and gas extraction
    "212":   4,   # Mining, except oil and gas
    "213":   5,   # Mining support activities
    "22":    6,   # Utilities
    "23":    7,   # Construction
    "311FT": 19,  # Food, beverage, and tobacco products (311+312 → '311' c=19)
    "313TT": 20,  # Textile mills and textile product mills (313+314 → '313' c=20)
    "315AL": 21,  # Apparel and leather and allied products (315+316 → '315' c=21)
    "321":   8,   # Wood products
    "322":   22,  # Paper products
    "323":   23,  # Printing and related support activities
    "324":   24,  # Petroleum and coal products
    "325":   25,  # Chemical products
    "326":   26,  # Plastics and rubber products
    "327":   9,   # Nonmetallic mineral products
    "331":   10,  # Primary metals
    "332":   11,  # Fabricated metal products
    "333":   12,  # Machinery
    "334":   13,  # Computer and electronic products
    "335":   14,  # Electrical equipment, appliances, and components
    "3361MV": 15, # Motor vehicles, bodies and trailers, and parts (336.1)
    "3364OT": 16, # Other transportation equipment (336.4)
    "337":   17,  # Furniture and related products
    "339":   18,  # Miscellaneous manufacturing
    "42":    27,  # Wholesale trade
    "441":   28,  # Motor vehicle and parts dealers
    "445":   29,  # Food and beverage stores
    "452":   30,  # General merchandise stores
    "4A0":   31,  # Other retail (442-4, 446-8, 451, 453-4)
    "481":   32,  # Air transportation
    "482":   33,  # Rail transportation
    "483":   34,  # Water transportation
    "484":   35,  # Truck transportation
    "485":   36,  # Transit and ground passenger transportation
    "486":   37,  # Pipeline transportation
    "487OS": 38,  # Other transportation and support activities (487+488+492)
    "493":   39,  # Warehousing and storage
    "511":   40,  # Publishing industries (except internet)
    "512":   41,  # Motion picture and sound recording industries
    "513":   42,  # Broadcasting and telecommunications
    "514":   43,  # Data processing, internet publishing, and other
    "521CI": 44,  # Federal Reserve banks, credit intermediation (521+522)
    "523":   45,  # Securities, commodity contracts, and investments
    "524":   46,  # Insurance carriers and related activities
    "525":   47,  # Funds, trusts, and other financial vehicles
    "532RL": 50,  # Rental and leasing services and lessors (532+533 → '532.533' c=50)
    "5411":  51,  # Legal services
    "5412OP": 53, # Other professional, scientific, and technical services
    "5415":  52,  # Computer systems design and related services
    "55":    54,  # Management of companies and enterprises
    "561":   55,  # Administrative and support services
    "562":   56,  # Waste management and remediation services
    "61":    57,  # Educational services
    "621":   58,  # Ambulatory health care services
    "622":   59,  # Hospitals
    "623":   60,  # Nursing and residential care facilities
    "624":   61,  # Social assistance
    "711AS": 62,  # Performing arts, spectator sports, museums (711+712)
    "713":   63,  # Amusements, gambling, and recreation industries
    "721":   64,  # Accommodation
    "722":   65,  # Food services and drinking places
    "81":    66,  # Other services (811+812+813+814)
    # Government / special categories — excluded from private-industry instrument
    "GFE":   None,
    "GFGD":  None,
    "GFGN":  None,
    "GSLE":  None,
    "GSLG":  None,
    "HS":    None,
    "ORE":   None,  # Owner-occupied real estate
    "Other": None,
    "Used":  None,
}

# BEA c codes that appear in processed_bea_value_added (1–60 only; 61–66 present
# in instrument_bea but absent from processed_bea_value_added).
BEA_C_IN_PBV: frozenset[int] = frozenset(range(1, 61))


# ---------------------------------------------------------------------------
# BEA GDPbyIndustry API — fetch gross output
# ---------------------------------------------------------------------------

def fetch_bea_gross_output(api_key: str) -> pd.DataFrame:
    """
    Fetch annual gross output (current dollars, $ millions) for all NAICS
    summary industries from BEA GDPbyIndustry, table GO.

    Returns df with columns [industry, year, go_millions].
    """
    url = BEA_API_BASE
    params = {
        "UserID": api_key,
        "method": "GetData",
        "datasetname": "GDPbyIndustry",
        "TableID": "15",
        "Frequency": "A",
        "Year": "ALL",
        "Industry": "ALL",
        "ResultFormat": "JSON",
    }
    print("Fetching BEA GDPbyIndustry gross output...", flush=True)
    resp = requests.get(url, params=params, timeout=60)
    resp.raise_for_status()
    payload = resp.json()

    try:
        data = payload["BEAAPI"]["Results"]["Data"]
    except (KeyError, TypeError):
        # The API sometimes wraps results differently; try alternate path
        try:
            data = payload["BEAAPI"]["Results"][0]["Data"]
        except (KeyError, TypeError, IndexError):
            raise ValueError(
                f"Unexpected BEA API response structure: {json.dumps(payload)[:500]}"
            )

    records = []
    for item in data:
        try:
            industry = str(item.get("IndustrYDescription") or item.get("Industry") or "").strip()
            ind_code = str(item.get("Industry") or "").strip()
            year = int(item.get("Year") or item.get("TimePeriod", 0))
            val_str = str(item.get("DataValue", "")).replace(",", "")
            if val_str in ("", "NM", "--"):
                continue
            value = float(val_str)
            if ind_code:
                records.append({"industry": ind_code, "year": year, "go_millions": value})
        except (ValueError, TypeError):
            continue

    if not records:
        raise ValueError("BEA GDPbyIndustry fetch returned no usable records.")

    df = pd.DataFrame(records)
    print(f"  {len(df):,} rows fetched, years {df['year'].min()}-{df['year'].max()}", flush=True)
    return df


# ---------------------------------------------------------------------------
# IO weight matrix from instrument_io_tables_api
# ---------------------------------------------------------------------------

def load_io_weights(conn: sqlite3.Connection, years: list[int]) -> dict[int, pd.DataFrame]:
    """
    For each year in `years`, load the Table 59 (Leontief inverse) from
    instrument_io_tables_api and build a (row_code × col_code) matrix of weights.

    Returns {year: DataFrame(index=row_code, columns=col_code)}.
    """
    available = {
        r[0] for r in conn.execute(
            "SELECT DISTINCT year FROM instrument_io_tables_api WHERE row_code != ''"
        ).fetchall()
    }

    weight_dict: dict[int, pd.DataFrame] = {}
    for yr in sorted(set(years)):
        yr_int = int(yr)
        # Use nearest available year if exact year not in DB
        if yr_int not in available:
            closest = min(available, key=lambda x: abs(x - yr_int))
            warnings.warn(
                f"IO table for year {yr_int} not found; using {closest} as proxy."
            )
            yr_int = closest

        df = pd.read_sql_query(
            "SELECT row_code, col_code, value FROM instrument_io_tables_api "
            "WHERE year=? AND row_code != ''",
            conn,
            params=(yr_int,),
        )
        mat = df.pivot(index="row_code", columns="col_code", values="value").fillna(0.0)
        weight_dict[int(yr)] = mat
        print(f"  Loaded IO matrix year={yr_int}: {mat.shape[0]} rows × {mat.shape[1]} cols", flush=True)

    return weight_dict


# ---------------------------------------------------------------------------
# Instrument construction
# ---------------------------------------------------------------------------

def compute_instrument(
    go_df: pd.DataFrame,
    io_weights: dict[int, pd.DataFrame],
    sample_years: list[int],
) -> pd.DataFrame:
    """
    For each BEA c code and each year in sample_years, compute:
        Instrument_c,t = sum over API col codes j of  L_cj,t * GO_j,t

    where L_cj,t is the IO weight (Leontief entry) for the API row code
    associated with BEA c code `c` and col code `j`.

    Returns DataFrame with columns [bea_c, year, instrument].
    """
    # Build reverse map: API row code → bea_c (for row industries only)
    api_to_c = {k: v for k, v in API_TO_BEA_C.items() if v is not None}

    # Go series: index=industry (API code), columns=year
    go_pivot = go_df.pivot(index="industry", columns="year", values="go_millions")

    records = []
    for yr in sorted(sample_years):
        # Get the IO weight matrix for this year
        yr_key = min(io_weights.keys(), key=lambda x: abs(x - yr))
        L = io_weights[yr_key]

        if yr not in go_pivot.columns:
            warnings.warn(f"GO data not available for year {yr}; skipping.")
            continue

        go_t = go_pivot[yr].dropna()

        for api_row, bea_c in api_to_c.items():
            if api_row not in L.index:
                continue

            # Row of Leontief inverse: how much of api_row's output is required
            # per unit of final demand for each col industry j
            row_weights = L.loc[api_row]

            # Weighted sum of GO across all col industries
            col_codes = row_weights.index
            go_vals = go_t.reindex(col_codes).fillna(0.0)
            instr = float((row_weights * go_vals).sum())

            if instr > 0:
                records.append({"api_code": api_row, "bea_c": bea_c, "year": yr, "instrument": instr})

    return pd.DataFrame(records)


# ---------------------------------------------------------------------------
# d_instrument = ln(Instrument_t) - ln(Instrument_{t-1})
# ---------------------------------------------------------------------------

def compute_d_instrument(instr_df: pd.DataFrame) -> pd.DataFrame:
    """
    Compute log-difference instrument within each bea_c panel.
    Returns df with columns [bea_c, year, instrument, d_instrument].
    """
    df = instr_df.sort_values(["bea_c", "year"]).copy()
    df["ln_instr"] = np.log(df["instrument"].where(df["instrument"] > 0))
    df["d_instrument"] = df.groupby("bea_c")["ln_instr"].diff()
    return df


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    load_dotenv(ROOT / ".env")
    api_key = os.environ.get("BEA_API_KEY", "")
    if not api_key:
        raise RuntimeError(
            "BEA_API_KEY not set. Add it to .env or export it before running."
        )

    conn = sqlite3.connect(DB_PATH)

    # --- 1. Fetch gross output from BEA API ---
    go_df = fetch_bea_gross_output(api_key)

    # We need years 2013–2024 (2013 anchors the first log-diff for 2014)
    target_years = list(range(2013, 2025))
    go_df = go_df[go_df["year"].isin(target_years)].copy()

    # Filter to API codes we have crosswalk entries for (excludes government etc.)
    known_api_codes = set(API_TO_BEA_C.keys())
    go_df = go_df[go_df["industry"].isin(known_api_codes)].copy()

    missing_go = known_api_codes - set(go_df["industry"].unique()) - {
        k for k, v in API_TO_BEA_C.items() if v is None
    }
    if missing_go:
        warnings.warn(
            f"GO data missing for API codes: {sorted(missing_go)}. "
            "They will be excluded from instrument construction."
        )
    print(
        f"  Using {go_df['industry'].nunique()} API industries, "
        f"years {go_df['year'].min()}-{go_df['year'].max()}"
    )

    # --- 2. Load IO weights ---
    print("\nLoading IO weight matrices...", flush=True)
    io_weights = load_io_weights(conn, target_years)

    # --- 3. Build and aggregate instrument levels ---
    print("\nConstructing instrument levels...", flush=True)
    instr_raw = compute_instrument(go_df, io_weights, target_years)
    print(f"  {len(instr_raw):,} (api_code, year) records")

    # Aggregate to bea_c level: sum exposures from all api_row codes mapping to same bea_c
    # (handles many-to-one cases like '311FT' → c=19 and any other c=19 codes)
    instr_agg = (
        instr_raw.groupby(["bea_c", "year"])["instrument"]
        .sum()
        .reset_index()
    )
    print(
        f"  Aggregated to {instr_agg['bea_c'].nunique()} BEA c codes, "
        f"{instr_agg['year'].nunique()} years"
    )

    # --- 4. Compute d_instrument ---
    print("\nComputing log-differences...", flush=True)
    instr_df = compute_d_instrument(instr_agg)

    # Drop anchor year (2013) — we only need 2014+ log-diffs
    instr_post2013 = instr_df[instr_df["year"] >= 2014].copy()
    n_valid = instr_post2013["d_instrument"].notna().sum()
    print(f"  {n_valid:,} non-null d_instrument values for 2014–2024")

    # --- 5. Write to output table ---
    print(f"\nWriting {OUT_TABLE}...", flush=True)
    out_df = instr_post2013[["bea_c", "year", "instrument", "ln_instr", "d_instrument"]].copy()
    out_df.to_sql(OUT_TABLE, conn, if_exists="replace", index=False)
    print(f"  {len(out_df):,} rows written to {OUT_TABLE!r}")

    # --- 6. Patch processed_bea_value_added for years 2014–2024 ---
    print("\nPatching processed_bea_value_added...", flush=True)

    # Load existing table
    pbv = pd.read_sql_query(
        "SELECT naics, code, year, go, va, pgo, pva, d_go, d_va_ind, d_instrument "
        "FROM processed_bea_value_added",
        conn,
    )

    # For patching, only update rows where code is in BEA_C_IN_PBV
    patch = (
        instr_post2013[instr_post2013["bea_c"].isin(BEA_C_IN_PBV)]
        [["bea_c", "year", "d_instrument"]]
        .rename(columns={"bea_c": "code"})
    )
    patch["code"] = patch["code"].astype(float)

    # Rows already in pbv for 2014+
    existing_post = pbv[pbv["year"] >= 2014].copy()
    new_rows_codes = set(zip(patch["code"], patch["year"]))
    existing_codes = set(zip(existing_post["code"], existing_post["year"]))

    # Update d_instrument in existing rows
    updated = 0
    pbv_indexed = pbv.set_index(["code", "year"])
    for _, row in patch.iterrows():
        key = (row["code"], row["year"])
        if key in pbv_indexed.index:
            pbv_indexed.at[key, "d_instrument"] = row["d_instrument"]
            updated += 1

    # Append genuinely new (code, year) combinations
    new_keys = new_rows_codes - existing_codes
    new_rows = patch[
        patch.apply(lambda r: (r["code"], r["year"]) in new_keys, axis=1)
    ].copy()
    new_rows["naics"] = None
    new_rows["go"] = None
    new_rows["va"] = None
    new_rows["pgo"] = None
    new_rows["pva"] = None
    new_rows["d_go"] = None
    new_rows["d_va_ind"] = None
    new_rows["d_instrument"] = new_rows["d_instrument"]

    pbv_final = pd.concat(
        [pbv_indexed.reset_index(), new_rows[pbv.columns]],
        ignore_index=True,
    ).sort_values(["code", "year"])

    pbv_final.to_sql("processed_bea_value_added", conn, if_exists="replace", index=False)
    print(
        f"  Updated {updated} existing rows; inserted {len(new_rows)} new rows "
        f"(total {len(pbv_final):,} in processed_bea_value_added)"
    )

    conn.close()
    print("\nScript 41 complete.")


if __name__ == "__main__":
    main()
