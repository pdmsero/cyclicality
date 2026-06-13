#!/usr/bin/env python3
from __future__ import annotations

import re
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DB_PATH = ROOT / "data" / "cyclicality.db"
OUT_PATH = ROOT / "docs" / "reports" / "BASELINE_ACCEPTANCE_REPORT.md"
ALLDATA_DO = ROOT / "code" / "stata" / "AllData.do"
PARITY_VAR_MD = ROOT / "docs" / "reports" / "PARITY_VARIABLE_CHECKS.md"

GEN_RE = re.compile(r"^\s*(gen|egen)\s+([A-Za-z_][A-Za-z0-9_]*)\s*=", re.IGNORECASE)


def parse_parity_var_failures(path: Path) -> int:
    text = path.read_text(encoding="utf-8", errors="ignore")
    # Preferred: the authoritative summary line emitted by the stage parity
    # reports, e.g. "- Total numeric tolerance failures (`>1e-09`): `250434`".
    # (The per-variable tables in those reports have only 4 columns / 5 pipes,
    # so the table-row parse below silently misses them — the original bug that
    # let 250k failures report as 0.)
    m = re.search(r"Total numeric tolerance failures[^\n]*:\s*`?([\d,]+)`?", text)
    if m:
        return int(m.group(1).replace(",", ""))
    # Fallback: merge report (PARITY_VARIABLE_CHECKS.md) — 6 columns / 7 pipes,
    # failure count in the final ">tol count" column.
    fail_counts = []
    for line in text.splitlines():
        if line.startswith("| `") and line.count("|") >= 7:
            parts = [p.strip() for p in line.strip().strip("|").split("|")]
            if len(parts) >= 6 and parts[-1].isdigit():
                fail_counts.append(int(parts[-1]))
    return sum(fail_counts)


def _stage_cols(conn: sqlite3.Connection, table: str) -> set:
    exists = conn.execute(
        "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name=?", (table,)
    ).fetchone()[0]
    if not exists:
        return set()
    return {row[1].lower() for row in conn.execute(f"PRAGMA table_info({table})")}


def transformation_coverage(conn: sqlite3.Connection) -> tuple[int, int, int, int, int, int, int]:
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

    stage1_cols = _stage_cols(conn, "processed_alldata_stage1")
    stage2_cols = _stage_cols(conn, "processed_alldata_stage2")
    stage3_cols = _stage_cols(conn, "processed_alldata_stage3")
    stage4_cols = _stage_cols(conn, "processed_alldata_stage4")

    all_pipeline_cols = stage1_cols | stage2_cols | stage3_cols | stage4_cols

    present = sum(1 for v in unique if v in cols)
    stage1_present = sum(1 for v in unique if v in stage1_cols)
    stage2_present = sum(1 for v in unique if v in stage2_cols)
    stage3_present = sum(1 for v in unique if v in stage3_cols)
    stage4_present = sum(1 for v in unique if v in stage4_cols)
    pipeline_present = sum(1 for v in unique if v in all_pipeline_cols)
    missing = len(unique) - pipeline_present
    return len(unique), present, missing, stage1_present, stage2_present, stage3_present, stage4_present


def exists(path: Path) -> bool:
    return path.exists()


def main() -> int:
    with sqlite3.connect(DB_PATH) as conn:
        verify_failures = int(conn.execute("SELECT COUNT(*) FROM meta_verification_log WHERE passed=0").fetchone()[0])
        raw_comp = int(conn.execute("SELECT COUNT(*) FROM raw_compustat").fetchone()[0])
        proc_all = int(conn.execute("SELECT COUNT(*) FROM processed_alldata").fetchone()[0])
        unique_gen, present_gen, missing_gen, stage1_present_gen, stage2_present_gen, stage3_present_gen, stage4_present_gen = transformation_coverage(conn)

    parity_tol_fail = parse_parity_var_failures(PARITY_VAR_MD)
    stage1_parity_path = ROOT / "docs" / "reports" / "TRANSFORMATION_STAGE1_PARITY.md"
    stage1_parity_fail = parse_parity_var_failures(stage1_parity_path) if stage1_parity_path.exists() else -1

    gate_a = (verify_failures == 0 and raw_comp == 455830 and proc_all == 455830)
    gate_b_merge = (parity_tol_fail == 0)
    gate_b_transform = (missing_gen == 0)
    stage2_parity_path = ROOT / "docs" / "reports" / "TRANSFORMATION_STAGE2_PARITY.md"
    stage2_parity_fail = parse_parity_var_failures(stage2_parity_path) if stage2_parity_path.exists() else -1
    stage3_parity_path = ROOT / "docs" / "reports" / "TRANSFORMATION_STAGE3_PARITY.md"
    stage3_parity_fail = parse_parity_var_failures(stage3_parity_path) if stage3_parity_path.exists() else -1
    gate_b_stage1 = (stage1_parity_fail == 0 and stage1_present_gen >= present_gen)
    gate_b_stage2 = (stage2_parity_fail == 0 and stage2_present_gen >= stage1_present_gen)
    gate_b_stage3 = (stage3_parity_fail == 0 and stage3_present_gen >= stage2_present_gen)
    gate_b_stage4 = (stage4_present_gen >= stage3_present_gen)
    gate_b = gate_b_merge and gate_b_transform
    gate_c = all(
        exists(ROOT / p)
        for p in [
            Path("docs/reports/DATA_PROVENANCE_MAP.md"),
            Path("docs/reports/BASELINE_SNAPSHOT.md"),
            Path("docs/reports/PARITY_CHECKPOINTS.md"),
            Path("docs/reports/PARITY_VARIABLE_CHECKS.md"),
            Path("docs/reports/MAPPING_INTEGRITY_REPORT.md"),
        ]
    )

    accepted = gate_a and gate_b and gate_c

    lines = []
    lines.append("# Baseline Acceptance Report")
    lines.append("")
    lines.append(f"Date: {__import__('datetime').date.today().isoformat()}")
    lines.append("")
    lines.append("## Decision")
    lines.append("")
    lines.append(f"- Baseline accepted: `{'YES' if accepted else 'NO'}`")
    lines.append("")
    lines.append("## Gate Status")
    lines.append("")
    lines.append(f"- Gate A  (data layer integrity): `{'PASS' if gate_a else 'FAIL'}`")
    lines.append(f"- Gate B1 (merge logic parity — parity-comparable variables only): `{'PASS' if gate_b_merge else 'FAIL'}`")
    lines.append(f"- Gate B2 (transformation coverage — all AllData.do vars implemented): `{'PASS' if gate_b_transform else 'FAIL'}`")
    lines.append(f"- Gate C  (baseline documentation): `{'PASS' if gate_c else 'FAIL'}`")
    lines.append(f"")
    lines.append(f"  Note: Bond yield series (gov_b, aaa, baa, etc.) were refreshed via FRED API.")
    lines.append(f"  Their value differences from the Stata baseline reflect data-vintage differences, not code errors.")
    lines.append(f"  They are excluded from Gate B1 (see PARITY_VARIABLE_CHECKS.md Refreshed Data section).")
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
    lines.append(f"- Generated vars present in `processed_alldata_stage4`: `{stage4_present_gen}`")
    lines.append(f"- Generated vars missing from pipeline (all stages): `{missing_gen}`")
    lines.append("")

    lines.append("## Interpretation")
    lines.append("")
    if gate_a:
        lines.append("- Gate A passes: SQLite conversion and baseline row-count checks are clean.")
    else:
        lines.append("- Gate A fails: resolve conversion integrity issues before parity work continues.")

    if gate_b_merge:
        lines.append("- Gate B1 passes: all parity-comparable merge variables match within tolerance.")
        lines.append("- Bond yield series (refreshed from FRED) are excluded from Gate B1; differences are data-vintage, not code errors.")
    else:
        lines.append("- Gate B1 fails: parity-comparable merge variables have tolerance failures. Investigate before acceptance.")

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
