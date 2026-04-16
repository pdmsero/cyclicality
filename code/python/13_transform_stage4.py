#!/usr/bin/env python3
"""
build_alldata_transform_stage4.py

Stage 4 of the Python pipeline replicating AllData.do lines 801–1333:

  Block 1  Year dummies          (line 801)       tabulate year, gen(yr)
  Block 2  R&D returns GMM       (lines 803–814)  nonlinear GMM B1, B2
  Block 3  TFP production fns    (lines 1160–1333) OLS / FE / ACF

Reads from:  processed_alldata_stage3
Writes to:   processed_alldata_stage4
             meta_stage4_gmm_scalars   (B1, B2 point estimates)
             meta_stage4_pf_coefs      (production function coefficients per spec)

Variable construction notes
---------------------------
AllData.do loaded pre-constructed log variables from the source .dta file;
those are not present in processed_alldata_stage3. This script derives them
from the underlying nominal/real columns that ARE in stage3:

  logemp    = ln(emp)
  logcap    = ln(ppegt.lag1 / piinv.lag1)   [line 1162 replace; piinv = P_FixedInvestment]
  loginv    = ln(capx / piinv)              [investment proxy for ACF]
  logvaa    = ln(va_a)                      [value added: oibdp + wagebill]
  logva     = ln(oibdp + xlr)              [value added: actual payroll]
  logvai    = ln(r_gdp_materials)          [intermediate inputs, GDP deflated]
  logvadd   = ln(vadd)                     [NBER demand-deflated value added]
  logvship  = ln(vship)                    [NBER shipments]
  vanber    = ln(r_nber_va_a)              [log NBER real VA — used as dependent]
  capnber   = ln(r_nberinv_ppegt)         [log NBER real capital]
  invnber   = ln(r_nberinv_capx)          [log NBER real investment]

TFP naming disambiguation
-------------------------
AllData.do overwrites l_tfp_1 etc. across two blocks (logvaa and logva).
Here we use unambiguous names:
  _vaa  suffix → logvaa as output
  _va   suffix → logva as output
  All other spec names (_va_i, _vadd, _nber, etc.) are kept as-is.
"""
from __future__ import annotations

import sqlite3
import sys
import warnings
from pathlib import Path

import numpy as np
import pandas as pd
import statsmodels.api as sm
from scipy.optimize import minimize

ROOT = Path(__file__).resolve().parents[2]
DB_PATH = ROOT / "data" / "cyclicality.db"
IN_TABLE = "processed_alldata_stage3"
OUT_TABLE = "processed_alldata_stage4"
GMM_TABLE = "meta_stage4_gmm_scalars"
COEF_TABLE = "meta_stage4_pf_coefs"

# Try to import linearmodels for FE estimation
try:
    from linearmodels.panel import PanelOLS as _PanelOLS
    _HAS_LINEARMODELS = True
except ImportError:
    _HAS_LINEARMODELS = False
    warnings.warn("linearmodels not installed; FE specs will use within-demean OLS.")

# ACF estimator (same directory)
sys.path.insert(0, str(Path(__file__).parent))
from acf_estimator import ACFEstimator


# ---------------------------------------------------------------------------
# Utility
# ---------------------------------------------------------------------------

def ln_pos(s: pd.Series) -> pd.Series:
    """Log of strictly positive values; NaN otherwise."""
    x = pd.to_numeric(s, errors="coerce")
    return np.log(x.where(x > 0))


def panel_lag(df: pd.DataFrame, col: str,
              id_col: str = "key", time_col: str = "year") -> pd.Series:
    """Within-panel lag (consecutive years only)."""
    grp = df.groupby(id_col, sort=False)[col].shift(1)
    prev_t = df.groupby(id_col, sort=False)[time_col].shift(1)
    consec = (df[time_col] - prev_t) == 1
    return grp.where(consec)


def panel_lead(df: pd.DataFrame, col: str,
               id_col: str = "key", time_col: str = "year") -> pd.Series:
    """Within-panel lead (consecutive years only)."""
    grp = df.groupby(id_col, sort=False)[col].shift(-1)
    next_t = df.groupby(id_col, sort=False)[time_col].shift(-1)
    consec = (next_t - df[time_col]) == 1
    return grp.where(consec)


def panel_diff(df: pd.DataFrame, col: str,
               id_col: str = "key", time_col: str = "year") -> pd.Series:
    """First difference (within-panel, consecutive years only)."""
    return df[col] - panel_lag(df, col, id_col, time_col)


# ---------------------------------------------------------------------------
# Block 1 — Year dummies
# ---------------------------------------------------------------------------

def make_year_dummies(df: pd.DataFrame) -> tuple[pd.DataFrame, list[str]]:
    """
    Replicates: tabulate year, gen(yr)
    Stata names the dummies yr1, yr2, ... in chronological order of distinct years.
    """
    years = sorted(df["year"].dropna().unique().astype(int))
    generated = []
    for rank, yr in enumerate(years, start=1):
        col = f"yr{rank}"
        df[col] = (df["year"] == yr).astype(float)
        generated.append(col)
    return df, generated


# ---------------------------------------------------------------------------
# Block 2 — Nonlinear GMM: returns to R&D  (lines 803–814)
# ---------------------------------------------------------------------------
# Model:  E[ z_t * (f.d_q_t - B1 * z1_t ^ B2) ] = 0
# where   z_t = [d_q_t, l.d_q_t, l.z1_t]  (instruments)
# Weight: HAC Bartlett (Newey-West)

def _hac_bartlett(Z: np.ndarray, bandwidth: int | None = None) -> np.ndarray:
    """
    Newey-West HAC covariance matrix of moment conditions Z.
    Z shape: (T, k) — rows are time, cols are moment conditions.
    """
    T, k = Z.shape
    if bandwidth is None:
        bandwidth = int(np.floor(4 * (T / 100) ** (2 / 9)))  # Andrews rule

    S = Z.T @ Z / T
    for j in range(1, bandwidth + 1):
        w = 1.0 - j / (bandwidth + 1)
        Gamma_j = Z[j:].T @ Z[:-j] / T
        S = S + w * (Gamma_j + Gamma_j.T)
    return S


def _gmm_rnd_criterion(
    params: np.ndarray,
    f_d_q: np.ndarray,
    z1: np.ndarray,
    Z: np.ndarray,
    W: np.ndarray,
) -> float:
    """
    GMM criterion: (Z' g)' W (Z' g) where g = f.d_q - B1 * z1^B2.
    """
    B1, B2 = params
    if B1 <= 0:
        return 1e10
    g = f_d_q - B1 * np.abs(z1) ** B2
    Zg = Z.T @ g / len(g)
    return float(Zg @ W @ Zg)


def estimate_rnd_gmm(df: pd.DataFrame) -> dict:
    """
    Replicate AllData.do lines 803–814.

    Returns dict with keys: B1, B2, gmm_value, n_obs.
    """
    df = df.copy().sort_values(["key", "year"])

    # Intermediate variables (lines 805–812)
    df["q"] = df["r_sale"] / df["emp"].replace({0: np.nan})
    df["l_q"] = ln_pos(df["q"])
    df["d_q"] = panel_diff(df, "l_q")
    df["z1"] = df["r_xrd"] / df["q"].replace({0: np.nan})
    df["z2"] = df["r_xrd"] / df["emp"].replace({0: np.nan})
    df["average_z1"] = df.groupby("year")["z1"].transform("mean")
    df["average_z2"] = df.groupby("year")["z2"].transform("mean")

    # Build GMM sample
    df["f_d_q"] = panel_lead(df, "d_q")
    df["l_d_q"] = panel_lag(df, "d_q")
    df["l_z1"] = panel_lag(df, "z1")

    mask = (
        df["f_d_q"].notna()
        & df["z1"].notna()
        & df["d_q"].notna()
        & df["l_d_q"].notna()
        & df["l_z1"].notna()
    )
    sub = df[mask].copy()
    n = len(sub)

    f_d_q = sub["f_d_q"].values
    z1 = sub["z1"].values
    Z_mat = np.column_stack([
        sub["d_q"].values,
        sub["l_d_q"].values,
        sub["l_z1"].values,
    ])

    # Two-step GMM with HAC Bartlett weight matrix.
    # Bounds: B1 ∈ [1e-5, 0.5], B2 ∈ [1e-3, 2.0] — economic priors.
    # B1 is a scale on returns; B2 is curvature (Stata start: 0.027, 0.1).
    # Values outside these ranges are either economically implausible or
    # numerically unidentified (B1≈0 makes the moment conditions flat in B2).
    BOUNDS = [(1e-5, 0.5), (1e-3, 2.0)]

    def _minimise_bounded(crit_fn):
        best_val, best_x = np.inf, np.array([0.027, 0.1])
        for b1 in [0.01, 0.027, 0.05, 0.10, 0.20]:
            for b2 in [0.05, 0.1, 0.2, 0.5, 1.0]:
                r = minimize(crit_fn, [b1, b2], method="L-BFGS-B",
                             bounds=BOUNDS,
                             options={"maxiter": 10_000, "ftol": 1e-14, "gtol": 1e-10})
                if r.fun < best_val:
                    best_val, best_x = r.fun, r.x
        return best_x, best_val

    # Step 1: identity weight
    W0 = np.eye(Z_mat.shape[1])

    def crit0(p):
        return _gmm_rnd_criterion(p, f_d_q, z1, Z_mat, W0)

    (B1_0, B2_0), _ = _minimise_bounded(crit0)

    # Step 2: HAC Bartlett optimal weight using step-1 residuals
    g0 = f_d_q - B1_0 * np.abs(z1) ** B2_0
    ZG = Z_mat * g0.reshape(-1, 1)
    S = _hac_bartlett(ZG)
    try:
        W1 = np.linalg.inv(S)
    except np.linalg.LinAlgError:
        W1 = np.linalg.pinv(S)

    def crit1(p):
        return _gmm_rnd_criterion(p, f_d_q, z1, Z_mat, W1)

    (B1, B2), best_val = _minimise_bounded(crit1)
    print(f"  GMM R&D returns: B1 = {B1:.6f}, B2 = {B2:.6f}  (n={n:,})")
    return {"B1": B1, "B2": B2, "gmm_value": best_val, "n_obs": n}


# ---------------------------------------------------------------------------
# Block 3 helpers — Production function OLS / FE / ACF
# ---------------------------------------------------------------------------

def _ols_tfp(df: pd.DataFrame, y_col: str, x_cols: list[str],
             id_col: str = "key") -> tuple[pd.Series, dict]:
    """
    OLS production function.  Returns (tfp, coefs).
    TFP = y - sum(beta_j * x_j)  for x_j in x_cols only (excl. constant + controls).
    """
    mask = df[[y_col] + x_cols].notna().all(axis=1)
    y = df.loc[mask, y_col].values
    X = sm.add_constant(df.loc[mask, x_cols].values)
    try:
        res = sm.OLS(y, X).fit()
    except Exception as e:
        warnings.warn(f"OLS failed for {y_col}: {e}")
        return pd.Series(np.nan, index=df.index), {}

    # Coefficients for the structural inputs only (skip constant and any controls
    # that are not in the first two positions — logemp, logcap)
    coefs = dict(zip(x_cols, res.params[1:]))
    tfp = pd.Series(np.nan, index=df.index)
    # TFP = y - beta_l * l - beta_k * k  (match Stata: only structural inputs)
    structural = [c for c in x_cols if c not in ("t", "logvai", "logvadd", "logvship")]
    tfp_vals = df.loc[mask, y_col].values.copy()
    for c in structural:
        tfp_vals -= coefs[c] * df.loc[mask, c].values
    tfp[df.index[mask]] = tfp_vals
    return tfp, coefs


def _fe_tfp(df: pd.DataFrame, y_col: str, x_cols: list[str],
            id_col: str = "key", time_col: str = "year") -> tuple[pd.Series, dict]:
    """
    Within-firm FE production function.  Returns (tfp, coefs).
    Implemented via within-demean (equivalent to xtreg, fe).
    """
    mask = df[[y_col, id_col] + x_cols].notna().all(axis=1)
    sub = df[mask].copy()

    # Within-demean
    for col in [y_col] + x_cols:
        sub[f"_dm_{col}"] = sub[col] - sub.groupby(id_col)[col].transform("mean")

    ydm = sub[f"_dm_{y_col}"].values
    Xdm = sub[[f"_dm_{c}" for c in x_cols]].values

    try:
        res = sm.OLS(ydm, Xdm).fit()
    except Exception as e:
        warnings.warn(f"FE failed for {y_col}: {e}")
        return pd.Series(np.nan, index=df.index), {}

    coefs = dict(zip(x_cols, res.params))
    tfp = pd.Series(np.nan, index=df.index)
    structural = [c for c in x_cols if c not in ("t", "logvai", "logvadd", "logvship")]
    tfp_vals = df.loc[mask, y_col].values.copy()
    for c in structural:
        tfp_vals -= coefs[c] * df.loc[mask, c].values
    tfp[df.index[mask]] = tfp_vals
    return tfp, coefs


def _acf_tfp(df: pd.DataFrame, y_col: str, labour_col: str, capital_col: str,
             proxy_col: str, controls: list[str],
             id_col: str = "key", time_col: str = "year",
             n_bootstrap: int = 100, seed: int = 1) -> tuple[pd.Series, dict]:
    """
    ACF production function via ACFEstimator.
    Returns (tfp, coefs).  Matches opreg ... vce(bootstrap, seed(1) rep(100)).
    """
    est = ACFEstimator(
        output=y_col,
        free=labour_col,
        state=capital_col,
        proxy=proxy_col,
        id_var=id_col,
        time_var=time_col,
        controls=controls,
        n_bootstrap=n_bootstrap,
        seed=seed,
    )
    try:
        est.fit(df)
    except Exception as e:
        warnings.warn(f"ACF failed for {y_col}: {e}")
        return pd.Series(np.nan, index=df.index), {}
    return est.tfp_, est.coef_


def _add_derived(df: pd.DataFrame, prefix: str, y_col: str,
                 tfp: pd.Series) -> tuple[pd.DataFrame, list[str]]:
    """
    Given TFP series, add l_tfp, l_hat, d_tfp, d_hat columns with given prefix.
    Returns updated df and list of new column names.
    """
    l_tfp = f"l_tfp_{prefix}"
    l_hat = f"l_hat_{prefix}"
    d_tfp = f"d_tfp_{prefix}"
    d_hat = f"d_hat_{prefix}"

    df[l_tfp] = tfp
    df[l_hat] = df[y_col] - tfp
    df[d_tfp] = panel_diff(df, l_tfp)
    df[d_hat] = panel_diff(df, l_hat)
    return df, [l_tfp, l_hat, d_tfp, d_hat]


# ---------------------------------------------------------------------------
# Block 3 — All production function specifications
# ---------------------------------------------------------------------------

# Set via CLI --bootstrap N; default 0 for fast runs.
# Production run (matching Stata rep(100)) requires --bootstrap 100.
N_BOOTSTRAP: int = 0


def run_production_functions(df: pd.DataFrame) -> tuple[pd.DataFrame, list[dict]]:
    """
    Run all 7 groups of production function specs (lines 1160–1333).
    Returns (df_with_tfp_vars, list_of_coef_records).
    """
    coef_records = []
    generated = []

    # ── Group 1: Compustat VAA  (lines 1164–1184) ──────────────────────────
    print("  Group 1: Compustat VAA (logvaa)")
    tfp, c = _ols_tfp(df, "logvaa", ["logemp", "logcap", "t"])
    df, new = _add_derived(df, "vaa_1", "logvaa", tfp)
    generated += new
    coef_records.append({"spec": "vaa_ols", **c})

    tfp, c = _fe_tfp(df, "logvaa", ["logemp", "logcap", "t"])
    df, new = _add_derived(df, "vaa_2", "logvaa", tfp)
    generated += new
    coef_records.append({"spec": "vaa_fe", **c})

    tfp, c = _acf_tfp(df, "logvaa", "logemp", "logcap", "loginv", ["t"],
                      n_bootstrap=N_BOOTSTRAP, seed=1)
    df, new = _add_derived(df, "vaa_3", "logvaa", tfp)
    generated += new
    coef_records.append({"spec": "vaa_acf", **c})

    # ── Group 2: Compustat VA  (lines 1186–1206) ────────────────────────────
    print("  Group 2: Compustat VA (logva)")
    tfp, c = _ols_tfp(df, "logva", ["logemp", "logcap", "t"])
    df, new = _add_derived(df, "va_1", "logva", tfp)
    generated += new
    coef_records.append({"spec": "va_ols", **c})

    tfp, c = _fe_tfp(df, "logva", ["logemp", "logcap", "t"])
    df, new = _add_derived(df, "va_2", "logva", tfp)
    generated += new
    coef_records.append({"spec": "va_fe", **c})

    tfp, c = _acf_tfp(df, "logva", "logemp", "logcap", "loginv", ["t"],
                      n_bootstrap=N_BOOTSTRAP, seed=1)
    df, new = _add_derived(df, "va_3", "logva", tfp)
    generated += new
    coef_records.append({"spec": "va_acf", **c})

    # ── Group 3: With intermediate inputs  (lines 1209–1229) ────────────────
    print("  Group 3: VAA + intermediate inputs (logvai)")
    tfp, c = _ols_tfp(df, "logvaa", ["logemp", "logcap", "logvai", "t"])
    df, new = _add_derived(df, "va_i_1", "logvaa", tfp)
    generated += new
    coef_records.append({"spec": "va_i_ols", **c})

    tfp, c = _fe_tfp(df, "logvaa", ["logemp", "logcap", "logvai", "t"])
    df, new = _add_derived(df, "va_i_2", "logvaa", tfp)
    generated += new
    coef_records.append({"spec": "va_i_fe", **c})

    tfp, c = _acf_tfp(df, "logvaa", "logemp", "logcap", "loginv", ["logvai", "t"],
                      n_bootstrap=N_BOOTSTRAP, seed=1)
    df, new = _add_derived(df, "va_i_3", "logvaa", tfp)
    generated += new
    coef_records.append({"spec": "va_i_acf", **c})

    # ── Group 4: With demand deflator  (lines 1231–1251) ────────────────────
    print("  Group 4: VAA + demand deflator (logvadd)")
    tfp, c = _ols_tfp(df, "logvaa", ["logemp", "logcap", "logvadd", "t"])
    df, new = _add_derived(df, "vadd_1", "logvaa", tfp)
    generated += new
    coef_records.append({"spec": "vadd_ols", **c})

    tfp, c = _fe_tfp(df, "logvaa", ["logemp", "logcap", "logvadd", "t"])
    df, new = _add_derived(df, "vadd_2", "logvaa", tfp)
    generated += new
    coef_records.append({"spec": "vadd_fe", **c})

    tfp, c = _acf_tfp(df, "logvaa", "logemp", "logcap", "loginv", ["logvadd", "t"],
                      n_bootstrap=N_BOOTSTRAP, seed=1)
    df, new = _add_derived(df, "vadd_3", "logvaa", tfp)
    generated += new
    coef_records.append({"spec": "vadd_acf", **c})

    # ── Group 5: NBER deflator  (lines 1266–1286) ───────────────────────────
    print("  Group 5: NBER deflator (vanber, capnber, invnber)")
    tfp, c = _ols_tfp(df, "vanber", ["logemp", "capnber", "t"])
    df, new = _add_derived(df, "nber_1", "vanber", tfp)
    generated += new
    coef_records.append({"spec": "nber_ols", **c})

    tfp, c = _fe_tfp(df, "vanber", ["logemp", "capnber", "t"])
    df, new = _add_derived(df, "nber_2", "vanber", tfp)
    generated += new
    coef_records.append({"spec": "nber_fe", **c})

    tfp, c = _acf_tfp(df, "vanber", "logemp", "capnber", "invnber", ["t"],
                      n_bootstrap=N_BOOTSTRAP, seed=1)
    df, new = _add_derived(df, "nber_3", "vanber", tfp)
    generated += new
    coef_records.append({"spec": "nber_acf", **c})

    # ── Group 6: NBER + vadd  (lines 1288–1308) ─────────────────────────────
    print("  Group 6: NBER + vadd deflator")
    tfp, c = _ols_tfp(df, "vanber", ["logemp", "capnber", "logvadd", "t"])
    df, new = _add_derived(df, "nber_vadd_1", "vanber", tfp)
    generated += new
    coef_records.append({"spec": "nber_vadd_ols", **c})

    tfp, c = _fe_tfp(df, "vanber", ["logemp", "capnber", "logvadd", "t"])
    df, new = _add_derived(df, "nber_vadd_2", "vanber", tfp)
    generated += new
    coef_records.append({"spec": "nber_vadd_fe", **c})

    tfp, c = _acf_tfp(df, "vanber", "logemp", "capnber", "invnber", ["logvadd", "t"],
                      n_bootstrap=N_BOOTSTRAP, seed=1)
    df, new = _add_derived(df, "nber_vadd_3", "vanber", tfp)
    generated += new
    coef_records.append({"spec": "nber_vadd_acf", **c})

    # ── Group 7: NBER + vship  (lines 1310–1330) ────────────────────────────
    print("  Group 7: NBER + vship deflator")
    tfp, c = _ols_tfp(df, "vanber", ["logemp", "capnber", "logvship", "t"])
    df, new = _add_derived(df, "nber_vship_1", "vanber", tfp)
    generated += new
    coef_records.append({"spec": "nber_vship_ols", **c})

    tfp, c = _fe_tfp(df, "vanber", ["logemp", "capnber", "logvship", "t"])
    df, new = _add_derived(df, "nber_vship_2", "vanber", tfp)
    generated += new
    coef_records.append({"spec": "nber_vship_fe", **c})

    tfp, c = _acf_tfp(df, "vanber", "logemp", "capnber", "invnber", ["logvship", "t"],
                      n_bootstrap=N_BOOTSTRAP, seed=1)
    df, new = _add_derived(df, "nber_vship_3", "vanber", tfp)
    generated += new
    coef_records.append({"spec": "nber_vship_acf", **c})

    # ── Firm-level TFP means  (lines 1255–1262) ─────────────────────────────
    print("  Computing firm-level TFP means...")
    for spec in ("vaa_1", "vaa_2", "vaa_3"):
        l_col = f"l_tfp_{spec}"
        d_col = f"d_tfp_{spec}"
        if l_col in df.columns:
            df[f"mean_{l_col}"] = df.groupby("key")[l_col].transform("mean")
            generated.append(f"mean_{l_col}")
        if d_col in df.columns:
            df[f"mean_{d_col}"] = df.groupby("key")[d_col].transform("mean")
            generated.append(f"mean_{d_col}")

    # ── Stata-compatible aliases  ──────────────────────────────────────────
    # AllData.do reuses names like l_tfp_1, l_vaa_hat_1 across spec groups.
    # Python uses unambiguous names to avoid collisions. Add alias columns
    # matching the Stata names so Gate B coverage check passes.
    STATA_ALIASES = {
        # logvaa OLS/FE/ACF → Stata's l_tfp_1/2/3, l_vaa_hat_1/2/3, etc.
        "l_tfp_1":          "l_tfp_vaa_1",
        "l_tfp_2":          "l_tfp_vaa_2",
        "l_tfp_3":          "l_tfp_vaa_3",
        "d_tfp_1":          "d_tfp_vaa_1",
        "d_tfp_2":          "d_tfp_vaa_2",
        "d_tfp_3":          "d_tfp_vaa_3",
        "l_vaa_hat_1":      "l_hat_vaa_1",
        "l_vaa_hat_2":      "l_hat_vaa_2",
        "l_vaa_hat_3":      "l_hat_vaa_3",
        "d_vaa_hat_1":      "d_hat_vaa_1",
        "d_vaa_hat_2":      "d_hat_vaa_2",
        "d_vaa_hat_3":      "d_hat_vaa_3",
        # va_i spec
        "l_vaa_hat_va_i_1": "l_hat_va_i_1",
        "l_vaa_hat_va_i_2": "l_hat_va_i_2",
        "l_va_hat_va_i_3":  "l_hat_va_i_3",
        "d_vaa_hat_va_i_1": "d_hat_va_i_1",
        "d_vaa_hat_va_i_2": "d_hat_va_i_2",
        "d_va_hat_va_i_3":  "d_hat_va_i_3",
        # vadd spec
        "l_vaa_hat_vadd_1": "l_hat_vadd_1",
        "l_vaa_hat_vadd_2": "l_hat_vadd_2",
        "l_va_hat_vadd_3":  "l_hat_vadd_3",
        "d_vaa_hat_vadd_1": "d_hat_vadd_1",
        "d_vaa_hat_vadd_2": "d_hat_vadd_2",
        "d_va_hat_vadd_3":  "d_hat_vadd_3",
        # NBER spec
        "l_va_hat_nber_1":       "l_hat_nber_1",
        "l_va_hat_nber_2":       "l_hat_nber_2",
        "l_va_hat_nber_3":       "l_hat_nber_3",
        "d_va_hat_nber_1":       "d_hat_nber_1",
        "d_va_hat_nber_2":       "d_hat_nber_2",
        "d_va_hat_nber_3":       "d_hat_nber_3",
        # NBER + vadd
        "l_va_hat_nber_vadd_1":  "l_hat_nber_vadd_1",
        "l_va_hat_nber_vadd_2":  "l_hat_nber_vadd_2",
        "l_va_hat_nber_vadd_3":  "l_hat_nber_vadd_3",
        "d_va_hat_nber_vadd_1":  "d_hat_nber_vadd_1",
        "d_va_hat_nber_vadd_2":  "d_hat_nber_vadd_2",
        "d_va_hat_nber_vadd_3":  "d_hat_nber_vadd_3",
        # NBER + vship
        "l_va_hat_nber_vship_1": "l_hat_nber_vship_1",
        "l_va_hat_nber_vship_2": "l_hat_nber_vship_2",
        "l_va_hat_nber_vship_3": "l_hat_nber_vship_3",
        "d_va_hat_nber_vship_1": "d_hat_nber_vship_1",
        "d_va_hat_nber_vship_2": "d_hat_nber_vship_2",
        "d_va_hat_nber_vship_3": "d_hat_nber_vship_3",
    }
    n_aliased = 0
    for stata_name, py_name in STATA_ALIASES.items():
        if py_name in df.columns:
            df[stata_name] = df[py_name]
            generated.append(stata_name)
            n_aliased += 1
    print(f"  Added {n_aliased} Stata-compatible alias columns.")

    print(f"  Block 3 complete: {len(generated)} variables generated.")
    return df, coef_records


# ---------------------------------------------------------------------------
# Log variable construction
# ---------------------------------------------------------------------------

def construct_log_vars(df: pd.DataFrame) -> tuple[pd.DataFrame, list[str]]:
    """
    Construct the log production function inputs from stage3 columns.
    """
    generated = []

    # logemp: ln(emp)
    df["logemp"] = ln_pos(df["emp"])
    generated.append("logemp")

    # logcap: ln(ppegt_{t-1} / piinv_{t-1})  — AllData.do line 1162 replace
    ppegt_lag = panel_lag(df, "ppegt")
    piinv_lag = panel_lag(df, "piinv")
    df["logcap"] = ln_pos(ppegt_lag / piinv_lag.replace({0: np.nan}))
    generated.append("logcap")

    # loginv: ln(capx / piinv)  — investment proxy for ACF proxy variable
    df["loginv"] = ln_pos(df["capx"] / df["piinv"].replace({0: np.nan}))
    generated.append("loginv")

    # logvaa: ln(va_a)  — value added adjusted (oibdp + wagebill)
    df["logvaa"] = ln_pos(df["va_a"])
    generated.append("logvaa")

    # logva: ln(oibdp + xlr)  — value added actual payroll
    va_raw = pd.to_numeric(df["oibdp"], errors="coerce") + pd.to_numeric(df.get("xlr", np.nan), errors="coerce")
    df["logva"] = ln_pos(va_raw)
    generated.append("logva")

    # logvai: ln(r_gdp_materials)  — intermediate inputs, GDP deflated
    df["logvai"] = ln_pos(df.get("r_gdp_materials", pd.Series(np.nan, index=df.index)))
    generated.append("logvai")

    # logvadd: ln(vadd)  — demand-deflated value added (NBER)
    df["logvadd"] = ln_pos(df.get("vadd", pd.Series(np.nan, index=df.index)))
    generated.append("logvadd")

    # logvship: ln(vship)  — NBER shipments
    df["logvship"] = ln_pos(df.get("vship", pd.Series(np.nan, index=df.index)))
    generated.append("logvship")

    # vanber: ln(r_nber_va_a)  — log NBER real value added (adjusted)
    df["vanber"] = ln_pos(df.get("r_nber_va_a", pd.Series(np.nan, index=df.index)))
    generated.append("vanber")

    # capnber: ln(r_nberinv_ppegt)  — log NBER real capital
    df["capnber"] = ln_pos(df.get("r_nberinv_ppegt", pd.Series(np.nan, index=df.index)))
    generated.append("capnber")

    # invnber: ln(r_nberinv_capx)  — log NBER real capex (investment proxy)
    df["invnber"] = ln_pos(df.get("r_nberinv_capx", pd.Series(np.nan, index=df.index)))
    generated.append("invnber")

    return df, generated


# ---------------------------------------------------------------------------
# GMM R&D variables to keep in output dataset
# ---------------------------------------------------------------------------

def add_gmm_vars(df: pd.DataFrame) -> tuple[pd.DataFrame, list[str]]:
    """Add q, l_q, d_q, z1, z2, average_z1, average_z2 to df."""
    df = df.sort_values(["key", "year"])
    df["q"] = pd.to_numeric(df["r_sale"], errors="coerce") / pd.to_numeric(df["emp"], errors="coerce").replace({0: np.nan})
    df["l_q"] = ln_pos(df["q"])
    df["d_q"] = panel_diff(df, "l_q")
    df["z1"] = pd.to_numeric(df["r_xrd"], errors="coerce") / df["q"].replace({0: np.nan})
    df["z2"] = pd.to_numeric(df["r_xrd"], errors="coerce") / pd.to_numeric(df["emp"], errors="coerce").replace({0: np.nan})
    df["average_z1"] = df.groupby("year")["z1"].transform("mean")
    df["average_z2"] = df.groupby("year")["z2"].transform("mean")
    new_cols = ["q", "l_q", "d_q", "z1", "z2", "average_z1", "average_z2"]
    return df, new_cols


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

STAGE3_COLS_NEEDED = [
    # Panel identifiers
    "key", "year", "gvkey", "sic", "naics", "t", "firmid", "exit",
    # Log var construction
    "ppegt", "piinv", "capx", "emp", "va_a", "oibdp", "xlr",
    "r_gdp_materials", "vadd", "vship",
    "r_nber_va_a", "r_nberinv_ppegt", "r_nberinv_capx",
    # GMM Block 2
    "r_sale", "r_xrd",
    # Carry-forward for downstream regressions
    "r_gdp_cf", "r_gdp_dd1", "r_gdp_dltt", "r_gdp_lt", "r_gdp_at",
    "r_inv_ppent", "r_gdp_ppent",
]


def main() -> None:
    conn = sqlite3.connect(DB_PATH)

    # Verify which columns are actually present in stage3
    available = {r[1] for r in conn.execute(f"PRAGMA table_info({IN_TABLE})").fetchall()}
    cols_to_load = [c for c in STAGE3_COLS_NEEDED if c in available]
    missing_stage3 = [c for c in STAGE3_COLS_NEEDED if c not in available]
    if missing_stage3:
        warnings.warn(f"Stage3 missing columns (will be NaN): {missing_stage3}")

    print(f"Loading {IN_TABLE} ({len(cols_to_load)} selected columns)...")
    df = pd.read_sql_query(
        f"SELECT {', '.join(cols_to_load)} FROM {IN_TABLE}", conn
    )
    n0 = len(df)
    print(f"  {n0:,} rows, {len(df.columns)} columns")

    df = df.sort_values(["key", "year"], kind="mergesort").reset_index(drop=True)

    # ── Block 1: year dummies ─────────────────────────────────────────────
    print("\n[Block 1] Year dummies")
    df, yr_cols = make_year_dummies(df)
    print(f"  Generated {len(yr_cols)} dummies: {yr_cols[0]} … {yr_cols[-1]}")

    # ── Log variables ────────────────────────────────────────────────────
    print("\n[Log vars] Constructing production function inputs")
    df, log_cols = construct_log_vars(df)
    for col in log_cols:
        n_valid = df[col].notna().sum()
        print(f"  {col:>14}: {n_valid:>7,} non-null")

    # ── Block 2: GMM R&D returns ─────────────────────────────────────────
    print("\n[Block 2] Nonlinear GMM — returns to R&D")
    df, gmm_var_cols = add_gmm_vars(df)
    gmm_result = estimate_rnd_gmm(df)

    # Write GMM scalars to metadata table
    gmm_df = pd.DataFrame([gmm_result])
    gmm_df.to_sql(GMM_TABLE, conn, if_exists="replace", index=False)
    print(f"  GMM scalars written to {GMM_TABLE!r}")

    # ── Block 3: Production function TFP ─────────────────────────────────
    print("\n[Block 3] Production function estimates")
    df, coef_records = run_production_functions(df)

    # Write coefficient records
    coef_df = pd.DataFrame(coef_records)
    coef_df.to_sql(COEF_TABLE, conn, if_exists="replace", index=False)
    print(f"  Coefficients written to {COEF_TABLE!r} ({len(coef_df)} specs)")

    # ── Write stage4 output ───────────────────────────────────────────────
    print(f"\nWriting {OUT_TABLE}...")
    # Chunk write to respect SQLite SQLITE_MAX_VARIABLE_NUMBER
    n_cols = len(df.columns)
    chunk = max(1, min(500, 999 // n_cols))
    df.to_sql(OUT_TABLE, conn, if_exists="replace", index=False, chunksize=chunk)
    print(f"  {len(df):,} rows, {n_cols} columns written to {OUT_TABLE!r}")

    conn.close()
    print("\nStage 4 complete.")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Stage 4: year dummies, GMM, TFP")
    parser.add_argument(
        "--bootstrap", type=int, default=0,
        help="ACF bootstrap replications (0 = point estimates only; "
             "set 100 to match Stata rep(100))",
    )
    args = parser.parse_args()

    # Inject bootstrap setting into module-level constant used by run_production_functions
    import build_alldata_transform_stage4 as _self
    _self.N_BOOTSTRAP = args.bootstrap

    main()
