# Cyclicality Paper: Analysis Plan

## Data Coverage Gap

**Current data:** 1951-2011 (60 years)
**Missing:** 2012-2025 (14 years)
**Gap:** 23% of potential sample period missing

---

## Data Sources & Update Status

| Source | Current Range | Update Available | Priority |
|--------|---------------|------------------|----------|
| **Compustat** | 1951-2011 | Yes (WRDS) | HIGH |
| **BEA Industry** | ~2011 | Yes (bea.gov) | HIGH |
| **NSF R&D** | ~2011 | Yes (nsf.gov/statistics) | HIGH |
| **NBER Manufacturing** | ~2011 | Unclear (dataset may be discontinued) | MEDIUM |
| **GDP/Deflators** | ~2011 | Yes (FRED/BEA) | HIGH |
| **Bond Yields** | ~2011 | Yes (FRED) | LOW |
| **Social Security Wages** | ~2011 | Yes (ssa.gov) | LOW |

---

## Analysis Pipeline

### Phase 1: Data Inventory & Validation
1. Confirm exact date ranges in each .dta file
2. Check if existing processed data is usable
3. Document variable definitions and sources

### Phase 2: Data Updates (if pursuing publication)
1. **Compustat**: Download 2012-2025 via WRDS
2. **BEA**: Download updated industry accounts (NAICS-based)
3. **NSF**: Check if new R&D survey data available
4. **NBER**: Determine if replacement dataset exists
5. **Macro**: Update GDP deflators, bond yields

### Phase 3: Code Adaptation
1. Update hardcoded paths in .do files
2. Adjust NAICS/SIC concordances if needed
3. Extend year dummies for new sample period

### Phase 4: Replication
1. Run [1]-[5] pipeline on existing data to verify replication
2. Run AllData.do main analysis
3. Compare output to paper tables

### Phase 5: Extension (with updated data)
1. Merge new data into existing structure
2. Re-run full analysis
3. Compare 1951-2011 vs 2012-2025 results
4. Check if R&D smoothing hypothesis holds in recent period

---

## Key Files

| File | Purpose |
|------|---------|
| `Data files/AllData.do` | Main analysis (1402 lines) |
| `Data files/CreatingUniqueDataset.do` | Master data merger |
| `data 2/[1]-[5]_*.do` | Pipeline scripts |
| `Cyclicality of R&D/MainText.tex` | Paper source |

---

## Instruments Data (Prepared But Not Implemented)

These were prepared for stronger IV strategies but never used in the paper:

| Data | Location | Potential Use |
|------|----------|---------------|
| IO Tables 1997-2013 | `Data/Cyclicality/IO*.numbers` | Input-output demand shocks |
| Export data 1972-1994 | `Data/Cyclicality/Exports*.dta` | Foreign demand shocks |
| EU KLEMS | `Data/Cyclicality/KLEMS*.dta` | Industry controls, robustness |

**Note:** Implementing these IVs would strengthen identification vs. the weak GDP IV currently used.

---

## Outdated Data Assessment

### Definitely Outdated (pre-2012):
- All Compustat firm data (AllCompustat.dta, AllData.dta)
- BEA industry accounts (BEA_ValueAdded.dta)
- GDP deflators (GDPData.dta)
- Bond yields (BondYields.dta)
- NSF R&D data (processed .dta files)

### Potentially Still Valid:
- NBER Manufacturing data (may cover historical period only)
- Export instrument data (historical, 1972-1994)
- IO tables (1997-2013, partial overlap)
- KLEMS data (depends on version)

### Raw Source Files (can be re-downloaded):
- NSF Excel files (1,080 files in R Version/Data/NSF/)
- BEA CSV files (in Data files/)

---

## Phased Approach

### Phase A: Replication (Now)
1. Verify existing code runs on existing 1951-2011 data
2. Document variable definitions and confirm table replication
3. Identify any code issues or missing dependencies

### Phase B: Data Update (When WRDS access secured)
1. Download Compustat 2012-2025
2. Update BEA, NSF, GDP data from public sources
3. Adapt code for extended sample
4. Re-run analysis on full 1951-2025 sample

### Phase C: Stronger Identification (Future)
1. Implement Export IV using Schott trade data
2. Implement IO Demand IV using input-output tables
3. Compare results across IV strategies
4. Address weak instrument concerns from original paper

---

## Immediate Next Steps

1. **Verify replication**: Run existing code on existing data
2. **Document gaps**: Create data dictionary
3. **Prepare for WRDS**: List exact Compustat variables needed
4. **Audit IV data**: Check completeness of export/IO data for future use
