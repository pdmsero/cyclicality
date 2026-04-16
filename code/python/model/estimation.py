"""
estimation.py
-------------
Run the paper's empirical specifications on the simulated panel to
reproduce Table 4.

The paper estimates (on Compustat data, and replicates on simulated data):

  Spec A:  Δlog(Z_{it}) = β_1 * Δlog(PY_{it}) + α_i + ε_{it}
  Spec B:  Z_{it}/PY_{it} = β_1 * Δlog(PY_{it}) + α_i + ε_{it}

where PY = nominal sales (revenue), Z = R&D expenditure, both in levels.
α_i are firm fixed effects.

Target moments from paper (Table 4, main specification):
  γ = 0.05 → β_1 ≈ 0.319  (Spec A, Δlog Z on Δlog PY)
  γ = 0.10 → β_1 ≈ 0.344
  γ = 0.15 → β_1 ≈ 0.372
  γ = 0.20 → β_1 ≈ 0.404

  R&D share regression coefficients: {-0.004, -0.008, -0.011, -0.014}

The coefficient β_1 < 1 (R&D is smoothed) and increasing in γ
(higher curvature → more sensitivity to current conditions).

Implementation
--------------
We use linearmodels.PanelOLS with entity effects for consistency with
the rest of the project. For the simulated panel we use standard SEs
(no clustering) to reduce noise from the small simulation panel.
"""

from __future__ import annotations
import numpy as np
import pandas as pd
from typing import Dict, Optional

from linearmodels import PanelOLS

from .simulation import SimulatedPanel


def prepare_regression_vars(panel: SimulatedPanel) -> pd.DataFrame:
    """
    Construct regression variables from the simulated panel.

    Returns a DataFrame with columns:
      firm, year, dlog_Z, dlog_PY, Z_PY_share, log_Z, log_PY
    """
    df = panel.df.copy()

    # Revenue = PY (in the model: Y_lev is physical output; revenue = θ^{-1}*Y
    # but since θ is a constant, log differences are the same)
    df["log_Z"]  = np.log(df["Z"].clip(lower=1e-12))
    df["log_PY"] = np.log(df["Y"].clip(lower=1e-12))

    df = df.sort_values(["firm", "year"])
    df["dlog_Z"]  = df.groupby("firm")["log_Z"].diff()
    df["dlog_PY"] = df.groupby("firm")["log_PY"].diff()
    df["Z_PY_share"] = df["Z"] / df["Y"].clip(lower=1e-12)

    # Drop first observation (NaN from diff) and any inf/nan
    df = df.dropna(subset=["dlog_Z", "dlog_PY"])
    df = df[np.isfinite(df["dlog_Z"]) & np.isfinite(df["dlog_PY"])]

    return df


def run_fe_regression(df: pd.DataFrame, dep_var: str,
                       indep_var: str = "dlog_PY",
                       label: str = "") -> Dict:
    """
    Run panel FE OLS regression: dep_var = β * indep_var + FE + ε

    Parameters
    ----------
    df       : DataFrame with firm, year columns + dep_var + indep_var
    dep_var  : dependent variable column name
    indep_var: independent variable column name
    label    : label for output dict

    Returns
    -------
    dict with keys: label, beta, se, pval, n, r2
    """
    df_clean = df[[dep_var, indep_var, "firm", "year"]].dropna()
    df_clean = df_clean[np.isfinite(df_clean[dep_var]) &
                        np.isfinite(df_clean[indep_var])]

    if len(df_clean) < 10:
        return {"label": label, "beta": np.nan, "se": np.nan,
                "pval": np.nan, "n": 0}

    mi = pd.MultiIndex.from_arrays(
        [df_clean["firm"].values, df_clean["year"].values],
        names=["firm", "year"]
    )
    dep  = pd.DataFrame({dep_var: df_clean[dep_var].values}, index=mi)
    exog = pd.DataFrame({indep_var: df_clean[indep_var].values}, index=mi)

    mod = PanelOLS(dep, exog, entity_effects=True)
    res = mod.fit(cov_type="unadjusted")   # standard SEs for simulated data

    return {
        "label":  label,
        "beta":   float(res.params[indep_var]),
        "se":     float(res.std_errors[indep_var]),
        "pval":   float(res.pvalues[indep_var]),
        "n":      int(res.nobs),
        "r2_within": float(res.rsquared),
    }


def estimate_table4(panel: SimulatedPanel, gamma: float,
                    method: str = "unknown") -> Dict:
    """
    Run both Table 4 specifications and return a results summary dict.

    Parameters
    ----------
    panel  : SimulatedPanel from simulation
    gamma  : curvature parameter (for labelling)
    method : solution method label ('perturbation', 'vfi', 'projection')

    Returns
    -------
    dict with all regression results
    """
    df = prepare_regression_vars(panel)

    # Spec A: Δlog(Z) on Δlog(PY)
    res_A = run_fe_regression(df, dep_var="dlog_Z", indep_var="dlog_PY",
                              label=f"Δlog(Z) ~ Δlog(PY) | γ={gamma}")

    # Spec B: Z/PY share on Δlog(PY)
    res_B = run_fe_regression(df, dep_var="Z_PY_share", indep_var="dlog_PY",
                              label=f"Z/PY ~ Δlog(PY) | γ={gamma}")

    return {
        "gamma":  gamma,
        "method": method,
        "spec_A": res_A,
        "spec_B": res_B,
        # Convenience aliases
        "beta_A": res_A.get("beta", np.nan),
        "beta_B": res_B.get("beta", np.nan),
        "n_obs":  res_A.get("n", 0),
    }


def format_table4(results_list: list) -> pd.DataFrame:
    """
    Format a list of estimate_table4 dicts into a publication-ready DataFrame.

    Columns: gamma, method, beta_A (Δlog Z ~ Δlog PY), beta_B (Z/PY ~ Δlog PY)
    Target values from paper:
      gamma: 0.05  0.10  0.15  0.20
      β_A:  0.319 0.344 0.372 0.404
      β_B: -0.004 -0.008 -0.011 -0.014
    """
    rows = []
    for r in results_list:
        rows.append({
            "gamma":  r["gamma"],
            "method": r["method"],
            "beta_A": round(r["beta_A"], 3) if not np.isnan(r["beta_A"]) else np.nan,
            "se_A":   round(r["spec_A"].get("se", np.nan), 5),   # 5 dp: SEs are ~0.0003
            "beta_B": round(r["beta_B"], 5) if not np.isnan(r["beta_B"]) else np.nan,
            "se_B":   round(r["spec_B"].get("se", np.nan), 5),
            "n":      r["n_obs"],
        })

    df = pd.DataFrame(rows)
    df = df.sort_values(["method", "gamma"]).reset_index(drop=True)
    return df


# ── Calibration targets (from paper Table 4) ──────────────────────────────────
TABLE4_TARGETS = {
    0.05: {"beta_A": 0.319, "beta_B": -0.004},
    0.10: {"beta_A": 0.344, "beta_B": -0.008},
    0.15: {"beta_A": 0.372, "beta_B": -0.011},
    0.20: {"beta_A": 0.404, "beta_B": -0.014},
}


def compare_to_targets(results_list: list) -> pd.DataFrame:
    """
    Compare estimated β_1 to paper targets.
    Returns DataFrame with columns: gamma, method, beta_A, target_A, diff_A, etc.
    """
    rows = []
    for r in results_list:
        g = r["gamma"]
        tgt = TABLE4_TARGETS.get(g, {})
        rows.append({
            "gamma":     g,
            "method":    r["method"],
            "beta_A":    r["beta_A"],
            "target_A":  tgt.get("beta_A", np.nan),
            "diff_A":    r["beta_A"] - tgt.get("beta_A", np.nan),
            "beta_B":    r["beta_B"],
            "target_B":  tgt.get("beta_B", np.nan),
            "diff_B":    r["beta_B"] - tgt.get("beta_B", np.nan),
        })
    return pd.DataFrame(rows).sort_values(["method", "gamma"]).reset_index(drop=True)
