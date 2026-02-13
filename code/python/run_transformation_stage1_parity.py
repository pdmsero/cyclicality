#!/usr/bin/env python3
from __future__ import annotations

import sqlite3
from pathlib import Path
import warnings

import numpy as np
import pandas as pd

from build_alldata_transform_stage1 import transform_stage1

ROOT = Path(__file__).resolve().parents[2]
DB_PATH = ROOT / "data" / "cyclicality.db"
REPORT_PATH = ROOT / "data" / "TRANSFORMATION_STAGE1_PARITY.md"
TOL = 1e-9


def numeric_diff(a: pd.Series, b: pd.Series) -> tuple[int, float, float]:
    aa = pd.to_numeric(a, errors="coerce")
    bb = pd.to_numeric(b, errors="coerce")
    both_nonnull = aa.notna() & bb.notna()
    if not both_nonnull.any():
        return 0, float("nan"), float("nan")
    diff = (aa[both_nonnull] - bb[both_nonnull]).abs()
    return int((diff > TOL).sum()), float(diff.max()), float(diff.mean())


def main() -> int:
    warnings.simplefilter("ignore", category=pd.errors.PerformanceWarning)
    with sqlite3.connect(DB_PATH) as conn:
        base = pd.read_sql_query("SELECT * FROM processed_alldata", conn)
        stage = pd.read_sql_query("SELECT * FROM processed_alldata_stage1", conn)

    recomputed, generated, _, _, _ = transform_stage1(base.copy())

    sort_cols = [c for c in ["key", "year", "gvkey", "datadate"] if c in recomputed.columns and c in stage.columns]
    if sort_cols:
        recomputed = recomputed.sort_values(sort_cols, kind="mergesort").reset_index(drop=True)
        stage = stage.sort_values(sort_cols, kind="mergesort").reset_index(drop=True)
    else:
        recomputed = recomputed.reset_index(drop=True)
        stage = stage.reset_index(drop=True)

    row_match = len(recomputed) == len(stage)

    common_generated = [c for c in generated if c in recomputed.columns and c in stage.columns]
    missing_in_stage = [c for c in generated if c not in stage.columns]

    per_var: list[tuple[str, int, float, float]] = []
    total_fail = 0
    for col in common_generated:
        fail, maxd, meand = numeric_diff(recomputed[col], stage[col])
        per_var.append((col, fail, maxd, meand))
        total_fail += fail

    lines: list[str] = []
    lines.append("# Transformation Stage 1 Parity")
    lines.append("")
    lines.append("Parity check between recomputed Stage-1 transforms and stored `processed_alldata_stage1` table.")
    lines.append("")
    lines.append("## Summary")
    lines.append("")
    lines.append(f"- Row count recomputed: `{len(recomputed)}`")
    lines.append(f"- Row count stored: `{len(stage)}`")
    lines.append(f"- Row count match: `{'YES' if row_match else 'NO'}`")
    lines.append(f"- Generated variables expected: `{len(generated)}`")
    lines.append(f"- Generated variables present in stored table: `{len(common_generated)}`")
    lines.append(f"- Missing generated variables in stored table: `{len(missing_in_stage)}`")
    lines.append(f"- Total numeric tolerance failures (`>{TOL}`): `{total_fail}`")
    lines.append("")

    if missing_in_stage:
        lines.append("## Missing Generated Variables")
        lines.append("")
        lines.append(", ".join(f"`{c}`" for c in missing_in_stage))
        lines.append("")

    lines.append("## Per-Variable Numeric Parity")
    lines.append("")
    lines.append("| Variable | >tol count | Max abs diff | Mean abs diff |")
    lines.append("|---|---:|---:|---:|")
    for col, fail, maxd, meand in per_var:
        maxs = "nan" if np.isnan(maxd) else f"{maxd:.6g}"
        means = "nan" if np.isnan(meand) else f"{meand:.6g}"
        lines.append(f"| `{col}` | {fail} | {maxs} | {means} |")

    REPORT_PATH.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote {REPORT_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
