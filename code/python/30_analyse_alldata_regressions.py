#!/usr/bin/env python3
"""
analyse_alldata_regressions.py
==============================
Python replication of AllData.do lines 816-1050.

Covers:
  Table 9  — Baseline COMPUSTAT regressions across eight deflator/PPE
             configurations (GDP primary, GDP alt, VA, VA+ipr, GO, GO+ipr,
             NBER, NBER+ipr).  Each configuration produces 6 models (A-F):
               A/D: dep = R&D growth (xrd_dep)
               B/E: dep = R&D-to-sales intensity (z_xrd_sale / z_xrd_va)
               C/F: dep = R&D-to-capex intensity (z_xrd_capx)
             A/B/C use firm sales as the output measure; D/E/F use value-added.

  Table 10 — Asymmetric growth regressions.  Firm sales and value-added
             growth are split into up (d_h_*) and down (d_l_*) components
             to test for asymmetric cyclicality.

  Endogeneity FE checks (lines 962-1050) — Baseline specs with an additional
             industry-level output control (d_va_ind, d_go, d_vadd, d_vship)
             to address endogeneity of firm-level output.

IV regressions (xtivreg2, AllData.do lines 1052-1159) are not implemented
here; they require a separate script using linearmodels.iv.IV2SLS / IVGMM.

Estimation equivalence
----------------------
  Stata:  xtreg dep exog i.year, fe vce(cluster sic)
  Python: PanelOLS(entity_effects=True, time_effects=True)
          .fit(cov_type="clustered", clusters=sic_series)

The unqualified Stata variables used in Table 10 map to:
  d_xrd  -> d_gdp_xrd (verified identical in processed_alldata_stage3)
  d_sale -> d_gdp_sale (verified identical)
  d_va   -> d_gdp_va   (verified identical)
  r_cf   -> r_gdp_cf   (GDP-deflated financial controls)
  r_dd1  -> r_gdp_dd1  (and similarly for r_dltt, r_lt, r_at, r_ppent)

Output
------
  results/alldata_table9_results.xlsx
  results/alldata_table10_results.xlsx
  results/alldata_endogeneity_results.xlsx
  results/alldata_regressions_summary.md
"""

from __future__ import annotations

import sqlite3
import warnings
from pathlib import Path
from typing import NamedTuple

import numpy as np
import pandas as pd
from linearmodels.panel import PanelOLS

warnings.filterwarnings("ignore", category=FutureWarning)
warnings.filterwarnings("ignore", category=pd.errors.PerformanceWarning)
warnings.filterwarnings("ignore", "invalid value encountered in sqrt")

ROOT = Path(__file__).resolve().parents[2]
DB_PATH = ROOT / "data" / "cyclicality.db"
RESULTS_DIR = ROOT / "results"
RESULTS_DIR.mkdir(exist_ok=True)


# ---------------------------------------------------------------------------
# Data loading
# ---------------------------------------------------------------------------

def load_data() -> pd.DataFrame:
    con = sqlite3.connect(DB_PATH)
    df = pd.read_sql("SELECT * FROM processed_alldata_stage3", con)
    con.close()
    df["year"] = pd.to_numeric(df["year"], errors="coerce").astype("Int64")
    df["sic"] = pd.to_numeric(df["sic"], errors="coerce")
    df = df.sort_values(["key", "year"]).reset_index(drop=True)
    return df


# ---------------------------------------------------------------------------
# Panel utility helpers
# ---------------------------------------------------------------------------

def panel_lag(df: pd.DataFrame, col: str, n: int = 1) -> pd.Series:
    """Lag `col` by `n` periods within each panel unit.

    Returns NaN when the gap to the prior observation is not exactly n years
    (no bridging over missing periods, mirroring Stata's l. operator with
    xtset key year, yearly).
    """
    grp = df.groupby("key", dropna=False, sort=False)
    lagged = grp[col].shift(n)
    prev_year = pd.to_numeric(grp["year"].shift(n), errors="coerce")
    curr_year = pd.to_numeric(df["year"], errors="coerce")
    return lagged.where((curr_year - prev_year) == n)


def build_lags(df: pd.DataFrame) -> pd.DataFrame:
    """Add all lag variables needed for the regressions.

    For each deflator prefix (gdp, va, go, nber) we lag the six financial
    controls by 1 and 2 periods.  We also lag the intensity ratios and the
    asymmetric output growth variables.
    """
    df = df.copy()

    prefixes = ["gdp", "va", "go", "nber"]
    ctrl_base = ["cf", "dd1", "dltt", "lt", "at", "ppent"]

    # Financial controls for each deflator
    for pref in prefixes:
        for c in ctrl_base:
            col = f"r_{pref}_{c}"
            if col in df.columns:
                df[f"l_{col}"] = panel_lag(df, col, 1)
                df[f"l2_{col}"] = panel_lag(df, col, 2)

    # Investment-deflated PPE (primary GDP spec uses r_inv_ppent)
    for col in ["r_inv_ppent", "r_inv_capx"]:
        if col in df.columns:
            df[f"l_{col}"] = panel_lag(df, col, 1)
            df[f"l2_{col}"] = panel_lag(df, col, 2)

    # Intensity ratios (lagged dep variables in models B, C, E, F)
    for col in ["z_xrd_sale", "z_xrd_va", "z_xrd_capx"]:
        if col in df.columns:
            df[f"l_{col}"] = panel_lag(df, col, 1)
            df[f"l2_{col}"] = panel_lag(df, col, 2)

    # Asymmetric output growth lags (Table 10)
    for col in ["d_h_sale", "d_l_sale", "d_h_va", "d_l_va"]:
        if col in df.columns:
            df[f"l_{col}"] = panel_lag(df, col, 1)

    # Output growth lags (l.d_{prefix}_sale and l.d_{prefix}_va)
    for pref in prefixes:
        for outcome in ["sale", "va"]:
            col = f"d_{pref}_{outcome}"
            if col in df.columns:
                df[f"l_{col}"] = panel_lag(df, col, 1)

    return df


# ---------------------------------------------------------------------------
# Regression wrapper
# ---------------------------------------------------------------------------

def _fe_ols_sic(y: pd.Series, X: pd.DataFrame,
                df: pd.DataFrame, label: str) -> dict:
    """Two-way FE OLS with SIC-cluster-robust SEs.

    Stata: xtreg dep exog i.year, fe vce(cluster sic)
    Python: PanelOLS(entity_effects=True, time_effects=True)
            .fit(cov_type="clustered", clusters=sic_series)
    """
    mask = y.notna() & X.notna().all(axis=1) & df["sic"].notna()
    n_obs = int(mask.sum())
    if n_obs < 20:
        return {"label": label, "n": 0, "params": {}, "se": {},
                "pvalues": {}, "estimator": "FE OLS (SIC cluster)"}

    X_f = X[mask].copy()
    # Drop zero-variance columns after complete-case filter
    varying = X_f.columns[X_f.nunique() > 1]
    X_f = X_f[varying]

    mi = pd.MultiIndex.from_arrays(
        [df.loc[mask, "key"].astype(str).values,
         df.loc[mask, "year"].values],
        names=["key", "year"],
    )
    dep = pd.DataFrame({"dep": y[mask].values}, index=mi)
    exog = pd.DataFrame(X_f.values, index=mi, columns=X_f.columns)
    sic_clusters = pd.Series(
        df.loc[mask, "sic"].values, index=mi, name="sic"
    )

    try:
        mod = PanelOLS(dep, exog, entity_effects=True, time_effects=True)
        res = mod.fit(cov_type="clustered", clusters=sic_clusters)
    except Exception as exc:
        return {"label": label, "n": n_obs, "params": {}, "se": {},
                "pvalues": {}, "estimator": "FE OLS (SIC cluster)",
                "error": str(exc)}

    return {
        "label":     label,
        "n":         int(res.nobs),
        "params":    res.params.to_dict(),
        "se":        res.std_errors.to_dict(),
        "pvalues":   res.pvalues.to_dict(),
        "estimator": "FE OLS (SIC cluster)",
    }


# ---------------------------------------------------------------------------
# Control-set builders
# ---------------------------------------------------------------------------

def _ctrl(df: pd.DataFrame, pref: str, ppent_col: str) -> pd.DataFrame:
    """Return emp + deflated financial controls + lags L1/L2.

    Corresponds to Stata:
      emp r_{pref}_{cf,dd1,dltt,lt,at,ppent_col}
          l.(r_{pref}_{cf,dd1,dltt,lt,at,ppent_col})
          l2.(r_{pref}_{cf,dd1,dltt,lt,at,ppent_col})
    where ppent_col may differ from r_{pref}_ppent (e.g. r_inv_ppent).
    """
    base_ctrl = [f"r_{pref}_{c}" for c in ["cf", "dd1", "dltt", "lt", "at"]]
    base_ctrl.append(ppent_col)
    l1 = [f"l_{c}" for c in base_ctrl]
    l2 = [f"l2_{c}" for c in base_ctrl]
    cols = ["emp"] + base_ctrl + l1 + l2
    return df[[c for c in cols if c in df.columns]]


# ---------------------------------------------------------------------------
# Table 9 — Baseline regressions
# ---------------------------------------------------------------------------

class Table9Config(NamedTuple):
    label:        str   # short name for output
    xrd_dep:      str   # R&D growth variable (dep for models A/D)
    pref:         str   # deflator prefix: gdp | va | go | nber
    ppent_col:    str   # PPE column (r_inv_ppent or r_{pref}_ppent)
    sale_ub:      float  # upper bound on sale output for filter
    va_ub:        float  # upper bound on VA output for filter
    xrd_sale_ub:  float  # upper bound on z_xrd_sale for filter
    xrd_va_ub:    float  # upper bound on z_xrd_va for filter


TABLE9_CONFIGS: list[Table9Config] = [
    # Primary — GDP deflator, investment-deflated PPE, ipr-deflated R&D
    Table9Config("gdp_primary",  "d_ipr_xrd", "gdp", "r_inv_ppent", 3, 1, 2, 1),
    # Alternative — GDP deflator, GDP-deflated PPE
    Table9Config("gdp_alt",      "d_gdp_xrd", "gdp", "r_gdp_ppent", 3, 1, 2, 1),
    # VA deflator
    Table9Config("va",           "d_va_xrd",  "va",  "r_va_ppent",  3, 1, 2, 1),
    # VA deflator, ipr-deflated R&D
    Table9Config("va_ipr",       "d_ipr_xrd", "va",  "r_va_ppent",  3, 1, 2, 1),
    # Gross output deflator
    Table9Config("go",           "d_go_xrd",  "go",  "r_go_ppent",  3, 1, 2, 1),
    # Gross output deflator, ipr-deflated R&D
    Table9Config("go_ipr",       "d_ipr_xrd", "go",  "r_go_ppent",  3, 1, 2, 1),
    # NBER deflator
    Table9Config("nber",         "d_nber_xrd","nber","r_nber_ppent", 3, 1, 2, 1),
    # NBER deflator, ipr-deflated R&D
    Table9Config("nber_ipr",     "d_ipr_xrd", "nber","r_nber_ppent", 3, 1, 2, 1),
]


def run_table9_config(df: pd.DataFrame, cfg: Table9Config) -> dict[str, dict]:
    """Run the 6-model block (A-F) for one Table 9 configuration."""
    results: dict[str, dict] = {}
    pref = cfg.pref
    ctrl = _ctrl(df, pref, cfg.ppent_col)

    sale_col = f"d_{pref}_sale"
    va_col   = f"d_{pref}_va"
    l_sale   = f"l_{sale_col}"
    l_va     = f"l_{va_col}"

    # ── Sale-based sample filter ──────────────────────────────────────────
    filt_sale = (
        (df["z_xrd_sale"] < cfg.xrd_sale_ub)
        & (df[cfg.xrd_dep] < 2) & (df[cfg.xrd_dep] > -2)
        & (df[sale_col] < cfg.sale_ub)   & (df[sale_col] > -cfg.sale_ub)
    )
    # ── VA-based sample filter ────────────────────────────────────────────
    filt_va = (
        (df["z_xrd_va"] < cfg.xrd_va_ub)
        & (df[cfg.xrd_dep] < 2) & (df[cfg.xrd_dep] > -2)
        & (df[va_col] < cfg.va_ub) & (df[va_col] > -cfg.va_ub)
    )

    df_s = df[filt_sale].copy()
    df_v = df[filt_va].copy()

    # Build control matrices for filtered sub-frames
    ctrl_s = _ctrl(df_s, pref, cfg.ppent_col)
    ctrl_v = _ctrl(df_v, pref, cfg.ppent_col)

    # ── Model A: dep=xrd_dep, output=sale ────────────────────────────────
    X = pd.concat([df_s[[sale_col, l_sale]], ctrl_s], axis=1)
    results[f"{cfg.label}_A"] = _fe_ols_sic(
        df_s[cfg.xrd_dep], X, df_s, f"{cfg.label}_A")

    # ── Model B: dep=z_xrd_sale, output=sale ─────────────────────────────
    X = pd.concat([df_s[["l_z_xrd_sale", "l2_z_xrd_sale", sale_col, l_sale]],
                   ctrl_s], axis=1)
    results[f"{cfg.label}_B"] = _fe_ols_sic(
        df_s["z_xrd_sale"], X, df_s, f"{cfg.label}_B")

    # ── Model C: dep=z_xrd_capx, output=sale ─────────────────────────────
    X = pd.concat([df_s[["l_z_xrd_capx", "l2_z_xrd_capx", sale_col, l_sale]],
                   ctrl_s], axis=1)
    results[f"{cfg.label}_C"] = _fe_ols_sic(
        df_s["z_xrd_capx"], X, df_s, f"{cfg.label}_C")

    # ── Model D: dep=xrd_dep, output=va ──────────────────────────────────
    X = pd.concat([df_v[[va_col, l_va]], ctrl_v], axis=1)
    results[f"{cfg.label}_D"] = _fe_ols_sic(
        df_v[cfg.xrd_dep], X, df_v, f"{cfg.label}_D")

    # ── Model E: dep=z_xrd_va, output=va ─────────────────────────────────
    X = pd.concat([df_v[["l_z_xrd_va", "l2_z_xrd_va", va_col, l_va]],
                   ctrl_v], axis=1)
    results[f"{cfg.label}_E"] = _fe_ols_sic(
        df_v["z_xrd_va"], X, df_v, f"{cfg.label}_E")

    # ── Model F: dep=z_xrd_capx, output=va ───────────────────────────────
    X = pd.concat([df_v[["l_z_xrd_capx", "l2_z_xrd_capx", va_col, l_va]],
                   ctrl_v], axis=1)
    results[f"{cfg.label}_F"] = _fe_ols_sic(
        df_v["z_xrd_capx"], X, df_v, f"{cfg.label}_F")

    return results


def run_table9(df: pd.DataFrame) -> dict[str, dict]:
    """Run all Table 9 configurations."""
    all_results: dict[str, dict] = {}
    for cfg in TABLE9_CONFIGS:
        all_results.update(run_table9_config(df, cfg))
        print(f"  Table 9 [{cfg.label}]: done")
    return all_results


# ---------------------------------------------------------------------------
# Table 10 — Asymmetric growth regressions (AllData.do lines 945–960)
# ---------------------------------------------------------------------------

def run_table10(df: pd.DataFrame) -> dict[str, dict]:
    """Asymmetric up/down output-growth regressions.

    Stata uses unqualified r_cf etc., which are identical to r_gdp_cf etc.
    (verified: d_xrd == d_gdp_xrd, d_sale == d_gdp_sale in stage3).
    """
    results: dict[str, dict] = {}
    # GDP-deflated controls (Stata r_cf = r_gdp_cf etc.)
    ctrl_cols_base = [f"r_gdp_{c}" for c in ["cf", "dd1", "dltt", "lt", "at", "ppent"]]
    l1_cols  = [f"l_{c}" for c in ctrl_cols_base]
    l2_cols  = [f"l2_{c}" for c in ctrl_cols_base]
    ctrl_all = ["emp"] + ctrl_cols_base + l1_cols + l2_cols

    # ── Sale-based filter (z_xrd_sale<2, d_xrd in (-2,2), d_sale in (-3,3)) ──
    filt_sale = (
        (df["z_xrd_sale"] < 2)
        & (df["d_xrd"].abs() < 2)        # d_xrd == d_gdp_xrd
        & (df["d_sale"].abs() < 3)        # d_sale == d_gdp_sale
    )
    # ── VA-based filter (z_xrd_va<1, d_xrd in (-2,2), d_va in (-1,1)) ──────
    filt_va = (
        (df["z_xrd_va"] < 1)
        & (df["d_xrd"].abs() < 2)
        & (df["d_va"].abs() < 1)          # d_va == d_gdp_va
    )

    df_s = df[filt_sale].copy()
    df_v = df[filt_va].copy()

    def _ctrl_t10(sub_df: pd.DataFrame) -> pd.DataFrame:
        cols = [c for c in ctrl_all if c in sub_df.columns]
        return sub_df[cols]

    # ── Models A-C: sale-based output ────────────────────────────────────
    asym_sale = ["d_h_sale", "d_l_sale", "l_d_h_sale", "l_d_l_sale"]

    # A: dep=d_xrd (=d_gdp_xrd), output=d_h/l_sale
    X = pd.concat([df_s[asym_sale], _ctrl_t10(df_s)], axis=1)
    results["t10_A"] = _fe_ols_sic(df_s["d_xrd"], X, df_s, "t10_A")

    # B: dep=z_xrd_sale, output=d_h/l_sale, + lagged dep
    X = pd.concat([df_s[["l_z_xrd_sale", "l2_z_xrd_sale"] + asym_sale],
                   _ctrl_t10(df_s)], axis=1)
    results["t10_B"] = _fe_ols_sic(df_s["z_xrd_sale"], X, df_s, "t10_B")

    # C: dep=z_xrd_capx, output=d_h/l_sale, + lagged dep
    X = pd.concat([df_s[["l_z_xrd_capx", "l2_z_xrd_capx"] + asym_sale],
                   _ctrl_t10(df_s)], axis=1)
    results["t10_C"] = _fe_ols_sic(df_s["z_xrd_capx"], X, df_s, "t10_C")

    # ── Models D-F: VA-based output ──────────────────────────────────────
    asym_va = ["d_h_va", "d_l_va", "l_d_h_va", "l_d_l_va"]

    # D: dep=d_xrd, output=d_h/l_va
    X = pd.concat([df_v[asym_va], _ctrl_t10(df_v)], axis=1)
    results["t10_D"] = _fe_ols_sic(df_v["d_xrd"], X, df_v, "t10_D")

    # E: dep=z_xrd_va, output=d_h/l_va, + lagged dep
    X = pd.concat([df_v[["l_z_xrd_va", "l2_z_xrd_va"] + asym_va],
                   _ctrl_t10(df_v)], axis=1)
    results["t10_E"] = _fe_ols_sic(df_v["z_xrd_va"], X, df_v, "t10_E")

    # F: dep=z_xrd_capx, output=d_h/l_va, + lagged dep
    X = pd.concat([df_v[["l_z_xrd_capx", "l2_z_xrd_capx"] + asym_va],
                   _ctrl_t10(df_v)], axis=1)
    results["t10_F"] = _fe_ols_sic(df_v["z_xrd_capx"], X, df_v, "t10_F")

    print("  Table 10: done")
    return results


# ---------------------------------------------------------------------------
# Endogeneity FE checks (AllData.do lines 962–1050)
# ---------------------------------------------------------------------------
#
# Adds one industry-level output control (d_va_ind, d_go, d_vadd, d_vship)
# to each of the four primary deflator specs (GDP, VA, GO, NBER).
# Four models per spec: sale+inst, va+inst, sale+go, va+go.
# Two specs per deflator: with native R&D deflator and with ipr deflator.

class EndoConfig(NamedTuple):
    label:     str
    xrd_dep:   str
    pref:      str
    ppent_col: str


ENDO_CONFIGS: list[EndoConfig] = [
    EndoConfig("endo_gdp",      "d_gdp_xrd", "gdp",  "r_gdp_ppent"),
    EndoConfig("endo_gdp_ipr",  "d_ipr_xrd", "gdp",  "r_gdp_ppent"),
    EndoConfig("endo_va",       "d_va_xrd",  "va",   "r_va_ppent"),
    EndoConfig("endo_va_ipr",   "d_ipr_xrd", "va",   "r_va_ppent"),
    EndoConfig("endo_go",       "d_go_xrd",  "go",   "r_go_ppent"),
    EndoConfig("endo_go_ipr",   "d_ipr_xrd", "go",   "r_go_ppent"),
    EndoConfig("endo_nber",     "d_nber_xrd","nber",  "r_nber_ppent"),
    EndoConfig("endo_nber_ipr", "d_ipr_xrd", "nber",  "r_nber_ppent"),
]

# Industry-level instruments map: (industry_var, go_var) pairs
# Stata uses: d_va_ind and d_go as the two industry-level controls
ENDO_INSTRUMENTS = ["d_va_ind", "d_go", "d_vadd", "d_vship"]


def run_endogeneity(df: pd.DataFrame) -> dict[str, dict]:
    """FE endogeneity checks: baseline + industry-level output control."""
    results: dict[str, dict] = {}

    for cfg in ENDO_CONFIGS:
        pref = cfg.pref
        sale_col = f"d_{pref}_sale"
        va_col   = f"d_{pref}_va"
        l_sale   = f"l_{sale_col}"
        l_va     = f"l_{va_col}"

        filt_sale = (
            (df["z_xrd_sale"] < 2)
            & (df[cfg.xrd_dep] < 2) & (df[cfg.xrd_dep] > -2)
            & (df[sale_col] < 3) & (df[sale_col] > -3)
        )
        filt_va = (
            (df["z_xrd_va"] < 1)
            & (df[cfg.xrd_dep] < 2) & (df[cfg.xrd_dep] > -2)
            & (df[va_col] < 1) & (df[va_col] > -1)
        )

        df_s = df[filt_sale].copy()
        df_v = df[filt_va].copy()

        ctrl_s = _ctrl(df_s, pref, cfg.ppent_col)
        ctrl_v = _ctrl(df_v, pref, cfg.ppent_col)

        for inst in ENDO_INSTRUMENTS:
            if inst not in df.columns:
                continue

            # Model A: sale output + instrument
            if inst in df_s.columns:
                X = pd.concat(
                    [df_s[[sale_col, l_sale, inst]], ctrl_s], axis=1
                )
                lbl = f"{cfg.label}_{inst}_sale"
                results[lbl] = _fe_ols_sic(
                    df_s[cfg.xrd_dep], X, df_s, lbl)

            # Model B: va output + instrument
            if inst in df_v.columns:
                X = pd.concat(
                    [df_v[[va_col, l_va, inst]], ctrl_v], axis=1
                )
                lbl = f"{cfg.label}_{inst}_va"
                results[lbl] = _fe_ols_sic(
                    df_v[cfg.xrd_dep], X, df_v, lbl)

        print(f"  Endogeneity [{cfg.label}]: done")

    return results


# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------

def results_to_df(results: dict[str, dict]) -> pd.DataFrame:
    """Convert result dicts to a tidy DataFrame for output."""
    rows = []
    for label, r in results.items():
        if not r.get("params"):
            rows.append({"label": label, "n": r.get("n", 0),
                         "variable": "", "coef": np.nan,
                         "se": np.nan, "pvalue": np.nan})
            continue
        for var, coef in r["params"].items():
            rows.append({
                "label":    label,
                "n":        r["n"],
                "variable": var,
                "coef":     coef,
                "se":       r["se"].get(var, np.nan),
                "pvalue":   r["pvalues"].get(var, np.nan),
            })
    return pd.DataFrame(rows)


def write_xlsx(results: dict[str, dict], path: Path, sheet_label: str) -> None:
    df_out = results_to_df(results)
    with pd.ExcelWriter(path, engine="openpyxl") as writer:
        df_out.to_excel(writer, sheet_name=sheet_label, index=False)
    print(f"  Wrote {path.name}")


def write_summary_md(
    t9: dict[str, dict],
    t10: dict[str, dict],
    endo: dict[str, dict],
    path: Path,
) -> None:
    """Write a markdown summary of key cyclicality coefficients."""
    lines = ["# AllData Regression Results Summary\n",
             "Replication of AllData.do lines 816–1050.\n",
             "Estimator: Two-way FE OLS, SIC-cluster-robust SEs.\n"]

    def _coef_line(res: dict, key: str) -> str:
        if not res.get("params"):
            return f"  {key}: n/a"
        coef = res["params"].get(key, np.nan)
        se   = res["se"].get(key, np.nan)
        pval = res["pvalues"].get(key, np.nan)
        stars = ("***" if pval < 0.01 else "**" if pval < 0.05
                 else "*" if pval < 0.10 else "")
        return f"  {key}: {coef:.4f}{stars} ({se:.4f}), n={res['n']}"

    lines.append("\n## Table 9 — Baseline (primary GDP spec, models A-F)\n")
    for model in ["A", "B", "C", "D", "E", "F"]:
        key = f"gdp_primary_{model}"
        if key in t9:
            out_col = "d_gdp_sale" if model in ("A","B","C") else "d_gdp_va"
            lines.append(f"  Model {model}: " + _coef_line(t9[key], out_col))
    lines.append("")

    lines.append("\n## Table 10 — Asymmetric growth (models A-F)\n")
    for model, out_col in [("A","d_h_sale"), ("B","d_h_sale"), ("C","d_h_sale"),
                           ("D","d_h_va"),   ("E","d_h_va"),   ("F","d_h_va")]:
        key = f"t10_{model}"
        if key in t10:
            lines.append(f"  Model {model}: " + _coef_line(t10[key], out_col))
    lines.append("")

    lines.append("\n## Endogeneity checks — GDP spec with d_va_ind\n")
    for suffix in ["_d_va_ind_sale", "_d_va_ind_va"]:
        key = f"endo_gdp{suffix}"
        if key in endo:
            out_col = "d_gdp_sale" if "sale" in suffix else "d_gdp_va"
            lines.append(f"  {key}: " + _coef_line(endo[key], out_col))
    lines.append("")

    path.write_text("\n".join(lines))
    print(f"  Wrote {path.name}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    print("Loading data …")
    df = load_data()
    print(f"  {len(df):,} rows loaded from processed_alldata_stage3")

    print("Building lag variables …")
    df = build_lags(df)

    print("\nRunning Table 9 regressions …")
    t9 = run_table9(df)

    print("\nRunning Table 10 regressions …")
    t10 = run_table10(df)

    print("\nRunning endogeneity FE checks …")
    endo = run_endogeneity(df)

    print("\nWriting output files …")
    write_xlsx(t9,   RESULTS_DIR / "alldata_table9_results.xlsx",   "Table9")
    write_xlsx(t10,  RESULTS_DIR / "alldata_table10_results.xlsx",  "Table10")
    write_xlsx(endo, RESULTS_DIR / "alldata_endogeneity_results.xlsx", "Endogeneity")
    write_summary_md(t9, t10, endo, RESULTS_DIR / "alldata_regressions_summary.md")

    print("\nDone.")


if __name__ == "__main__":
    main()
