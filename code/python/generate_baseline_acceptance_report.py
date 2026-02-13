#!/usr/bin/env python3
from __future__ import annotations

import re
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DB_PATH = ROOT / "data" / "cyclicality.db"
OUT_PATH = ROOT / "data" / "BASELINE_ACCEPTANCE_REPORT.md"
ALLDATA_DO = ROOT / "code" / "stata" / "AllData.do"
PARITY_VAR_MD = ROOT / "data" / "PARITY_VARIABLE_CHECKS.md"

GEN_RE = re.compile(r"^\s*(gen|egen)\s+([A-Za-z_][A-Za-z0-9_]*)\s*=", re.IGNORECASE)


def parse_parity_var_failures(path: Path) -> int:
    text = path.read_text(encoding="utf-8", errors="ignore")
    # numeric parity table lines end with |> tol count |
    fail_counts = []
    for line in text.splitlines():
        if line.startswith("| `") and line.count("|") >= 7:
            parts = [p.strip() for p in line.strip().strip("|").split("|")]
            if len(parts) >= 6 and parts[-1].isdigit():
                fail_counts.append(int(parts[-1]))
    return sum(fail_counts)


def transformation_coverage(conn: sqlite3.Connection) -> tuple[int, int, int, int, int, int]:
    cols = {row[1].lower() for row in conn.execute("PRAGMA table_info(processed_alldata)")}
    gen_vars = []
    for line in ALLDATA_DO.read_text(encoding="utf-8", errors="ignore").splitlines():
        m = GEN_RE.match(line)
        if m:
            gen_vars.append(m.group(2).lower())
    unique = []
    seen = set()
    for v in gen_vars:
        if v not in seen:
            seen.add(v)
            unique.append(v)
    present = sum(1 for v in unique if v in cols)
    stage1_cols = {row[1].lower() for row in conn.execute("PRAGMA table_info(processed_alldata_stage1)")} if conn.execute("SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='processed_alldata_stage1'").fetchone()[0] else set()
    stage2_cols = {row[1].lower() for row in conn.execute("PRAGMA table_info(processed_alldata_stage2)")} if conn.execute("SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='processed_alldata_stage2'").fetchone()[0] else set()
    stage3_cols = {row[1].lower() for row in conn.execute("PRAGMA table_info(processed_alldata_stage3)")} if conn.execute("SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='processed_alldata_stage3'").fetchone()[0] else set()
    stage1_present = sum(1 for v in unique if v in stage1_cols)
    stage2_present = sum(1 for v in unique if v in stage2_cols)
    stage3_present = sum(1 for v in unique if v in stage3_cols)
    missing = len(unique) - present
    return len(unique), present, missing, stage1_present, stage2_present, stage3_present


def exists(path: Path) -> bool:
    return path.exists()


def main() -> int:
    with sqlite3.connect(DB_PATH) as conn:
        verify_failures = int(conn.execute("SELECT COUNT(*) FROM meta_verification_log WHERE passed=0").fetchone()[0])
        raw_comp = int(conn.execute("SELECT COUNT(*) FROM raw_compustat").fetchone()[0])
        proc_all = int(conn.execute("SELECT COUNT(*) FROM processed_alldata").fetchone()[0])
        unique_gen, present_gen, missing_gen, stage1_present_gen, stage2_present_gen, stage3_present_gen = transformation_coverage(conn)

    parity_tol_fail = parse_parity_var_failures(PARITY_VAR_MD)
    stage1_parity_path = ROOT / "data" / "TRANSFORMATION_STAGE1_PARITY.md"
    stage1_parity_fail = parse_parity_var_failures(stage1_parity_path) if stage1_parity_path.exists() else -1

    gate_a = (verify_failures == 0 and raw_comp == 455830 and proc_all == 455830)
    gate_b_merge = (parity_tol_fail == 0)
    gate_b_transform = (missing_gen == 0)
    stage2_parity_path = ROOT / "data" / "TRANSFORMATION_STAGE2_PARITY.md"
    stage2_parity_fail = parse_parity_var_failures(stage2_parity_path) if stage2_parity_path.exists() else -1
    stage3_parity_path = ROOT / "data" / "TRANSFORMATION_STAGE3_PARITY.md"
    stage3_parity_fail = parse_parity_var_failures(stage3_parity_path) if stage3_parity_path.exists() else -1
    gate_b_stage1 = (stage1_parity_fail == 0 and stage1_present_gen >= present_gen)
    gate_b_stage2 = (stage2_parity_fail == 0 and stage2_present_gen >= stage1_present_gen)
    gate_b_stage3 = (stage3_parity_fail == 0 and stage3_present_gen >= stage2_present_gen)
    gate_b = gate_b_merge and gate_b_transform
    gate_c = all(
        exists(ROOT / p)
        for p in [
            Path("data/DATA_PROVENANCE_MAP.md"),
            Path("data/BASELINE_SNAPSHOT.md"),
            Path("data/PARITY_CHECKPOINTS.md"),
            Path("data/PARITY_VARIABLE_CHECKS.md"),
            Path("data/MAPPING_INTEGRITY_REPORT.md"),
        ]
    )

    accepted = gate_a and gate_b and gate_c

    lines = []
    lines.append("# Baseline Acceptance Report")
    lines.append("")
    lines.append("Date: 2026-02-12")
    lines.append("")
    lines.append("## Decision")
    lines.append("")
    lines.append(f"- Baseline accepted: `{'YES' if accepted else 'NO'}`")
    lines.append("")
    lines.append("## Gate Status")
    lines.append("")
    lines.append(f"- Gate A (data layer integrity): `{'PASS' if gate_a else 'FAIL'}`")
    lines.append(f"- Gate B (Stata -> Python baseline parity): `{'PASS' if gate_b else 'FAIL'}`")
    lines.append(f"- Gate C (baseline documentation): `{'PASS' if gate_c else 'FAIL'}`")
    lines.append("")

    lines.append("## Evidence")
    lines.append("")
    lines.append(f"- Verification failures (`meta_verification_log passed=0`): `{verify_failures}`")
    lines.append(f"- `raw_compustat` row count: `{raw_comp}`")
    lines.append(f"- `processed_alldata` row count: `{proc_all}`")
    lines.append(f"- Merge-variable parity numeric tolerance failures: `{parity_tol_fail}`")
    lines.append(f"- Stage-1 transformed-variable parity failures: `{stage1_parity_fail}`")
    lines.append(f"- Stage-2 transformed-variable parity failures: `{stage2_parity_fail}`")
    lines.append(f"- Stage-3 transformed-variable parity failures: `{stage3_parity_fail}`")
    lines.append(f"- `AllData.do` unique generated variables: `{unique_gen}`")
    lines.append(f"- Generated vars present in `processed_alldata`: `{present_gen}`")
    lines.append(f"- Generated vars present in `processed_alldata_stage1`: `{stage1_present_gen}`")
    lines.append(f"- Generated vars present in `processed_alldata_stage2`: `{stage2_present_gen}`")
    lines.append(f"- Generated vars present in `processed_alldata_stage3`: `{stage3_present_gen}`")
    lines.append(f"- Generated vars missing from `processed_alldata`: `{missing_gen}`")
    lines.append("")

    lines.append("## Interpretation")
    lines.append("")
    if gate_a:
        lines.append("- Gate A passes: SQLite conversion and baseline row-count checks are clean.")
    else:
        lines.append("- Gate A fails: resolve conversion integrity issues before parity work continues.")

    if gate_b_merge:
        lines.append("- Merge-level parity checks pass for tested merged variables.")
    else:
        lines.append("- Merge-level parity checks fail and must be fixed before acceptance.")

    if gate_b_stage1:
        lines.append("- Stage-1 transformation parity checks pass for implemented variables.")
    if gate_b_stage2:
        lines.append("- Stage-2 transformation parity checks pass for implemented variables.")
    if gate_b_stage3:
        lines.append("- Stage-3 transformation parity checks pass for implemented variables.")
    if not gate_b_transform:
        lines.append("- Transformation parity is incomplete: most `AllData.do` generated variables are not implemented in the Python baseline yet.")

    if gate_c:
        lines.append("- Gate C documentation artifacts are present.")
    else:
        lines.append("- Gate C documentation is incomplete.")

    lines.append("")
    lines.append("## Required Actions Before Acceptance")
    lines.append("")
    if accepted:
        lines.append("- No blocking actions. Baseline is accepted.")
    else:
        lines.append("1. Implement `AllData.do` transformation layer in Python.")
        lines.append("2. Produce variable-level parity checks for transformed variables.")
        lines.append("3. Re-run this acceptance report after transformation parity checks.")

    OUT_PATH.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote {OUT_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
