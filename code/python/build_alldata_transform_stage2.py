#!/usr/bin/env python3
from __future__ import annotations

import sqlite3
from pathlib import Path
import warnings

import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[2]
DB_PATH = ROOT / "data" / "cyclicality.db"
REPORT_PATH = ROOT / "data" / "TRANSFORMATION_STAGE2_REPORT.md"
OUT_TABLE = "processed_alldata_stage2"


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


def stage_binary(series: pd.Series, label: str) -> tuple[pd.Series, pd.Series]:
    hi = pd.Series(np.nan, index=series.index, dtype="float64")
    hi = hi.mask(series > 0, 1.0)
    hi = hi.mask(series < 0, 0.0)
    lo = 1.0 - hi
    hi = hi * series
    lo = lo * series
    hi.name = f"d_h_{label}"
    lo.name = f"d_l_{label}"
    return hi, lo


def transform_stage2(
    df: pd.DataFrame,
) -> tuple[pd.DataFrame, list[str], list[str], list[str]]:
    """Apply deterministic Stage-2 blocks from AllData.do lines ~416-791."""
    required_base = {"key", "year"}
    missing_base = sorted(required_base - set(df.columns))
    if missing_base:
        raise ValueError(f"Missing required columns for stage2: {missing_base}")

    df = df.sort_values(["key", "year"], kind="mergesort").reset_index(drop=True).copy()
    generated: list[str] = []
    skipped: list[str] = []
    assumptions: list[str] = []

    # Growth rates.
    growth_map = {
        "d_gdp_xrd": "r_gdp_xrd",
        "d_va_xrd": "r_va_xrd",
        "d_go_xrd": "r_go_xrd",
        "d_nber_xrd": "r_nber_xrd",
        "d_ipr_xrd": "r_ipr_xrd",
        "d_gdp_va": "r_gdp_va",
        "d_va_va": "r_va_va",
        "d_go_va": "r_go_va",
        "d_nber_va": "r_nber_va",
        "d_gdp_va_a": "r_gdp_va_a",
        "d_va_va_a": "r_va_va_a",
        "d_go_va_a": "r_go_va_a",
        "d_nber_va_a": "r_nber_va_a",
        "d_gdp_va_e": "r_gdp_va_e",
        "d_va_va_e": "r_va_va_e",
        "d_go_va_e": "r_go_va_e",
        "d_nber_va_e": "r_nber_va_e",
        "d_gdp_sale": "r_gdp_sale",
        "d_va_sale": "r_va_sale",
        "d_go_sale": "r_go_sale",
        "d_nber_sale": "r_nber_sale",
        "d_gdp_sale_i": "r_gdp_sale_i",
        "d_va_sale_i": "r_va_sale_i",
        "d_go_sale_i": "r_go_sale_i",
        "d_nber_sale_i": "r_nber_sale_i",
    }
    for out_col, src_col in growth_map.items():
        if src_col not in df.columns:
            skipped.append(f"{out_col}: missing source `{src_col}`")
            continue
        lag = panel_lag(df, src_col)
        df[out_col] = ln_pos(df[src_col]) - ln_pos(lag)
        generated.append(out_col)

    if "d_gdp" in df.columns:
        assumptions.append("Reused existing `d_gdp` (case-insensitive equivalent of Stata `d_GDP`).")
    elif {"gdp", "p_gdp"}.issubset(df.columns):
        gdp_def = safe_div(df["gdp"], df["p_gdp"])
        lag_gdp_def = panel_lag(pd.DataFrame({"key": df["key"], "year": df["year"], "tmp": gdp_def}), "tmp")
        df["d_gdp"] = ln_pos(gdp_def) - ln_pos(lag_gdp_def)
        generated.append("d_gdp")
    else:
        skipped.append("d_gdp (Stata d_GDP): missing `gdp` or `p_gdp`")

    # Ratios.
    if {"xrd", "sale"}.issubset(df.columns):
        df["z_xrd_sale"] = safe_div(df["xrd"], df["sale"])
        generated.append("z_xrd_sale")
    else:
        skipped.append("z_xrd_sale: missing `xrd` or `sale`")
    if {"xrd", "va"}.issubset(df.columns):
        df["z_xrd_va"] = safe_div(df["xrd"], df["va"])
        generated.append("z_xrd_va")
    else:
        skipped.append("z_xrd_va: missing `xrd` or `va`")
    if {"xrd", "va_a"}.issubset(df.columns):
        df["z_xrd_va_a"] = safe_div(df["xrd"], df["va_a"])
        generated.append("z_xrd_va_a")
    else:
        skipped.append("z_xrd_va_a: missing `xrd` or `va_a`")
    if {"xrd", "capx"}.issubset(df.columns):
        df["z_xrd_capx"] = safe_div(df["xrd"], df["xrd"] + df["capx"])
        generated.append("z_xrd_capx")
    else:
        skipped.append("z_xrd_capx: missing `xrd` or `capx`")

    # Financial variables.
    fin_required = {"prcc12", "cshoq12", "ib", "dp", "ppent", "at", "ceq", "txdb", "dltt", "dlc", "seq", "dvp", "dvc", "che"}
    if fin_required.issubset(df.columns):
        lag_ppent = panel_lag(df, "ppent")
        df["mkv"] = df["prcc12"] * df["cshoq12"]
        df["cfratio"] = safe_div(df["ib"] + df["dp"], lag_ppent)
        df["Q"] = safe_div(df["at"] + df["mkv"] - df["ceq"] - df["txdb"], df["at"])
        df["debt"] = safe_div(df["dltt"] + df["dlc"], df["seq"] + df["dltt"] + df["dlc"])
        df["div"] = safe_div(df["dvp"] + df["dvc"], lag_ppent)
        df["cash"] = safe_div(df["che"], lag_ppent)
        generated += ["mkv", "cfratio", "Q", "debt", "div", "cash"]

        df["KZ"] = -1.001909 * df["cfratio"] + 0.2826389 * df["Q"] + 3.139193 * df["debt"] - 39.3678 * df["div"] - 1.314759 * df["cash"]
        generated.append("KZ")

        kz1 = (df["KZ"] < -4.575488).astype(float)
        kz2 = ((df["KZ"] > -4.575488) & (df["KZ"] <= -1.35775)).astype(float)
        kz3 = ((df["KZ"] > -1.35775) & (df["KZ"] <= 0.3688995)).astype(float)
        kz4 = (df["KZ"] > 0.3688995).astype(float)
        df["KZ_1"], df["KZ_2"], df["KZ_3"], df["KZ_4"] = kz1, kz2, kz3, kz4
        generated += ["KZ_1", "KZ_2", "KZ_3", "KZ_4"]

        divpos = pd.Series(np.nan, index=df.index, dtype="float64")
        divpos = divpos.mask((df["dvc"] > 0) | (df["dvp"] > 0), 1.0)
        divpos = divpos.mask(divpos != 1.0, 0.0)
        df["divpos"] = divpos
        generated.append("divpos")

        for out, src in [("lnta", "r_gdp_at"), ("ln_va_ta", "r_va_at"), ("ln_go_ta", "r_go_at"), ("ln_nber_ta", "r_nber_at")]:
            if src in df.columns:
                df[out] = ln_pos(df[src])
                generated.append(out)
            else:
                skipped.append(f"{out}: missing `{src}`")

        ww_required = {"cfratio", "divpos", "debt", "lnta", "d_gdp_sale_i", "d_gdp_sale"}
        if ww_required.issubset(df.columns):
            df["WW"] = (
                -0.091 * df["cfratio"]
                - 0.062 * df["divpos"]
                + 0.021 * df["debt"]
                - 0.044 * df["lnta"]
                + 0.102 * df["d_gdp_sale_i"]
                - 0.035 * df["d_gdp_sale"]
            )
            generated.append("WW")

            ww1 = (df["WW"] < -0.4075759).astype(float)
            ww2 = ((df["WW"] > -0.4075759) & (df["WW"] <= -0.3237967)).astype(float)
            ww3 = ((df["WW"] > -0.3237967) & (df["WW"] <= -0.2442014)).astype(float)
            ww4 = (df["WW"] > -0.2442014).astype(float)
            df["WW_1"], df["WW_2"], df["WW_3"], df["WW_4"] = ww1, ww2, ww3, ww4
            generated += ["WW_1", "WW_2", "WW_3", "WW_4"]
        else:
            skipped.append("WW and WW_*: missing one or more required inputs")
    else:
        skipped.append("Financial block skipped: missing one or more required inputs")

    # Interactions between growth rates and constraint bins.
    interaction_sources = {
        "sale": "d_gdp_sale",
        "va_a": "d_gdp_va_a",
        "va": "d_gdp_va",
        "go": "d_go",
        "va_i": "d_va_ind",
        "vadd": "d_vadd",
        "vship": "d_vship",
    }
    for suffix, src in interaction_sources.items():
        for i in range(1, 5):
            kz = f"KZ_{i}"
            ww = f"WW_{i}"
            out_kz = f"d_{suffix}_KZ{i}"
            out_ww = f"d_{suffix}_WW{i}"
            if src in df.columns and kz in df.columns:
                df[out_kz] = df[src] * df[kz]
                generated.append(out_kz)
            else:
                skipped.append(f"{out_kz}: missing `{src}` or `{kz}`")
            if src in df.columns and ww in df.columns:
                df[out_ww] = df[src] * df[ww]
                generated.append(out_ww)
            else:
                skipped.append(f"{out_ww}: missing `{src}` or `{ww}`")

    # Financial-condition direction bins.
    for fc in ["ag", "bg", "ba"]:
        if fc not in df.columns:
            skipped.append(f"d_h_{fc}/d_l_{fc}: missing `{fc}`")
            continue
        lag_fc = panel_lag(df, fc)
        h = pd.Series(np.nan, index=df.index, dtype="float64")
        h = h.mask(df[fc] > lag_fc, 1.0)
        h = h.mask(df[fc] < lag_fc, 0.0)
        l = 1.0 - h
        h_col = f"d_h_{fc}"
        l_col = f"d_l_{fc}"
        df[h_col] = h
        df[l_col] = l
        generated += [h_col, l_col]
        for suffix, src in [("sale", "d_gdp_sale"), ("va_a", "d_gdp_va_a"), ("va", "d_gdp_va")]:
            if src in df.columns:
                h_out = f"d_h_{fc}_fc_{suffix}"
                l_out = f"d_l_{fc}_fc_{suffix}"
                df[h_out] = df[h_col] * df[src]
                df[l_out] = df[l_col] * df[src]
                generated += [h_out, l_out]
            else:
                skipped.append(f"d_h_{fc}_fc_{suffix}/d_l_{fc}_fc_{suffix}: missing `{src}`")

    # Asymmetric growth rates.
    asym_map = {
        "va": "d_gdp_va",
        "va_a": "d_gdp_va_a",
        "sale": "d_gdp_sale",
        "GDP": "d_gdp",
        "va_i": "d_va_ind",
        "go": "d_go",
        "vadd": "d_vadd",
        "vship": "d_vship",
    }
    for label, src in asym_map.items():
        if src not in df.columns:
            skipped.append(f"d_h_{label}/d_l_{label}: missing `{src}`")
            continue
        hi, lo = stage_binary(df[src], label)
        df[hi.name] = hi
        df[lo.name] = lo
        generated += [hi.name, lo.name]

    # Alias assumptions needed for deviation block naming used in AllData.do.
    alias_map = {
        "d_xrd": "d_gdp_xrd",
        "d_sale": "d_gdp_sale",
        "d_va": "d_gdp_va",
        "d_va_a": "d_gdp_va_a",
        "d_va_i": "d_va_ind",
    }
    for alias, src in alias_map.items():
        if alias not in df.columns and src in df.columns:
            df[alias] = df[src]
            generated.append(alias)
            assumptions.append(f"Alias `{alias}` derived from `{src}` for deviation block parity.")

    # Deviation block.
    deviation_stems = ["xrd", "sale", "gdp", "va", "va_a", "va_i", "go", "vadd", "vship"]
    for stem in deviation_stems:
        src = f"d_{stem}"
        mean_col = f"mean_d_{stem}"
        dev_col = f"dev_{stem}"
        if src not in df.columns:
            skipped.append(f"{mean_col}/{dev_col}: missing `{src}`")
            continue
        df[mean_col] = df.groupby("key", dropna=False)[src].transform("mean")
        df[dev_col] = df[src] - df[mean_col]
        generated += [mean_col, dev_col]

    for stem in ["sale", "gdp", "va", "va_a", "va_i", "go", "vadd", "vship"]:
        src = f"dev_{stem}"
        if src not in df.columns:
            skipped.append(f"dev_h_{stem}/dev_l_{stem}: missing `{src}`")
            continue
        hi = pd.Series(np.nan, index=df.index, dtype="float64")
        hi = hi.mask(df[src] > 0, 1.0)
        hi = hi.mask(df[src] < 0, 0.0)
        lo = 1.0 - hi
        h_col = f"dev_h_{stem}"
        l_col = f"dev_l_{stem}"
        df[h_col] = df[src] * hi
        df[l_col] = df[src] * lo
        generated += [h_col, l_col]

    return df, sorted(set(generated)), sorted(set(skipped)), assumptions


def main() -> int:
    warnings.simplefilter("ignore", category=pd.errors.PerformanceWarning)
    with sqlite3.connect(DB_PATH) as conn:
        stage1_df = pd.read_sql_query("SELECT * FROM processed_alldata_stage1", conn)

    out_df, generated, skipped, assumptions = transform_stage2(stage1_df)

    with sqlite3.connect(DB_PATH) as conn:
        sql_chunk = safe_to_sql_chunksize(conn, len(out_df.columns))
        conn.execute(f"DROP TABLE IF EXISTS {OUT_TABLE}")
        out_df = out_df.copy()
        out_df.to_sql(OUT_TABLE, conn, if_exists="replace", index=False, method="multi", chunksize=sql_chunk)
        out_rows = int(conn.execute(f"SELECT COUNT(*) FROM {OUT_TABLE}").fetchone()[0])

    lines = []
    lines.append("# Transformation Stage 2 Report")
    lines.append("")
    lines.append("Implements deterministic `AllData.do` transformation blocks after Stage 1.")
    lines.append("")
    lines.append("## Output")
    lines.append("")
    lines.append(f"- SQLite table: `{OUT_TABLE}`")
    lines.append(f"- Input rows (`processed_alldata_stage1`): `{len(stage1_df)}`")
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
