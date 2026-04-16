# Data Provenance Map (Verified + Inferred)

Date prepared: 2026-02-12

This map combines:
- local repo lineage (`code/stata/*.do`, file names, `meta_sources`), and
- official online source pages.

## How to read this
- **Confirmed**: directly evidenced by local scripts and/or explicit source pages.
- **Inferred**: highly likely based on naming/variables, but not explicitly documented in this repo.
- **Unknown**: local artifact source not yet documented.

## Source Families

| Local data family | SQLite tables (examples) | Likely original source | Download formats at source | `.dta` native from source? | Confidence |
|---|---|---|---|---|---|
| Compustat firm panel | `raw_compustat`, `processed_compustat`, `processed_alldata` | S&P Compustat via WRDS | WRDS query exports (often CSV/SAS pull; user-defined extract) | **Usually no** official packaged `.dta`; `.dta` often researcher export/conversion | Confirmed |
| NBER-CES manufacturing database | `raw_nber_exports`, `raw_nber_ces`, `raw_nber_mp_naics`, `raw_nber_mp_sic`, `processed_nber_exports` | NBER-CES Manufacturing Industry Database (Census/BLS/BEA inputs) | Stata, SAS, Excel, CSV | **Yes** | Confirmed |
| BEA industry accounts (value added/deflators/output) | `raw_bea_value_added`, `processed_bea_value_added`, `raw_bea_csv_*`, many `raw_bea_section1_*` | BEA Industry Economic Accounts / GDP-by-Industry / IO data | CSV/XLS/XLSX/ZIP/API | **No official Stata package**; local `.dta` likely transformed | Confirmed |
| BEA NIPA macro tables | `raw_gdp`, `processed_gdp`, `instrument_bea_gdp`, `instrument_bea_deflators_gdp` | BEA NIPA (e.g., tables 1.5.4, 1.5.5 per README) | CSV/XLS/XLSX/API | **No official Stata package** | Confirmed |
| Interest rates / bond yields | `raw_bond_yields` | FRED (Moody's AAA/BAA and Treasury bill series) | CSV/API | **No** | Inferred |
| Social Security wage index | `raw_social_security_wage` | SSA Average Wage Index (AWI) | HTML/table download/scrape | **No** | Inferred |
| NAICS/SIC and BEA code mappings | `lookup_naics_to_sic`, `lookup_codes_naics_sic`, `lookup_bea_naics_two_digit`, `lookup_bea_naics_three_digit`, `lookup_two_digit_bea_naics` | Census NAICS/SIC concordances + project-specific BEA concordances | XLS/XLSX (official concordances) | **No official Stata package**; local `.dta` likely transformed/manual curation | Confirmed (family), inferred (exact build steps) |
| Export instrument annual files | `instrument_exports` | Likely historical industry export files (possibly NBER/Census-derived extracts) | Often CSV/XLS at source | Unknown | Inferred |
| IO instrument files | `instrument_io_tables` (from `.numbers`) | BEA Input-Output accounts | XLS/CSV/ZIP/API at source; local files are Apple Numbers | **No** | Inferred |
| KLEMS instrument files | `instrument_klems_*` | BEA-BLS Integrated Industry-Level Production Account (KLEMS) (or project-curated KLEMS extract) | XLSX at BEA | **No official Stata package**; local `.dta` likely transformed | Inferred |
| NSF raw archive | (deferred from SQLite main run) `data/industry/nsf_raw/*.xls` | NSF NCSES tables (historical R&D/statistical tables) | XLS/XLSX/PDF | **No** | Confirmed |
| Stock market merge inputs | `raw_stock_market` | Could be WRDS/CRSP/Compustat-derived project extract | Varies | Unknown | Unknown |
| MATLAB instrument | `instrument_value_added_mat` | Project-generated or externally provided matrix artifact | `.mat` | N/A | Unknown |

## Key online evidence (official pages)

- WRDS vendor page listing S&P Compustat availability via WRDS:
  - https://wrds-www.wharton.upenn.edu/pages/about/data-vendors/sp-global-market-intelligence/
- NBER-CES Manufacturing Industry Database (explicit Stata/SAS/Excel/CSV links + concordances):
  - https://www.nber.org/research/data/nber-ces-manufacturing-industry-database
- BEA Open Data formats (CSV/XLS/ZIP/API):
  - https://www.bea.gov/open-data
- BEA Industry Economic Accounts:
  - https://www.bea.gov/data/economic-accounts/industry
- BEA Input-Output Accounts data:
  - https://www.bea.gov/data/industries/input-output-accounts-data
- BEA Integrated Industry-Level Production Account (KLEMS):
  - https://www.bea.gov/products/integrated-industry-level-production-account-klems
- Census NAICS concordances (includes SIC-to-NAICS and NAICS-to-SIC concordances):
  - https://www.census.gov/naics/concordances/concordances.html
- SSA Average Wage Index (AWI):
  - https://www.ssa.gov/oact/COLA/awidevelop.html
- FRED Moody's BAA:
  - https://fred.stlouisfed.org/series/BAA
- FRED Moody's AAA:
  - https://fred.stlouisfed.org/series/AAA
- FRED 3-Month Treasury Bill (monthly):
  - https://fred.stlouisfed.org/series/TB3MS
- NSF NCSES National Patterns (example collection landing):
  - https://ncses.nsf.gov/data-collections/national-patterns

## What this implies about `.dta`

- **Likely native `.dta` from external source**: NBER-CES files (source explicitly offers Stata downloads).
- **Likely researcher-converted to `.dta`**: BEA, Census concordances, FRED/SSA, KLEMS (official sources mainly provide CSV/XLS/XLSX/API, not Stata bundles).
- **Potentially researcher-exported `.dta` from licensed platform**: Compustat/other WRDS pulls.

## Remaining provenance gaps to close

1. `raw_stock_market` exact origin (CRSP vs Compustat market module vs other).
2. `instrument_exports` exact upstream dataset URL and transformation script.
3. `instrument_value_added_mat` generation method and script provenance.
4. Exact script lineage for `lookup_*` build (some mapping logic exists in Stata scripts, but not full end-to-end documented).

