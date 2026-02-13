#!/usr/bin/env python3
from __future__ import annotations

import sqlite3
from pathlib import Path

import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[2]
DB_PATH = ROOT / "data" / "cyclicality.db"
OUT_PATH = ROOT / "data" / "PARITY_VARIABLE_CHECKS.md"
TOL = 1e-9


def build_code_from_naics3(naics_series: pd.Series) -> pd.Series:
    naics3 = naics_series.astype("string").str.strip().str[:3]
    mapping: dict[str, int] = {}
    groups = {
        1: ["111", "112"],
        2: ["113", "114", "115"],
        3: ["211"],
        4: ["212"],
        5: ["213"],
        6: ["221"],
        7: ["233"],
        8: ["311", "312"],
        9: ["313", "314"],
        10: ["315", "316"],
        11: ["321"],
        12: ["322"],
        13: ["323"],
        14: ["324"],
        15: ["325"],
        16: ["326"],
        17: ["327"],
        18: ["331"],
        19: ["332"],
        20: ["333"],
        21: ["334"],
        22: ["335"],
        23: ["336"],
        24: ["337"],
        25: ["339"],
        26: ["441"],
        27: ["442", "443", "444", "446", "447", "448", "451", "453", "454"],
        28: ["445"],
        29: ["452"],
        30: ["481"],
        31: ["482"],
        32: ["483"],
        33: ["484"],
        34: ["485"],
        35: ["486"],
        36: ["487", "488", "492"],
        37: ["493"],
        38: ["511"],
        39: ["512"],
        40: ["513"],
        41: ["514"],
        42: ["521", "522"],
        43: ["523"],
        44: ["524"],
        45: ["525"],
        46: ["531"],
        47: ["532", "533"],
        48: ["541"],
        49: ["561"],
        50: ["562"],
        51: ["611"],
        52: ["621"],
        53: ["622"],
        54: ["623"],
        55: ["624"],
        56: ["711", "712"],
        57: ["713"],
        58: ["721"],
        59: ["722"],
        60: ["811", "812", "813", "814"],
    }
    for code, vals in groups.items():
        for v in vals:
            mapping[v] = code
    return naics3.map(mapping).astype("Int64")


def merge_step(
    master: pd.DataFrame,
    using_df: pd.DataFrame,
    on: list[str],
    step_name: str,
) -> tuple[pd.DataFrame, dict[str, int | str]]:
    merged = master.merge(using_df, on=on, how="left", indicator=True)
    stats = {
        "step": step_name,
        "master_rows_before": len(master),
        "matched_master": int((merged["_merge"] == "both").sum()),
        "unmatched_master": int((merged["_merge"] == "left_only").sum()),
    }
    using_only = using_df.merge(master[on].drop_duplicates(), on=on, how="left", indicator=True)
    stats["using_only"] = int((using_only["_merge"] == "left_only").sum())

    # Stata pattern drops only _merge==2 (using-only), which does not change master rows in left merge.
    merged = merged.drop(columns=["_merge"])
    return merged, stats


def numeric_parity(source: pd.Series, target: pd.Series) -> dict[str, float | int]:
    src = pd.to_numeric(source, errors="coerce")
    tgt = pd.to_numeric(target, errors="coerce")
    both_nonnull = src.notna() & tgt.notna()
    both_null = src.isna() & tgt.isna()
    null_mismatch = int((src.isna() ^ tgt.isna()).sum())

    out: dict[str, float | int] = {
        "rows": int(len(src)),
        "both_nonnull": int(both_nonnull.sum()),
        "both_null": int(both_null.sum()),
        "null_mismatch": null_mismatch,
    }

    if both_nonnull.any():
        diff = (src[both_nonnull] - tgt[both_nonnull]).abs()
        out["max_abs_diff"] = float(diff.max())
        out["mean_abs_diff"] = float(diff.mean())
        out["tol_fail_count"] = int((diff > TOL).sum())
    else:
        out["max_abs_diff"] = float("nan")
        out["mean_abs_diff"] = float("nan")
        out["tol_fail_count"] = 0
    return out


def main() -> int:
    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA busy_timeout=5000")

    master = pd.read_sql_query(
        "SELECT key, CAST(year AS INTEGER) AS year, CAST(sic AS INTEGER) AS sic, naics FROM raw_compustat",
        conn,
    )

    stock = pd.read_sql_query(
        "SELECT key, CAST(year AS INTEGER) AS year, smbl, prcc12, div12, ern12, bkv, cshoq12, navm12 "
        "FROM raw_stock_market",
        conn,
    )

    bea = pd.read_sql_query(
        "SELECT CAST(code AS INTEGER) AS code, CAST(year AS INTEGER) AS year, "
        "go, va, pgo, pva, d_go, d_va_ind, d_instrument FROM processed_bea_value_added",
        conn,
    )

    nber = pd.read_sql_query(
        "SELECT CAST(sic AS INTEGER) AS sic, CAST(year AS INTEGER) AS year, "
        "vship, vadd, piship, piinv, dtfp5, tfp5, dtfp4, tfp4, exports, d_vadd, d_vship, d_exports "
        "FROM processed_nber_exports",
        conn,
    )

    bond = pd.read_sql_query(
        "SELECT CAST(year AS INTEGER) AS year, gov_b, aaa, baa, aaa_g, baa_g, baa_aaa, d_y, ag, bg, ba "
        "FROM raw_bond_yields",
        conn,
    )

    ss = pd.read_sql_query(
        "SELECT CAST(year AS INTEGER) AS year, awi, averagewage FROM raw_social_security_wage",
        conn,
    )

    gdp = pd.read_sql_query(
        "SELECT CAST(year AS INTEGER) AS year, gdp, p_gdp, p_nonresidential, p_ipr, d_gdp FROM processed_gdp",
        conn,
    )

    # Reconstruct merge path.
    steps: list[dict[str, int | str]] = []
    work = master.copy()

    work, s = merge_step(work, stock, ["key", "year"], "1:1 key/year with raw_stock_market")
    steps.append(s)

    work["code"] = build_code_from_naics3(work["naics"])
    work, s = merge_step(work, bea, ["code", "year"], "m:1 code/year with processed_bea_value_added")
    steps.append(s)

    work, s = merge_step(work, nber, ["sic", "year"], "m:1 sic/year with processed_nber_exports")
    steps.append(s)

    work, s = merge_step(work, bond, ["year"], "m:1 year with raw_bond_yields")
    steps.append(s)

    work, s = merge_step(work, ss, ["year"], "m:1 year with raw_social_security_wage")
    steps.append(s)

    work, s = merge_step(work, gdp, ["year"], "m:1 year with processed_gdp")
    steps.append(s)

    work = work.drop(columns=["naics", "code"])  # Stata drops temp fields.

    # Compare to processed_alldata on key/year.
    target_cols = [
        "smbl", "prcc12", "div12", "ern12", "bkv", "cshoq12", "navm12",
        "go", "va", "pgo", "pva", "d_go", "d_va_ind", "d_instrument",
        "vship", "vadd", "piship", "piinv", "dtfp5", "tfp5", "dtfp4", "tfp4", "exports", "d_vadd", "d_vship", "d_exports",
        "gov_b", "aaa", "baa", "aaa_g", "baa_g", "baa_aaa", "d_y", "ag", "bg", "ba",
        "awi", "averagewage",
        "gdp", "p_gdp", "p_nonresidential", "p_ipr", "d_gdp",
    ]

    target = pd.read_sql_query(
        "SELECT key, CAST(year AS INTEGER) AS year, " + ", ".join(target_cols) + " FROM processed_alldata",
        conn,
    )

    comp = work.merge(target, on=["key", "year"], how="inner", suffixes=("_recon", "_target"))

    # Compare categorical/text fields by exact equality.
    text_cols = ["smbl"]
    text_metrics: list[dict[str, int | str | float]] = []
    for col in text_cols:
        a = comp[f"{col}_recon"].astype("string")
        b = comp[f"{col}_target"].astype("string")
        both_null = int((a.isna() & b.isna()).sum())
        null_mismatch = int((a.isna() ^ b.isna()).sum())
        both_nonnull = a.notna() & b.notna()
        exact_match = int((a[both_nonnull] == b[both_nonnull]).sum())
        total_nonnull = int(both_nonnull.sum())
        eq_rate = (100.0 * exact_match / total_nonnull) if total_nonnull else float("nan")
        text_metrics.append(
            {
                "variable": col,
                "rows": len(comp),
                "both_null": both_null,
                "null_mismatch": null_mismatch,
                "both_nonnull": total_nonnull,
                "exact_match": exact_match,
                "exact_match_pct": eq_rate,
            }
        )

    # Numeric parity.
    num_cols = [c for c in target_cols if c not in text_cols]
    num_metrics: list[dict[str, int | str | float]] = []
    for col in num_cols:
        m = numeric_parity(comp[f"{col}_recon"], comp[f"{col}_target"])
        m["variable"] = col
        num_metrics.append(m)

    lines: list[str] = []
    lines.append("# Parity Variable Checks")
    lines.append("")
    lines.append("Variable-level parity report for the merge sequence in `CreatingUniqueDataset.do`.")
    lines.append("")
    lines.append("## Step Diagnostics")
    lines.append("")
    lines.append("| Step | Master rows before | Matched master | Unmatched master | Using-only |")
    lines.append("|---|---:|---:|---:|---:|")
    for s in steps:
        lines.append(
            f"| {s['step']} | {s['master_rows_before']} | {s['matched_master']} | {s['unmatched_master']} | {s['using_only']} |"
        )
    lines.append("")
    lines.append(f"Comparison join rows (`reconstructed` ∩ `processed_alldata` on key/year): `{len(comp)}`")
    lines.append("")

    lines.append("## Text Variable Parity")
    lines.append("")
    lines.append("| Variable | Both non-null | Exact matches | Exact match % | Null mismatches |")
    lines.append("|---|---:|---:|---:|---:|")
    for m in text_metrics:
        pct = "nan" if pd.isna(m["exact_match_pct"]) else f"{m['exact_match_pct']:.4f}%"
        lines.append(
            f"| `{m['variable']}` | {m['both_nonnull']} | {m['exact_match']} | {pct} | {m['null_mismatch']} |"
        )
    lines.append("")

    lines.append("## Numeric Variable Parity")
    lines.append("")
    lines.append("| Variable | Both non-null | Null mismatches | Max abs diff | Mean abs diff | > tol count |")
    lines.append("|---|---:|---:|---:|---:|---:|")
    for m in num_metrics:
        max_abs = "nan" if np.isnan(m["max_abs_diff"]) else f"{m['max_abs_diff']:.6g}"
        mean_abs = "nan" if np.isnan(m["mean_abs_diff"]) else f"{m['mean_abs_diff']:.6g}"
        lines.append(
            f"| `{m['variable']}` | {m['both_nonnull']} | {m['null_mismatch']} | {max_abs} | {mean_abs} | {m['tol_fail_count']} |"
        )

    lines.append("")
    lines.append("## Notes")
    lines.append("")
    lines.append("- Tolerance for numeric comparison: `1e-9`.")
    lines.append("- Differences here indicate merge/type/alignment differences relative to `processed_alldata` and should be investigated before model-level parity.")

    OUT_PATH.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote {OUT_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
