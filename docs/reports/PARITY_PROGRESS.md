# Parity Progress

Date: 2026-02-13

## Completed

- Implemented Stage-1 transformation pipeline from `AllData.do`:
  - `code/python/build_alldata_transform_stage1.py`
  - Outputs: `processed_alldata_stage1`, `data/TRANSFORMATION_STAGE1_REPORT.md`
- Implemented Stage-1 transformed-variable parity check:
  - `code/python/run_transformation_stage1_parity.py`
  - Output: `data/TRANSFORMATION_STAGE1_PARITY.md`
- Implemented Stage-2 transformation pipeline from `AllData.do` deterministic blocks:
  - `code/python/build_alldata_transform_stage2.py`
  - Outputs: `processed_alldata_stage2`, `data/TRANSFORMATION_STAGE2_REPORT.md`
- Implemented Stage-2 transformed-variable parity check:
  - `code/python/run_transformation_stage2_parity.py`
  - Output: `data/TRANSFORMATION_STAGE2_PARITY.md`
- Implemented Stage-3 transformation pipeline from deterministic tail blocks:
  - `code/python/build_alldata_transform_stage3.py`
  - Outputs: `processed_alldata_stage3`, `data/TRANSFORMATION_STAGE3_REPORT.md`
- Implemented Stage-3 transformed-variable parity check:
  - `code/python/run_transformation_stage3_parity.py`
  - Output: `data/TRANSFORMATION_STAGE3_PARITY.md`
- Implemented transformation coverage audit:
  - `code/python/audit_transformation_coverage.py`
  - Output: `data/TRANSFORMATION_COVERAGE_AUDIT.md`
- Implemented baseline acceptance gate report:
  - `code/python/generate_baseline_acceptance_report.py`
  - Output: `data/BASELINE_ACCEPTANCE_REPORT.md`
- Implemented merge-step checkpoint runner:
  - `code/python/run_parity_checkpoints.py`
  - Output: `data/PARITY_CHECKPOINTS.md`
- Implemented mapping integrity diagnostics:
  - `code/python/generate_mapping_integrity_report.py`
  - Output: `data/MAPPING_INTEGRITY_REPORT.md`
- Implemented variable-level merge parity checks:
  - `code/python/run_parity_variable_checks.py`
  - Output: `data/PARITY_VARIABLE_CHECKS.md`

## Result Summary

- Baseline acceptance status is currently **NO** (Gate A PASS, Gate B FAIL, Gate C PASS).
- Merge-step diagnostics mirror expected Stata merge behavior (using-only drops do not change master row count).
- Reconstructed merge outputs match `processed_alldata` exactly for tested merged variables (numeric diffs all zero under tolerance `1e-9`).
- Stage-1/2/3 transformed-variable parity checks pass for implemented blocks (all numeric diffs zero under tolerance `1e-9`).
- `AllData.do` generated-variable coverage is now `83.78%` in `processed_alldata_stage3` (310/370).
- Remaining blockers are non-deterministic/statistical Stata blocks (e.g., `gmm`, `tabulate ..., gen(...)`) and mapping-policy/documentation risks (one-to-many NAICS/SIC, null BEA join keys).

## Re-run Commands

```bash
cd /Users/pedro/Documents/Projects/papers/cyclicality
python3 code/python/run_parity_checkpoints.py
python3 code/python/generate_mapping_integrity_report.py
python3 code/python/run_parity_variable_checks.py
python3 code/python/audit_transformation_coverage.py
python3 code/python/generate_baseline_acceptance_report.py
python3 code/python/build_alldata_transform_stage1.py
python3 code/python/run_transformation_stage1_parity.py
python3 code/python/build_alldata_transform_stage2.py
python3 code/python/run_transformation_stage2_parity.py
python3 code/python/build_alldata_transform_stage3.py
python3 code/python/run_transformation_stage3_parity.py
```

## Next

1. Implement a Stage-4 policy layer for non-deterministic commands (`tabulate ..., gen(...)`, `gmm`) with explicit replication-vs-modernized modes.
2. Build a formal mapping-policy spec for NAICS/SIC at each aggregation level (2/3/4-digit) and codify tie-break/default rules.
3. Re-run acceptance after Stage-4 implementation and add a frozen parity snapshot.
