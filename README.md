# Cyclicality of R&D at the Firm Level

Python replication and extension workspace for the paper.

## Project status (April 2026)

The Python pipeline fully replicates all paper results (Tables 9, 10, IV tables,
financial constraints, industry-level analysis, and Table 4 model simulation).
Public data sources have been refreshed to their latest vintages. Compustat is
the only remaining gap, pending WRDS credentials.

| Component | Status |
|---|---|
| SQLite conversion and ingestion | Complete |
| Python parity with Stata baseline | Complete |
| Public data refresh | Complete (BEA, BLS, SSA, FRED through 2024/2026) |
| IO tables | Complete (legacy 1997–2013 + BEA API 2014–2024) |
| Compustat refresh | Blocked — requires WRDS credentials |

## Repository layout

```
code/
  python/       Numbered pipeline scripts (01–40) + model/ subpackage
  stata/        Original Stata scripts used in the paper
  r/            Original R extraction scripts (superseded by Python pipeline)
  dynare/       Dynare model files

data/
  cyclicality.db          Canonical SQLite database (3.1 GB)
  processed/              Original Stata baseline outputs (read-only; see processed/README.md)
  compustat/              WRDS Compustat extracts
  industry/               BEA, NBER-CES, NSF raw files
  instruments/            IV instrument inputs (IO tables, KLEMS, exports, BEA deflators)
  crosswalks/             SIC/NAICS code lists
  DATA_DICTIONARY.md      Full column-level documentation of cyclicality.db
  DATA_PROVENANCE_MAP.md  Source-family mapping and confidence levels

results/                  Regression output tables (xlsx + md) and figures
paper/                    LaTeX source and original figures
docs/                     Data source notes and NSF codebook
archive/                  Archived legacy material (see archive/r_project/README.md)
```

## Running the pipeline

```bash
pip install -r requirements.txt

# Transform + analysis only (default — skips ingestion)
python3 run_pipeline.py

# Full pipeline including data ingestion
python3 run_pipeline.py --include-ingestion

# Specific scripts
python3 run_pipeline.py --only 30 31

# Print pipeline stages
python3 run_pipeline.py --list
```

## Environment / API keys

Copy `.env.example` to `.env` and fill in your keys (never commit `.env`):

```
FRED_API_KEY=...     # https://fred.stlouisfed.org/docs/api/api_key.html
BEA_API_KEY=...      # https://apps.bea.gov/API/signup/
```

These are used by `08_refresh_macro_data.py` (FRED bond yields) and
`04_ingest_io_tables.py --api-years` (BEA IO tables).

## Data sources

- Compustat (WRDS)
- NBER-CES manufacturing dataset
- BEA industry accounts and NIPA (GDP, value-added, deflators)
- BLS QCEW wage data
- SSA average wage index
- FRED (bond yields)
- NSF R&D survey
- Census SIC/NAICS concordances

See `data/DATA_PROVENANCE_MAP.md` for source-level detail, confidence ratings,
and format notes. See `data/DATA_DICTIONARY.md` for column-level documentation.

## Parity and validation

Scripts 20–27 run parity checks against the Stata baseline outputs in
`data/processed/`. Generated reports are written to `data/` (see `data/README.md`).
The baseline acceptance report is at `data/BASELINE_ACCEPTANCE_REPORT.md`.
