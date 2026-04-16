#!/usr/bin/env python3
"""
analyse_compustat_nber.py
=========================
Python replication of [2]_final_data_compustat_NBER.do.

Data source: processed_compustat_nber table in cyclicality.db.
Panel structure: key (firm), year.

The script mirrors the three main estimation blocks:

  1. FE OLS — symmetric output measures (d_vadd, d_vship, d_sale, d_va_a),
     each paired with R&D growth (d_xrd) and two R&D intensity measures.
  2. FE OLS — asymmetric output splits (g_h_*, g_l_*), same R&D measure grid.
  3. FE IV / GMM2 — sales and value-added instrumented by value-added / shipments
     growth (and their leads), both symmetric and asymmetric.
  4. Demeaned data section — within-firm demeaned growth rates, same grid.

Estimation equivalences
-----------------------
Stata: xtreg ... fe vce(cluster key)
Python: linearmodels.PanelOLS, entity_effects=True, cov_type='clustered'

Stata: xtivreg2 ... fe cluster(key) robust
Python: within-demean by entity + linearmodels.iv.IV2SLS, cov_type='clustered'

Stata: xtivreg2 ... fe gmm2 cluster(key)
Python: within-demean by entity + linearmodels.iv.IVGMM, cov_type='clustered'

Controls: emp, r_cf, r_dd1, r_dltt, r_lt, r_at, r_ppent, their lags (l. l2.),
          time dummies t1–t48.

Output
------
  results/compustat_nber_results.xlsx   (one sheet per regression block)
  results/compustat_nber_results.md     (cyclicality coefficient summary)
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

XLSX_PATH = RESULTS_DIR / "compustat_nber_results.xlsx"
MD_PATH = RESULTS_DIR / "compustat_nber_results.md"


# ---------------------------------------------------------------------------
# Panel utility helpers
# ---------------------------------------------------------------------------

def panel_lag(df: pd.DataFrame, col: str,
              panel: str = "key", time: str = "year",
              n: int = 1) -> pd.Series:
    """Lag `col` by `n` periods within each panel unit.

    Returns NaN whenever the observation is not exactly n years after the
    previous one (i.e. panel gaps are not bridged).
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
    """Add lags, leads, and any missing derived variables."""
    df = df.sort_values(["key", "year"]).copy()
    df["year"] = pd.to_numeric(df["year"], errors="coerce").astype("Int64")

    # Lags of financial controls (for l. and l2. terms in Stata)
    ctrl_lag_cols = ["r_cf", "r_dd1", "r_dltt", "r_lt", "r_at"]
    for col in ctrl_lag_cols:
        if col in df.columns:
            df[f"l_{col}"] = panel_lag(df, col)
            df[f"l2_{col}"] = panel_lag(df, col, n=2)

    # Lags of intensity ratios (l. and l2.)
    intensity_cols = [
        "z_rd_vadd", "z_rd_vship", "z_rd_sale", "z_rd_capx", "z_rd_va_a",
    ]
    for col in intensity_cols:
        if col in df.columns:
            df[f"l_{col}"] = panel_lag(df, col)
            df[f"l2_{col}"] = panel_lag(df, col, n=2)

    # Lead of growth rates (for IV instruments: f.d_vadd etc.)
    for col in ["d_vadd", "d_vship", "g_h_vadd", "g_l_vadd",
                "g_h_vship", "g_l_vship"]:
        if col in df.columns:
            df[f"f_{col}"] = panel_lead(df, col)

    return df


# ---------------------------------------------------------------------------
# Regression wrappers
# ---------------------------------------------------------------------------

def _make_panel_mi(df: pd.DataFrame, y: pd.Series,
                   X: pd.DataFrame) -> tuple | None:
    """Prepare MultiIndex (key, year) data for linearmodels PanelOLS.

    Drops zero-variance columns from the filtered regressor matrix before
    returning, mirroring Stata's automatic collinear-variable removal.
    """
    mask = y.notna() & X.notna().all(axis=1)
    if mask.sum() < 20:
        return None
    X_f = X[mask]
    # Drop columns with no variation in the estimation sample (e.g. time
    # dummies that fall outside the panel window after complete-case filter).
    varying = X_f.columns[X_f.nunique() > 1]
    X_f = X_f[varying]
    mi = pd.MultiIndex.from_arrays(
        [df.loc[mask, "key"].values,
         df.loc[mask, "year"].values],
        names=["key", "year"],
    )
    dep = pd.DataFrame({"dep": y[mask].values}, index=mi)
    exog = pd.DataFrame(X_f.values, index=mi, columns=X_f.columns)
    return dep, exog


def _fe_ols_cluster(y: pd.Series, X: pd.DataFrame,
                    df: pd.DataFrame, label: str) -> dict:
    """FE OLS, cluster-robust SEs at entity level.
    Stata: xtreg ... fe vce(cluster key)
    """
    panel = _make_panel_mi(df, y, X)
    if panel is None:
        return {"label": label, "estimator": "FE OLS", "n": 0, "results": None}
    dep, exog = panel
    mod = PanelOLS(dep, exog, entity_effects=True)
    res = mod.fit(cov_type="clustered", cluster_entity=True)
    return _extract_panel(res, label, "FE OLS")


def _fe_iv_cluster(y: pd.Series, X_exog: pd.DataFrame,
                   X_endog: pd.DataFrame, Z: pd.DataFrame,
                   df: pd.DataFrame, label: str,
                   gmm2: bool = False) -> dict:
    """FE 2SLS or GMM2 via within-demeaning + IV2SLS/IVGMM.
    Stata: xtivreg2 ... fe cluster(key) [gmm2]
    """
    mask = (y.notna()
            & X_exog.notna().all(axis=1)
            & X_endog.notna().all(axis=1)
            & Z.notna().all(axis=1))
    if mask.sum() < 20:
        est = "FE GMM2" if gmm2 else "FE IV"
        return {"label": label, "estimator": est, "n": 0, "results": None}

    df_sub = df.loc[mask, ["key"]].copy()
    y_s, Xe_s, Xn_s, Z_s = (y[mask].copy(), X_exog[mask].copy(),
                              X_endog[mask].copy(), Z[mask].copy())

    def _demean(s: pd.Series) -> pd.Series:
        return s - df_sub["key"].map(s.groupby(df_sub["key"]).mean())

    y_w = _demean(y_s)
    Xe_w = Xe_s.apply(_demean)
    Xn_w = Xn_s.apply(_demean)
    Z_w = Z_s.apply(_demean)

    Xc_w = sm.add_constant(Xe_w, has_constant="add")
    cluster_ids = df_sub["key"].values

    est = "FE GMM2" if gmm2 else "FE IV"
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
    return {
        "label": label, "estimator": estimator,
        "n": int(res.nobs),
        "params": res.params.to_dict(),
        "pvalues": res.pvalues.to_dict(),
        "se": res.std_errors.to_dict(),
        "results": res,
    }


def _extract_iv(res, label: str, estimator: str) -> dict:
    return {
        "label": label, "estimator": estimator,
        "n": int(res.nobs),
        "params": res.params.to_dict(),
        "pvalues": res.pvalues.to_dict(),
        "se": res.std_errors.to_dict(),
        "results": res,
    }


# ---------------------------------------------------------------------------
# Standard regressor sets
# ---------------------------------------------------------------------------

def _time_dummies(df: pd.DataFrame) -> pd.DataFrame:
    """Return time-dummy columns t1–t48."""
    cols = [f"t{i}" for i in range(1, 49)]
    return df[[c for c in cols if c in df.columns]]


def _financial_controls(df: pd.DataFrame) -> pd.DataFrame:
    """Standard controls + lags for financial variables.

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
# Regression blocks
# ---------------------------------------------------------------------------

def run_fe_ols_sym(df: pd.DataFrame, output_col: str,
                   depA: str, depB: str, depC: str,
                   block_name: str) -> list[dict]:
    """
    FE OLS block for one symmetric output measure.

    A: d_xrd ~ output_col + controls + year dummies
    B: depB   ~ l.depB l2.depB output_col + controls + year dummies
    C: depC   ~ l.depC l2.depC output_col + controls + year dummies
    """
    ctrl = _financial_controls(df)
    tdums = _time_dummies(df)
    results = []

    # A: R&D growth
    X_A = pd.concat([df[[output_col]], ctrl, tdums], axis=1)
    results.append(_fe_ols_cluster(df[depA], X_A, df, f"{block_name}_A"))

    # B: R&D / output intensity (with 2 lags)
    l_B, l2_B = df.get(f"l_{depB}"), df.get(f"l2_{depB}")
    if l_B is not None and l2_B is not None:
        X_B = pd.concat([l_B, l2_B, df[[output_col]], ctrl, tdums], axis=1)
        results.append(_fe_ols_cluster(df[depB], X_B, df, f"{block_name}_B"))
    else:
        results.append({"label": f"{block_name}_B", "estimator": "FE OLS",
                        "n": 0, "results": None})

    # C: R&D / capx intensity (with 2 lags)
    l_C, l2_C = df.get(f"l_{depC}"), df.get(f"l2_{depC}")
    if l_C is not None and l2_C is not None:
        X_C = pd.concat([l_C, l2_C, df[[output_col]], ctrl, tdums], axis=1)
        results.append(_fe_ols_cluster(df[depC], X_C, df, f"{block_name}_C"))
    else:
        results.append({"label": f"{block_name}_C", "estimator": "FE OLS",
                        "n": 0, "results": None})
    return results


def run_fe_ols_asym(df: pd.DataFrame, gh_col: str, gl_col: str,
                    depA: str, depB: str, depC: str,
                    block_name: str) -> list[dict]:
    """FE OLS with asymmetric output splits (g_h_*, g_l_*)."""
    ctrl = _financial_controls(df)
    tdums = _time_dummies(df)
    results = []

    X_A = pd.concat([df[[gh_col, gl_col]], ctrl, tdums], axis=1)
    results.append(_fe_ols_cluster(df[depA], X_A, df, f"{block_name}_A"))

    l_B, l2_B = df.get(f"l_{depB}"), df.get(f"l2_{depB}")
    if l_B is not None and l2_B is not None:
        X_B = pd.concat([l_B, l2_B, df[[gh_col, gl_col]], ctrl, tdums],
                        axis=1)
        results.append(_fe_ols_cluster(df[depB], X_B, df, f"{block_name}_B"))
    else:
        results.append({"label": f"{block_name}_B", "estimator": "FE OLS",
                        "n": 0, "results": None})

    l_C, l2_C = df.get(f"l_{depC}"), df.get(f"l2_{depC}")
    if l_C is not None and l2_C is not None:
        X_C = pd.concat([l_C, l2_C, df[[gh_col, gl_col]], ctrl, tdums],
                        axis=1)
        results.append(_fe_ols_cluster(df[depC], X_C, df, f"{block_name}_C"))
    else:
        results.append({"label": f"{block_name}_C", "estimator": "FE OLS",
                        "n": 0, "results": None})
    return results


def run_fe_iv_block(df: pd.DataFrame, endog_col: str, iv_cols: list[str],
                    depA: str, depB: str, depC: str,
                    block_name: str, gmm2: bool = False) -> list[dict]:
    """
    FE IV / GMM2 block for one (endogenous output, instruments) pair.

    A: depA ~ (endog_col = IVs) + controls + year dummies
    B: depB ~ l.depB l2.depB (endog_col = IVs) + controls + year dummies
    C: depC ~ l.depC l2.depC (endog_col = IVs) + controls + year dummies
    """
    ctrl = _financial_controls(df)
    tdums = _time_dummies(df)
    X_endog = df[[endog_col]]
    Z = df[iv_cols]
    results = []

    # A
    Xe_A = pd.concat([ctrl, tdums], axis=1)
    results.append(_fe_iv_cluster(df[depA], Xe_A, X_endog, Z, df,
                                  f"{block_name}_A", gmm2=gmm2))

    # B
    l_B, l2_B = df.get(f"l_{depB}"), df.get(f"l2_{depB}")
    if l_B is not None and l2_B is not None:
        Xe_B = pd.concat([l_B, l2_B, ctrl, tdums], axis=1)
        results.append(_fe_iv_cluster(df[depB], Xe_B, X_endog, Z, df,
                                      f"{block_name}_B", gmm2=gmm2))
    else:
        est = "FE GMM2" if gmm2 else "FE IV"
        results.append({"label": f"{block_name}_B", "estimator": est,
                        "n": 0, "results": None})

    # C
    l_C, l2_C = df.get(f"l_{depC}"), df.get(f"l2_{depC}")
    if l_C is not None and l2_C is not None:
        Xe_C = pd.concat([l_C, l2_C, ctrl, tdums], axis=1)
        results.append(_fe_iv_cluster(df[depC], Xe_C, X_endog, Z, df,
                                      f"{block_name}_C", gmm2=gmm2))
    else:
        est = "FE GMM2" if gmm2 else "FE IV"
        results.append({"label": f"{block_name}_C", "estimator": est,
                        "n": 0, "results": None})
    return results


def run_fe_iv_asym_block(df: pd.DataFrame,
                         endog_h: str, endog_l: str,
                         iv_cols: list[str],
                         depA: str, depB: str, depC: str,
                         block_name: str, gmm2: bool = False) -> list[dict]:
    """FE IV / GMM2 with asymmetric endogenous regressors."""
    ctrl = _financial_controls(df)
    tdums = _time_dummies(df)
    X_endog = df[[endog_h, endog_l]]
    Z = df[iv_cols]
    results = []

    Xe_A = pd.concat([ctrl, tdums], axis=1)
    results.append(_fe_iv_cluster(df[depA], Xe_A, X_endog, Z, df,
                                  f"{block_name}_A", gmm2=gmm2))

    l_B, l2_B = df.get(f"l_{depB}"), df.get(f"l2_{depB}")
    if l_B is not None and l2_B is not None:
        Xe_B = pd.concat([l_B, l2_B, ctrl, tdums], axis=1)
        results.append(_fe_iv_cluster(df[depB], Xe_B, X_endog, Z, df,
                                      f"{block_name}_B", gmm2=gmm2))
    else:
        est = "FE GMM2" if gmm2 else "FE IV"
        results.append({"label": f"{block_name}_B", "estimator": est,
                        "n": 0, "results": None})

    l_C, l2_C = df.get(f"l_{depC}"), df.get(f"l2_{depC}")
    if l_C is not None and l2_C is not None:
        Xe_C = pd.concat([l_C, l2_C, ctrl, tdums], axis=1)
        results.append(_fe_iv_cluster(df[depC], Xe_C, X_endog, Z, df,
                                      f"{block_name}_C", gmm2=gmm2))
    else:
        est = "FE GMM2" if gmm2 else "FE IV"
        results.append({"label": f"{block_name}_C", "estimator": est,
                        "n": 0, "results": None})
    return results


# ---------------------------------------------------------------------------
# Results formatting
# ---------------------------------------------------------------------------

def results_to_df(results: list[dict]) -> pd.DataFrame:
    rows = []
    for r in results:
        if r.get("results") is None:
            rows.append({"label": r["label"], "estimator": r["estimator"],
                         "n": r["n"], "variable": "—",
                         "coef": np.nan, "se": np.nan, "pvalue": np.nan})
            continue
        for var, coef in r["params"].items():
            rows.append({
                "label": r["label"], "estimator": r["estimator"],
                "n": r["n"], "variable": var,
                "coef": coef,
                "se": r["se"].get(var, np.nan),
                "pvalue": r["pvalues"].get(var, np.nan),
            })
    return pd.DataFrame(rows)


def _stars(p: float) -> str:
    if p < 0.01: return "***"
    if p < 0.05: return "**"
    if p < 0.10: return "*"
    return ""


def cyclicality_summary(all_results: dict[str, list[dict]],
                        cycle_vars: list[str]) -> pd.DataFrame:
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
                        "block": block_name, "label": r["label"],
                        "estimator": r["estimator"], "cycle_var": cv,
                        "coef": round(coef, 4), "se": round(se, 4),
                        "pvalue": round(pv, 4), "stars": _stars(pv),
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
            "SELECT * FROM processed_compustat_nber ORDER BY key, year",
            conn,
        )

    print(f"  Loaded {len(df)} rows, {df.shape[1]} columns.")
    print(f"  Panel: {df['key'].nunique()} firms, "
          f"years {int(pd.to_numeric(df['year'], errors='coerce').min())}"
          f"–{int(pd.to_numeric(df['year'], errors='coerce').max())}")

    # Numeric coercion for all analytical columns
    skip_str = {"gvkey", "naics", "sic", "spcsrc"}
    for col in df.columns:
        if col not in skip_str:
            df[col] = pd.to_numeric(df[col], errors="coerce")

    df = build_analysis_vars(df)

    all_results: dict[str, list[dict]] = {}

    # -----------------------------------------------------------------------
    # SECTION 1: FE OLS — Symmetric output measures
    # -----------------------------------------------------------------------
    print("\n--- Section 1: FE OLS — Symmetric ---")

    output_specs = [
        ("d_vadd",  "z_rd_vadd",  "1a_vadd"),
        ("d_vship", "z_rd_vship", "1b_vship"),
        ("d_sale",  "z_rd_sale",  "1c_sale"),
        ("d_va_a",  "z_rd_va_a",  "1d_va_a"),
    ]
    for out_col, z_col, tag in output_specs:
        all_results[f"ols_sym_{tag}"] = run_fe_ols_sym(
            df, out_col, "d_xrd", z_col, "z_rd_capx",
            f"ols_sym_{tag}"
        )
        print(f"  {tag} done")

    # -----------------------------------------------------------------------
    # SECTION 2: FE OLS — Asymmetric output splits
    # -----------------------------------------------------------------------
    print("\n--- Section 2: FE OLS — Asymmetric ---")

    asym_specs = [
        ("g_h_vadd",  "g_l_vadd",  "z_rd_vadd",  "2a_vadd"),
        ("g_h_vship", "g_l_vship", "z_rd_vship", "2b_vship"),
        ("g_h_sale",  "g_l_sale",  "z_rd_sale",  "2c_sale"),
        ("g_h_va_a",  "g_l_va_a",  "z_rd_va_a",  "2d_va_a"),
    ]
    for gh, gl, z_col, tag in asym_specs:
        all_results[f"ols_asym_{tag}"] = run_fe_ols_asym(
            df, gh, gl, "d_xrd", z_col, "z_rd_capx",
            f"ols_asym_{tag}"
        )
        print(f"  {tag} done")

    # -----------------------------------------------------------------------
    # SECTION 3: FE IV — Symmetric (d_sale instrumented)
    # -----------------------------------------------------------------------
    print("\n--- Section 3: FE IV — Symmetric ---")

    # 3a: d_sale ~ (d_sale = d_vadd f.d_vadd)
    all_results["iv_sym_sale_iv_vadd"] = run_fe_iv_block(
        df, "d_sale", ["d_vadd", "f_d_vadd"],
        "d_xrd", "z_rd_sale", "z_rd_capx",
        "iv_sym_sale_iv_vadd"
    )
    print("  3a done")

    # 3b: GMM2 version
    all_results["gmm2_sym_sale_iv_vadd"] = run_fe_iv_block(
        df, "d_sale", ["d_vadd", "f_d_vadd"],
        "d_xrd", "z_rd_sale", "z_rd_capx",
        "gmm2_sym_sale_iv_vadd", gmm2=True
    )
    print("  3b done")

    # 3c: d_va_a instrumented by d_vadd, f.d_vadd
    all_results["iv_sym_vaa_iv_vadd"] = run_fe_iv_block(
        df, "d_va_a", ["d_vadd", "f_d_vadd"],
        "d_xrd", "z_rd_va_a", "z_rd_capx",
        "iv_sym_vaa_iv_vadd"
    )
    print("  3c done")

    all_results["gmm2_sym_vaa_iv_vadd"] = run_fe_iv_block(
        df, "d_va_a", ["d_vadd", "f_d_vadd"],
        "d_xrd", "z_rd_va_a", "z_rd_capx",
        "gmm2_sym_vaa_iv_vadd", gmm2=True
    )
    print("  3d done")

    # 3e: d_sale instrumented by d_vship, f.d_vship
    all_results["iv_sym_sale_iv_vship"] = run_fe_iv_block(
        df, "d_sale", ["d_vship", "f_d_vship"],
        "d_xrd", "z_rd_sale", "z_rd_capx",
        "iv_sym_sale_iv_vship"
    )
    print("  3e done")

    all_results["gmm2_sym_sale_iv_vship"] = run_fe_iv_block(
        df, "d_sale", ["d_vship", "f_d_vship"],
        "d_xrd", "z_rd_sale", "z_rd_capx",
        "gmm2_sym_sale_iv_vship", gmm2=True
    )
    print("  3f done")

    # 3g: d_va_a instrumented by d_vship, f.d_vship
    all_results["iv_sym_vaa_iv_vship"] = run_fe_iv_block(
        df, "d_va_a", ["d_vship", "f_d_vship"],
        "d_xrd", "z_rd_va_a", "z_rd_capx",
        "iv_sym_vaa_iv_vship"
    )
    print("  3g done")

    all_results["gmm2_sym_vaa_iv_vship"] = run_fe_iv_block(
        df, "d_va_a", ["d_vship", "f_d_vship"],
        "d_xrd", "z_rd_va_a", "z_rd_capx",
        "gmm2_sym_vaa_iv_vship", gmm2=True
    )
    print("  3h done")

    # -----------------------------------------------------------------------
    # SECTION 4: FE IV — Asymmetric (g_h_sale, g_l_sale instrumented)
    # -----------------------------------------------------------------------
    print("\n--- Section 4: FE IV — Asymmetric ---")

    # Instruments for asymmetric sale: g_h_vadd, g_l_vadd, f.g_h_vadd, f.g_l_vadd
    iv_asym_vadd = ["g_h_vadd", "g_l_vadd", "f_g_h_vadd", "f_g_l_vadd"]
    iv_asym_vship = ["g_h_vship", "g_l_vship", "f_g_h_vship", "f_g_l_vship"]

    # Check instruments available
    for col in iv_asym_vadd + iv_asym_vship:
        if col not in df.columns:
            print(f"  WARNING: instrument {col} missing from data")

    # 4a–4b: (g_h_sale, g_l_sale) IV by (g_h_vadd, g_l_vadd, f.)
    all_results["iv_asym_sale_iv_vadd"] = run_fe_iv_asym_block(
        df, "g_h_sale", "g_l_sale",
        iv_asym_vadd,
        "d_xrd", "z_rd_sale", "z_rd_capx",
        "iv_asym_sale_iv_vadd"
    )
    print("  4a done")

    all_results["gmm2_asym_sale_iv_vadd"] = run_fe_iv_asym_block(
        df, "g_h_sale", "g_l_sale",
        iv_asym_vadd,
        "d_xrd", "z_rd_sale", "z_rd_capx",
        "gmm2_asym_sale_iv_vadd", gmm2=True
    )
    print("  4b done")

    # 4c–4d: (g_h_sale, g_l_sale) IV by (g_h_vship, g_l_vship, f.)
    all_results["iv_asym_sale_iv_vship"] = run_fe_iv_asym_block(
        df, "g_h_sale", "g_l_sale",
        iv_asym_vship,
        "d_xrd", "z_rd_sale", "z_rd_capx",
        "iv_asym_sale_iv_vship"
    )
    print("  4c done")

    all_results["gmm2_asym_sale_iv_vship"] = run_fe_iv_asym_block(
        df, "g_h_sale", "g_l_sale",
        iv_asym_vship,
        "d_xrd", "z_rd_sale", "z_rd_capx",
        "gmm2_asym_sale_iv_vship", gmm2=True
    )
    print("  4d done")

    # 4e–4h: (g_h_va_a, g_l_va_a) IV by vadd and vship instruments
    all_results["iv_asym_vaa_iv_vadd"] = run_fe_iv_asym_block(
        df, "g_h_va_a", "g_l_va_a",
        iv_asym_vadd,
        "d_xrd", "z_rd_va_a", "z_rd_capx",
        "iv_asym_vaa_iv_vadd"
    )
    print("  4e done")

    all_results["gmm2_asym_vaa_iv_vadd"] = run_fe_iv_asym_block(
        df, "g_h_va_a", "g_l_va_a",
        iv_asym_vadd,
        "d_xrd", "z_rd_va_a", "z_rd_capx",
        "gmm2_asym_vaa_iv_vadd", gmm2=True
    )
    print("  4f done")

    all_results["iv_asym_vaa_iv_vship"] = run_fe_iv_asym_block(
        df, "g_h_va_a", "g_l_va_a",
        iv_asym_vship,
        "d_xrd", "z_rd_va_a", "z_rd_capx",
        "iv_asym_vaa_iv_vship"
    )
    print("  4g done")

    all_results["gmm2_asym_vaa_iv_vship"] = run_fe_iv_asym_block(
        df, "g_h_va_a", "g_l_va_a",
        iv_asym_vship,
        "d_xrd", "z_rd_va_a", "z_rd_capx",
        "gmm2_asym_vaa_iv_vship", gmm2=True
    )
    print("  4h done")

    # -----------------------------------------------------------------------
    # SECTION 5: Demeaned data (within-firm demeaned growth rates)
    # -----------------------------------------------------------------------
    print("\n--- Section 5: Demeaned data ---")

    # 5.1: FE OLS on demeaned variables (symmetric)
    dev_specs = [
        ("dev_vadd",  "z_rd_vadd",  "5a_dev_vadd"),
        ("dev_vship", "z_rd_vship", "5b_dev_vship"),
        ("dev_sale",  "z_rd_sale",  "5c_dev_sale"),
        ("dev_va_a",  "z_rd_va_a",  "5d_dev_va_a"),
    ]
    for dev_col, z_col, tag in dev_specs:
        all_results[f"dev_ols_sym_{tag}"] = run_fe_ols_sym(
            df, dev_col, "dev_xrd", z_col, "z_rd_capx",
            f"dev_ols_sym_{tag}"
        )
        print(f"  5.1 {tag} done")

    # 5.2: FE OLS on demeaned variables (asymmetric)
    dev_asym_specs = [
        ("dev_g_h_vadd",  "dev_g_l_vadd",  "z_rd_vadd",  "5e_dev_vadd"),
        ("dev_g_h_vship", "dev_g_l_vship", "z_rd_vship", "5f_dev_vship"),
        ("dev_g_h_sale",  "dev_g_l_sale",  "z_rd_sale",  "5g_dev_sale"),
        ("dev_g_h_va_a",  "dev_g_l_va_a",  "z_rd_va_a",  "5h_dev_va_a"),
    ]
    for gh, gl, z_col, tag in dev_asym_specs:
        if gh not in df.columns or gl not in df.columns:
            print(f"  Skipping {tag} — {gh}/{gl} missing")
            continue
        all_results[f"dev_ols_asym_{tag}"] = run_fe_ols_asym(
            df, gh, gl, "dev_xrd", z_col, "z_rd_capx",
            f"dev_ols_asym_{tag}"
        )
        print(f"  5.2 {tag} done")

    # -----------------------------------------------------------------------
    # Output
    # -----------------------------------------------------------------------
    print("\nSaving results …")

    cycle_vars = [
        "d_vadd", "d_vship", "d_sale", "d_va_a",
        "g_h_vadd", "g_l_vadd", "g_h_vship", "g_l_vship",
        "g_h_sale", "g_l_sale", "g_h_va_a", "g_l_va_a",
        "dev_vadd", "dev_vship", "dev_sale", "dev_va_a",
        "dev_g_h_vadd", "dev_g_l_vadd", "dev_g_h_sale", "dev_g_l_sale",
    ]
    summary_df = cyclicality_summary(all_results, cycle_vars)

    with pd.ExcelWriter(XLSX_PATH, engine="openpyxl") as writer:
        summary_df.to_excel(writer, sheet_name="cyclicality_summary",
                            index=False)
        for block_name, result_list in all_results.items():
            df_block = results_to_df(result_list)
            sheet = block_name[:31]
            df_block.to_excel(writer, sheet_name=sheet, index=False)

    print(f"Wrote {XLSX_PATH}")

    md_lines = [
        "# Compustat × NBER Analysis: Cyclicality Coefficient Summary",
        "",
        "Replication of `[2]_final_data_compustat_NBER.do`.",
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
