# Replication Checklist: Cyclicality Project

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

This document tracks the step-by-step process for fully replicating the analysis and tables in the working paper draft, Cyclicality of R&D at the Firm Level, using the scripts and data in Google Drive, ported to Python.

## General Steps
- [ ] Inventory all scripts and data files in `/Data files`
- [ ] Review the working paper and list all tables/results to be replicated
- [ ] Map each table/result to the relevant script(s) and data
- [ ] Set up Python environment and Google Drive access
- [ ] **Port and validate BEA and GDP aggregate data scripts in Python**
- [ ] **Update BEA and GDP aggregate data to the present**
- [ ] **Document data sources and update steps**
- [ ] Port each relevant firm-level script to Python (see below)
- [ ] Verify Python outputs match those in the paper
- [ ] Document any missing or unclear steps

## Aggregate Data (BEA & GDP) Porting Progress
- [ ] `BEA.do` → Python
- [ ] `GDP.do` → Python
- [ ] Validate processed aggregate data against working paper tables/figures
- [ ] Update BEA and GDP data to most recent available
- [ ] Document BEA and GDP data sources, download dates, and any changes

## Script Porting Progress (Firm-level)
- [ ] `AllData.do` → Python
- [ ] `NBER.do` → Python
- [ ] `CreatingUniqueDataset.do` → Python
- [ ] Any other relevant scripts (add as discovered)

## Table/Result Verification
- [ ] Table 1: [Description] — [ ] Script mapped: ____ — [ ] Output matches
- [ ] Table 2: [Description] — [ ] Script mapped: ____ — [ ] Output matches
- [ ] ... (add as discovered)

## Data Access
- [ ] Set up Google Drive API or `gdown`/`PyDrive` for direct data access
- [ ] Test reading `.dta` files in Python (e.g., with `pandas.read_stata`)

## Issues & Notes
- [ ] [Add any missing, unclear, or problematic steps here]

---

**Update this checklist as you progress. Add new tasks, tables, or scripts as needed.** 