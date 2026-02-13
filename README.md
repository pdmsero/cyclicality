# Cyclicality of R&D at the Firm Level

This repository is the local replication and Python-port workspace for the paper.

## Current Operating Mode

- Baseline-first workflow: reproduce existing results with fixed vintages before any data refresh.
- Canonical data layer: `data/cyclicality.db`.
- Original source files are retained in `data/` for verification and auditability.

## Project Status (as of 2026-02-12)

- SQLite conversion completed and verified (`meta_verification_log` failures = 0).
- Provenance map created at `data/DATA_PROVENANCE_MAP.md`.
- Next focus: Python parity with baseline Stata outputs.

## Repository Layout

- `code/stata/`: original Stata scripts used in the paper pipeline.
- `code/python/convert_to_sqlite.py`: conversion script from source files to SQLite.
- `data/cyclicality.db`: unified SQLite database for analysis.
- `DATA_MANAGEMENT_PLAN.md`: execution strategy and phases.
- `REPLICATION_CHECKLIST.md`: operational checklist for baseline parity and refresh.
- `ANALYSIS_PLAN.md`: analysis sequencing and validation priorities.

## Data Sources (high level)

- Compustat (WRDS)
- NBER-CES manufacturing datasets
- BEA industry and NIPA data
- FRED macro/interest rate series
- SSA AWI
- Census concordances (NAICS/SIC)

See `data/DATA_PROVENANCE_MAP.md` for detailed source-family mapping, confidence levels, and format notes.

## Baseline-First Rule

Do not refresh to newer vintages until all of the following are true:

1. Conversion integrity checks pass.
2. Python outputs match baseline Stata outputs for target tables/figures.
3. Baseline snapshot and provenance are documented.

## Notes

- NSF modernization remains deferred unless needed for a target output.
- Use `DATA_MANAGEMENT_PLAN.md` as the source of truth for execution order.
