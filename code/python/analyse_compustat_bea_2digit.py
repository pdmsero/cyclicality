#!/usr/bin/env python3
"""
analyse_compustat_bea_2digit.py
================================
Python replication of [4]_compustat_BEA_2digits.do.

Data source: processed_compustat_bea_2digit table in cyclicality.db.
Panel structure: key (firm), year.

The Stata script is a short exploratory FE OLS script (88 lines).  It runs
three specification tiers for each of two output measures (d_go, d_va) and
two dependent variables (d_xrd, z_rd_go / z_rd_va):

  Tier 1: xtreg dep output, fe
           (entity FE only, no controls, no time dummies)
  Tier 2: xtreg dep output t1-t62, fe
           (entity FE + year dummies)
  Tier 3: xtreg dep output emp r_che r_dd1 r_dltt r_lt r_at r_ppent
                       l.(r_che r_dd1 r_dltt r_lt r_at)
                       l2.(r_che r_dd1 r_dltt r_lt r_at) t1-t62, fe
           (full controls + year dummies)

Note: the Stata code does not use vce(cluster), so standard FE standard
errors are used here (not cluster-robust).  Time dummies t1-t62 are
pre-computed in the processed_compustat_bea_2digit table.

Output
------
  results/compustat_bea_2digit_results.xlsx
  results/compustat_bea_2digit_results.md
"""

from __future__ import annotations

import sqlite3
import warnings
from pathlib import Path

import numpy as np
import pandas as pd
from linearmodels.panel import PanelOLS

warnings.filterwarnings("ignore", category=FutureWarning)
warnings.filterwarnings("ignore", category=pd.errors.PerformanceWarning)

ROOT = Path(__file__).resolve().parents[2]
DB_PATH = ROOT / "data" / "cyclicality.db"
RESULTS_DIR = ROOT / "results"
RESULTS_DIR.mkdir(exist_ok=True)

XLSX_PATH = RESULTS_DIR / "compustat_bea_2digit_results.xlsx"
MD_PATH = RESULTS_DIR / "compustat_bea_2digit_results.md"


# ---------------------------------------------------------------------------
# Panel utility helpers
# ---------------------------------------------------------------------------

def panel_lag(df: pd.DataFrame, col: str,
              panel: str = "key", time: str = "year",
              n: int = 1) -> pd.Series:
    """Lag `col` by `n` periods within each panel unit."""
    grp = df.groupby(panel, dropna=False, sort=False)
    lagged = grp[col].shift(n)
    prev_year = pd.to_numeric(grp[time].shift(n), errors="coerce")
    curr_year = pd.to_numeric(df[time], errors="coerce")
    return lagged.where((curr_year - prev_year) == n)


def build_analysis_vars(df: pd.DataFrame) -> pd.DataFrame:
    """Add lags of financial controls (l. and l2.)."""
    df = df.sort_values(["key", "year"]).copy()
    df["year"] = pd.to_numeric(df["year"], errors="coerce").astype("Int64")

    ctrl_lag_cols = ["r_che", "r_dd1", "r_dltt", "r_lt", "r_at"]
    for col in ctrl_lag_cols:
        if col in df.columns:
            df[f"l_{col}"] = panel_lag(df, col)
            df[f"l2_{col}"] = panel_lag(df, col, n=2)
    return df


# ---------------------------------------------------------------------------
# Regression wrapper
# ---------------------------------------------------------------------------

def _fe_ols(y: pd.Series, X: pd.DataFrame,
            df: pd.DataFrame, label: str) -> dict:
    """Entity FE OLS with standard (non-clustered) SEs.
    Stata: xtreg dep exog, fe
    """
    mask = y.notna() & X.notna().all(axis=1)
    if mask.sum() < 20:
        return {"label": label, "estimator": "FE OLS", "n": 0, "results": None}

    X_f = X[mask]
    # Drop constant columns after complete-case filter (e.g. early t-dummies)
    varying = X_f.columns[X_f.nunique() > 1]
    X_f = X_f[varying]

    mi = pd.MultiIndex.from_arrays(
        [df.loc[mask, "key"].values, df.loc[mask, "year"].values],
        names=["key", "year"],
    )
    dep = pd.DataFrame({"dep": y[mask].values}, index=mi)
    exog = pd.DataFrame(X_f.values, index=mi, columns=X_f.columns)

    mod = PanelOLS(dep, exog, entity_effects=True)
    res = mod.fit()   # default (non-clustered) standard errors
    return {
        "label": label, "estimator": "FE OLS",
        "n": int(res.nobs),
        "params": res.params.to_dict(),
        "pvalues": res.pvalues.to_dict(),
        "se": res.std_errors.to_dict(),
        "results": None,
    }


# ---------------------------------------------------------------------------
# Standard regressor sets
# ---------------------------------------------------------------------------

def _time_dummies(df: pd.DataFrame) -> pd.DataFrame:
    """Return all t1–t62 time dummy columns present in df."""
    cols = [f"t{i}" for i in range(1, 63)]
    return df[[c for c in cols if c in df.columns]]


def _full_controls(df: pd.DataFrame) -> pd.DataFrame:
    """emp, r_che, r_dd1, r_dltt, r_lt, r_at, r_ppent, lags l. and l2."""
    base = ["emp", "r_che", "r_dd1", "r_dltt", "r_lt", "r_at", "r_ppent"]
    lag_cols = ["r_che", "r_dd1", "r_dltt", "r_lt", "r_at"]
    l1 = [f"l_{c}" for c in lag_cols]
    l2 = [f"l2_{c}" for c in lag_cols]
    all_cols = base + l1 + l2
    return df[[c for c in all_cols if c in df.columns]]


# ---------------------------------------------------------------------------
# Regression blocks
# ---------------------------------------------------------------------------

def run_regression_grid(df: pd.DataFrame) -> dict[str, dict]:
    """Run all 12 regressions from the Stata script.

    Returns a dict mapping label → result dict.
    """
    tdums = _time_dummies(df)
    ctrl = _full_controls(df)
    results: dict[str, dict] = {}

    # R&D growth (d_xrd) as dependent
    for out_col, lbl in [("d_go", "go"), ("d_va", "va")]:
        if out_col not in df.columns:
            continue
        dep = df["d_xrd"]

        # Tier 1: entity FE only, no controls
        X = df[[out_col]]
        results[f"t1_{lbl}"] = _fe_ols(dep, X, df, f"t1_{lbl}")

        # Tier 2: entity FE + year dummies
        X = pd.concat([df[[out_col]], tdums], axis=1)
        results[f"t2_{lbl}"] = _fe_ols(dep, X, df, f"t2_{lbl}")

        # Tier 3: entity FE + controls + year dummies
        X = pd.concat([df[[out_col]], ctrl, tdums], axis=1)
        results[f"t3_{lbl}"] = _fe_ols(dep, X, df, f"t3_{lbl}")

    # R&D intensity (z_rd_go / z_rd_va) as dependent
    for out_col, z_dep, lbl in [
        ("d_go", "z_rd_go", "go"),
        ("d_va", "z_rd_va", "va"),
    ]:
        if out_col not in df.columns or z_dep not in df.columns:
            continue
        dep = df[z_dep]

        # Tier 1
        X = df[[out_col]]
        results[f"t1_z_{lbl}"] = _fe_ols(dep, X, df, f"t1_z_{lbl}")

        # Tier 2
        X = pd.concat([df[[out_col]], tdums], axis=1)
        results[f"t2_z_{lbl}"] = _fe_ols(dep, X, df, f"t2_z_{lbl}")

        # Tier 3
        X = pd.concat([df[[out_col]], ctrl, tdums], axis=1)
        results[f"t3_z_{lbl}"] = _fe_ols(dep, X, df, f"t3_z_{lbl}")

    return results


# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------

def results_to_df(results: dict[str, dict]) -> pd.DataFrame:
    """Flatten results dict to a summary DataFrame."""
    rows = []
    for label, r in results.items():
        row = {"label": label, "estimator": r.get("estimator", ""),
               "n": r.get("n", 0)}
        if r.get("params"):
            for coef, val in r["params"].items():
                row[f"coef_{coef}"] = val
            for coef, val in r.get("pvalues", {}).items():
                row[f"pval_{coef}"] = val
            for coef, val in r.get("se", {}).items():
                row[f"se_{coef}"] = val
        rows.append(row)
    return pd.DataFrame(rows)


def build_markdown_summary(results: dict[str, dict]) -> str:
    lines = [
        "# Compustat × BEA 2-Digit: Estimation Summary",
        "",
        "Replication of [4]_compustat_BEA_2digits.do (entity FE OLS only).",
        "",
        "| Spec | Dep | Output | Coef | p-value | n |",
        "|------|-----|--------|------|---------|---|",
    ]
    ctrl_stems = {"emp", "r_che", "r_dd1", "r_dltt", "r_lt", "r_at",
                  "r_ppent", "l_", "l2_", "t", "const"}
    for label, r in results.items():
        if not r.get("params"):
            continue
        params = r["params"]
        pvals = r["pvalues"]
        out_coefs = {k: v for k, v in params.items()
                     if not any(k.startswith(s) for s in ctrl_stems)
                     and not k[0] == "t"}
        for coef, val in out_coefs.items():
            pv = pvals.get(coef, float("nan"))
            stars = "***" if pv < 0.01 else "**" if pv < 0.05 else "*" if pv < 0.1 else ""
            lines.append(f"| {label} | {coef} | {coef} | "
                         f"{val:.4f}{stars} | {pv:.3f} | {r['n']:,} |")
    return "\n".join(lines) + "\n"


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:
    print("Loading data from cyclicality.db …")
    with sqlite3.connect(DB_PATH) as conn:
        df = pd.read_sql_query(
            "SELECT * FROM processed_compustat_bea_2digit", conn
        )
    print(f"  Loaded {len(df):,} rows, {len(df.columns)} columns.")
    print(f"  Panel: {df['key'].nunique():,} firms, "
          f"years {int(df['year'].min())}-{int(df['year'].max())}")

    print("Building analysis variables …")
    df = build_analysis_vars(df)

    print("Running regression grid …")
    results = run_regression_grid(df)
    print(f"  Completed {len(results)} regressions.")

    print("Saving results …")
    summary_df = results_to_df(results)
    with pd.ExcelWriter(XLSX_PATH, engine="openpyxl") as writer:
        summary_df.to_excel(writer, sheet_name="results", index=False)

    md_text = build_markdown_summary(results)
    MD_PATH.write_text(md_text, encoding="utf-8")

    print(f"Wrote {XLSX_PATH}")
    print(f"Wrote {MD_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
