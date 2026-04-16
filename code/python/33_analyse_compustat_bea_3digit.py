#!/usr/bin/env python3
"""
analyse_compustat_bea_3digit.py
================================
Python replication of [3]_compustat_BEA_3digits.do.

Data source: processed_compustat_bea_3digit table in cyclicality.db.
Panel structure: key (firm), year.

The Stata script runs two identical estimation grids that differ only in the
clustering variable.  Each grid contains:

  1.  FE OLS — symmetric output measures (go, va_i, sale, va_a)
  2.  FE OLS — asymmetric output splits (d_h_*, d_l_*)
  3.  FE IV  — symmetric and asymmetric (industry growth rates as instruments)
  4.  Demeaned OLS — symmetric and asymmetric
  5.  Demeaned IV  — symmetric and asymmetric
  6.  Demeaned GMM2

Grid 1: cluster at entity (key) level
Grid 2: cluster at 3-digit NAICS (naics3) level

Estimation equivalences
-----------------------
Stata: xtreg ... i.year, fe vce(cluster key/naics)
Python: PanelOLS(entity_effects=True, time_effects=True), cov_type='clustered'

Stata: xtivreg2 ... i.year, fe cluster(key/naics) [gmm2]
Python: two-way within-demean (entity+time) + IV2SLS/IVGMM, cov_type='clustered'

Controls: emp, r_cf, r_dd1, r_dltt, r_lt, r_at, r_ppent, their lags (l. l2.)
Year FE absorbed via entity+time_effects in OLS; two-way demeaning in IV.

Note
----
The Stata script appends system-GMM blocks (xtabond / xtdpdsys) at the end.
These estimators are not available in standard Python panel packages and are
omitted.  Their Python equivalents would require linearmodels.panel.FamaMacBeth
or a custom Arellano-Bond implementation; this is flagged in the output.

Output
------
  results/compustat_bea_3digit_results.xlsx   (one sheet per block)
  results/compustat_bea_3digit_results.md     (headline coefficient summary)
"""

from __future__ import annotations

import sqlite3
import warnings
from pathlib import Path

import numpy as np
import pandas as pd
import statsmodels.api as sm
from linearmodels.panel import PanelOLS
from linearmodels.iv import IV2SLS, IVGMM

warnings.filterwarnings("ignore", category=FutureWarning)
warnings.filterwarnings("ignore", category=pd.errors.PerformanceWarning)
warnings.filterwarnings("ignore", "invalid value encountered in sqrt")

ROOT = Path(__file__).resolve().parents[2]
DB_PATH = ROOT / "data" / "cyclicality.db"
RESULTS_DIR = ROOT / "results"
RESULTS_DIR.mkdir(exist_ok=True)

XLSX_PATH = RESULTS_DIR / "compustat_bea_3digit_results.xlsx"
MD_PATH = RESULTS_DIR / "compustat_bea_3digit_results.md"

# ---------------------------------------------------------------------------
# Panel utility helpers
# ---------------------------------------------------------------------------

def panel_lag(df: pd.DataFrame, col: str,
              panel: str = "key", time: str = "year",
              n: int = 1) -> pd.Series:
    """Lag `col` by `n` periods within each panel unit.

    Returns NaN whenever the consecutive-year condition fails, so panel gaps
    are never bridged.
    """
    grp = df.groupby(panel, dropna=False, sort=False)
    lagged = grp[col].shift(n)
    prev_year = pd.to_numeric(grp[time].shift(n), errors="coerce")
    curr_year = pd.to_numeric(df[time], errors="coerce")
    return lagged.where((curr_year - prev_year) == n)


def panel_lead(df: pd.DataFrame, col: str,
               panel: str = "key", time: str = "year",
               n: int = 1) -> pd.Series:
    """Lead `col` by `n` periods within each panel unit."""
    grp = df.groupby(panel, dropna=False, sort=False)
    led = grp[col].shift(-n)
    next_year = pd.to_numeric(grp[time].shift(-n), errors="coerce")
    curr_year = pd.to_numeric(df[time], errors="coerce")
    return led.where((next_year - curr_year) == n)


# ---------------------------------------------------------------------------
# Variable construction
# ---------------------------------------------------------------------------

def build_analysis_vars(df: pd.DataFrame) -> pd.DataFrame:
    """Add lags, leads, and any missing derived variables needed for estimation."""
    df = df.sort_values(["key", "year"]).copy()
    df["year"] = pd.to_numeric(df["year"], errors="coerce").astype("Int64")

    # Lags of financial controls (l. and l2.)
    ctrl_lag_cols = ["r_cf", "r_dd1", "r_dltt", "r_lt", "r_at"]
    for col in ctrl_lag_cols:
        if col in df.columns:
            df[f"l_{col}"] = panel_lag(df, col)
            df[f"l2_{col}"] = panel_lag(df, col, n=2)

    # Lags of R&D intensity ratios (l. and l2.)
    intensity_cols = [
        "z_rd_go", "z_rd_va_i", "z_rd_sale", "z_rd_va_a", "z_rd_capx",
    ]
    for col in intensity_cols:
        if col in df.columns:
            df[f"l_{col}"] = panel_lag(df, col)
            df[f"l2_{col}"] = panel_lag(df, col, n=2)

    # Leads of industry-level growth rates used as IV instruments
    for col in ["d_go", "d_va_i",
                "d_h_go", "d_l_go", "d_h_va_i", "d_l_va_i"]:
        if col in df.columns:
            df[f"f_{col}"] = panel_lead(df, col)

    # Leads of demeaned growth rates used as instruments in the demeaned section
    for col in ["dev_go", "dev_va_i",
                "dev_g_h_go", "dev_g_l_go",
                "dev_g_h_va_i", "dev_g_l_va_i"]:
        if col in df.columns:
            df[f"f_{col}"] = panel_lead(df, col)

    return df


# ---------------------------------------------------------------------------
# Regression wrappers
# ---------------------------------------------------------------------------

def _drop_constant_cols(X: pd.DataFrame) -> pd.DataFrame:
    """Drop columns with no variation (e.g. time dummies outside the panel
    window after complete-case filtering).  Mirrors Stata's automatic handling
    of collinear variables."""
    varying = X.columns[X.nunique() > 1]
    return X[varying]


def _fe_ols_cluster(y: pd.Series, X: pd.DataFrame,
                    df: pd.DataFrame, label: str,
                    cluster_col: str = "key") -> dict:
    """Two-way FE OLS with clustered SEs.

    Stata: xtreg ... i.year, fe vce(cluster {cluster_col})
    Python: PanelOLS(entity_effects=True, time_effects=True)
    """
    mask = y.notna() & X.notna().all(axis=1)
    n_obs = mask.sum()
    if n_obs < 20:
        return {"label": label, "estimator": "FE OLS", "n": 0, "results": None}

    X_f = _drop_constant_cols(X[mask])

    mi = pd.MultiIndex.from_arrays(
        [df.loc[mask, "key"].values, df.loc[mask, "year"].values],
        names=["key", "year"],
    )
    dep = pd.DataFrame({"dep": y[mask].values}, index=mi)
    exog = pd.DataFrame(X_f.values, index=mi, columns=X_f.columns)

    mod = PanelOLS(dep, exog, entity_effects=True, time_effects=True)
    if cluster_col == "key":
        res = mod.fit(cov_type="clustered", cluster_entity=True)
    else:
        # For non-entity clustering (e.g. naics3), pass a Series with the
        # same MultiIndex (entity, time) as the panel data.
        cl_series = pd.Series(
            pd.Categorical(df.loc[mask, cluster_col]).codes,
            index=mi,
            name="cluster",
        )
        res = mod.fit(cov_type="clustered", clusters=cl_series)

    return _extract_panel(res, label, "FE OLS")


def _two_way_demean_batch(df_all: pd.DataFrame,
                          entity: pd.Series,
                          time: pd.Series) -> pd.DataFrame:
    """Batch two-way within-transform for all columns simultaneously.

    Computes  X_w = X - entity_mean(X) - time_mean(X) + grand_mean(X)
    using a single groupby per axis, which is ~N_cols times faster than
    column-by-column demeaning.

    This is the exact Mundlak within estimator, equivalent to
    xtivreg2 ... i.year, fe in Stata (one-pass; unbiased for orthogonal FEs).
    """
    em = df_all.groupby(entity, sort=False).transform("mean")
    tm = df_all.groupby(time, sort=False).transform("mean")
    gm = df_all.mean()
    return df_all - em - tm + gm


def _fe_iv_cluster(y: pd.Series, X_exog: pd.DataFrame,
                   X_endog: pd.DataFrame, Z: pd.DataFrame,
                   df: pd.DataFrame, label: str,
                   gmm2: bool = False,
                   cluster_col: str = "key") -> dict:
    """Two-way FE 2SLS or GMM2 via within-demeaning + IV2SLS/IVGMM.

    Stata: xtivreg2 ... i.year, fe cluster({cluster_col}) [gmm2]
    Python: entity+time within transform, then IV2SLS/IVGMM with clustered SEs.
    """
    mask = (y.notna()
            & X_exog.notna().all(axis=1)
            & X_endog.notna().all(axis=1)
            & Z.notna().all(axis=1))
    est = "FE GMM2" if gmm2 else "FE IV"
    if mask.sum() < 20:
        return {"label": label, "estimator": est, "n": 0, "results": None}

    # Deduplicate column list (cluster_col may equal "key")
    _cols = list(dict.fromkeys(["key", "year", cluster_col]))
    df_sub = df.loc[mask, _cols].copy()
    y_s = y[mask].copy().rename("__y__")
    Xe_s = X_exog[mask].copy()
    Xn_s = X_endog[mask].copy()
    Z_s = Z[mask].copy()

    entity = df_sub["key"]
    time = df_sub["year"]

    # Batch demean all variables in one pass per axis — prevents OOM on large
    # panels by avoiding repeated groupby calls per column.
    all_cols = pd.concat([y_s, Xe_s, Xn_s, Z_s], axis=1)
    demeaned = _two_way_demean_batch(all_cols, entity, time)

    y_w = demeaned["__y__"]
    Xe_w = demeaned[Xe_s.columns]
    Xn_w = demeaned[Xn_s.columns]
    Z_w = demeaned[Z_s.columns]

    Xc_w = sm.add_constant(Xe_w, has_constant="add")
    cluster_ids = pd.Categorical(df_sub[cluster_col]).codes

    try:
        cls = IVGMM if gmm2 else IV2SLS
        res = cls(y_w, Xc_w, Xn_w, Z_w).fit(
            cov_type="clustered", clusters=cluster_ids
        )
    except Exception as e:
        return {"label": label, "estimator": est, "n": int(mask.sum()),
                "results": None, "error": str(e)}

    return _extract_iv(res, label, est)


def _extract_panel(res, label: str, estimator: str) -> dict:
    """Extract summary statistics only — do not retain the result object to
    avoid accumulating large linearmodels objects in memory."""
    return {
        "label": label, "estimator": estimator,
        "n": int(res.nobs),
        "params": res.params.to_dict(),
        "pvalues": res.pvalues.to_dict(),
        "se": res.std_errors.to_dict(),
        "results": None,   # object discarded to save memory
    }


def _extract_iv(res, label: str, estimator: str) -> dict:
    """Extract summary statistics only."""
    return {
        "label": label, "estimator": estimator,
        "n": int(res.nobs),
        "params": res.params.to_dict(),
        "pvalues": res.pvalues.to_dict(),
        "se": res.std_errors.to_dict(),
        "results": None,   # object discarded to save memory
    }


# ---------------------------------------------------------------------------
# Standard regressor sets
# ---------------------------------------------------------------------------

def _financial_controls(df: pd.DataFrame) -> pd.DataFrame:
    """Standard controls + lags used throughout the script.

    Corresponds to:
      emp r_cf r_dd1 r_dltt r_lt r_at r_ppent
      l.(r_cf r_dd1 r_dltt r_lt r_at)
      l2.(r_cf r_dd1 r_dltt r_lt r_at)
    """
    base = ["emp", "r_cf", "r_dd1", "r_dltt", "r_lt", "r_at", "r_ppent"]
    lag_cols = ["r_cf", "r_dd1", "r_dltt", "r_lt", "r_at"]
    l1 = [f"l_{c}" for c in lag_cols]
    l2 = [f"l2_{c}" for c in lag_cols]
    all_cols = base + l1 + l2
    return df[[c for c in all_cols if c in df.columns]]


# ---------------------------------------------------------------------------
# OLS regression blocks
# ---------------------------------------------------------------------------

def run_ols_sym(df: pd.DataFrame, output_col: str,
                z_B: str, block_name: str,
                cluster_col: str = "key") -> list[dict]:
    """OLS symmetric block for one output measure.

    A: d_xrd ~ output_col + controls + FEs
    B: z_B   ~ l.z_B l2.z_B output_col + controls + FEs
    C: z_rd_capx ~ l.z_rd_capx l2.z_rd_capx output_col + controls + FEs
    """
    ctrl = _financial_controls(df)
    results = []

    # A
    X_A = pd.concat([df[[output_col]], ctrl], axis=1)
    results.append(_fe_ols_cluster(df["d_xrd"], X_A, df,
                                   f"{block_name}_A", cluster_col))
    # B
    lB = df.get(f"l_{z_B}")
    l2B = df.get(f"l2_{z_B}")
    if lB is not None and l2B is not None:
        X_B = pd.concat([lB.rename(f"l_{z_B}"),
                          l2B.rename(f"l2_{z_B}"),
                          df[[output_col]], ctrl], axis=1)
        results.append(_fe_ols_cluster(df[z_B], X_B, df,
                                       f"{block_name}_B", cluster_col))
    else:
        results.append({"label": f"{block_name}_B", "estimator": "FE OLS",
                        "n": 0, "results": None})
    # C
    lC = df.get("l_z_rd_capx")
    l2C = df.get("l2_z_rd_capx")
    if lC is not None and l2C is not None:
        X_C = pd.concat([lC.rename("l_z_rd_capx"),
                          l2C.rename("l2_z_rd_capx"),
                          df[[output_col]], ctrl], axis=1)
        results.append(_fe_ols_cluster(df["z_rd_capx"], X_C, df,
                                       f"{block_name}_C", cluster_col))
    else:
        results.append({"label": f"{block_name}_C", "estimator": "FE OLS",
                        "n": 0, "results": None})
    return results


def run_ols_asym(df: pd.DataFrame, gh_col: str, gl_col: str,
                 z_B: str, block_name: str,
                 cluster_col: str = "key") -> list[dict]:
    """OLS asymmetric block for one output split pair.

    A: d_xrd    ~ gh_col gl_col + controls + FEs
    B: z_B      ~ l.z_B l2.z_B gh_col gl_col + controls + FEs
    C: z_rd_capx ~ l l2 gh_col gl_col + controls + FEs
    """
    ctrl = _financial_controls(df)
    results = []

    X_A = pd.concat([df[[gh_col, gl_col]], ctrl], axis=1)
    results.append(_fe_ols_cluster(df["d_xrd"], X_A, df,
                                   f"{block_name}_A", cluster_col))

    lB = df.get(f"l_{z_B}")
    l2B = df.get(f"l2_{z_B}")
    if lB is not None and l2B is not None:
        X_B = pd.concat([lB.rename(f"l_{z_B}"),
                          l2B.rename(f"l2_{z_B}"),
                          df[[gh_col, gl_col]], ctrl], axis=1)
        results.append(_fe_ols_cluster(df[z_B], X_B, df,
                                       f"{block_name}_B", cluster_col))
    else:
        results.append({"label": f"{block_name}_B", "estimator": "FE OLS",
                        "n": 0, "results": None})

    lC = df.get("l_z_rd_capx")
    l2C = df.get("l2_z_rd_capx")
    if lC is not None and l2C is not None:
        X_C = pd.concat([lC.rename("l_z_rd_capx"),
                          l2C.rename("l2_z_rd_capx"),
                          df[[gh_col, gl_col]], ctrl], axis=1)
        results.append(_fe_ols_cluster(df["z_rd_capx"], X_C, df,
                                       f"{block_name}_C", cluster_col))
    else:
        results.append({"label": f"{block_name}_C", "estimator": "FE OLS",
                        "n": 0, "results": None})
    return results


# ---------------------------------------------------------------------------
# IV regression blocks
# ---------------------------------------------------------------------------

def run_iv_sym_block(df: pd.DataFrame,
                     endog_col: str, iv_cols: list[str],
                     dep_A: str, z_B: str,
                     block_name: str,
                     cluster_col: str = "key",
                     gmm2: bool = False) -> list[dict]:
    """FE IV block for one symmetric (single-endogenous) specification.

    A: dep_A    ~ (endog_col = IVs) + controls + FEs
    B: z_B      ~ l.z_B l2.z_B (endog_col = IVs) + controls + FEs
    C: z_rd_capx ~ l l2 (endog_col = IVs) + controls + FEs
    """
    ctrl = _financial_controls(df)
    X_endog = df[[endog_col]]
    Z = df[iv_cols]
    results = []

    # A
    results.append(_fe_iv_cluster(df[dep_A], ctrl, X_endog, Z, df,
                                  f"{block_name}_A", gmm2, cluster_col))
    # B
    lB = df.get(f"l_{z_B}")
    l2B = df.get(f"l2_{z_B}")
    if lB is not None and l2B is not None:
        Xe_B = pd.concat([lB.rename(f"l_{z_B}"),
                           l2B.rename(f"l2_{z_B}"), ctrl], axis=1)
        results.append(_fe_iv_cluster(df[z_B], Xe_B, X_endog, Z, df,
                                      f"{block_name}_B", gmm2, cluster_col))
    else:
        results.append({"label": f"{block_name}_B",
                        "estimator": "FE GMM2" if gmm2 else "FE IV",
                        "n": 0, "results": None})
    # C
    lC = df.get("l_z_rd_capx")
    l2C = df.get("l2_z_rd_capx")
    if lC is not None and l2C is not None:
        Xe_C = pd.concat([lC.rename("l_z_rd_capx"),
                           l2C.rename("l2_z_rd_capx"), ctrl], axis=1)
        results.append(_fe_iv_cluster(df["z_rd_capx"], Xe_C, X_endog, Z, df,
                                      f"{block_name}_C", gmm2, cluster_col))
    else:
        results.append({"label": f"{block_name}_C",
                        "estimator": "FE GMM2" if gmm2 else "FE IV",
                        "n": 0, "results": None})
    return results


def run_iv_asym_block(df: pd.DataFrame,
                      endog_cols: list[str], iv_cols: list[str],
                      dep_A: str, z_B: str,
                      block_name: str,
                      cluster_col: str = "key",
                      gmm2: bool = False) -> list[dict]:
    """FE IV block for one asymmetric (two-endogenous) specification.

    Stata: xtivreg2 dep_A (endog_h endog_l = IVs...) controls i.year, fe
    """
    ctrl = _financial_controls(df)
    X_endog = df[endog_cols]
    Z = df[iv_cols]
    results = []

    results.append(_fe_iv_cluster(df[dep_A], ctrl, X_endog, Z, df,
                                  f"{block_name}_A", gmm2, cluster_col))

    lB = df.get(f"l_{z_B}")
    l2B = df.get(f"l2_{z_B}")
    if lB is not None and l2B is not None:
        Xe_B = pd.concat([lB.rename(f"l_{z_B}"),
                           l2B.rename(f"l2_{z_B}"), ctrl], axis=1)
        results.append(_fe_iv_cluster(df[z_B], Xe_B, X_endog, Z, df,
                                      f"{block_name}_B", gmm2, cluster_col))
    else:
        results.append({"label": f"{block_name}_B",
                        "estimator": "FE GMM2" if gmm2 else "FE IV",
                        "n": 0, "results": None})

    lC = df.get("l_z_rd_capx")
    l2C = df.get("l2_z_rd_capx")
    if lC is not None and l2C is not None:
        Xe_C = pd.concat([lC.rename("l_z_rd_capx"),
                           l2C.rename("l2_z_rd_capx"), ctrl], axis=1)
        results.append(_fe_iv_cluster(df["z_rd_capx"], Xe_C, X_endog, Z, df,
                                      f"{block_name}_C", gmm2, cluster_col))
    else:
        results.append({"label": f"{block_name}_C",
                        "estimator": "FE GMM2" if gmm2 else "FE IV",
                        "n": 0, "results": None})
    return results


# ---------------------------------------------------------------------------
# Main estimation grid
# ---------------------------------------------------------------------------

def run_all_blocks(df: pd.DataFrame,
                   cluster_col: str = "key") -> dict[str, list[dict]]:
    """Run the full estimation grid for one clustering specification.

    Returns a dict mapping block_name → list of regression result dicts.
    """
    tag = f"cl_{cluster_col}"
    all_results: dict[str, list[dict]] = {}

    # ------------------------------------------------------------------
    # Section 1: FE OLS — Symmetric
    # ------------------------------------------------------------------
    print(f"  [{tag}] 1. OLS symmetric")
    sym_specs = [
        ("d_go",   "z_rd_go",   "go"),
        ("d_va_i", "z_rd_va_i", "va_i"),
        ("d_sale", "z_rd_sale", "sale"),
        ("d_va_a", "z_rd_va_a", "va_a"),
    ]
    for out_col, z_B, label in sym_specs:
        if out_col in df.columns and z_B in df.columns:
            key = f"ols_sym_{label}_{tag}"
            all_results[key] = run_ols_sym(
                df, out_col, z_B, key, cluster_col=cluster_col)

    # ------------------------------------------------------------------
    # Section 2: FE OLS — Asymmetric
    # ------------------------------------------------------------------
    print(f"  [{tag}] 2. OLS asymmetric")
    asym_specs = [
        ("d_h_go",   "d_l_go",   "z_rd_go",   "go"),
        ("d_h_va_i", "d_l_va_i", "z_rd_va_i", "va_i"),
        ("d_h_va_a", "d_l_va_a", "z_rd_va_a", "va_a"),
        ("d_h_sale", "d_l_sale", "z_rd_sale",  "sale"),
    ]
    for gh, gl, z_B, label in asym_specs:
        if gh in df.columns and gl in df.columns:
            key = f"ols_asym_{label}_{tag}"
            all_results[key] = run_ols_asym(
                df, gh, gl, z_B, key, cluster_col=cluster_col)

    # ------------------------------------------------------------------
    # Section 3: FE IV — Symmetric (d_sale, d_va_a endogenous)
    # ------------------------------------------------------------------
    print(f"  [{tag}] 3. IV symmetric")
    # a: d_sale = (d_go, f.d_go)
    if all(c in df.columns for c in ["d_sale", "d_go", "f_d_go"]):
        key = f"iv_sym_sale_go_{tag}"
        all_results[key] = run_iv_sym_block(
            df, "d_sale", ["d_go", "f_d_go"],
            "d_xrd", "z_rd_sale", key, cluster_col)

    # b: d_sale = (d_va_i, f.d_va_i)
    if all(c in df.columns for c in ["d_sale", "d_va_i", "f_d_va_i"]):
        key = f"iv_sym_sale_va_i_{tag}"
        all_results[key] = run_iv_sym_block(
            df, "d_sale", ["d_va_i", "f_d_va_i"],
            "d_xrd", "z_rd_sale", key, cluster_col)

    # c: d_va_a = (d_va_i, f.d_va_i)
    if all(c in df.columns for c in ["d_va_a", "d_va_i", "f_d_va_i"]):
        key = f"iv_sym_va_a_va_i_{tag}"
        all_results[key] = run_iv_sym_block(
            df, "d_va_a", ["d_va_i", "f_d_va_i"],
            "d_xrd", "z_rd_va_a", key, cluster_col)

    # d: d_va_a = (d_go, f.d_go)
    if all(c in df.columns for c in ["d_va_a", "d_go", "f_d_go"]):
        key = f"iv_sym_va_a_go_{tag}"
        all_results[key] = run_iv_sym_block(
            df, "d_va_a", ["d_go", "f_d_go"],
            "d_xrd", "z_rd_va_a", key, cluster_col)

    # ------------------------------------------------------------------
    # Section 4: FE IV — Asymmetric
    # ------------------------------------------------------------------
    print(f"  [{tag}] 4. IV asymmetric")
    # e: (d_h_sale, d_l_sale) = (d_h_go, d_l_go, f.d_h_go, f.d_l_go)
    iv_e = ["d_h_go", "d_l_go", "f_d_h_go", "f_d_l_go"]
    if all(c in df.columns for c in ["d_h_sale", "d_l_sale"] + iv_e):
        key = f"iv_asym_sale_go_{tag}"
        all_results[key] = run_iv_asym_block(
            df, ["d_h_sale", "d_l_sale"], iv_e,
            "d_xrd", "z_rd_sale", key, cluster_col)

    # f: (d_h_sale, d_l_sale) = (d_h_va_i, d_l_va_i, f.d_h_va_i, f.d_l_va_i)
    iv_f = ["d_h_va_i", "d_l_va_i", "f_d_h_va_i", "f_d_l_va_i"]
    if all(c in df.columns for c in ["d_h_sale", "d_l_sale"] + iv_f):
        key = f"iv_asym_sale_va_i_{tag}"
        all_results[key] = run_iv_asym_block(
            df, ["d_h_sale", "d_l_sale"], iv_f,
            "d_xrd", "z_rd_sale", key, cluster_col)

    # g: (d_h_va_a, d_l_va_a) = (d_h_va_i, d_l_va_i, f.d_h_va_i, f.d_l_va_i)
    if all(c in df.columns for c in ["d_h_va_a", "d_l_va_a"] + iv_f):
        key = f"iv_asym_va_a_va_i_{tag}"
        all_results[key] = run_iv_asym_block(
            df, ["d_h_va_a", "d_l_va_a"], iv_f,
            "d_xrd", "z_rd_va_a", key, cluster_col)

    # h: (d_h_va_a, d_l_va_a) = (d_h_go, d_l_go, f.d_h_go, f.d_l_go)
    if all(c in df.columns for c in ["d_h_va_a", "d_l_va_a"] + iv_e):
        key = f"iv_asym_va_a_go_{tag}"
        all_results[key] = run_iv_asym_block(
            df, ["d_h_va_a", "d_l_va_a"], iv_e,
            "d_xrd", "z_rd_va_a", key, cluster_col)

    # ------------------------------------------------------------------
    # Section 5: Demeaned OLS — Symmetric
    # ------------------------------------------------------------------
    print(f"  [{tag}] 5. Demeaned OLS symmetric")
    dev_sym_specs = [
        ("dev_go",   "z_rd_go",   "go"),
        ("dev_va_i", "z_rd_va_i", "va_i"),
        ("dev_sale", "z_rd_sale", "sale"),
        ("dev_va_a", "z_rd_va_a", "va_a"),
    ]
    for out_col, z_B, label in dev_sym_specs:
        if out_col in df.columns:
            key = f"ols_dev_sym_{label}_{tag}"
            all_results[key] = run_ols_sym(
                df, out_col, z_B, key, cluster_col=cluster_col)

    # ------------------------------------------------------------------
    # Section 6: Demeaned OLS — Asymmetric
    # ------------------------------------------------------------------
    print(f"  [{tag}] 6. Demeaned OLS asymmetric")
    dev_asym_specs = [
        ("dev_h_go",      "dev_l_go",      "z_rd_go",   "go"),
        ("dev_g_h_va_i",  "dev_g_l_va_i",  "z_rd_va_i", "va_i"),
        ("dev_g_h_va_a",  "dev_g_l_va_a",  "z_rd_va_a", "va_a"),
        ("dev_g_h_sale",  "dev_g_l_sale",  "z_rd_sale",  "sale"),
    ]
    for gh, gl, z_B, label in dev_asym_specs:
        if gh in df.columns and gl in df.columns:
            key = f"ols_dev_asym_{label}_{tag}"
            all_results[key] = run_ols_asym(
                df, gh, gl, z_B, key, cluster_col=cluster_col)

    # ------------------------------------------------------------------
    # Section 7: Demeaned IV — Symmetric
    # ------------------------------------------------------------------
    print(f"  [{tag}] 7. Demeaned IV symmetric")
    # a: dev_sale = (dev_go, f.dev_go)
    if all(c in df.columns for c in ["dev_sale", "dev_go", "f_dev_go"]):
        key = f"iv_dev_sym_sale_go_{tag}"
        all_results[key] = run_iv_sym_block(
            df, "dev_sale", ["dev_go", "f_dev_go"],
            "dev_xrd", "z_rd_sale", key, cluster_col)

    # b: dev_sale = (dev_va_i, f.dev_va_i)
    if all(c in df.columns for c in ["dev_sale", "dev_va_i", "f_dev_va_i"]):
        key = f"iv_dev_sym_sale_va_i_{tag}"
        all_results[key] = run_iv_sym_block(
            df, "dev_sale", ["dev_va_i", "f_dev_va_i"],
            "dev_xrd", "z_rd_sale", key, cluster_col)

    # c: dev_va_a = (dev_va_i, f.dev_va_i)
    if all(c in df.columns for c in ["dev_va_a", "dev_va_i", "f_dev_va_i"]):
        key = f"iv_dev_sym_va_a_va_i_{tag}"
        all_results[key] = run_iv_sym_block(
            df, "dev_va_a", ["dev_va_i", "f_dev_va_i"],
            "dev_xrd", "z_rd_va_a", key, cluster_col)

    # ------------------------------------------------------------------
    # Section 8: Demeaned IV — Asymmetric
    # ------------------------------------------------------------------
    print(f"  [{tag}] 8. Demeaned IV asymmetric")
    # d: (dev_g_h_sale, dev_g_l_sale) = (dev_g_h_go, dev_g_l_go, leads)
    iv_devd = ["dev_g_h_go", "dev_g_l_go", "f_dev_g_h_go", "f_dev_g_l_go"]
    if all(c in df.columns for c in ["dev_g_h_sale", "dev_g_l_sale"] + iv_devd):
        key = f"iv_dev_asym_sale_go_{tag}"
        all_results[key] = run_iv_asym_block(
            df, ["dev_g_h_sale", "dev_g_l_sale"], iv_devd,
            "dev_xrd", "z_rd_sale", key, cluster_col)

    # e: (dev_g_h_sale, dev_g_l_sale) = (dev_g_h_va_i, dev_g_l_va_i, leads)
    iv_deve = ["dev_g_h_va_i", "dev_g_l_va_i", "f_dev_g_h_va_i", "f_dev_g_l_va_i"]
    if all(c in df.columns for c in ["dev_g_h_sale", "dev_g_l_sale"] + iv_deve):
        key = f"iv_dev_asym_sale_va_i_{tag}"
        all_results[key] = run_iv_asym_block(
            df, ["dev_g_h_sale", "dev_g_l_sale"], iv_deve,
            "dev_xrd", "z_rd_sale", key, cluster_col)

    # f: (dev_g_h_va_a, dev_g_l_va_a) = (dev_g_h_va_i, dev_g_l_va_i, leads)
    if all(c in df.columns for c in ["dev_g_h_va_a", "dev_g_l_va_a"] + iv_deve):
        key = f"iv_dev_asym_va_a_va_i_{tag}"
        all_results[key] = run_iv_asym_block(
            df, ["dev_g_h_va_a", "dev_g_l_va_a"], iv_deve,
            "dev_xrd", "z_rd_va_a", key, cluster_col)

    # ------------------------------------------------------------------
    # Section 9: Demeaned GMM2 (same specs as IV, gmm2=True)
    # ------------------------------------------------------------------
    print(f"  [{tag}] 9. Demeaned GMM2")
    if all(c in df.columns for c in ["dev_sale", "dev_go", "f_dev_go"]):
        key = f"gmm2_dev_sale_go_{tag}"
        all_results[key] = run_iv_sym_block(
            df, "dev_sale", ["dev_go", "f_dev_go"],
            "dev_xrd", "z_rd_sale", key, cluster_col, gmm2=True)

    if all(c in df.columns for c in ["dev_sale", "dev_va_i", "f_dev_va_i"]):
        key = f"gmm2_dev_sale_va_i_{tag}"
        all_results[key] = run_iv_sym_block(
            df, "dev_sale", ["dev_va_i", "f_dev_va_i"],
            "dev_xrd", "z_rd_sale", key, cluster_col, gmm2=True)

    if all(c in df.columns for c in ["dev_va_a", "dev_va_i", "f_dev_va_i"]):
        key = f"gmm2_dev_va_a_va_i_{tag}"
        all_results[key] = run_iv_sym_block(
            df, "dev_va_a", ["dev_va_i", "f_dev_va_i"],
            "dev_xrd", "z_rd_va_a", key, cluster_col, gmm2=True)

    if all(c in df.columns for c in ["dev_g_h_sale", "dev_g_l_sale"] + iv_devd):
        key = f"gmm2_dev_asym_sale_go_{tag}"
        all_results[key] = run_iv_asym_block(
            df, ["dev_g_h_sale", "dev_g_l_sale"], iv_devd,
            "dev_xrd", "z_rd_sale", key, cluster_col, gmm2=True)

    if all(c in df.columns for c in ["dev_g_h_sale", "dev_g_l_sale"] + iv_deve):
        key = f"gmm2_dev_asym_sale_va_i_{tag}"
        all_results[key] = run_iv_asym_block(
            df, ["dev_g_h_sale", "dev_g_l_sale"], iv_deve,
            "dev_xrd", "z_rd_sale", key, cluster_col, gmm2=True)

    if all(c in df.columns for c in ["dev_g_h_va_a", "dev_g_l_va_a"] + iv_deve):
        key = f"gmm2_dev_asym_va_a_va_i_{tag}"
        all_results[key] = run_iv_asym_block(
            df, ["dev_g_h_va_a", "dev_g_l_va_a"], iv_deve,
            "dev_xrd", "z_rd_va_a", key, cluster_col, gmm2=True)

    return all_results


# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------

def _results_to_df(res_list: list[dict], key_coef: str | None = None) -> pd.DataFrame:
    """Convert a list of regression result dicts to a summary DataFrame."""
    rows = []
    for r in res_list:
        row = {
            "label": r["label"],
            "estimator": r.get("estimator", ""),
            "n": r.get("n", 0),
        }
        if r.get("results") is not None and r.get("params"):
            for coef, val in r["params"].items():
                row[f"coef_{coef}"] = val
            for coef, val in r.get("pvalues", {}).items():
                row[f"pval_{coef}"] = val
            for coef, val in r.get("se", {}).items():
                row[f"se_{coef}"] = val
        rows.append(row)
    return pd.DataFrame(rows)


def build_markdown_summary(all_results: dict[str, list[dict]]) -> str:
    """Build a human-readable Markdown summary of key coefficients."""
    lines = [
        "# Compustat × BEA 3-Digit: Estimation Summary",
        "",
        "Replication of [3]_compustat_BEA_3digits.do.",
        "",
        "Key coefficient: output growth measure on d_xrd (column A regressions).",
        "",
    ]

    for block_name, res_list in sorted(all_results.items()):
        a_res = next((r for r in res_list
                      if r["label"].endswith("_A") and r.get("results") is not None),
                     None)
        if a_res is None:
            continue
        params = a_res.get("params", {})
        pvals = a_res.get("pvalues", {})
        # find the output coefficient (not const, not a control)
        ctrl_stems = {"emp", "r_cf", "r_dd1", "r_dltt", "r_lt", "r_at",
                      "r_ppent", "l_", "l2_", "const"}
        output_coefs = {k: v for k, v in params.items()
                        if not any(k.startswith(s) for s in ctrl_stems)}
        for coef, val in output_coefs.items():
            pv = pvals.get(coef, float("nan"))
            stars = ("***" if pv < 0.01 else
                     "**" if pv < 0.05 else
                     "*" if pv < 0.10 else "")
            lines.append(
                f"- **{block_name}**: {coef} = {val:.4f}{stars}"
                f"  (p={pv:.3f}, n={a_res['n']:,})"
            )
    lines.append("")
    lines.append("*Note: System GMM blocks (xtabond / xtdpdsys) from the original "
                 "Stata script are not implemented; no direct equivalent is available "
                 "in standard Python panel packages.*")
    return "\n".join(lines) + "\n"


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:
    print("Loading data from cyclicality.db …")
    with sqlite3.connect(DB_PATH) as conn:
        df = pd.read_sql_query(
            "SELECT * FROM processed_compustat_bea_3digit", conn
        )
    print(f"  Loaded {len(df):,} rows, {len(df.columns)} columns.")
    print(f"  Panel: {df['key'].nunique():,} firms, "
          f"years {int(df['year'].min())}-{int(df['year'].max())}")

    print("Building analysis variables …")
    df = build_analysis_vars(df)

    all_results: dict[str, list[dict]] = {}

    print("\n--- Grid 1: cluster by key ---")
    all_results.update(run_all_blocks(df, cluster_col="key"))

    print("\n--- Grid 2: cluster by naics3 ---")
    all_results.update(run_all_blocks(df, cluster_col="naics3"))

    # ------------------------------------------------------------------
    # Save results
    # ------------------------------------------------------------------
    print("\nSaving results …")
    with pd.ExcelWriter(XLSX_PATH, engine="openpyxl") as writer:
        for block_name, res_list in all_results.items():
            sdf = _results_to_df(res_list)
            # Excel sheet names: max 31 chars
            sheet = block_name[:31]
            sdf.to_excel(writer, sheet_name=sheet, index=False)

    md_text = build_markdown_summary(all_results)
    MD_PATH.write_text(md_text, encoding="utf-8")

    print(f"Wrote {XLSX_PATH}")
    print(f"Wrote {MD_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
