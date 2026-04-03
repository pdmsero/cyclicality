#!/usr/bin/env python3
"""
analyse_financial_constraints.py
==================================
Python replication of [5]_data_financial_constraints.do.

Data source: processed_financial_constraints table in cyclicality.db.
Panel structure: key (firm), year.

The Stata script (606 lines) runs 96 entity FE OLS regressions with
vce(cluster key) across four analysis sections:

  Section 1 (21 regs): Baseline cyclicality — basic output measures and
                        asymmetric (expansion / contraction) variants.
  Section 2 (9 regs):  KZ financial constraints quartiles — output ×
                        KZ_1–KZ_4 indicator interactions.
  Section 3 (36 regs): WW financial constraints quartiles and corporate
                        spread (AAA growth, BAA growth, BAA–AAA spread)
                        conditioning variables.
  Section 4 (30 regs): Demeaned variants — same as Sections 1–2 but
                        using within-firm-mean-deviated growth rates.

Common specification throughout:
  xtreg dep output_vars emp r_cf r_dd1 r_dltt r_lt r_at r_ppent
        l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at)
        t1–t46, fe vce(cluster key)

For intensity-level dependents (z_rd_*), lagged values l.z and l2.z are
included as additional regressors, replicating the Stata dynamic spec.

KZ and WW blocks also include Wald equality tests:
  H0: beta[quartile_1] = beta[quartile_4]
reported as F-statistic and p-value (chi-sq(1) / 1).

Output
------
  results/financial_constraints_results.xlsx
  results/financial_constraints_results.md
"""

from __future__ import annotations

import sqlite3
import warnings
from pathlib import Path

import numpy as np
import pandas as pd
from linearmodels.panel import PanelOLS
from scipy import stats

warnings.filterwarnings("ignore", category=FutureWarning)
warnings.filterwarnings("ignore", category=pd.errors.PerformanceWarning)

ROOT = Path(__file__).resolve().parents[2]
DB_PATH = ROOT / "data" / "cyclicality.db"
RESULTS_DIR = ROOT / "results"
RESULTS_DIR.mkdir(exist_ok=True)

XLSX_PATH = RESULTS_DIR / "financial_constraints_results.xlsx"
MD_PATH = RESULTS_DIR / "financial_constraints_results.md"

# Control lag columns: l. and l2. of these five variables
_CTRL_LAG_COLS = ["r_cf", "r_dd1", "r_dltt", "r_lt", "r_at"]
_BASE_CTRL_COLS = ["emp", "r_cf", "r_dd1", "r_dltt", "r_lt", "r_at", "r_ppent"]


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
    """
    Add lag columns needed for regressions:
      - l_r_cf, l2_r_cf, ... (l1 and l2 of the five control variables)
      - l_z_rd_va, l2_z_rd_va, l_z_rd_sale, l2_z_rd_sale,
        l_z_rd_va_a, l2_z_rd_va_a, l_z_rd_capx, l2_z_rd_capx
        (lagged dep vars for dynamic intensity specs)
      - d_h_ag_fc_va, d_l_ag_fc_va  (missing from table; constructed as
        d_h_ag * d_va and d_l_ag * d_va)
    """
    df = df.sort_values(["key", "year"]).copy()
    df["year"] = pd.to_numeric(df["year"], errors="coerce").astype("Int64")

    # Control lags
    for col in _CTRL_LAG_COLS:
        if col in df.columns:
            df[f"l_{col}"] = panel_lag(df, col)
            df[f"l2_{col}"] = panel_lag(df, col, n=2)

    # Lagged intensity dependents (for dynamic z_rd_* specs)
    z_cols = ["z_rd_va", "z_rd_sale", "z_rd_va_a", "z_rd_capx"]
    for col in z_cols:
        if col in df.columns:
            df[f"l_{col}"] = panel_lag(df, col)
            df[f"l2_{col}"] = panel_lag(df, col, n=2)

    # d_h_ag_fc_va and d_l_ag_fc_va are missing from the pre-computed table
    if "d_h_ag" in df.columns and "d_va" in df.columns:
        df["d_h_ag_fc_va"] = df["d_h_ag"] * df["d_va"]
    if "d_l_ag" in df.columns and "d_va" in df.columns:
        df["d_l_ag_fc_va"] = df["d_l_ag"] * df["d_va"]

    return df


# ---------------------------------------------------------------------------
# Regressor-set helpers
# ---------------------------------------------------------------------------

def _time_dummies(df: pd.DataFrame) -> pd.DataFrame:
    """Return all t1–t46 time dummy columns present in df."""
    cols = [f"t{i}" for i in range(1, 47)]
    return df[[c for c in cols if c in df.columns]]


def _full_controls(df: pd.DataFrame) -> pd.DataFrame:
    """emp, r_cf, r_dd1, r_dltt, r_lt, r_at, r_ppent, and l./l2. lags."""
    l1 = [f"l_{c}" for c in _CTRL_LAG_COLS]
    l2 = [f"l2_{c}" for c in _CTRL_LAG_COLS]
    all_cols = _BASE_CTRL_COLS + l1 + l2
    return df[[c for c in all_cols if c in df.columns]]


def _drop_constant_cols(X: pd.DataFrame) -> pd.DataFrame:
    """Drop zero-variance columns (e.g. time dummies outside sample window)."""
    varying = X.columns[X.nunique() > 1]
    return X[varying]


# ---------------------------------------------------------------------------
# Regression wrapper
# ---------------------------------------------------------------------------

def _fe_ols_cluster(y: pd.Series, X: pd.DataFrame,
                    df: pd.DataFrame, label: str,
                    test_pair: tuple[str, str] | None = None) -> dict:
    """
    Entity FE OLS with entity-clustered SEs.
    Stata equivalent: xtreg dep exog, fe vce(cluster key)

    Parameters
    ----------
    test_pair : optional (coef_name_1, coef_name_4)
        If provided, performs a Wald test H0: beta[coef1] = beta[coef4]
        and stores the chi-sq stat and p-value in the result dict.
    """
    mask = y.notna() & X.notna().all(axis=1)
    if mask.sum() < 20:
        return {"label": label, "estimator": "FE OLS (cluster key)",
                "n": 0, "results": None}

    X_f = _drop_constant_cols(X[mask])

    mi = pd.MultiIndex.from_arrays(
        [df.loc[mask, "key"].values, df.loc[mask, "year"].values],
        names=["key", "year"],
    )
    dep = pd.DataFrame({"dep": y[mask].values}, index=mi)
    exog = pd.DataFrame(X_f.values, index=mi, columns=X_f.columns)

    mod = PanelOLS(dep, exog, entity_effects=True)
    res = mod.fit(cov_type="clustered", cluster_entity=True)

    result = {
        "label": label,
        "estimator": "FE OLS (cluster key)",
        "n": int(res.nobs),
        "params": res.params.to_dict(),
        "pvalues": res.pvalues.to_dict(),
        "se": res.std_errors.to_dict(),
        "results": None,
    }

    # Optional Wald test: H0 beta[c1] = beta[c4]
    if test_pair is not None:
        c1, c4 = test_pair
        if c1 in res.params.index and c4 in res.params.index:
            b = res.params
            V = res.cov
            diff = b[c1] - b[c4]
            var_diff = V.loc[c1, c1] + V.loc[c4, c4] - 2 * V.loc[c1, c4]
            chi2 = float(diff ** 2 / var_diff)
            pval_test = float(1 - stats.chi2.cdf(chi2, df=1))
            result["wald_chi2"] = chi2
            result["wald_pval"] = pval_test
            result["wald_h0"] = f"{c1} = {c4}"

    return result


# ---------------------------------------------------------------------------
# Section 1: Baseline regressions
# ---------------------------------------------------------------------------

def run_section1(df: pd.DataFrame) -> dict[str, dict]:
    """
    21 FE OLS regressions covering basic output measures (d_va, d_sale,
    d_va_a) and asymmetric expansion/contraction variants.

    Dependents:  d_xrd  |  z_rd_{va,sale,va_a,capx}
    Output vars: symmetric and asymmetric growth rates
    """
    tdums = _time_dummies(df)
    ctrl = _full_controls(df)
    results: dict[str, dict] = {}

    # ------------------------------------------------------------------
    # 3 symmetric-output blocks (lines 225–300 in Stata)
    # Each block: dep = d_xrd / z_rd_{out} / z_rd_capx
    # ------------------------------------------------------------------
    symmetric_blocks = [
        ("d_va",   "z_rd_va",   "va"),
        ("d_sale", "z_rd_sale", "sale"),
        ("d_va_a", "z_rd_va_a", "va_a"),
    ]
    for out_col, z_dep, tag in symmetric_blocks:
        if out_col not in df.columns:
            continue
        out = df[[out_col]]

        results[f"s1_{tag}_dxrd"] = _fe_ols_cluster(
            df["d_xrd"], pd.concat([out, ctrl, tdums], axis=1),
            df, f"s1_{tag}_dxrd")

        if z_dep in df.columns:
            lz1 = df.get(f"l_{z_dep}", pd.Series(dtype=float))
            lz2 = df.get(f"l2_{z_dep}", pd.Series(dtype=float))
            z_rhs = pd.concat([out, ctrl, tdums,
                                lz1.rename(f"l_{z_dep}"),
                                lz2.rename(f"l2_{z_dep}")], axis=1)
            results[f"s1_{tag}_z"] = _fe_ols_cluster(
                df[z_dep], z_rhs, df, f"s1_{tag}_z")

        # z_rd_capx as third dependent
        if "z_rd_capx" in df.columns:
            lz1c = df.get("l_z_rd_capx", pd.Series(dtype=float))
            lz2c = df.get("l2_z_rd_capx", pd.Series(dtype=float))
            capx_rhs = pd.concat([out, ctrl, tdums,
                                   lz1c.rename("l_z_rd_capx"),
                                   lz2c.rename("l2_z_rd_capx")], axis=1)
            results[f"s1_{tag}_zcapx"] = _fe_ols_cluster(
                df["z_rd_capx"], capx_rhs, df, f"s1_{tag}_zcapx")

    # ------------------------------------------------------------------
    # 4 asymmetric-output blocks (lines 258–300 in Stata)
    # Each: output = (d_h_X, d_l_X) pair
    # ------------------------------------------------------------------
    asym_blocks = [
        ("d_h_va",   "d_l_va",   "z_rd_va",   "z_rd_capx", "asym_va_va"),
        ("d_h_sale", "d_l_sale", "z_rd_sale",  "z_rd_capx", "asym_sale_sale"),
        ("d_h_va",   "d_l_va_a", "z_rd_va_a",  "z_rd_capx", "asym_va_va_a"),
        ("d_h_va_a", "d_l_va_a", "z_rd_va_a",  "z_rd_capx", "asym_va_a_va_a"),
    ]
    for h_col, l_col, z_dep, _zcapx, tag in asym_blocks:
        if h_col not in df.columns or l_col not in df.columns:
            continue
        out2 = df[[h_col, l_col]]

        results[f"s1_{tag}_dxrd"] = _fe_ols_cluster(
            df["d_xrd"], pd.concat([out2, ctrl, tdums], axis=1),
            df, f"s1_{tag}_dxrd")

        if z_dep in df.columns:
            lz1 = df.get(f"l_{z_dep}", pd.Series(dtype=float))
            lz2 = df.get(f"l2_{z_dep}", pd.Series(dtype=float))
            z_rhs = pd.concat([out2, ctrl, tdums,
                                lz1.rename(f"l_{z_dep}"),
                                lz2.rename(f"l2_{z_dep}")], axis=1)
            results[f"s1_{tag}_z"] = _fe_ols_cluster(
                df[z_dep], z_rhs, df, f"s1_{tag}_z")

        if "z_rd_capx" in df.columns:
            lz1c = df.get("l_z_rd_capx", pd.Series(dtype=float))
            lz2c = df.get("l2_z_rd_capx", pd.Series(dtype=float))
            capx_rhs = pd.concat([out2, ctrl, tdums,
                                   lz1c.rename("l_z_rd_capx"),
                                   lz2c.rename("l2_z_rd_capx")], axis=1)
            results[f"s1_{tag}_zcapx"] = _fe_ols_cluster(
                df["z_rd_capx"], capx_rhs, df, f"s1_{tag}_zcapx")

    return results


# ---------------------------------------------------------------------------
# Section 2: KZ financial constraints quartiles
# ---------------------------------------------------------------------------

def run_section2(df: pd.DataFrame) -> dict[str, dict]:
    """
    9 regressions with output × KZ quartile interactions (KZ_1–KZ_4).
    Each regression includes a Wald test for quartile_1 = quartile_4.

    Blocks: d_sale_KZ, d_va_a_KZ, d_va_KZ
    Dependents: d_xrd  |  z_rd_sale/va_a/va  |  z_rd_capx
    """
    tdums = _time_dummies(df)
    ctrl = _full_controls(df)
    results: dict[str, dict] = {}

    kz_blocks = [
        # (kz_col_prefix, dep_z, tag)
        ("d_sale", "z_rd_sale", "sale"),
        ("d_va_a", "z_rd_va_a", "va_a"),
        ("d_va",   "z_rd_va",   "va"),
    ]
    for prefix, z_dep, tag in kz_blocks:
        q_cols = [f"{prefix}_kz{i}" for i in range(1, 5)]
        # Check lower-case column names (DB stores them lower-case)
        if not all(c in df.columns for c in q_cols):
            continue
        out = df[q_cols]
        test_pair = (f"{prefix}_kz1", f"{prefix}_kz4")

        # Dep: d_xrd
        results[f"s2_kz_{tag}_dxrd"] = _fe_ols_cluster(
            df["d_xrd"], pd.concat([out, ctrl, tdums], axis=1),
            df, f"s2_kz_{tag}_dxrd", test_pair=test_pair)

        # Dep: z_rd_{tag}
        if z_dep in df.columns:
            lz1 = df.get(f"l_{z_dep}", pd.Series(dtype=float))
            lz2 = df.get(f"l2_{z_dep}", pd.Series(dtype=float))
            z_rhs = pd.concat([out, ctrl, tdums,
                                lz1.rename(f"l_{z_dep}"),
                                lz2.rename(f"l2_{z_dep}")], axis=1)
            results[f"s2_kz_{tag}_z"] = _fe_ols_cluster(
                df[z_dep], z_rhs, df, f"s2_kz_{tag}_z", test_pair=test_pair)

        # Dep: z_rd_capx
        if "z_rd_capx" in df.columns:
            lz1c = df.get("l_z_rd_capx", pd.Series(dtype=float))
            lz2c = df.get("l2_z_rd_capx", pd.Series(dtype=float))
            capx_rhs = pd.concat([out, ctrl, tdums,
                                   lz1c.rename("l_z_rd_capx"),
                                   lz2c.rename("l2_z_rd_capx")], axis=1)
            results[f"s2_kz_{tag}_zcapx"] = _fe_ols_cluster(
                df["z_rd_capx"], capx_rhs, df, f"s2_kz_{tag}_zcapx",
                test_pair=test_pair)

    return results


# ---------------------------------------------------------------------------
# Section 3: WW quartiles + corporate spreads
# ---------------------------------------------------------------------------

def run_section3(df: pd.DataFrame) -> dict[str, dict]:
    """
    36 regressions:
      - 9  WW quartile-interaction blocks (same structure as KZ section 2)
      - 27 corporate spread blocks: ag (AAA growth), bg (BAA growth),
            ba (BAA–AAA spread), each × three output measures (sale,
            va_a, va), with asymmetric high/low indicators.
    """
    tdums = _time_dummies(df)
    ctrl = _full_controls(df)
    results: dict[str, dict] = {}

    # ------------------------------------------------------------------
    # WW quartiles (lines 348–379)
    # ------------------------------------------------------------------
    ww_blocks = [
        ("d_sale", "z_rd_sale", "sale"),
        ("d_va_a", "z_rd_va_a", "va_a"),
        ("d_va",   "z_rd_va",   "va"),
    ]
    for prefix, z_dep, tag in ww_blocks:
        q_cols = [f"{prefix}_ww{i}" for i in range(1, 5)]
        if not all(c in df.columns for c in q_cols):
            continue
        out = df[q_cols]
        test_pair = (f"{prefix}_ww1", f"{prefix}_ww4")

        results[f"s3_ww_{tag}_dxrd"] = _fe_ols_cluster(
            df["d_xrd"], pd.concat([out, ctrl, tdums], axis=1),
            df, f"s3_ww_{tag}_dxrd", test_pair=test_pair)

        if z_dep in df.columns:
            lz1 = df.get(f"l_{z_dep}", pd.Series(dtype=float))
            lz2 = df.get(f"l2_{z_dep}", pd.Series(dtype=float))
            z_rhs = pd.concat([out, ctrl, tdums,
                                lz1.rename(f"l_{z_dep}"),
                                lz2.rename(f"l2_{z_dep}")], axis=1)
            results[f"s3_ww_{tag}_z"] = _fe_ols_cluster(
                df[z_dep], z_rhs, df, f"s3_ww_{tag}_z", test_pair=test_pair)

        if "z_rd_capx" in df.columns:
            lz1c = df.get("l_z_rd_capx", pd.Series(dtype=float))
            lz2c = df.get("l2_z_rd_capx", pd.Series(dtype=float))
            capx_rhs = pd.concat([out, ctrl, tdums,
                                   lz1c.rename("l_z_rd_capx"),
                                   lz2c.rename("l2_z_rd_capx")], axis=1)
            results[f"s3_ww_{tag}_zcapx"] = _fe_ols_cluster(
                df["z_rd_capx"], capx_rhs, df, f"s3_ww_{tag}_zcapx",
                test_pair=test_pair)

    # ------------------------------------------------------------------
    # Corporate spread asymmetric blocks (lines 381–480)
    # spread × output: ag, bg, ba  ×  sale, va_a, va
    # ------------------------------------------------------------------
    spread_output_blocks = [
        # (h_col, l_col, z_dep, tag)
        # ag × sale
        ("d_h_ag_fc_sale", "d_l_ag_fc_sale", "z_rd_sale",  "ag_sale"),
        # ag × va_a
        ("d_h_ag_fc_va_a", "d_l_ag_fc_va_a", "z_rd_va_a",  "ag_va_a"),
        # ag × va
        ("d_h_ag_fc_va",   "d_l_ag_fc_va",   "z_rd_va",    "ag_va"),
        # bg × sale
        ("d_h_bg_fc_sale", "d_l_bg_fc_sale", "z_rd_sale",  "bg_sale"),
        # bg × va_a
        ("d_h_bg_fc_va_a", "d_l_bg_fc_va_a", "z_rd_va_a",  "bg_va_a"),
        # bg × va
        ("d_h_bg_fc_va",   "d_l_bg_fc_va",   "z_rd_va",    "bg_va"),
        # ba × sale
        ("d_h_ba_fc_sale", "d_l_ba_fc_sale", "z_rd_sale",  "ba_sale"),
        # ba × va_a
        ("d_h_ba_fc_va_a", "d_l_ba_fc_va_a", "z_rd_va_a",  "ba_va_a"),
        # ba × va
        ("d_h_ba_fc_va",   "d_l_ba_fc_va",   "z_rd_va",    "ba_va"),
    ]
    for h_col, l_col, z_dep, tag in spread_output_blocks:
        if h_col not in df.columns or l_col not in df.columns:
            continue
        out2 = df[[h_col, l_col]]

        results[f"s3_{tag}_dxrd"] = _fe_ols_cluster(
            df["d_xrd"], pd.concat([out2, ctrl, tdums], axis=1),
            df, f"s3_{tag}_dxrd")

        if z_dep in df.columns:
            lz1 = df.get(f"l_{z_dep}", pd.Series(dtype=float))
            lz2 = df.get(f"l2_{z_dep}", pd.Series(dtype=float))
            z_rhs = pd.concat([out2, ctrl, tdums,
                                lz1.rename(f"l_{z_dep}"),
                                lz2.rename(f"l2_{z_dep}")], axis=1)
            results[f"s3_{tag}_z"] = _fe_ols_cluster(
                df[z_dep], z_rhs, df, f"s3_{tag}_z")

        if "z_rd_capx" in df.columns:
            lz1c = df.get("l_z_rd_capx", pd.Series(dtype=float))
            lz2c = df.get("l2_z_rd_capx", pd.Series(dtype=float))
            capx_rhs = pd.concat([out2, ctrl, tdums,
                                   lz1c.rename("l_z_rd_capx"),
                                   lz2c.rename("l2_z_rd_capx")], axis=1)
            results[f"s3_{tag}_zcapx"] = _fe_ols_cluster(
                df["z_rd_capx"], capx_rhs, df, f"s3_{tag}_zcapx")

    return results


# ---------------------------------------------------------------------------
# Section 4: Demeaned variants
# ---------------------------------------------------------------------------

def run_section4(df: pd.DataFrame) -> dict[str, dict]:
    """
    30 regressions using within-firm-mean-deviated growth rates.
    Mirrors Sections 1–2 but replaces d_xrd with dev_xrd and
    output growth rates with their demeaned counterparts.

    KZ blocks also include Wald equality tests.
    """
    tdums = _time_dummies(df)
    ctrl = _full_controls(df)
    results: dict[str, dict] = {}

    if "dev_xrd" not in df.columns:
        return results

    # ------------------------------------------------------------------
    # Symmetric demeaned output (lines 487–518)
    # ------------------------------------------------------------------
    sym_dem_blocks = [
        ("dev_va",   "z_rd_va",   "va"),
        ("dev_sale", "z_rd_sale", "sale"),
        ("dev_va_a", "z_rd_va_a", "va_a"),
    ]
    for out_col, z_dep, tag in sym_dem_blocks:
        if out_col not in df.columns:
            continue
        out = df[[out_col]]

        results[f"s4_{tag}_dxrd"] = _fe_ols_cluster(
            df["dev_xrd"], pd.concat([out, ctrl, tdums], axis=1),
            df, f"s4_{tag}_dxrd")

        if z_dep in df.columns:
            lz1 = df.get(f"l_{z_dep}", pd.Series(dtype=float))
            lz2 = df.get(f"l2_{z_dep}", pd.Series(dtype=float))
            z_rhs = pd.concat([out, ctrl, tdums,
                                lz1.rename(f"l_{z_dep}"),
                                lz2.rename(f"l2_{z_dep}")], axis=1)
            results[f"s4_{tag}_z"] = _fe_ols_cluster(
                df[z_dep], z_rhs, df, f"s4_{tag}_z")

        if "z_rd_capx" in df.columns:
            lz1c = df.get("l_z_rd_capx", pd.Series(dtype=float))
            lz2c = df.get("l2_z_rd_capx", pd.Series(dtype=float))
            capx_rhs = pd.concat([out, ctrl, tdums,
                                   lz1c.rename("l_z_rd_capx"),
                                   lz2c.rename("l2_z_rd_capx")], axis=1)
            results[f"s4_{tag}_zcapx"] = _fe_ols_cluster(
                df["z_rd_capx"], capx_rhs, df, f"s4_{tag}_zcapx")

    # ------------------------------------------------------------------
    # Asymmetric demeaned output (lines 520–562)
    # ------------------------------------------------------------------
    asym_dem_blocks = [
        ("dev_g_h_va",   "dev_g_l_va",   "z_rd_va",   "asym_va_va"),
        ("dev_g_h_sale", "dev_g_l_sale", "z_rd_sale",  "asym_sale_sale"),
        ("dev_g_h_va",   "dev_g_l_va_a", "z_rd_va_a",  "asym_va_va_a"),
        ("dev_g_h_va_a", "dev_g_l_va_a", "z_rd_va_a",  "asym_va_a_va_a"),
    ]
    for h_col, l_col, z_dep, tag in asym_dem_blocks:
        if h_col not in df.columns or l_col not in df.columns:
            continue
        out2 = df[[h_col, l_col]]

        results[f"s4_{tag}_dxrd"] = _fe_ols_cluster(
            df["dev_xrd"], pd.concat([out2, ctrl, tdums], axis=1),
            df, f"s4_{tag}_dxrd")

        if z_dep in df.columns:
            lz1 = df.get(f"l_{z_dep}", pd.Series(dtype=float))
            lz2 = df.get(f"l2_{z_dep}", pd.Series(dtype=float))
            z_rhs = pd.concat([out2, ctrl, tdums,
                                lz1.rename(f"l_{z_dep}"),
                                lz2.rename(f"l2_{z_dep}")], axis=1)
            results[f"s4_{tag}_z"] = _fe_ols_cluster(
                df[z_dep], z_rhs, df, f"s4_{tag}_z")

        if "z_rd_capx" in df.columns:
            lz1c = df.get("l_z_rd_capx", pd.Series(dtype=float))
            lz2c = df.get("l2_z_rd_capx", pd.Series(dtype=float))
            capx_rhs = pd.concat([out2, ctrl, tdums,
                                   lz1c.rename("l_z_rd_capx"),
                                   lz2c.rename("l2_z_rd_capx")], axis=1)
            results[f"s4_{tag}_zcapx"] = _fe_ols_cluster(
                df["z_rd_capx"], capx_rhs, df, f"s4_{tag}_zcapx")

    # ------------------------------------------------------------------
    # KZ quartiles with demeaned dep (lines 564–606)
    # ------------------------------------------------------------------
    kz_dem_blocks = [
        ("d_sale", "z_rd_sale", "sale"),
        ("d_va_a", "z_rd_va_a", "va_a"),
        ("d_va",   "z_rd_va",   "va"),
    ]
    for prefix, z_dep, tag in kz_dem_blocks:
        q_cols = [f"{prefix}_kz{i}" for i in range(1, 5)]
        if not all(c in df.columns for c in q_cols):
            continue
        out = df[q_cols]
        test_pair = (f"{prefix}_kz1", f"{prefix}_kz4")

        results[f"s4_kz_{tag}_dxrd"] = _fe_ols_cluster(
            df["dev_xrd"], pd.concat([out, ctrl, tdums], axis=1),
            df, f"s4_kz_{tag}_dxrd", test_pair=test_pair)

        if z_dep in df.columns:
            lz1 = df.get(f"l_{z_dep}", pd.Series(dtype=float))
            lz2 = df.get(f"l2_{z_dep}", pd.Series(dtype=float))
            z_rhs = pd.concat([out, ctrl, tdums,
                                lz1.rename(f"l_{z_dep}"),
                                lz2.rename(f"l2_{z_dep}")], axis=1)
            results[f"s4_kz_{tag}_z"] = _fe_ols_cluster(
                df[z_dep], z_rhs, df, f"s4_kz_{tag}_z", test_pair=test_pair)

        if "z_rd_capx" in df.columns:
            lz1c = df.get("l_z_rd_capx", pd.Series(dtype=float))
            lz2c = df.get("l2_z_rd_capx", pd.Series(dtype=float))
            capx_rhs = pd.concat([out, ctrl, tdums,
                                   lz1c.rename("l_z_rd_capx"),
                                   lz2c.rename("l2_z_rd_capx")], axis=1)
            results[f"s4_kz_{tag}_zcapx"] = _fe_ols_cluster(
                df["z_rd_capx"], capx_rhs, df, f"s4_kz_{tag}_zcapx",
                test_pair=test_pair)

    return results


# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------

def results_to_df(results: dict[str, dict]) -> pd.DataFrame:
    """Flatten results dict to a summary DataFrame."""
    rows = []
    for label, r in results.items():
        row = {
            "label": label,
            "estimator": r.get("estimator", ""),
            "n": r.get("n", 0),
            "wald_h0": r.get("wald_h0", ""),
            "wald_chi2": r.get("wald_chi2", np.nan),
            "wald_pval": r.get("wald_pval", np.nan),
        }
        if r.get("params"):
            for coef, val in r["params"].items():
                row[f"coef_{coef}"] = val
            for coef, val in r.get("pvalues", {}).items():
                row[f"pval_{coef}"] = val
            for coef, val in r.get("se", {}).items():
                row[f"se_{coef}"] = val
        rows.append(row)
    return pd.DataFrame(rows)


# Stems to exclude from the "key output coefficient" column in markdown
_CTRL_STEMS = {
    "emp", "r_cf", "r_dd1", "r_dltt", "r_lt", "r_at", "r_ppent",
    "l_r_", "l2_r_", "l_z_", "l2_z_",
}


def _is_output_coef(name: str) -> bool:
    """Return True if coef name is an output / treatment variable."""
    if name.startswith("t") and name[1:].isdigit():
        return False  # time dummy
    for stem in _CTRL_STEMS:
        if name.startswith(stem):
            return False
    return True


def build_markdown_summary(results: dict[str, dict]) -> str:
    lines = [
        "# Financial Constraints: Estimation Summary",
        "",
        "Replication of [5]_data_financial_constraints.do (FE OLS, cluster key).",
        "",
        "| Spec | Dep | Output coef | Est | p-value | n | Wald chi2 | Wald p |",
        "|------|-----|-------------|-----|---------|---|-----------|--------|",
    ]
    for label, r in results.items():
        if not r.get("params"):
            continue
        params = r["params"]
        pvals = r["pvalues"]
        out_coefs = {k: v for k, v in params.items() if _is_output_coef(k)}
        wald_chi2 = r.get("wald_chi2", float("nan"))
        wald_pval = r.get("wald_pval", float("nan"))
        for coef, val in out_coefs.items():
            pv = pvals.get(coef, float("nan"))
            stars = ("***" if pv < 0.01 else
                     "**"  if pv < 0.05 else
                     "*"   if pv < 0.1  else "")
            wchi = f"{wald_chi2:.2f}" if np.isfinite(wald_chi2) else ""
            wp   = f"{wald_pval:.3f}" if np.isfinite(wald_pval) else ""
            lines.append(
                f"| {label} | {coef} | {coef} | "
                f"{val:.4f}{stars} | {pv:.3f} | {r['n']:,} | {wchi} | {wp} |"
            )
    return "\n".join(lines) + "\n"


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:
    print("Loading data from cyclicality.db …")
    with sqlite3.connect(DB_PATH) as conn:
        df = pd.read_sql_query(
            "SELECT * FROM processed_financial_constraints", conn
        )
    print(f"  Loaded {len(df):,} rows, {len(df.columns)} columns.")
    print(f"  Panel: {df['key'].nunique():,} firms, "
          f"years {int(df['year'].min())}-{int(df['year'].max())}")

    print("Building analysis variables (lags, missing interactions) …")
    df = build_analysis_vars(df)

    all_results: dict[str, dict] = {}

    print("Section 1: Baseline regressions …")
    s1 = run_section1(df)
    all_results.update(s1)
    print(f"  Completed {len(s1)} regressions.")

    print("Section 2: KZ financial constraints quartiles …")
    s2 = run_section2(df)
    all_results.update(s2)
    print(f"  Completed {len(s2)} regressions.")

    print("Section 3: WW quartiles + corporate spreads …")
    s3 = run_section3(df)
    all_results.update(s3)
    print(f"  Completed {len(s3)} regressions.")

    print("Section 4: Demeaned variants …")
    s4 = run_section4(df)
    all_results.update(s4)
    print(f"  Completed {len(s4)} regressions.")

    print(f"Total regressions: {len(all_results)}")

    print("Saving results …")
    summary_df = results_to_df(all_results)
    with pd.ExcelWriter(XLSX_PATH, engine="openpyxl") as writer:
        summary_df.to_excel(writer, sheet_name="results", index=False)

    md_text = build_markdown_summary(all_results)
    MD_PATH.write_text(md_text, encoding="utf-8")

    print(f"Wrote {XLSX_PATH}")
    print(f"Wrote {MD_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
