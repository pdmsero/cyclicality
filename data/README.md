# data/

## Primary data layer

`cyclicality.db` — the canonical SQLite database (3.1 GB). All Python pipeline
scripts read from and write to this file. See `DATA_DICTIONARY.md` for a full
description of the 416-column `processed_alldata_stage3` table and all other tables.

## Subdirectories

| Directory | Contents |
|---|---|
| `compustat/` | Raw Compustat extracts from WRDS (`AllCompustat.dta`, `sic5809.dta`). Requires WRDS credentials to refresh. |
| `crosswalks/` | SIC 1987 and NAICS 2002 code lists used to build `instrument_naics_sic_map` in the DB. |
| `industry/` | BEA industry accounts (CSV), NBER-CES manufacturing data, NSF R&D survey raw files, and one BLS XLSX. |
| `instruments/` | Raw inputs for IV instrument construction: BEA GDP/deflator XLS files, IO tables (see below), KLEMS data, exports data, and a MATLAB Leontief inverse (`ValueAddedInstrument.mat`). |
| `instruments/io_tables/` | Leontief inverse matrices. `IO{year}.csv` (1997–2013): headerless 134×67 legacy format. `IO{year}_api.csv` (2014–2024): BEA API summary format with headers (73×73 NAICS). Both are ingested into `cyclicality.db` via `code/python/04_ingest_io_tables.py`. |
| `processed/` | **Original Stata pipeline outputs — read-only replication baseline.** See `processed/README.md`. Not outputs of the Python pipeline. |

## Generated markdown reports

The following markdown files in this directory are **pipeline outputs**, not data.
They are written here by scripts 23–27 and document parity checks, coverage audits,
and baseline acceptance. They are candidates for relocation to `docs/reports/` in
a future cleanup pass (tracked in `CLEANUP_NOTES.md`).

| File | Written by |
|---|---|
| `BASELINE_ACCEPTANCE_REPORT.md` | `27_generate_baseline_report.py` |
| `BASELINE_SNAPSHOT.md` | `27_generate_baseline_report.py` |
| `DATA_DICTIONARY.md` | hand-maintained |
| `DATA_PROVENANCE_MAP.md` | `26_generate_mapping_report.py` |
| `MAPPING_INTEGRITY_REPORT.md` | `26_generate_mapping_report.py` |
| `PARITY_CHECKPOINTS.md` | `23_parity_checkpoints.py` |
| `PARITY_PROGRESS.md` | `23_parity_checkpoints.py` |
| `PARITY_VARIABLE_CHECKS.md` | `24_parity_variable_checks.py` |
| `TRANSFORMATION_COVERAGE_AUDIT.md` | `25_audit_coverage.py` |
| `TRANSFORMATION_STAGE{1,2,3}_PARITY.md` | `20–22_parity_stage*.py` |
| `TRANSFORMATION_STAGE{1,2,3}_REPORT.md` | `20–22_parity_stage*.py` |

## Literature scaffolding

`literature.db` and `literature.json` are empty scaffolding for a planned
literature-review tool (0 papers ingested). See `CLEANUP_NOTES.md`.
