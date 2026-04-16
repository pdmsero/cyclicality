#!/usr/bin/env python3
from __future__ import annotations

import sqlite3
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).resolve().parents[2]
DB_PATH = ROOT / "data" / "cyclicality.db"
OUT_PATH = ROOT / "data" / "PARITY_CHECKPOINTS.md"


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


def duplicate_key_groups(df: pd.DataFrame, keys: list[str]) -> int:
    return int((df.groupby(keys, dropna=False).size() > 1).sum())


def merge_stats(master: pd.DataFrame, using: pd.DataFrame, keys: list[str]) -> tuple[int, int, int]:
    using_keys = using[keys].drop_duplicates()
    merged = master[keys].merge(using_keys, on=keys, how="left", indicator=True)
    matched = int((merged["_merge"] == "both").sum())
    unmatched = int((merged["_merge"] == "left_only").sum())

    master_keys = master[keys].drop_duplicates()
    using_merge = using[keys].merge(master_keys, on=keys, how="left", indicator=True)
    using_only = int((using_merge["_merge"] == "left_only").sum())
    return matched, unmatched, using_only


def main() -> int:
    conn = sqlite3.connect(DB_PATH)

    master = pd.read_sql_query(
        "SELECT key, CAST(year AS INTEGER) AS year, CAST(sic AS INTEGER) AS sic, naics FROM raw_compustat",
        conn,
    )
    stock = pd.read_sql_query("SELECT key, CAST(year AS INTEGER) AS year FROM raw_stock_market", conn)
    bea = pd.read_sql_query(
        "SELECT CAST(code AS INTEGER) AS code, CAST(year AS INTEGER) AS year FROM processed_bea_value_added",
        conn,
    )
    nber = pd.read_sql_query(
        "SELECT CAST(sic AS INTEGER) AS sic, CAST(year AS INTEGER) AS year FROM processed_nber_exports",
        conn,
    )
    bond = pd.read_sql_query("SELECT CAST(year AS INTEGER) AS year FROM raw_bond_yields", conn)
    ss = pd.read_sql_query("SELECT CAST(year AS INTEGER) AS year FROM raw_social_security_wage", conn)
    gdp = pd.read_sql_query("SELECT CAST(year AS INTEGER) AS year FROM processed_gdp", conn)

    base_rows = len(master)
    final_all_data_rows = int(pd.read_sql_query("SELECT COUNT(*) AS c FROM processed_alldata", conn)["c"].iloc[0])

    master_code = master.copy()
    master_code["code"] = build_code_from_naics3(master_code["naics"])

    checkpoints: list[dict[str, int | str]] = []

    # 1: 1:1 key/year with stock
    matched, unmatched, using_only = merge_stats(master, stock, ["key", "year"])
    checkpoints.append(
        {
            "step": "1",
            "merge": "1:1 key year with raw_stock_market",
            "master_rows_before": base_rows,
            "master_key_duplicate_groups": duplicate_key_groups(master, ["key", "year"]),
            "using_key_duplicate_groups": duplicate_key_groups(stock, ["key", "year"]),
            "master_null_join_key_rows": int(master[["key", "year"]].isna().any(axis=1).sum()),
            "using_null_join_key_rows": int(stock[["key", "year"]].isna().any(axis=1).sum()),
            "matched_master_rows": matched,
            "unmatched_master_rows": unmatched,
            "using_only_rows": using_only,
            "rows_after_drop_merge_eq_2": base_rows,
        }
    )

    # 2: m:1 code/year with BEA
    matched, unmatched, using_only = merge_stats(master_code, bea, ["code", "year"])
    checkpoints.append(
        {
            "step": "2",
            "merge": "m:1 code year with processed_bea_value_added",
            "master_rows_before": base_rows,
            "master_key_duplicate_groups": 0,
            "using_key_duplicate_groups": duplicate_key_groups(bea, ["code", "year"]),
            "master_null_join_key_rows": int(master_code[["code", "year"]].isna().any(axis=1).sum()),
            "using_null_join_key_rows": int(bea[["code", "year"]].isna().any(axis=1).sum()),
            "matched_master_rows": matched,
            "unmatched_master_rows": unmatched,
            "using_only_rows": using_only,
            "rows_after_drop_merge_eq_2": base_rows,
        }
    )

    # 3: m:1 sic/year with NBER
    matched, unmatched, using_only = merge_stats(master, nber, ["sic", "year"])
    checkpoints.append(
        {
            "step": "3",
            "merge": "m:1 sic year with processed_nber_exports",
            "master_rows_before": base_rows,
            "master_key_duplicate_groups": 0,
            "using_key_duplicate_groups": duplicate_key_groups(nber, ["sic", "year"]),
            "master_null_join_key_rows": int(master[["sic", "year"]].isna().any(axis=1).sum()),
            "using_null_join_key_rows": int(nber[["sic", "year"]].isna().any(axis=1).sum()),
            "matched_master_rows": matched,
            "unmatched_master_rows": unmatched,
            "using_only_rows": using_only,
            "rows_after_drop_merge_eq_2": base_rows,
        }
    )

    for idx, using_df, label in [
        ("4", bond, "raw_bond_yields"),
        ("5", ss, "raw_social_security_wage"),
        ("6", gdp, "processed_gdp"),
    ]:
        matched, unmatched, using_only = merge_stats(master, using_df, ["year"])
        checkpoints.append(
            {
                "step": idx,
                "merge": f"m:1 year with {label}",
                "master_rows_before": base_rows,
                "master_key_duplicate_groups": 0,
                "using_key_duplicate_groups": duplicate_key_groups(using_df, ["year"]),
                "master_null_join_key_rows": int(master[["year"]].isna().any(axis=1).sum()),
                "using_null_join_key_rows": int(using_df[["year"]].isna().any(axis=1).sum()),
                "matched_master_rows": matched,
                "unmatched_master_rows": unmatched,
                "using_only_rows": using_only,
                "rows_after_drop_merge_eq_2": base_rows,
            }
        )

    lines: list[str] = []
    lines.append("# Parity Checkpoints")
    lines.append("")
    lines.append("First-pass row-count parity diagnostics for the merge sequence in `code/stata/supporting/CreatingUniqueDataset.do`.")
    lines.append("")
    lines.append("## Baseline")
    lines.append("")
    lines.append(f"- `raw_compustat` rows: `{base_rows}`")
    lines.append(f"- `processed_alldata` rows (reference target): `{final_all_data_rows}`")
    lines.append("")
    lines.append("## Merge Diagnostics")
    lines.append("")
    lines.append("| Step | Merge | Master rows before | Matched master | Unmatched master | Using-only rows | Rows after drop `_merge==2` | Master dup key groups | Using dup key groups | Master null join keys | Using null join keys |")
    lines.append("|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|")
    for cp in checkpoints:
        lines.append(
            f"| {cp['step']} | {cp['merge']} | {cp['master_rows_before']} | {cp['matched_master_rows']} | {cp['unmatched_master_rows']} | {cp['using_only_rows']} | {cp['rows_after_drop_merge_eq_2']} | {cp['master_key_duplicate_groups']} | {cp['using_key_duplicate_groups']} | {cp['master_null_join_key_rows']} | {cp['using_null_join_key_rows']} |"
        )

    lines.append("")
    lines.append("## Notes")
    lines.append("")
    lines.append("- Drops of `_merge==2` remove using-only rows; master row count should remain constant.")
    lines.append("- This is a checkpoint report, not full variable-level parity yet.")
    lines.append("- Step 2 uses the exact NAICS3->code mapping from the Stata script.")

    OUT_PATH.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote {OUT_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
