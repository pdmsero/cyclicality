#!/usr/bin/env python3
"""
analyse_rnd_industry.py
=======================
Python replication of [1]_RND_Industry_data_final.do.

Data source: processed_rnd_industry table in cyclicality.db.
Panel structure: code (20 SIC-based industry groups), year (1956–1998, t=1–43).

Regression structure
--------------------
The script mirrors the five main sections of the Stata do-file in order:

  1. OLS / FE OLS — RAW R&D (growth rate and intensity, shipments and
     value-added, symmetric and asymmetric growth splits)
  2. OLS / FE OLS — MI R&D (multiply-imputed; same specification grid)
  3. IV 2SLS / FE IV — RAW R&D (instruments: g_y and f_g_y; asymmetric
     variants use g_h_y, g_l_y, f_g_h_y, f_g_l_y)
  4. IV 2SLS / FE IV — MI R&D
  5. GMM-2step variants of IV sections (RAW and MI)
  6. HP-deviation section — MI only (OLS + FE + IV + GMM2)

Estimation notes
----------------
- Stata `reg ... robust`          → statsmodels OLS, cov_type='HC1'
- Stata `xtreg ... fe robust`     → linearmodels PanelOLS, entity_effects,
                                    cov_type='robust'
- Stata `ivreg2 ... robust`       → linearmodels IV2SLS, cov_type='robust'
- Stata `xtivreg2 ... fe cluster` → within-demean + IV2SLS, cov_type='clustered'
- Stata `ivreg2 ... gmm2`         → linearmodels IVGMM, weight_type='robust'
- Stata `xtivreg2 ... fe gmm2`    → within-demean + IVGMM, weight_type='robust'

HP filter: statsmodels hpfilter(series, lamb=6.25) applied per entity.
Lags/leads: constructed via groupby + shift; consecutive-year check enforced.

Output
------
Results are saved to:
  results/rnd_industry_results.xlsx   (one sheet per regression block)
  results/rnd_industry_results.md     (summary of key cyclicality coefficients)
"""

from __future__ import annotations

import sqlite3
import warnings
from pathlib import Path
from typing import Optional

import numpy as np
import pandas as pd
import statsmodels.api as sm
from statsmodels.tsa.filters.hp_filter import hpfilter
from linearmodels.panel import PanelOLS
from linearmodels.iv import IV2SLS, IVGMM

warnings.filterwarnings("ignore", category=FutureWarning)
warnings.filterwarnings("ignore", category=pd.errors.PerformanceWarning)

ROOT = Path(__file__).resolve().parents[2]
DB_PATH = ROOT / "data" / "cyclicality.db"
RESULTS_DIR = ROOT / "results"
RESULTS_DIR.mkdir(exist_ok=True)

XLSX_PATH = RESULTS_DIR / "rnd_industry_results.xlsx"
MD_PATH = RESULTS_DIR / "rnd_industry_results.md"


# ---------------------------------------------------------------------------
# Panel utility helpers
# ---------------------------------------------------------------------------

def panel_lag(df: pd.DataFrame, col: str,
              panel: str = "code", time: str = "year",
              n: int = 1) -> pd.Series:
    """Lag `col` by `n` periods within each panel unit.

    Returns NaN whenever the preceding observation is not exactly n years
    earlier (i.e. gaps in the panel are not bridged).
    """
    grp = df.groupby(panel, dropna=False, sort=False)
    lagged = grp[col].shift(n)
    prev_year = pd.to_numeric(
        grp[time].shift(n), errors="coerce"
    )
    current_year = pd.to_numeric(df[time], errors="coerce")
    consecutive = (current_year - prev_year) == n
    return lagged.where(consecutive)


def panel_lead(df: pd.DataFrame, col: str,
               panel: str = "code", time: str = "year",
               n: int = 1) -> pd.Series:
    """Lead `col` by `n` periods within each panel unit."""
    grp = df.groupby(panel, dropna=False, sort=False)
    led = grp[col].shift(-n)
    next_year = pd.to_numeric(
        grp[time].shift(-n), errors="coerce"
    )
    current_year = pd.to_numeric(df[time], errors="coerce")
    consecutive = (next_year - current_year) == n
    return led.where(consecutive)


def hp_filter_per_entity(df: pd.DataFrame, col: str,
                         panel: str = "code",
                         lamb: float = 6.25) -> tuple[pd.Series, pd.Series]:
    """Apply Hodrick-Prescott filter per entity (lambda=6.25 for annual data).

    Returns (cycle, trend) as Series indexed identically to df.
    Matches Stata's `tsfilter hp ... smooth(6.25)`.
    """
    cycle = pd.Series(np.nan, index=df.index)
    trend = pd.Series(np.nan, index=df.index)
    for entity, grp in df.groupby(panel, dropna=False, sort=False):
        s = grp[col].dropna()
        if len(s) < 4:
            continue
        c, t = hpfilter(s.values, lamb=lamb)
        cycle.loc[s.index] = c
        trend.loc[s.index] = t
    return cycle, trend


# ---------------------------------------------------------------------------
# Variable construction
# ---------------------------------------------------------------------------

def build_analysis_vars(df: pd.DataFrame) -> pd.DataFrame:
    """Construct all derived variables needed for the regressions.

    The processed_rnd_industry table already contains the main derived
    variables from the Stata do-file (g_ship, g_vadd, year dummies, HP
    deviations, etc.).  This function adds lagged/lead variables that
    cannot be pre-stored in the table.
    """
    df = df.sort_values(["code", "year"]).copy()
    df["year"] = df["year"].astype(int)

    # --- Lags of intensity ratios (used as regressors) ----------------------
    for col in ["sh_raw_vadd", "sh_raw_ship", "sh_mi_vadd", "sh_mi_ship",
                "z_raw_invest", "z_mi_invest", "r_equip", "r_plant"]:
        df[f"l_{col}"] = panel_lag(df, col)
        df[f"l2_{col}"] = panel_lag(df, col, n=2)

    # --- Lead of GDP growth instruments -------------------------------------
    df["f_g_y"] = panel_lead(df, "g_y")
    df["f_g_h_y"] = panel_lead(df, "g_h_y")
    df["f_g_l_y"] = panel_lead(df, "g_l_y")

    # --- Asymmetric GDP growth dummies (should already exist but ensure) ----
    if "d_h_y" not in df.columns:
        df["d_h_y"] = (df["g_y"] > 0).astype(float)
        df["d_l_y"] = (df["g_y"] < 0).astype(float)
        df["g_h_y"] = df["g_y"] * df["d_h_y"]
        df["g_l_y"] = df["g_y"] * df["d_l_y"]

    # --- Lagged intensity ratios for HP-deviation IV section ----------------
    # (already covered above via l_sh_mi_vadd etc.)

    return df


# ---------------------------------------------------------------------------
# Regression wrappers
# ---------------------------------------------------------------------------

def _ols_robust(y: pd.Series, X: pd.DataFrame,
                label: str) -> dict:
    """Pooled OLS with HC1 heteroskedasticity-robust SEs (Stata: reg ... robust)."""
    Xc = sm.add_constant(X, has_constant="add")
    mask = y.notna() & Xc.notna().all(axis=1)
    res = sm.OLS(y[mask], Xc[mask]).fit(cov_type="HC1")
    return _extract_ols(res, label, estimator="Pooled OLS")


def _fe_ols_robust(y: pd.Series, X: pd.DataFrame,
                   df: pd.DataFrame, label: str) -> dict:
    """FE OLS with entity effects, heteroskedasticity-robust SEs
    (Stata: xtreg ... fe robust)."""
    panel_data = _make_panel_data(df, y, X)
    if panel_data is None:
        return {"label": label, "estimator": "FE OLS", "n": 0,
                "results": None}
    dep, exog = panel_data
    mod = PanelOLS(dep, exog, entity_effects=True)
    res = mod.fit(cov_type="robust")
    return _extract_panel(res, label, estimator="FE OLS")


def _pooled_iv(y: pd.Series, X_exog: pd.DataFrame, X_endog: pd.DataFrame,
               Z: pd.DataFrame, label: str) -> dict:
    """Pooled 2SLS with heteroskedasticity-robust SEs
    (Stata: ivreg2 ... robust)."""
    mask = (y.notna()
            & X_exog.notna().all(axis=1)
            & X_endog.notna().all(axis=1)
            & Z.notna().all(axis=1))
    if mask.sum() < X_exog.shape[1] + X_endog.shape[1] + 5:
        return {"label": label, "estimator": "Pooled IV", "n": 0,
                "results": None}
    Xc = sm.add_constant(X_exog[mask], has_constant="add")
    mod = IV2SLS(y[mask], Xc, X_endog[mask], Z[mask])
    res = mod.fit(cov_type="robust")
    return _extract_iv(res, label, estimator="Pooled IV")


def _fe_iv(y: pd.Series, X_exog: pd.DataFrame, X_endog: pd.DataFrame,
           Z: pd.DataFrame, df: pd.DataFrame, label: str) -> dict:
    """FE 2SLS via within-demeaning + IV2SLS with cluster-robust SEs
    (Stata: xtivreg2 ... fe cluster(code))."""
    all_cols = list(X_exog.columns) + list(X_endog.columns) + list(Z.columns)
    mask = (y.notna()
            & X_exog.notna().all(axis=1)
            & X_endog.notna().all(axis=1)
            & Z.notna().all(axis=1))
    if mask.sum() < 10:
        return {"label": label, "estimator": "FE IV", "n": 0, "results": None}

    df_sub = df.loc[mask, ["code"]].copy()
    y_s = y[mask].copy()
    Xe_s = X_exog[mask].copy()
    Xn_s = X_endog[mask].copy()
    Z_s = Z[mask].copy()

    # Within-demean by entity
    def _demean(s: pd.Series) -> pd.Series:
        return s - df_sub["code"].map(s.groupby(df_sub["code"]).mean())

    y_w = _demean(y_s)
    Xe_w = Xe_s.apply(_demean)
    Xn_w = Xn_s.apply(_demean)
    Z_w = Z_s.apply(_demean)

    Xc_w = sm.add_constant(Xe_w, has_constant="add")
    cluster_ids = df_sub["code"].values

    try:
        mod = IV2SLS(y_w, Xc_w, Xn_w, Z_w)
        res = mod.fit(cov_type="clustered", clusters=cluster_ids)
    except Exception as e:
        return {"label": label, "estimator": "FE IV", "n": mask.sum(),
                "results": None, "error": str(e)}
    return _extract_iv(res, label, estimator="FE IV")


def _pooled_gmm2(y: pd.Series, X_exog: pd.DataFrame, X_endog: pd.DataFrame,
                 Z: pd.DataFrame, label: str) -> dict:
    """Pooled GMM-2step (Stata: ivreg2 ... robust gmm2)."""
    mask = (y.notna()
            & X_exog.notna().all(axis=1)
            & X_endog.notna().all(axis=1)
            & Z.notna().all(axis=1))
    if mask.sum() < X_exog.shape[1] + X_endog.shape[1] + 5:
        return {"label": label, "estimator": "Pooled GMM2", "n": 0,
                "results": None}
    Xc = sm.add_constant(X_exog[mask], has_constant="add")
    mod = IVGMM(y[mask], Xc, X_endog[mask], Z[mask])
    res = mod.fit(cov_type="robust")
    return _extract_iv(res, label, estimator="Pooled GMM2")


def _fe_gmm2(y: pd.Series, X_exog: pd.DataFrame, X_endog: pd.DataFrame,
             Z: pd.DataFrame, df: pd.DataFrame, label: str) -> dict:
    """FE GMM-2step via within-demeaning
    (Stata: xtivreg2 ... fe robust gmm2)."""
    mask = (y.notna()
            & X_exog.notna().all(axis=1)
            & X_endog.notna().all(axis=1)
            & Z.notna().all(axis=1))
    if mask.sum() < 10:
        return {"label": label, "estimator": "FE GMM2", "n": 0,
                "results": None}

    df_sub = df.loc[mask, ["code"]].copy()
    y_s = y[mask].copy()
    Xe_s = X_exog[mask].copy()
    Xn_s = X_endog[mask].copy()
    Z_s = Z[mask].copy()

    def _demean(s: pd.Series) -> pd.Series:
        return s - df_sub["code"].map(s.groupby(df_sub["code"]).mean())

    y_w = _demean(y_s)
    Xe_w = Xe_s.apply(_demean)
    Xn_w = Xn_s.apply(_demean)
    Z_w = Z_s.apply(_demean)

    Xc_w = sm.add_constant(Xe_w, has_constant="add")
    cluster_ids = df_sub["code"].values

    try:
        mod = IVGMM(y_w, Xc_w, Xn_w, Z_w)
        res = mod.fit(cov_type="clustered", clusters=cluster_ids)
    except Exception as e:
        return {"label": label, "estimator": "FE GMM2", "n": mask.sum(),
                "results": None, "error": str(e)}
    return _extract_iv(res, label, estimator="FE GMM2")


# ---------------------------------------------------------------------------
# Result extraction helpers
# ---------------------------------------------------------------------------

def _extract_ols(res, label: str, estimator: str) -> dict:
    params = res.params
    pvals = res.pvalues
    se = res.bse
    n = int(res.nobs)
    return {
        "label": label,
        "estimator": estimator,
        "n": n,
        "params": params.to_dict(),
        "pvalues": pvals.to_dict(),
        "se": se.to_dict(),
        "results": res,
    }


def _extract_panel(res, label: str, estimator: str) -> dict:
    params = res.params
    pvals = res.pvalues
    se = res.std_errors
    n = int(res.nobs)
    return {
        "label": label,
        "estimator": estimator,
        "n": n,
        "params": params.to_dict(),
        "pvalues": pvals.to_dict(),
        "se": se.to_dict(),
        "results": res,
    }


def _extract_iv(res, label: str, estimator: str) -> dict:
    params = res.params
    pvals = res.pvalues
    se = res.std_errors
    n = int(res.nobs)
    return {
        "label": label,
        "estimator": estimator,
        "n": n,
        "params": params.to_dict(),
        "pvalues": pvals.to_dict(),
        "se": se.to_dict(),
        "results": res,
    }


def _make_panel_data(df: pd.DataFrame, y: pd.Series,
                     X: pd.DataFrame) -> Optional[tuple]:
    """Prepare MultiIndex DataFrame for linearmodels PanelOLS."""
    mi = pd.MultiIndex.from_arrays(
        [df["code"].values, df["year"].values], names=["code", "year"]
    )
    mask = y.notna() & X.notna().all(axis=1)
    if mask.sum() < 10:
        return None
    dep = pd.DataFrame({"dep": y[mask].values}, index=mi[mask])
    exog = pd.DataFrame(X[mask].values, index=mi[mask], columns=X.columns)
    return dep, exog


# ---------------------------------------------------------------------------
# Standard regressor sets
# ---------------------------------------------------------------------------

def _year_dummies(df: pd.DataFrame, start: int = 5) -> pd.DataFrame:
    """Return year-dummy columns y{start} ... y43."""
    cols = [f"y{i}" for i in range(start, 44)]
    present = [c for c in cols if c in df.columns]
    return df[present]


def _controls(df: pd.DataFrame) -> pd.DataFrame:
    """Standard controls: emp, r_equip, l_r_equip, r_plant, l_r_plant."""
    return df[["emp", "r_equip", "l_r_equip", "r_plant", "l_r_plant"]]


def _controls_tt(df: pd.DataFrame) -> pd.DataFrame:
    """Controls with linear/quadratic time trend (for IV section)."""
    return df[["emp", "r_equip", "l_r_equip", "r_plant", "l_r_plant",
               "t", "t2"]]


# ---------------------------------------------------------------------------
# Regression blocks
# ---------------------------------------------------------------------------

def run_ols_block(df: pd.DataFrame, rnd_col: str, g_col: str,
                  sh_col: str, z_col: str,
                  block_name: str) -> list[dict]:
    """
    OLS + FE block for one (R&D measure, output measure) pair.

    Mirrors the Stata pattern:
      reg  rnd_col  g_col  controls  ydums  → A
      xtreg rnd_col g_col  controls  ydums  → B
      reg  sh_col  l.sh l2.sh g_col  controls  ydums  → C
      xtreg sh_col l.sh l2.sh g_col  controls  ydums  → D
      reg  z_col   l.z  l2.z  g_col  controls  ydums  → E
      xtreg z_col  l.z  l2.z  g_col  controls  ydums  → F
    """
    results = []
    ydums = _year_dummies(df, start=5)
    ctrl = _controls(df)
    l_sh = df[f"l_{sh_col}"]
    l2_sh = df[f"l2_{sh_col}"]
    l_z = df[f"l_{z_col}"]
    l2_z = df[f"l2_{z_col}"]

    X_A = pd.concat([df[[g_col]], ctrl, ydums], axis=1)
    results.append(_ols_robust(df[rnd_col], X_A, f"{block_name}_A"))
    results.append(_fe_ols_robust(df[rnd_col], pd.concat([df[[g_col]], ctrl], axis=1),
                                  df, f"{block_name}_B"))

    ydums_C = _year_dummies(df, start=6)
    X_C = pd.concat([l_sh, l2_sh, df[[g_col]], ctrl, ydums_C], axis=1)
    results.append(_ols_robust(df[sh_col], X_C, f"{block_name}_C"))
    results.append(_fe_ols_robust(df[sh_col],
                                  pd.concat([l_sh, l2_sh, df[[g_col]], ctrl], axis=1),
                                  df, f"{block_name}_D"))

    X_E = pd.concat([l_z, l2_z, df[[g_col]], ctrl, ydums], axis=1)
    results.append(_ols_robust(df[z_col], X_E, f"{block_name}_E"))
    results.append(_fe_ols_robust(df[z_col],
                                  pd.concat([l_z, l2_z, df[[g_col]], ctrl], axis=1),
                                  df, f"{block_name}_F"))
    return results


def run_ols_asymmetric_block(df: pd.DataFrame, rnd_col: str,
                              gh_col: str, gl_col: str,
                              sh_col: str, z_col: str,
                              block_name: str) -> list[dict]:
    """OLS + FE block with asymmetric growth splits (g_h, g_l)."""
    results = []
    ydums = _year_dummies(df, start=5)
    ctrl = _controls(df)
    l_sh = df[f"l_{sh_col}"]
    l2_sh = df[f"l2_{sh_col}"]
    l_z = df[f"l_{z_col}"]
    l2_z = df[f"l2_{z_col}"]

    X_A = pd.concat([df[[gh_col, gl_col]], ctrl, ydums], axis=1)
    results.append(_ols_robust(df[rnd_col], X_A, f"{block_name}_A"))
    results.append(_fe_ols_robust(df[rnd_col],
                                  pd.concat([df[[gh_col, gl_col]], ctrl], axis=1),
                                  df, f"{block_name}_B"))

    ydums_C = _year_dummies(df, start=6)
    X_C = pd.concat([l_sh, l2_sh, df[[gh_col, gl_col]], ctrl, ydums_C], axis=1)
    results.append(_ols_robust(df[sh_col], X_C, f"{block_name}_C"))
    results.append(_fe_ols_robust(df[sh_col],
                                  pd.concat([l_sh, l2_sh, df[[gh_col, gl_col]], ctrl], axis=1),
                                  df, f"{block_name}_D"))

    X_E = pd.concat([l_z, l2_z, df[[gh_col, gl_col]], ctrl, ydums], axis=1)
    results.append(_ols_robust(df[z_col], X_E, f"{block_name}_E"))
    results.append(_fe_ols_robust(df[z_col],
                                  pd.concat([l_z, l2_z, df[[gh_col, gl_col]], ctrl], axis=1),
                                  df, f"{block_name}_F"))
    return results


def run_iv_block(df: pd.DataFrame, rnd_col: str, g_endog: str,
                 sh_col: str, z_col: str,
                 iv_sym: list[str], block_name: str,
                 gmm2: bool = False) -> list[dict]:
    """
    IV / GMM2 block for one (R&D measure, output measure) pair.

    Instruments for symmetric specification: iv_sym (g_y, f_g_y).
    Mirrors:
      ivreg2  rnd  (g_endog = iv_sym) controls t t2 → A
      xtivreg2 rnd (g_endog = iv_sym) controls t t2 fe → B
      ivreg2  sh   l.sh l2.sh (g_endog = iv_sym) ... → C/D
      ivreg2  z    l.z  l2.z  (g_endog = iv_sym) ... → E/F
    """
    fn_pool = _pooled_gmm2 if gmm2 else _pooled_iv
    fn_fe = _fe_gmm2 if gmm2 else _fe_iv
    est = "GMM2" if gmm2 else "IV"
    ctrl = _controls_tt(df)
    l_sh = df[f"l_{sh_col}"]
    l2_sh = df[f"l2_{sh_col}"]
    l_z = df[f"l_{z_col}"]
    l2_z = df[f"l2_{z_col}"]
    Z = df[iv_sym]

    results = []
    results.append(fn_pool(df[rnd_col], ctrl, df[[g_endog]], Z,
                           f"{block_name}_A"))
    results.append(fn_fe(df[rnd_col], ctrl, df[[g_endog]], Z, df,
                         f"{block_name}_B"))

    ctrl_sh = pd.concat([l_sh, l2_sh, ctrl], axis=1)
    results.append(fn_pool(df[sh_col], ctrl_sh, df[[g_endog]], Z,
                           f"{block_name}_C"))
    results.append(fn_fe(df[sh_col], ctrl_sh, df[[g_endog]], Z, df,
                         f"{block_name}_D"))

    ctrl_z = pd.concat([l_z, l2_z, ctrl], axis=1)
    results.append(fn_pool(df[z_col], ctrl_z, df[[g_endog]], Z,
                           f"{block_name}_E"))
    results.append(fn_fe(df[z_col], ctrl_z, df[[g_endog]], Z, df,
                         f"{block_name}_F"))
    return results


def run_iv_asymmetric_block(df: pd.DataFrame, rnd_col: str,
                             gh_endog: str, gl_endog: str,
                             sh_col: str, z_col: str,
                             iv_cols: list[str], block_name: str,
                             gmm2: bool = False) -> list[dict]:
    """IV / GMM2 block with asymmetric endogenous regressors."""
    fn_pool = _pooled_gmm2 if gmm2 else _pooled_iv
    fn_fe = _fe_gmm2 if gmm2 else _fe_iv
    ctrl = _controls_tt(df)
    l_sh = df[f"l_{sh_col}"]
    l2_sh = df[f"l2_{sh_col}"]
    l_z = df[f"l_{z_col}"]
    l2_z = df[f"l2_{z_col}"]
    Z = df[iv_cols]
    X_endog = df[[gh_endog, gl_endog]]

    results = []
    results.append(fn_pool(df[rnd_col], ctrl, X_endog, Z,
                           f"{block_name}_A"))
    results.append(fn_fe(df[rnd_col], ctrl, X_endog, Z, df,
                         f"{block_name}_B"))

    ctrl_sh = pd.concat([l_sh, l2_sh, ctrl], axis=1)
    results.append(fn_pool(df[sh_col], ctrl_sh, X_endog, Z,
                           f"{block_name}_C"))
    results.append(fn_fe(df[sh_col], ctrl_sh, X_endog, Z, df,
                         f"{block_name}_D"))

    ctrl_z = pd.concat([l_z, l2_z, ctrl], axis=1)
    results.append(fn_pool(df[z_col], ctrl_z, X_endog, Z,
                           f"{block_name}_E"))
    results.append(fn_fe(df[z_col], ctrl_z, X_endog, Z, df,
                         f"{block_name}_F"))
    return results


# ---------------------------------------------------------------------------
# Results formatting
# ---------------------------------------------------------------------------

def results_to_df(results: list[dict]) -> pd.DataFrame:
    """Flatten a list of regression result dicts into a tidy DataFrame."""
    rows = []
    for r in results:
        if r.get("results") is None:
            rows.append({
                "label": r["label"],
                "estimator": r["estimator"],
                "n": r["n"],
                "variable": "—",
                "coef": np.nan,
                "se": np.nan,
                "pvalue": np.nan,
            })
            continue
        for var, coef in r["params"].items():
            rows.append({
                "label": r["label"],
                "estimator": r["estimator"],
                "n": r["n"],
                "variable": var,
                "coef": coef,
                "se": r["se"].get(var, np.nan),
                "pvalue": r["pvalues"].get(var, np.nan),
            })
    return pd.DataFrame(rows)


def _stars(p: float) -> str:
    if p < 0.01:
        return "***"
    if p < 0.05:
        return "**"
    if p < 0.10:
        return "*"
    return ""


def cyclicality_summary(all_results: dict[str, list[dict]],
                        cycle_vars: list[str]) -> pd.DataFrame:
    """Extract cyclicality coefficients from all blocks into one table."""
    rows = []
    for block_name, result_list in all_results.items():
        for r in result_list:
            if r.get("results") is None:
                continue
            for cv in cycle_vars:
                if cv in r["params"]:
                    coef = r["params"][cv]
                    se = r["se"].get(cv, np.nan)
                    pv = r["pvalues"].get(cv, np.nan)
                    rows.append({
                        "block": block_name,
                        "label": r["label"],
                        "estimator": r["estimator"],
                        "cycle_var": cv,
                        "coef": round(coef, 4),
                        "se": round(se, 4),
                        "pvalue": round(pv, 4),
                        "stars": _stars(pv),
                        "n": r["n"],
                    })
    return pd.DataFrame(rows)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:
    print("Loading data from cyclicality.db …")
    with sqlite3.connect(DB_PATH) as conn:
        df = pd.read_sql_query(
            "SELECT * FROM processed_rnd_industry ORDER BY code, year",
            conn,
        )

    print(f"  Loaded {len(df)} rows, {df.shape[1]} columns.")
    print(f"  Panel: {df['code'].nunique()} industry codes, "
          f"years {int(df['year'].min())}–{int(df['year'].max())}")

    # Ensure numeric types for key columns
    numeric_cols = [
        "code", "year", "t", "t2", "raw", "mi", "g_ship", "g_vadd",
        "g_h_ship", "g_l_ship", "g_h_vadd", "g_l_vadd", "g_y", "g_h_y",
        "g_l_y", "emp", "r_equip", "r_plant", "sh_raw_vadd", "sh_raw_ship",
        "sh_mi_vadd", "sh_mi_ship", "z_raw_invest", "z_mi_invest",
        "raw_level", "mi_level", "r_vadd", "r_vship", "r_invest",
        "dev_mi", "dev_vadd", "dev_vship",
        "dev_h_g_vadd", "dev_l_g_vadd", "dev_h_g_ship", "dev_l_g_ship",
    ] + [f"y{i}" for i in range(1, 44)]
    for c in numeric_cols:
        if c in df.columns:
            df[c] = pd.to_numeric(df[c], errors="coerce")

    df = build_analysis_vars(df)

    # Ensure column names are safe for indexing
    df = df.rename(columns={"d92": "D92"})

    all_results: dict[str, list[dict]] = {}

    # -----------------------------------------------------------------------
    # SECTION 1: OLS — RAW R&D
    # -----------------------------------------------------------------------
    print("\n--- Section 1: OLS — RAW R&D ---")

    # 1a. Value-added measure, symmetric
    all_results["raw_ols_vadd_sym"] = run_ols_block(
        df, "raw", "g_vadd", "sh_raw_vadd", "z_raw_invest",
        "raw_ols_vadd_sym"
    )
    print("  1a done")

    # 1b. Shipments measure, symmetric
    all_results["raw_ols_ship_sym"] = run_ols_block(
        df, "raw", "g_ship", "sh_raw_ship", "z_raw_invest",
        "raw_ols_ship_sym"
    )
    print("  1b done")

    # 1c. Value-added measure, asymmetric
    all_results["raw_ols_vadd_asym"] = run_ols_asymmetric_block(
        df, "raw", "g_h_vadd", "g_l_vadd", "sh_raw_vadd", "z_raw_invest",
        "raw_ols_vadd_asym"
    )
    print("  1c done")

    # 1d. Shipments measure, asymmetric
    all_results["raw_ols_ship_asym"] = run_ols_asymmetric_block(
        df, "raw", "g_h_ship", "g_l_ship", "sh_raw_ship", "z_raw_invest",
        "raw_ols_ship_asym"
    )
    print("  1d done")

    # -----------------------------------------------------------------------
    # SECTION 2: OLS — MI R&D
    # -----------------------------------------------------------------------
    print("\n--- Section 2: OLS — MI R&D ---")

    all_results["mi_ols_vadd_sym"] = run_ols_block(
        df, "mi", "g_vadd", "sh_mi_vadd", "z_mi_invest",
        "mi_ols_vadd_sym"
    )
    print("  2a done")

    all_results["mi_ols_ship_sym"] = run_ols_block(
        df, "mi", "g_ship", "sh_mi_ship", "z_mi_invest",
        "mi_ols_ship_sym"
    )
    print("  2b done")

    all_results["mi_ols_vadd_asym"] = run_ols_asymmetric_block(
        df, "mi", "g_h_vadd", "g_l_vadd", "sh_mi_vadd", "z_mi_invest",
        "mi_ols_vadd_asym"
    )
    print("  2c done")

    all_results["mi_ols_ship_asym"] = run_ols_asymmetric_block(
        df, "mi", "g_h_ship", "g_l_ship", "sh_mi_ship", "z_mi_invest",
        "mi_ols_ship_asym"
    )
    print("  2d done")

    # -----------------------------------------------------------------------
    # SECTION 3: IV — RAW R&D
    # -----------------------------------------------------------------------
    print("\n--- Section 3: IV 2SLS — RAW R&D ---")

    iv_sym = ["g_y", "f_g_y"]
    iv_asym = ["g_h_y", "g_l_y", "f_g_h_y", "f_g_l_y"]

    # 3a. Value-added, symmetric IV
    all_results["raw_iv_vadd_sym"] = run_iv_block(
        df, "raw", "g_vadd", "sh_raw_vadd", "z_raw_invest",
        iv_sym, "raw_iv_vadd_sym"
    )
    print("  3a done")

    # 3b. Shipments, symmetric IV
    all_results["raw_iv_ship_sym"] = run_iv_block(
        df, "raw", "g_ship", "sh_raw_ship", "z_raw_invest",
        iv_sym, "raw_iv_ship_sym"
    )
    print("  3b done")

    # 3c. Value-added, asymmetric IV (instruments: g_h_y, g_l_y, f.)
    all_results["raw_iv_vadd_asym_split"] = run_iv_asymmetric_block(
        df, "raw", "g_h_vadd", "g_l_vadd", "sh_raw_vadd", "z_raw_invest",
        iv_asym, "raw_iv_vadd_asym_split"
    )
    print("  3c done")

    # 3d. Shipments, asymmetric IV
    all_results["raw_iv_ship_asym_split"] = run_iv_asymmetric_block(
        df, "raw", "g_h_ship", "g_l_ship", "sh_raw_ship", "z_raw_invest",
        iv_asym, "raw_iv_ship_asym_split"
    )
    print("  3d done")

    # 3e. Value-added, asymmetric endog, symmetric IV (instruments: g_y, f_g_y)
    all_results["raw_iv_vadd_asym_sym_iv"] = run_iv_asymmetric_block(
        df, "raw", "g_h_vadd", "g_l_vadd", "sh_raw_vadd", "z_raw_invest",
        iv_sym, "raw_iv_vadd_asym_sym_iv"
    )
    print("  3e done")

    # 3f. Shipments, asymmetric endog, symmetric IV
    all_results["raw_iv_ship_asym_sym_iv"] = run_iv_asymmetric_block(
        df, "raw", "g_h_ship", "g_l_ship", "sh_raw_ship", "z_raw_invest",
        iv_sym, "raw_iv_ship_asym_sym_iv"
    )
    print("  3f done")

    # -----------------------------------------------------------------------
    # SECTION 4: IV — MI R&D
    # -----------------------------------------------------------------------
    print("\n--- Section 4: IV 2SLS — MI R&D ---")

    all_results["mi_iv_vadd_sym"] = run_iv_block(
        df, "mi", "g_vadd", "sh_mi_vadd", "z_mi_invest",
        iv_sym, "mi_iv_vadd_sym"
    )
    print("  4a done")

    all_results["mi_iv_ship_sym"] = run_iv_block(
        df, "mi", "g_ship", "sh_mi_ship", "z_mi_invest",
        iv_sym, "mi_iv_ship_sym"
    )
    print("  4b done")

    all_results["mi_iv_vadd_asym_split"] = run_iv_asymmetric_block(
        df, "mi", "g_h_vadd", "g_l_vadd", "sh_mi_vadd", "z_mi_invest",
        iv_asym, "mi_iv_vadd_asym_split"
    )
    print("  4c done")

    all_results["mi_iv_ship_asym_split"] = run_iv_asymmetric_block(
        df, "mi", "g_h_ship", "g_l_ship", "sh_mi_ship", "z_mi_invest",
        iv_asym, "mi_iv_ship_asym_split"
    )
    print("  4d done")

    all_results["mi_iv_vadd_asym_sym_iv"] = run_iv_asymmetric_block(
        df, "mi", "g_h_vadd", "g_l_vadd", "sh_mi_vadd", "z_mi_invest",
        iv_sym, "mi_iv_vadd_asym_sym_iv"
    )
    print("  4e done")

    all_results["mi_iv_ship_asym_sym_iv"] = run_iv_asymmetric_block(
        df, "mi", "g_h_ship", "g_l_ship", "sh_mi_ship", "z_mi_invest",
        iv_sym, "mi_iv_ship_asym_sym_iv"
    )
    print("  4f done")

    # -----------------------------------------------------------------------
    # SECTION 5: GMM2 — RAW R&D
    # -----------------------------------------------------------------------
    print("\n--- Section 5: GMM2 — RAW R&D ---")

    all_results["raw_gmm2_vadd_sym"] = run_iv_block(
        df, "raw", "g_vadd", "sh_raw_vadd", "z_raw_invest",
        iv_sym, "raw_gmm2_vadd_sym", gmm2=True
    )
    print("  5a done")

    all_results["raw_gmm2_ship_sym"] = run_iv_block(
        df, "raw", "g_ship", "sh_raw_ship", "z_raw_invest",
        iv_sym, "raw_gmm2_ship_sym", gmm2=True
    )
    print("  5b done")

    all_results["raw_gmm2_vadd_asym"] = run_iv_asymmetric_block(
        df, "raw", "g_h_vadd", "g_l_vadd", "sh_raw_vadd", "z_raw_invest",
        iv_asym, "raw_gmm2_vadd_asym", gmm2=True
    )
    print("  5c done")

    all_results["raw_gmm2_ship_asym"] = run_iv_asymmetric_block(
        df, "raw", "g_h_ship", "g_l_ship", "sh_raw_ship", "z_raw_invest",
        iv_asym, "raw_gmm2_ship_asym", gmm2=True
    )
    print("  5d done")

    # -----------------------------------------------------------------------
    # SECTION 6: GMM2 — MI R&D
    # -----------------------------------------------------------------------
    print("\n--- Section 6: GMM2 — MI R&D ---")

    all_results["mi_gmm2_vadd_sym"] = run_iv_block(
        df, "mi", "g_vadd", "sh_mi_vadd", "z_mi_invest",
        iv_sym, "mi_gmm2_vadd_sym", gmm2=True
    )
    print("  6a done")

    all_results["mi_gmm2_ship_sym"] = run_iv_block(
        df, "mi", "g_ship", "sh_mi_ship", "z_mi_invest",
        iv_sym, "mi_gmm2_ship_sym", gmm2=True
    )
    print("  6b done")

    all_results["mi_gmm2_vadd_asym"] = run_iv_asymmetric_block(
        df, "mi", "g_h_vadd", "g_l_vadd", "sh_mi_vadd", "z_mi_invest",
        iv_asym, "mi_gmm2_vadd_asym", gmm2=True
    )
    print("  6c done")

    all_results["mi_gmm2_ship_asym"] = run_iv_asymmetric_block(
        df, "mi", "g_h_ship", "g_l_ship", "sh_mi_ship", "z_mi_invest",
        iv_asym, "mi_gmm2_ship_asym", gmm2=True
    )
    print("  6d done")

    # -----------------------------------------------------------------------
    # SECTION 7: HP Deviations — MI R&D (OLS + FE + IV + GMM2)
    # -----------------------------------------------------------------------
    print("\n--- Section 7: HP Deviations — MI R&D ---")

    # 7.1 OLS — symmetric deviations
    all_results["dev_mi_ols_vadd_sym"] = run_ols_block(
        df, "dev_mi", "dev_vadd", "sh_mi_vadd", "z_mi_invest",
        "dev_mi_ols_vadd_sym"
    )
    print("  7.1a done")

    all_results["dev_mi_ols_ship_sym"] = run_ols_block(
        df, "dev_mi", "dev_vship", "sh_mi_ship", "z_mi_invest",
        "dev_mi_ols_ship_sym"
    )
    print("  7.1b done")

    # 7.2 OLS — asymmetric deviations
    all_results["dev_mi_ols_vadd_asym"] = run_ols_asymmetric_block(
        df, "dev_mi", "dev_h_g_vadd", "dev_l_g_vadd",
        "sh_mi_vadd", "z_mi_invest",
        "dev_mi_ols_vadd_asym"
    )
    print("  7.2a done")

    all_results["dev_mi_ols_ship_asym"] = run_ols_asymmetric_block(
        df, "dev_mi", "dev_h_g_ship", "dev_l_g_ship",
        "sh_mi_ship", "z_mi_invest",
        "dev_mi_ols_ship_asym"
    )
    print("  7.2b done")

    # 7.3 IV — symmetric deviations
    all_results["dev_mi_iv_vadd_sym"] = run_iv_block(
        df, "dev_mi", "dev_vadd", "sh_mi_vadd", "z_mi_invest",
        iv_sym, "dev_mi_iv_vadd_sym"
    )
    print("  7.3a done")

    all_results["dev_mi_iv_ship_sym"] = run_iv_block(
        df, "dev_mi", "dev_vship", "sh_mi_ship", "z_mi_invest",
        iv_sym, "dev_mi_iv_ship_sym"
    )
    print("  7.3b done")

    # 7.4 IV — asymmetric deviations
    all_results["dev_mi_iv_vadd_asym"] = run_iv_asymmetric_block(
        df, "dev_mi", "dev_h_g_vadd", "dev_l_g_vadd",
        "sh_mi_vadd", "z_mi_invest",
        iv_asym, "dev_mi_iv_vadd_asym"
    )
    print("  7.4a done")

    all_results["dev_mi_iv_ship_asym"] = run_iv_asymmetric_block(
        df, "dev_mi", "dev_h_g_ship", "dev_l_g_ship",
        "sh_mi_ship", "z_mi_invest",
        iv_asym, "dev_mi_iv_ship_asym"
    )
    print("  7.4b done")

    # 7.5 GMM2 — symmetric deviations
    all_results["dev_mi_gmm2_vadd_sym"] = run_iv_block(
        df, "dev_mi", "dev_vadd", "sh_mi_vadd", "z_mi_invest",
        iv_sym, "dev_mi_gmm2_vadd_sym", gmm2=True
    )
    print("  7.5a done")

    all_results["dev_mi_gmm2_ship_sym"] = run_iv_block(
        df, "dev_mi", "dev_vship", "sh_mi_ship", "z_mi_invest",
        iv_sym, "dev_mi_gmm2_ship_sym", gmm2=True
    )
    print("  7.5b done")

    # 7.6 GMM2 — asymmetric deviations
    all_results["dev_mi_gmm2_vadd_asym"] = run_iv_asymmetric_block(
        df, "dev_mi", "dev_h_g_vadd", "dev_l_g_vadd",
        "sh_mi_vadd", "z_mi_invest",
        iv_asym, "dev_mi_gmm2_vadd_asym", gmm2=True
    )
    print("  7.6a done")

    all_results["dev_mi_gmm2_ship_asym"] = run_iv_asymmetric_block(
        df, "dev_mi", "dev_h_g_ship", "dev_l_g_ship",
        "sh_mi_ship", "z_mi_invest",
        iv_asym, "dev_mi_gmm2_ship_asym", gmm2=True
    )
    print("  7.6b done")

    # -----------------------------------------------------------------------
    # Output
    # -----------------------------------------------------------------------
    print("\nSaving results …")

    cycle_vars = [
        "g_vadd", "g_ship", "g_h_vadd", "g_l_vadd", "g_h_ship", "g_l_ship",
        "dev_vadd", "dev_vship", "dev_h_g_vadd", "dev_l_g_vadd",
        "dev_h_g_ship", "dev_l_g_ship",
    ]
    summary_df = cyclicality_summary(all_results, cycle_vars)

    with pd.ExcelWriter(XLSX_PATH, engine="openpyxl") as writer:
        # Summary sheet: cyclicality coefficients across all specifications
        summary_df.to_excel(writer, sheet_name="cyclicality_summary", index=False)

        # One sheet per block with full regression output
        for block_name, result_list in all_results.items():
            df_block = results_to_df(result_list)
            # Excel sheet names max 31 chars
            sheet = block_name[:31]
            df_block.to_excel(writer, sheet_name=sheet, index=False)

    print(f"Wrote {XLSX_PATH}")

    # Markdown summary of headline cyclicality results
    md_lines = [
        "# R&D Industry Analysis: Cyclicality Coefficient Summary",
        "",
        "Replication of `[1]_RND_Industry_data_final.do`.",
        "",
        "## Key cyclicality coefficients",
        "",
        "| Block | Label | Estimator | Cycle variable | Coef | SE | p | Sig | N |",
        "|-------|-------|-----------|---------------|------|----|---|-----|---|",
    ]
    for _, row in summary_df.iterrows():
        md_lines.append(
            f"| {row['block']} | {row['label']} | {row['estimator']} | "
            f"{row['cycle_var']} | {row['coef']} | {row['se']} | "
            f"{row['pvalue']} | {row['stars']} | {row['n']} |"
        )
    MD_PATH.write_text("\n".join(md_lines) + "\n", encoding="utf-8")
    print(f"Wrote {MD_PATH}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
