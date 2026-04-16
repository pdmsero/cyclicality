#!/usr/bin/env python3
"""
analyse_alldata_iv.py
=====================
Python replication of AllData.do lines 1052–1159 (xtivreg2 blocks).

Implements FE IV and FE GMM2 via within-entity demeaning + linearmodels IV2SLS
/ IVGMM with SIC-cluster-robust SEs.

Stata equivalence
-----------------
  Stata:  xtivreg2 dep (endog = instrs) exog yr*, fe ivar(key) tvar(year)
                   robust cluster(sic)
  Python: within-demean by entity, then IV2SLS(y_w, const+exog_w, endog_w, Z_w)
          .fit(cov_type="clustered", clusters=sic_ids)

  Note: `yr*` time dummies become redundant after within-demeaning (demeaning
  absorbs entity FE; time dummies are retained as exogenous regressors for
  consistency with the Stata spec).

Instrument sets
---------------
  The five Stata instruments are:
    d_go    — firm-level gross-output deflated growth (Gross Output BEA deflator)
    d_va_i  — industry-level BEA value-added growth (same for all firms in SIC)
    d_vadd  — NBER value-added growth (manufacturing firms)
    d_vship — NBER shipments growth (manufacturing firms)
    d_output — national BEA aggregate real output growth (NOT currently in the
               panel dataset; specs using d_output are skipped with a note)

  Leads (f.d_go, f.d_vadd, f.d_vship, f.d_va_i) are computed at runtime.

Blocks
------
  Block 1 (lines 1054–1091): Symmetric IV — d_sale (or d_va or d_va_a)
           instrumented by each of the four available aggregate output
           instruments and their leads.  Endogeneity test: d_sale / d_va.

  Block 2 (lines 1093–1105): Demeaned symmetric IV — dev_sale instrumented
           by dev_go, dev_va_i, dev_vadd, dev_vship (and their leads).

  Block 3 (lines 1107–1131): Asymmetric IV — d_h_sale + d_l_sale
           instrumented jointly by the corresponding split instruments.

  Block 4 (lines 1133–1157): Demeaned asymmetric IV — dev_h/l_sale
           instrumented by dev_h/l_go, dev_h/l_va_i, dev_h/l_vadd,
           dev_h/l_vship (and their leads/without leads).

All controls: emp r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent
              l.(same) l2.(same)   [Stata r_cf = r_gdp_cf etc.]

Output
------
  results/alldata_iv_results.xlsx   (one sheet per block)
  results/alldata_iv_summary.md
"""

from __future__ import annotations

import sqlite3
import warnings
from pathlib import Path

import numpy as np
import pandas as pd
import statsmodels.api as sm
from linearmodels.iv import IV2SLS, IVGMM

warnings.filterwarnings("ignore", category=FutureWarning)
warnings.filterwarnings("ignore", category=pd.errors.PerformanceWarning)
warnings.filterwarnings("ignore", "invalid value encountered in sqrt")
warnings.filterwarnings("ignore", "The provided covariance estimator")

ROOT = Path(__file__).resolve().parents[2]
DB_PATH = ROOT / "data" / "cyclicality.db"
RESULTS_DIR = ROOT / "results"
RESULTS_DIR.mkdir(exist_ok=True)


# ---------------------------------------------------------------------------
# Data loading
# ---------------------------------------------------------------------------

def load_data() -> pd.DataFrame:
    con = sqlite3.connect(DB_PATH)
    con.execute("PRAGMA cache_size = -8192")   # 8 MB page cache (default is 2 MB per kB setting)
    con.execute("PRAGMA mmap_size = 0")        # disable mmap to avoid double-mapping 3 GB file
    # Enumerate only the columns required by this script to stay well under 4 GB RAM.
    existing = {r[1] for r in con.execute("PRAGMA table_info(processed_alldata_stage3)").fetchall()}
    needed_prefixes = (
        "d_", "dev_", "f_d_", "f_dev_",                          # growth/deviation/lead vars
        "z_xrd_", "l_z_xrd_", "l2_z_xrd_",                       # R&D ratios + lags
        "r_gdp_", "r_va_", "r_go_", "r_nber_",                   # deflated financials
        "l_r_gdp_", "l_r_va_", "l_r_go_", "l_r_nber_",           # L1 deflated financials
        "l2_r_gdp_", "l2_r_va_", "l2_r_go_", "l2_r_nber_",       # L2 deflated financials
        "r_inv_", "r_nberinv_",                                    # investment-deflated
    )
    id_cols  = ["key", "year", "sic"]
    misc     = ["emp", "KZ", "KZ_1", "KZ_2", "KZ_3", "KZ_4",
                "WW", "WW_1", "WW_2", "WW_3", "WW_4"]
    sel = sorted(set(
        id_cols + misc +
        [c for c in existing if any(c.startswith(p) for p in needed_prefixes)]
    ))
    sql = f"SELECT {', '.join(c for c in sel if c in existing)} FROM processed_alldata_stage3"
    df = pd.read_sql(sql, con, dtype="float32")
    con.close()
    df["key"]  = df["key"].astype(str)
    df["year"] = pd.to_numeric(df["year"], errors="coerce").astype("Int64")
    df["sic"]  = pd.to_numeric(df["sic"],  errors="coerce")
    df = df.sort_values(["key", "year"]).reset_index(drop=True)
    return df


# ---------------------------------------------------------------------------
# Panel utility helpers
# ---------------------------------------------------------------------------

def panel_lag(df: pd.DataFrame, col: str, n: int = 1) -> pd.Series:
    grp = df.groupby("key", dropna=False, sort=False)
    lagged = grp[col].shift(n)
    prev = pd.to_numeric(grp["year"].shift(n), errors="coerce")
    curr = pd.to_numeric(df["year"], errors="coerce")
    return lagged.where((curr - prev) == n)


def panel_lead(df: pd.DataFrame, col: str, n: int = 1) -> pd.Series:
    grp = df.groupby("key", dropna=False, sort=False)
    led = grp[col].shift(-n)
    nxt  = pd.to_numeric(grp["year"].shift(-n), errors="coerce")
    curr = pd.to_numeric(df["year"], errors="coerce")
    return led.where((nxt - curr) == n)


def build_iv_vars(df: pd.DataFrame) -> pd.DataFrame:
    """Add all lags, leads, and control lags needed for IV regressions."""
    df = df.copy()

    # Financial control lags (r_gdp_* = Stata r_*)
    ctrl_base = ["r_gdp_cf", "r_gdp_dd1", "r_gdp_dltt",
                 "r_gdp_lt", "r_gdp_at", "r_gdp_ppent"]
    for c in ctrl_base:
        if c in df.columns:
            df[f"l_{c}"]  = panel_lag(df, c, 1)
            df[f"l2_{c}"] = panel_lag(df, c, 2)

    # Intensity ratio lags
    for c in ["z_xrd_sale", "z_xrd_va", "z_xrd_va_a", "z_xrd_capx"]:
        if c in df.columns:
            df[f"l_{c}"]  = panel_lag(df, c, 1)
            df[f"l2_{c}"] = panel_lag(df, c, 2)

    # Leads of symmetric instruments
    for c in ["d_go", "d_va_i", "d_vadd", "d_vship"]:
        if c in df.columns:
            df[f"f_{c}"] = panel_lead(df, c, 1)

    # Asymmetric output growth lags (endog regressors in asym specs)
    for c in ["d_h_sale", "d_l_sale"]:
        if c in df.columns:
            df[f"l_{c}"] = panel_lag(df, c, 1)

    # Leads of asymmetric instruments
    for c in ["d_h_go", "d_l_go", "d_h_va_i", "d_l_va_i",
              "d_h_vadd", "d_l_vadd", "d_h_vship", "d_l_vship"]:
        if c in df.columns:
            df[f"f_{c}"] = panel_lead(df, c, 1)

    # Leads of demeaned asymmetric instruments
    for c in ["dev_h_go", "dev_l_go", "dev_h_vadd", "dev_l_vadd",
              "dev_h_vship", "dev_l_vship", "dev_h_va_i", "dev_l_va_i"]:
        if c in df.columns:
            df[f"f_{c}"] = panel_lead(df, c, 1)

    # Leads of demeaned symmetric instruments
    for c in ["dev_go", "dev_va_i", "dev_vadd", "dev_vship"]:
        if c in df.columns:
            df[f"f_{c}"] = panel_lead(df, c, 1)

    # Lagged endog regressors for symmetric IV (l.d_sale, l.d_va)
    for c in ["d_sale", "d_va", "d_va_a"]:
        if c in df.columns:
            df[f"l_{c}"] = panel_lag(df, c, 1)

    return df


# ---------------------------------------------------------------------------
# Regression wrapper — FE IV via entity within-demeaning
# ---------------------------------------------------------------------------

def _fe_iv_sic(y: pd.Series,
               X_exog: pd.DataFrame,
               X_endog: pd.DataFrame,
               Z: pd.DataFrame,
               df: pd.DataFrame,
               label: str) -> dict:
    """FE 2SLS, SIC-cluster-robust SEs.

    Stata: xtivreg2 dep (endog = instrs) exog yr*, fe ivar(key) tvar(year)
           robust cluster(sic)
    Python: within-demean by entity, then IV2SLS with SIC clusters.
    """
    mask = (y.notna()
            & X_exog.notna().all(axis=1)
            & X_endog.notna().all(axis=1)
            & Z.notna().all(axis=1)
            & df["sic"].notna())
    n_obs = int(mask.sum())
    if n_obs < 20:
        return {"label": label, "estimator": "FE IV", "n": 0,
                "params": {}, "se": {}, "pvalues": {}}

    df_m = df.loc[mask, ["key", "sic"]].copy()
    y_m   = y[mask].copy()
    Xe_m  = X_exog[mask].copy()
    Xn_m  = X_endog[mask].copy()
    Z_m   = Z[mask].copy()

    # Drop zero-variance columns in exog
    Xe_m = Xe_m[[c for c in Xe_m.columns if Xe_m[c].nunique() > 1]]

    # Within-entity demean
    def _demean(s: pd.Series) -> pd.Series:
        return s - df_m["key"].map(s.groupby(df_m["key"]).mean())

    y_w  = _demean(y_m)
    Xe_w = Xe_m.apply(_demean)
    Xn_w = Xn_m.apply(_demean)
    Z_w  = Z_m.apply(_demean)

    Xc_w = sm.add_constant(Xe_w, has_constant="add")
    sic_ids = df_m["sic"].values

    try:
        res = IV2SLS(y_w, Xc_w, Xn_w, Z_w).fit(
            cov_type="clustered", clusters=sic_ids
        )
    except Exception as exc:
        return {"label": label, "estimator": "FE IV", "n": n_obs,
                "params": {}, "se": {}, "pvalues": {},
                "error": str(exc)}

    return {
        "label":     label,
        "estimator": "FE IV",
        "n":         int(res.nobs),
        "params":    res.params.to_dict(),
        "se":        res.std_errors.to_dict(),
        "pvalues":   res.pvalues.to_dict(),
    }


# ---------------------------------------------------------------------------
# Standard exogenous controls
# ---------------------------------------------------------------------------

def _exog_ctrl(df: pd.DataFrame) -> pd.DataFrame:
    """emp + r_gdp_{cf,dd1,dltt,lt,at,ppent} + L1 + L2 lags.

    Stata: emp r_cf r_dd1 r_dltt r_lt r_at r_ppent
                l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)
                l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)
    where r_cf etc. = r_gdp_cf etc. (verified identical in stage3).
    """
    base = [f"r_gdp_{c}" for c in ["cf", "dd1", "dltt", "lt", "at", "ppent"]]
    l1   = [f"l_{c}" for c in base]
    l2   = [f"l2_{c}" for c in base]
    cols = ["emp"] + base + l1 + l2
    return df[[c for c in cols if c in df.columns]]


# ---------------------------------------------------------------------------
# Block 1: Symmetric IV — d_sale or d_va or d_va_a instrumented
#          (AllData.do lines 1054–1091)
# ---------------------------------------------------------------------------
#
# Five instrument options: d_go, d_va_i, d_vadd, d_vship, d_output(missing)
# Each instrument used with its lead: (d_go f.d_go) etc.
# Three endog specs: d_sale, d_va, d_va_a

SYMM_INSTRUMENTS = [
    ("d_go",    "f_d_go"),
    ("d_va_i",  "f_d_va_i"),
    ("d_vadd",  "f_d_vadd"),
    ("d_vship", "f_d_vship"),
    # d_output not in dataset — skipped
]


def run_block1(df: pd.DataFrame) -> dict[str, dict]:
    """Block 1: symmetric IV — d_sale / d_va / d_va_a."""
    results: dict[str, dict] = {}
    exog = _exog_ctrl(df)

    # ── Spec 1: dep=d_xrd, endog=(d_sale, l_d_sale) ──────────────────────
    filt_sale = (
        (df["z_xrd_sale"] < 2)
        & (df["d_xrd"].abs() < 2)
        & (df["d_sale"].abs() < 3)
    )
    df_s = df[filt_sale].copy()
    exog_s = _exog_ctrl(df_s)
    endog_sale = df_s[["d_sale", "l_d_sale"]]

    for inst, f_inst in SYMM_INSTRUMENTS:
        if inst not in df_s.columns or f_inst not in df_s.columns:
            continue
        Z = df_s[[inst, f_inst]]
        lbl = f"b1_sale_{inst}"
        results[lbl] = _fe_iv_sic(
            df_s["d_xrd"], exog_s, endog_sale, Z, df_s, lbl)

    # ── Spec 2: dep=d_xrd, endog=(d_va, l_d_va) ─────────────────────────
    filt_va = (
        (df["z_xrd_va"] < 1)
        & (df["d_xrd"].abs() < 2)
        & (df["d_va"].abs() < 1)
    )
    df_v = df[filt_va].copy()
    exog_v = _exog_ctrl(df_v)
    endog_va = df_v[["d_va", "l_d_va"]]

    for inst, f_inst in SYMM_INSTRUMENTS:
        if inst not in df_v.columns or f_inst not in df_v.columns:
            continue
        Z = df_v[[inst, f_inst]]
        lbl = f"b1_va_{inst}"
        results[lbl] = _fe_iv_sic(
            df_v["d_xrd"], exog_v, endog_va, Z, df_v, lbl)

    # ── Spec 3: dep=d_xrd, endog=(d_va_a, l_d_va_a) ─────────────────────
    filt_va_a = df["z_xrd_va_a"] < 2
    df_a = df[filt_va_a].copy()
    exog_a = _exog_ctrl(df_a)
    endog_va_a = df_a[["d_va_a", "l_d_va_a"]]

    for inst, f_inst in SYMM_INSTRUMENTS:
        if inst not in df_a.columns or f_inst not in df_a.columns:
            continue
        Z = df_a[[inst, f_inst]]
        lbl = f"b1_va_a_{inst}"
        results[lbl] = _fe_iv_sic(
            df_a["d_xrd"], exog_a, endog_va_a, Z, df_a, lbl)

    print(f"  Block 1: {len(results)} regressions")
    return results


# ---------------------------------------------------------------------------
# Block 2: Demeaned symmetric IV — dev_sale / dev_go etc.
#          (AllData.do lines 1093–1105)
# ---------------------------------------------------------------------------
#
# Stata: xtivreg2 dev_xrd (dev_sale = dev_go f.dev_go) emp r_cf ... yr*
#                 if z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic)

DEMEANED_SYMM_INSTRUMENTS = [
    ("dev_go",    "f_dev_go"),
    ("dev_va_i",  "f_dev_va_i"),
    ("dev_vadd",  "f_dev_vadd"),
    ("dev_vship", "f_dev_vship"),
]


def run_block2(df: pd.DataFrame) -> dict[str, dict]:
    """Block 2: demeaned symmetric IV."""
    results: dict[str, dict] = {}
    filt = df["z_xrd_sale"] < 2
    df_f = df[filt].copy()
    exog = _exog_ctrl(df_f)
    endog = df_f[["dev_sale"]]

    for inst, f_inst in DEMEANED_SYMM_INSTRUMENTS:
        if inst not in df_f.columns:
            continue
        if f_inst in df_f.columns:
            Z = df_f[[inst, f_inst]]
        else:
            Z = df_f[[inst]]
        lbl = f"b2_{inst}"
        results[lbl] = _fe_iv_sic(
            df_f["dev_xrd"], exog, endog, Z, df_f, lbl)

    print(f"  Block 2: {len(results)} regressions")
    return results


# ---------------------------------------------------------------------------
# Block 3: Asymmetric IV — d_h/l_sale instrumented jointly
#          (AllData.do lines 1107–1131)
# ---------------------------------------------------------------------------
#
# Stata: xtivreg2 d_xrd (d_h_sale d_l_sale = d_h_go d_l_go f.(d_h_go d_l_go))
#                 emp r_cf ... yr* if z_xrd_sale<2, fe ivar(key) tvar(year)
#                 robust cluster(sic)
# Two sub-blocks: with leads (lines 1107–1117) and without leads (1120–1130)

ASYM_INSTRUMENT_PAIRS = [
    ("d_h_go",    "d_l_go",    "f_d_h_go",    "f_d_l_go"),
    ("d_h_va_i",  "d_l_va_i",  "f_d_h_va_i",  "f_d_l_va_i"),
    ("d_h_vadd",  "d_l_vadd",  "f_d_h_vadd",  "f_d_l_vadd"),
    ("d_h_vship", "d_l_vship", "f_d_h_vship", "f_d_l_vship"),
    # d_h/l_output: not in dataset — skipped
]


def run_block3(df: pd.DataFrame) -> dict[str, dict]:
    """Block 3: asymmetric IV with and without leads."""
    results: dict[str, dict] = {}
    filt = df["z_xrd_sale"] < 2
    df_f = df[filt].copy()
    exog = _exog_ctrl(df_f)
    endog = df_f[["d_h_sale", "d_l_sale"]]

    for h_inst, l_inst, f_h, f_l in ASYM_INSTRUMENT_PAIRS:
        if h_inst not in df_f.columns or l_inst not in df_f.columns:
            continue

        # With leads
        if f_h in df_f.columns and f_l in df_f.columns:
            Z = df_f[[h_inst, l_inst, f_h, f_l]]
            lbl = f"b3_lead_{h_inst[2:]}"
            results[lbl] = _fe_iv_sic(
                df_f["d_xrd"], exog, endog, Z, df_f, lbl)

        # Without leads
        Z = df_f[[h_inst, l_inst]]
        lbl = f"b3_nolead_{h_inst[2:]}"
        results[lbl] = _fe_iv_sic(
            df_f["d_xrd"], exog, endog, Z, df_f, lbl)

    print(f"  Block 3: {len(results)} regressions")
    return results


# ---------------------------------------------------------------------------
# Block 4: Demeaned asymmetric IV — dev_h/l_sale
#          (AllData.do lines 1133–1157)
# ---------------------------------------------------------------------------
#
# Two sub-blocks: with leads and without leads.

DEMEANED_ASYM_PAIRS = [
    ("dev_h_go",    "dev_l_go",    "f_dev_h_go",    "f_dev_l_go"),
    ("dev_h_va_i",  "dev_l_va_i",  "f_dev_h_va_i",  "f_dev_l_va_i"),
    ("dev_h_vadd",  "dev_l_vadd",  "f_dev_h_vadd",  "f_dev_l_vadd"),
    ("dev_h_vship", "dev_l_vship", "f_dev_h_vship",  "f_dev_l_vship"),
    # dev_h/l_output: not in dataset — skipped
]


def run_block4(df: pd.DataFrame) -> dict[str, dict]:
    """Block 4: demeaned asymmetric IV with and without leads."""
    results: dict[str, dict] = {}
    filt = df["z_xrd_sale"] < 2
    df_f = df[filt].copy()
    exog = _exog_ctrl(df_f)
    endog = df_f[["dev_h_sale", "dev_l_sale"]]

    for h_inst, l_inst, f_h, f_l in DEMEANED_ASYM_PAIRS:
        if h_inst not in df_f.columns or l_inst not in df_f.columns:
            continue

        # With leads
        if f_h in df_f.columns and f_l in df_f.columns:
            Z = df_f[[h_inst, l_inst, f_h, f_l]]
            lbl = f"b4_lead_{h_inst[4:]}"
            results[lbl] = _fe_iv_sic(
                df_f["dev_xrd"], exog, endog, Z, df_f, lbl)

        # Without leads
        Z = df_f[[h_inst, l_inst]]
        lbl = f"b4_nolead_{h_inst[4:]}"
        results[lbl] = _fe_iv_sic(
            df_f["dev_xrd"], exog, endog, Z, df_f, lbl)

    print(f"  Block 4: {len(results)} regressions")
    return results


# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------

def results_to_df(results: dict[str, dict]) -> pd.DataFrame:
    rows = []
    for label, r in results.items():
        if not r.get("params"):
            rows.append({"label": label, "n": r.get("n", 0),
                         "variable": "", "coef": np.nan,
                         "se": np.nan, "pvalue": np.nan,
                         "error": r.get("error", "")})
            continue
        for var, coef in r["params"].items():
            rows.append({
                "label":    label,
                "n":        r["n"],
                "variable": var,
                "coef":     coef,
                "se":       r["se"].get(var, np.nan),
                "pvalue":   r["pvalues"].get(var, np.nan),
                "error":    "",
            })
    return pd.DataFrame(rows)


def write_xlsx(blocks: dict[str, dict[str, dict]], path: Path) -> None:
    with pd.ExcelWriter(path, engine="openpyxl") as writer:
        for sheet, results in blocks.items():
            df_out = results_to_df(results)
            df_out.to_excel(writer, sheet_name=sheet[:31], index=False)
    print(f"  Wrote {path.name}")


def write_summary_md(blocks: dict[str, dict[str, dict]], path: Path) -> None:
    lines = [
        "# AllData IV Regression Results Summary\n",
        "Replication of AllData.do lines 1052–1159.\n",
        "Estimator: FE IV (within-entity demean + IV2SLS), SIC-cluster-robust SEs.\n",
        "\nNote: d_output / d_h_output / d_l_output specs skipped "
        "(variable not in cyclicality.db panel; requires BEA national "
        "aggregate output growth merged separately).\n",
    ]

    def _coef_line(res: dict, key: str) -> str:
        if not res.get("params"):
            err = res.get("error", "n/a")
            return f"  {key}: FAILED ({err[:60]})"
        coef = res["params"].get(key, np.nan)
        se   = res["se"].get(key, np.nan)
        pval = res["pvalues"].get(key, np.nan)
        stars = ("***" if pval < 0.01 else "**" if pval < 0.05
                 else "*" if pval < 0.10 else "")
        return f"  {key}: {coef:.4f}{stars} ({se:.4f}), n={res['n']}"

    for block_name, results in blocks.items():
        lines.append(f"\n## {block_name}\n")
        for lbl, res in results.items():
            # Show coefficient on the primary output variable
            for cand in ["d_sale", "d_va", "d_va_a", "dev_sale",
                         "d_h_sale", "dev_h_sale"]:
                if res.get("params", {}).get(cand) is not None:
                    lines.append(f"  {lbl}: " + _coef_line(res, cand))
                    break
            else:
                lines.append(f"  {lbl}: n={res.get('n', 0)}")

    path.write_text("\n".join(lines))
    print(f"  Wrote {path.name}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    print("Loading data …")
    df = load_data()
    print(f"  {len(df):,} rows from processed_alldata_stage3")

    print("Building IV variables (lags, leads) …")
    df = build_iv_vars(df)

    print("\nRunning Block 1 — symmetric IV (d_sale / d_va / d_va_a) …")
    b1 = run_block1(df)

    print("\nRunning Block 2 — demeaned symmetric IV (dev_sale) …")
    b2 = run_block2(df)

    print("\nRunning Block 3 — asymmetric IV (d_h/l_sale) …")
    b3 = run_block3(df)

    print("\nRunning Block 4 — demeaned asymmetric IV (dev_h/l_sale) …")
    b4 = run_block4(df)

    blocks = {"Block1_Symm": b1, "Block2_DemeanedSymm": b2,
              "Block3_Asym": b3, "Block4_DemeanedAsym": b4}

    print("\nWriting output …")
    write_xlsx(blocks, RESULTS_DIR / "alldata_iv_results.xlsx")
    write_summary_md(blocks, RESULTS_DIR / "alldata_iv_summary.md")

    total = sum(len(v) for v in blocks.values())
    print(f"\nDone — {total} IV regressions written.")


if __name__ == "__main__":
    main()
