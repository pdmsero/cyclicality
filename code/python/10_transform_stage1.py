#!/usr/bin/env python3
from __future__ import annotations

import sqlite3
from pathlib import Path
import warnings

import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[2]
DB_PATH = ROOT / "data" / "cyclicality.db"
REPORT_PATH = ROOT / "docs" / "reports" / "TRANSFORMATION_STAGE1_REPORT.md"
OUT_TABLE = "processed_alldata_stage1"


def safe_div(num: pd.Series, den: pd.Series) -> pd.Series:
    den2 = den.replace({0: np.nan})
    return num / den2


def sqlite_max_variables(conn: sqlite3.Connection) -> int:
    default_max = 999
    try:
        rows = conn.execute("PRAGMA compile_options;").fetchall()
    except Exception:
        return default_max
    for (opt,) in rows:
        if isinstance(opt, str) and opt.startswith("MAX_VARIABLE_NUMBER="):
            try:
                return int(opt.split("=", 1)[1])
            except ValueError:
                return default_max
    return default_max


def safe_to_sql_chunksize(conn: sqlite3.Connection, n_columns: int, cap: int = 2000) -> int:
    if n_columns <= 0:
        return cap
    return max(1, min(cap, sqlite_max_variables(conn) // n_columns))


def build_prefixed_block(df: pd.DataFrame, prefix: str, denom_col: str) -> list[str]:
    base_map = {
        "cf": "cf",
        "cfmxrd": "cfmxrd",
        "at": "at",
        "capx": "capx",
        "ceq": "ceq",
        "che": "che",
        "dd1": "dd1",
        "dlc": "dlc",
        "dltt": "dltt",
        "dp": "dp",
        "dvc": "dvc",
        "dvp": "dvp",
        "ib": "ib",
        "lt": "lt",
        "oibdp": "oibdp",
        "ppent": "ppent",
        "ppegt": "ppegt",
        "sale": "sale",
        "sale_i": "sale_i",
        "seq": "seq",
        "txdb": "txdb",
        "xlr": "xlr",
        "xrd": "xrd",
        "va": "va",
        "va_a": "va_a",
        "va_e": "va_e",
        "tex": "tex",
        "materials": "materials",
    }
    block: dict[str, pd.Series] = {}
    den = df[denom_col]
    for out_stub, src_col in base_map.items():
        out_col = f"{prefix}_{out_stub}"
        block[out_col] = safe_div(df[src_col], den)
    df[list(block.keys())] = pd.DataFrame(block)
    made = list(block.keys())
    return made


# QCEW compound sector codes: some 2-digit NAICS ranges share one QCEW code
_QCEW_COMPOUND: dict[str, str] = {
    "31": "31-33", "32": "31-33", "33": "31-33",
    "44": "44-45", "45": "44-45",
    "48": "48-49", "49": "48-49",
}


def apply_qcew_wages(df: pd.DataFrame, conn: sqlite3.Connection) -> pd.DataFrame:
    """Override national SSA averagewage with QCEW industry-level wages (2001+).

    Hierarchy: 6-digit NAICS → 5 → 4 → 3 → 2-digit sector → all-private.
    Falls back to the existing SSA averagewage where no QCEW match is found
    (years < 2001 or suppressed industries).
    """
    qcew = pd.read_sql_query(
        "SELECT year, naics_code, naics_digits, avg_annual_pay "
        "FROM bls_qcew_wages WHERE disclosure_code = '' AND year >= 2001",
        conn,
    )
    if qcew.empty:
        return df

    # Integer year for joining
    df = df.copy()
    df["_year_int"] = pd.to_numeric(df["year"], errors="coerce").astype("Int64")
    naics_str = df["naics"].fillna("").astype(str).str.strip()

    # Build NAICS prefix columns (raw 2-digit before compound mapping)
    df["_n6"] = naics_str.str[:6]
    df["_n5"] = naics_str.str[:5]
    df["_n4"] = naics_str.str[:4]
    df["_n3"] = naics_str.str[:3]
    df["_n2_raw"] = naics_str.str[:2]
    df["_n2"] = df["_n2_raw"].map(lambda x: _QCEW_COMPOUND.get(x, x))

    # Build per-level lookups keyed by (year, naics_code)
    for lvl, col in [(6, "_n6"), (5, "_n5"), (4, "_n4"), (3, "_n3"), (2, "_n2"), (0, None)]:
        subset = qcew[qcew["naics_digits"] == lvl][["year", "naics_code", "avg_annual_pay"]].copy()
        if subset.empty:
            df[f"_wage_{lvl}"] = np.nan
            continue
        subset = subset.rename(columns={"naics_code": f"_k{lvl}", "avg_annual_pay": f"_wage_{lvl}"})
        subset["_year_int"] = subset["year"].astype("Int64")
        if lvl == 0:
            # all-private: naics_code = "10", merge on year only
            subset_ap = subset[["_year_int", f"_wage_{lvl}"]].drop_duplicates("_year_int")
            df = df.merge(subset_ap, on="_year_int", how="left")
        else:
            df = df.merge(
                subset[["_year_int", f"_k{lvl}", f"_wage_{lvl}"]],
                left_on=["_year_int", col],
                right_on=["_year_int", f"_k{lvl}"],
                how="left",
            ).drop(columns=[f"_k{lvl}"])

    # Coalesce finest to coarsest, then fall back to SSA national average
    qcew_wage = (
        df["_wage_6"]
        .combine_first(df["_wage_5"])
        .combine_first(df["_wage_4"])
        .combine_first(df["_wage_3"])
        .combine_first(df["_wage_2"])
        .combine_first(df["_wage_0"])
    )
    df["averagewage"] = qcew_wage.combine_first(df["averagewage"])

    # Log coverage
    n_qcew = qcew_wage.notna().sum()
    n_ssa = df["averagewage"].notna().sum() - n_qcew
    print(
        f"  QCEW wage coverage: {n_qcew:,} firm-years from QCEW, "
        f"{n_ssa:,} remaining from SSA national average"
    )

    # Clean up temporary columns
    tmp_cols = [c for c in df.columns if c.startswith("_")]
    df = df.drop(columns=tmp_cols)
    return df


def transform_stage1(
    df: pd.DataFrame,
) -> tuple[pd.DataFrame, list[str], int, int, int]:
    """Apply Stage-1 AllData.do filters/transforms.

    Returns:
      transformed_df, generated_vars, rows_before, rows_after_nonneg, rows_after_nonmissing
    """
    rows_before = len(df)

    # AllData.do housecleaning filters.
    filt_nonneg = ~(
        (df["at"] < 0)
        | (df["capx"] < 0)
        | (df["dd1"] < 0)
        | (df["dlc"] < 0)
        | (df["dltt"] < 0)
        | (df["emp"] < 0)
        | (df["ppent"] < 0)
        | (df["sale"] < 0)
        | (df["xrd"] < 0)
        | (df["xlr"] < 0)
    )
    df = df.loc[filt_nonneg].copy()
    rows_after_nonneg = len(df)

    filt_nonmissing = df["xrd"].notna() & df["sale"].notna() & df["oibdp"].notna()
    df = df.loc[filt_nonmissing].copy()
    rows_after_nonmissing = len(df)

    # Auxiliary variables.
    generated: list[str] = []
    df["va"] = df["oibdp"] + df["xlr"]
    generated.append("va")

    df["averagesalary"] = safe_div(df["xlr"] * 1000.0, df["emp"])
    generated.append("averagesalary")

    df["meansalary"] = df.groupby("year", dropna=False)["averagesalary"].transform("mean")
    generated.append("meansalary")

    df["wagebill"] = (df["emp"] * df["averagewage"]) / 1000.0
    generated.append("wagebill")

    df["va_a"] = df["oibdp"] + df["wagebill"]
    generated.append("va_a")

    df["payroll"] = (df["emp"] * df["meansalary"]) / 1000.0
    generated.append("payroll")

    df["va_e"] = df["oibdp"] + df["payroll"]
    generated.append("va_e")

    df["tex"] = df["sale"] - df["oibdp"]
    generated.append("tex")

    df["materials"] = df["tex"] - df["wagebill"]
    generated.append("materials")

    df["va_o"] = df["sale"] - df["materials"]
    generated.append("va_o")

    df["cf"] = df["ib"] + df["dp"]
    generated.append("cf")

    df["cfmxrd"] = df["cf"] - df["xrd"]
    generated.append("cfmxrd")

    # Deflated blocks from AllData.do repetitive sections.
    generated += build_prefixed_block(df, "r_gdp", "p_gdp")
    generated += build_prefixed_block(df, "r_va", "pva")
    generated += build_prefixed_block(df, "r_go", "pgo")
    generated += build_prefixed_block(df, "r_nber", "piship")

    # Additional ratios present in same section.
    extra_block = {
        "r_ipr_xrd": safe_div(df["xrd"], df["p_ipr"]),
        "r_inv_capx": safe_div(df["capx"], df["p_nonresidential"]),
        "r_inv_ppent": safe_div(df["ppent"], df["p_nonresidential"]),
        "r_inv_ppegt": safe_div(df["ppegt"], df["p_nonresidential"]),
        "r_nberinv_capx": safe_div(df["capx"], df["piinv"]),
        "r_nberinv_ppent": safe_div(df["ppent"], df["piinv"]),
        "r_nberinv_ppegt": safe_div(df["ppegt"], df["piinv"]),
    }
    df[list(extra_block.keys())] = pd.DataFrame(extra_block)
    generated += list(extra_block.keys())
    return df, generated, rows_before, rows_after_nonneg, rows_after_nonmissing


def main() -> int:
    warnings.simplefilter("ignore", category=pd.errors.PerformanceWarning)
    with sqlite3.connect(DB_PATH) as conn:
        base_df = pd.read_sql_query("SELECT * FROM processed_alldata", conn)
        print("Applying QCEW industry-level wages…")
        base_df = apply_qcew_wages(base_df, conn)
    df, generated, rows_before, rows_after_nonneg, rows_after_nonmissing = transform_stage1(base_df)

    # Persist stage table.
    with sqlite3.connect(DB_PATH) as conn:
        sql_chunk = safe_to_sql_chunksize(conn, len(df.columns))
        conn.execute(f"DROP TABLE IF EXISTS {OUT_TABLE}")
        df = df.copy()  # defragment after many column insertions
        df.to_sql(OUT_TABLE, conn, if_exists="replace", index=False, method="multi", chunksize=sql_chunk)
        stage_rows = int(conn.execute(f"SELECT COUNT(*) FROM {OUT_TABLE}").fetchone()[0])

    lines = []
    lines.append("# Transformation Stage 1 Report")
    lines.append("")
    lines.append("Implements initial `AllData.do` cleaning and transformation blocks in Python.")
    lines.append("")
    lines.append("## Output")
    lines.append("")
    lines.append(f"- SQLite table: `{OUT_TABLE}`")
    lines.append(f"- Rows written: `{stage_rows}`")
    lines.append("")
    lines.append("## Row Filters")
    lines.append("")
    lines.append(f"- Input rows (`processed_alldata`): `{rows_before}`")
    lines.append(f"- After nonnegative filter block: `{rows_after_nonneg}`")
    lines.append(f"- After missingness filter block: `{rows_after_nonmissing}`")
    lines.append(f"- Total dropped: `{rows_before - rows_after_nonmissing}`")
    lines.append("")
    lines.append("## Variables Generated in Stage 1")
    lines.append("")
    lines.append(f"- Count: `{len(generated)}`")
    lines.append("")
    lines.append(", ".join(f"`{v}`" for v in generated))
    lines.append("")
    lines.append("## Notes")
    lines.append("")
    lines.append("- This stage focuses on the early and repetitive transformation blocks from `AllData.do`.")
    lines.append("- Remaining sections (growth rates, ratios, constraints indices, regressions) are not yet ported.")

    REPORT_PATH.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote {REPORT_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
