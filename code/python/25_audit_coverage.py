#!/usr/bin/env python3
from __future__ import annotations

import re
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ALLDATA_DO = ROOT / "code" / "stata" / "AllData.do"
DB_PATH = ROOT / "data" / "cyclicality.db"
OUT_PATH = ROOT / "data" / "TRANSFORMATION_COVERAGE_AUDIT.md"

GEN_RE = re.compile(r"^\s*(gen|egen)\s+([A-Za-z_][A-Za-z0-9_]*)\s*=", re.IGNORECASE)
DROP_RE = re.compile(r"^\s*drop\s+if\s+(.+)$", re.IGNORECASE)


def main() -> int:
    raw_lines = ALLDATA_DO.read_text(encoding="utf-8", errors="ignore").splitlines()

    generated_vars: list[tuple[int, str, str]] = []
    drop_filters: list[tuple[int, str]] = []

    for i, line in enumerate(raw_lines, start=1):
        m = GEN_RE.match(line)
        if m:
            cmd, var = m.group(1).lower(), m.group(2)
            generated_vars.append((i, cmd, var.lower()))
            continue
        d = DROP_RE.match(line)
        if d:
            drop_filters.append((i, d.group(1).strip()))

    with sqlite3.connect(DB_PATH) as conn:
        cols = {row[1].lower() for row in conn.execute("PRAGMA table_info(processed_alldata)")}
        stage1_exists = conn.execute("SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='processed_alldata_stage1'").fetchone()[0] > 0
        stage1_cols = {row[1].lower() for row in conn.execute("PRAGMA table_info(processed_alldata_stage1)")} if stage1_exists else set()
        stage2_exists = conn.execute("SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='processed_alldata_stage2'").fetchone()[0] > 0
        stage2_cols = {row[1].lower() for row in conn.execute("PRAGMA table_info(processed_alldata_stage2)")} if stage2_exists else set()
        stage3_exists = conn.execute("SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='processed_alldata_stage3'").fetchone()[0] > 0
        stage3_cols = {row[1].lower() for row in conn.execute("PRAGMA table_info(processed_alldata_stage3)")} if stage3_exists else set()

    unique_gen_vars: list[str] = []
    seen = set()
    for _, _, v in generated_vars:
        if v not in seen:
            seen.add(v)
            unique_gen_vars.append(v)

    present = [v for v in unique_gen_vars if v in cols]
    missing = [v for v in unique_gen_vars if v not in cols]
    stage1_present = [v for v in unique_gen_vars if v in stage1_cols]
    stage1_missing = [v for v in unique_gen_vars if v not in stage1_cols]
    stage2_present = [v for v in unique_gen_vars if v in stage2_cols]
    stage2_missing = [v for v in unique_gen_vars if v not in stage2_cols]
    stage3_present = [v for v in unique_gen_vars if v in stage3_cols]
    stage3_missing = [v for v in unique_gen_vars if v not in stage3_cols]

    lines: list[str] = []
    lines.append("# Transformation Coverage Audit")
    lines.append("")
    lines.append("Audit of `code/stata/AllData.do` generated variables versus columns currently present in `processed_alldata`.")
    lines.append("")
    lines.append("## Summary")
    lines.append("")
    lines.append(f"- `gen/egen` statements found: `{len(generated_vars)}`")
    lines.append(f"- Unique generated variable names: `{len(unique_gen_vars)}`")
    lines.append(f"- Present in `processed_alldata`: `{len(present)}`")
    lines.append(f"- Missing from `processed_alldata`: `{len(missing)}`")
    lines.append("")
    pct = (100.0 * len(present) / len(unique_gen_vars)) if unique_gen_vars else 0.0
    lines.append(f"- Coverage ratio (processed_alldata): `{pct:.2f}%`")
    if stage1_cols:
        stage1_pct = (100.0 * len(stage1_present) / len(unique_gen_vars)) if unique_gen_vars else 0.0
        lines.append(f"- Coverage ratio (processed_alldata_stage1): `{stage1_pct:.2f}%`")
    if stage2_cols:
        stage2_pct = (100.0 * len(stage2_present) / len(unique_gen_vars)) if unique_gen_vars else 0.0
        lines.append(f"- Coverage ratio (processed_alldata_stage2): `{stage2_pct:.2f}%`")
    if stage3_cols:
        stage3_pct = (100.0 * len(stage3_present) / len(unique_gen_vars)) if unique_gen_vars else 0.0
        lines.append(f"- Coverage ratio (processed_alldata_stage3): `{stage3_pct:.2f}%`")
    lines.append("")

    lines.append("## Data Cleaning Filters in `AllData.do`")
    lines.append("")
    if drop_filters:
        lines.append("| Line | Filter |")
        lines.append("|---:|---|")
        for ln, expr in drop_filters:
            lines.append(f"| {ln} | `{expr}` |")
    else:
        lines.append("No `drop if` filters detected.")
    lines.append("")

    lines.append("## Generated Variables Present in `processed_alldata`")
    lines.append("")
    if present:
        lines.append(", ".join(f"`{v}`" for v in present))
    else:
        lines.append("None")
    lines.append("")

    lines.append("## Generated Variables Missing from `processed_alldata`")
    lines.append("")
    if missing:
        lines.append("| Variable | First `gen/egen` line |")
        lines.append("|---|---:|")
        first_line = {}
        for ln, _, v in generated_vars:
            first_line.setdefault(v, ln)
        for v in missing:
            lines.append(f"| `{v}` | {first_line[v]} |")
    else:
        lines.append("None")
    lines.append("")

    if stage1_cols:
        lines.append("## Stage 1 Coverage Delta")
        lines.append("")
        lines.append(f"- Present in `processed_alldata_stage1`: `{len(stage1_present)}`")
        lines.append(f"- Missing from `processed_alldata_stage1`: `{len(stage1_missing)}`")
        lines.append("")
    if stage2_cols:
        lines.append("## Stage 2 Coverage Delta")
        lines.append("")
        lines.append(f"- Present in `processed_alldata_stage2`: `{len(stage2_present)}`")
        lines.append(f"- Missing from `processed_alldata_stage2`: `{len(stage2_missing)}`")
        lines.append("")
    if stage3_cols:
        lines.append("## Stage 3 Coverage Delta")
        lines.append("")
        lines.append(f"- Present in `processed_alldata_stage3`: `{len(stage3_present)}`")
        lines.append(f"- Missing from `processed_alldata_stage3`: `{len(stage3_missing)}`")
        lines.append("")

    lines.append("## Interpretation")
    lines.append("")
    lines.append("- `processed_alldata` is currently a merged-source baseline and does not yet include most transformed variables from `AllData.do`.")
    lines.append("- Next parity stage should implement these transformations in Python and compare outputs variable-by-variable.")

    OUT_PATH.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote {OUT_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
