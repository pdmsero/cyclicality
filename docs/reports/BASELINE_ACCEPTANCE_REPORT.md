# Baseline Acceptance Report

Date: 2026-04-09

## Decision

- Baseline accepted: `YES`

## Gate Status

- Gate A  (data layer integrity): `PASS`
- Gate B1 (merge logic parity — parity-comparable variables only): `PASS`
- Gate B2 (transformation coverage — all AllData.do vars implemented): `PASS`
- Gate C  (baseline documentation): `PASS`

  Note: Bond yield series (gov_b, aaa, baa, etc.) were refreshed via FRED API.
  Their value differences from the Stata baseline reflect data-vintage differences, not code errors.
  They are excluded from Gate B1 (see PARITY_VARIABLE_CHECKS.md Refreshed Data section).

## Evidence

- Verification failures (`meta_verification_log passed=0`): `0`
- `raw_compustat` row count: `455830`
- `processed_alldata` row count: `455830`
- Merge-variable parity numeric tolerance failures: `0`
- Stage-1 transformed-variable parity failures: `0`
- Stage-2 transformed-variable parity failures: `0`
- Stage-3 transformed-variable parity failures: `0`
- `AllData.do` unique generated variables: `370`
- Generated vars present in `processed_alldata`: `2`
- Generated vars present in `processed_alldata_stage1`: `131`
- Generated vars present in `processed_alldata_stage2`: `302`
- Generated vars present in `processed_alldata_stage3`: `310`
- Generated vars present in `processed_alldata_stage4`: `79`
- Generated vars missing from pipeline (all stages): `0`

## Interpretation

- Gate A passes: SQLite conversion and baseline row-count checks are clean.
- Gate B1 passes: all parity-comparable merge variables match within tolerance.
- Bond yield series (refreshed from FRED) are excluded from Gate B1; differences are data-vintage, not code errors.
- Stage-1 transformation parity checks pass for implemented variables.
- Stage-2 transformation parity checks pass for implemented variables.
- Stage-3 transformation parity checks pass for implemented variables.
- Gate C documentation artifacts are present.

## Required Actions Before Acceptance

- No blocking actions. Baseline is accepted.
