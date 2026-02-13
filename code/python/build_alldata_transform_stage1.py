#!/usr/bin/env python3
from __future__ import annotations

import sqlite3
from pathlib import Path
import warnings

import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[2]
DB_PATH = ROOT / "data" / "cyclicality.db"
REPORT_PATH = ROOT / "data" / "TRANSFORMATION_STAGE1_REPORT.md"
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
        base_df = pd.read_sql_query(f"SELECT * FROM processed_alldata", conn)
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
