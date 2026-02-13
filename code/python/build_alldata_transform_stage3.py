#!/usr/bin/env python3
from __future__ import annotations

import sqlite3
from pathlib import Path
import warnings

import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[2]
DB_PATH = ROOT / "data" / "cyclicality.db"
REPORT_PATH = ROOT / "data" / "TRANSFORMATION_STAGE3_REPORT.md"
OUT_TABLE = "processed_alldata_stage3"


def safe_div(num: pd.Series, den: pd.Series) -> pd.Series:
    return num / den.replace({0: np.nan})


def ln_pos(s: pd.Series) -> pd.Series:
    x = pd.to_numeric(s, errors="coerce")
    return np.log(x.where(x > 0))


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


def panel_lag(df: pd.DataFrame, col: str, panel: str = "key", time: str = "year") -> pd.Series:
    prev = df.groupby(panel, dropna=False, sort=False)[col].shift(1)
    prev_year = pd.to_numeric(df.groupby(panel, dropna=False, sort=False)[time].shift(1), errors="coerce")
    year = pd.to_numeric(df[time], errors="coerce")
    is_consecutive = (year - prev_year) == 1
    return prev.where(is_consecutive)


def transform_stage3(
    df: pd.DataFrame,
) -> tuple[pd.DataFrame, list[str], list[str], list[str]]:
    """Apply deterministic tail blocks from AllData.do lines ~793-813."""
    for col in ["key", "year", "gvkey"]:
        if col not in df.columns:
            raise ValueError(f"Missing required column `{col}` for stage3")

    df = df.sort_values(["key", "year"], kind="mergesort").reset_index(drop=True).copy()
    generated: list[str] = []
    skipped: list[str] = []
    assumptions: list[str] = []

    # Exit variable block.
    df["t"] = np.arange(1, len(df) + 1, dtype=np.int64)
    df["firmid"] = df["gvkey"]
    generated += ["t", "firmid"]

    firm_group = df.groupby("firmid", dropna=False, sort=False)
    df["count"] = firm_group["firmid"].transform("size").astype("float64")
    df["survivor"] = (df["count"] == 61).astype(float)
    df["has95"] = firm_group["year"].transform(lambda s: (s == 2011).any()).astype(float)
    df["has_gaps"] = firm_group["year"].transform(lambda s: float((s.diff() != 1).iloc[1:].any()) if len(s) > 1 else 0.0)
    df["exit"] = (
        (df["survivor"] == 0)
        & (df["has95"] == 0)
        & (df["has_gaps"] != 1)
        & (firm_group.cumcount() == (firm_group["year"].transform("size") - 1))
    ).astype(float)
    df.loc[(df["exit"] == 1) & (df["year"] == 2011), "exit"] = 0.0
    generated += ["count", "survivor", "has95", "has_gaps", "exit"]

    # Returns to R&D pre-regression variables.
    if "r_sale" not in df.columns and "r_gdp_sale" in df.columns:
        df["r_sale"] = df["r_gdp_sale"]
        assumptions.append("Alias `r_sale` derived from `r_gdp_sale` for returns block.")
        generated.append("r_sale")
    if "r_xrd" not in df.columns and "r_gdp_xrd" in df.columns:
        df["r_xrd"] = df["r_gdp_xrd"]
        assumptions.append("Alias `r_xrd` derived from `r_gdp_xrd` for returns block.")
        generated.append("r_xrd")

    if {"r_sale", "emp"}.issubset(df.columns):
        df["q_ret"] = safe_div(df["r_sale"], df["emp"])
        assumptions.append("Stored returns block `q` as `q_ret` because SQLite treats `q` and `Q` as duplicate column names.")
        df["l_q"] = ln_pos(df["q_ret"])
        lag_lq = panel_lag(df, "l_q")
        df["d_q"] = df["l_q"] - lag_lq
        generated += ["q_ret", "l_q", "d_q"]
    else:
        skipped.append("q_ret/l_q/d_q: missing `r_sale` or `emp`")

    if {"r_xrd", "q_ret"}.issubset(df.columns):
        df["z1"] = safe_div(df["r_xrd"], df["q_ret"])
        generated.append("z1")
    else:
        skipped.append("z1: missing `r_xrd` or `q_ret`")
    if {"r_xrd", "emp"}.issubset(df.columns):
        df["z2"] = safe_div(df["r_xrd"], df["emp"])
        generated.append("z2")
    else:
        skipped.append("z2: missing `r_xrd` or `emp`")

    if "z1" in df.columns:
        df["average_z1"] = df.groupby("year", dropna=False)["z1"].transform("mean")
        generated.append("average_z1")
    else:
        skipped.append("average_z1: missing `z1`")
    if "z2" in df.columns:
        df["average_z2"] = df.groupby("year", dropna=False)["z2"].transform("mean")
        generated.append("average_z2")
    else:
        skipped.append("average_z2: missing `z2`")

    return df, sorted(set(generated)), sorted(set(skipped)), assumptions


def main() -> int:
    warnings.simplefilter("ignore", category=pd.errors.PerformanceWarning)
    with sqlite3.connect(DB_PATH) as conn:
        stage2_df = pd.read_sql_query("SELECT * FROM processed_alldata_stage2", conn)

    out_df, generated, skipped, assumptions = transform_stage3(stage2_df)

    with sqlite3.connect(DB_PATH) as conn:
        sql_chunk = safe_to_sql_chunksize(conn, len(out_df.columns))
        conn.execute(f"DROP TABLE IF EXISTS {OUT_TABLE}")
        out_df = out_df.copy()
        out_df.to_sql(OUT_TABLE, conn, if_exists="replace", index=False, method="multi", chunksize=sql_chunk)
        out_rows = int(conn.execute(f"SELECT COUNT(*) FROM {OUT_TABLE}").fetchone()[0])

    lines = []
    lines.append("# Transformation Stage 3 Report")
    lines.append("")
    lines.append("Implements deterministic tail blocks of `AllData.do` (exit variables and returns-prep variables).")
    lines.append("")
    lines.append("## Output")
    lines.append("")
    lines.append(f"- SQLite table: `{OUT_TABLE}`")
    lines.append(f"- Input rows (`processed_alldata_stage2`): `{len(stage2_df)}`")
    lines.append(f"- Rows written: `{out_rows}`")
    lines.append(f"- Generated variables: `{len(generated)}`")
    lines.append(f"- Skipped formulas: `{len(skipped)}`")
    lines.append("")
    lines.append("## Generated Variables")
    lines.append("")
    lines.append(", ".join(f"`{v}`" for v in generated) if generated else "None")
    lines.append("")
    lines.append("## Skipped Formulas")
    lines.append("")
    if skipped:
        for s in skipped:
            lines.append(f"- {s}")
    else:
        lines.append("- None")
    lines.append("")
    lines.append("## Assumptions")
    lines.append("")
    if assumptions:
        for a in assumptions:
            lines.append(f"- {a}")
    else:
        lines.append("- None")

    REPORT_PATH.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote {REPORT_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
