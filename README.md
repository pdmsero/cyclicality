# Cyclicality of R&D at the Firm Level: Replicating the Working Paper Analysis

## Data Sources

- **Nominal Values:**  
  **Table 1.5.5. Gross Domestic Product, Expanded Detail**  
  [Billions of dollars]  
  [Last Revised: June 26, 2025 – Next Release: July 30, 2025]  
  [BEA Table 1.5.5 Source](https://apps.bea.gov/iTable/?reqid=19&step=2&isuri=1&categories=survey&_gl=1*kfq9yj*_ga*MzgzNzk3NjcyLjE3NTE0MTI1ODA.*_ga_J4698JNNFT*czE3NTE0MTI1ODAkbzEkZzEkdDE3NTE0MTI1OTQkajQ2JGwwJGgw#eyJhcHBpZCI6MTksInN0ZXBzIjpbMSwyLDMsM10sImRhdGEiOltbImNhdGVnb3JpZXMiLCJTdXJ2ZXkiXSxbIk5JUEFfVGFibGVfTGlzdCIsIjM1Il0sWyJGaXJzdF9ZZWFyIiwiMjAyMyJdLFsiTGFzdF9ZZWFyIiwiMjAyNSJdLFsiU2NhbGUiLCItOSJdLFsiU2VyaWVzIiwiQSJdLFsiU2VsZWN0X2FsbF95ZWFycyIsIjEiXV19)

- **Price Indices:**  
  **Table 1.5.4. Price Indexes for Gross Domestic Product, Expanded Detail**  
  [Index numbers, 2017=100]  
  [Last Revised: June 26, 2025 – Next Release: July 30, 2025]  
  [BEA Table 1.5.4 Source](https://apps.bea.gov/iTable/?reqid=19&step=2&isuri=1&categories=survey&_gl=1*kfq9yj*_ga*MzgzNzk3NjcyLjE3NTE0MTI1ODA.*_ga_J4698JNNFT*czE3NTE0MTI1ODAkbzEkZzEkdDE3NTE0MTI1OTQkajQ2JGwwJGgw#eyJhcHBpZCI6MTksInN0ZXBzIjpbMSwyLDMsM10sImRhdGEiOltbImNhdGVnb3JpZXMiLCJTdXJ2ZXkiXSxbIk5JUEFfVGFibGVfTGlzdCIsIjM1Il0sWyJGaXJzdF9ZZWFyIiwiMjAyMyJdLFsiTGFzdF9ZZWFyIiwiMjAyNSJdLFsiU2NhbGUiLCItOSJdLFsiU2VyaWVzIiwiQSJdLFsiU2VsZWN0X2FsbF95ZWFycyIsIjEiXV19)

## Project Overview
This project aims to fully replicate the analysis and tables presented in the working paper draft, **Cyclicality of R&D at the Firm Level**, using the original scripts and data in `/Data files` (Google Drive). The ultimate goal is to port all analysis to Python for simplicity and reproducibility, while keeping all data in Google Drive (no local copies).

## Data Location
- **All data and original scripts are stored in Google Drive:**
  - `/My Drive/Work/Research/Papers/Cyclicality of R&D at the Firm Level/Data files`
- Data will be accessed directly from Google Drive using Python tools (e.g., `gdown`, `PyDrive`, or Google Drive API).

## Aggregate Data Processing Scripts
- Python scripts for processing aggregate BEA and GDP data are located in the `scripts/` directory:
  - `scripts/process_bea_data.py` — Processes industry value added and related aggregates from BEA. See [BEA Industry Economic Accounts](https://www.bea.gov/data/industry).
  - `scripts/process_gdp_data.py` — Processes macroeconomic GDP data. See [BEA NIPA GDP Data](https://www.bea.gov/data/gdp/gross-domestic-product).
- Update the file paths as needed to match your local or cloud data structure.

## Original Scripts and Data Files
Below are the main scripts and data files found in `/Data files`:

- `AllData.do` — Main Stata script for data processing and analysis (1400+ lines)
- `NBER.do`, `BEA.do`, `GDP.do` — Stata scripts for specific data sources
- `CreatingUniqueDataset.do` — Script for dataset construction
- `.dta` files — Stata data files (e.g., `AllData.dta`, `NBER_EXPORTS.dta`, `BEA_ValueAdded.dta`, etc.)
- `StockMarketData.dta`, `AllCompustat.dta`, `Exports.dta`, etc. — Additional data sources

**Note:** Only scripts and data relevant to the tables/results in the working paper will be ported and documented in detail. As we cross-check with the draft, this list will be refined.

## Planned Workflow
1. **Inventory and review all scripts and data files.**
2. **Cross-check each table/result in the working paper with the scripts to identify dependencies.**
3. **Port each relevant script to Python, ensuring outputs match the draft results.**
4. **Access all data directly from Google Drive using Python tools.**
5. **Document each step and update the checklist as we progress.**

## Environment Setup
- Python 3.x
- Recommended packages: `pandas`, `numpy`, `statsmodels`, `gdown` or `PyDrive`, `stata_kernel` (for reference), and any others as needed.
- Instructions for Google Drive authentication will be provided in the checklist as needed.

## Documentation
- All documentation, including this README and the replication checklist, will be kept in the `/cyclicality` GitHub folder.

---

**For detailed progress and next steps, see `REPLICATION_CHECKLIST.md`.**

## Notes

Project state is tracked in `workspace.db` and dashboard views. Legacy `.context/` files were archived.

