# Cyclicality Data Management Plan

## Current State
- **Total**: 948 MB across 1,301 files
- **Stata (.dta)**: 806 MB (84 files) - already compressed
- **Excel (.xls/.xlsx)**: 98 MB (1,064 files) - inefficient XML format
- **CSV**: 33 MB (32 files)
- **Other**: 11 MB (.numbers, .mat)

## Storage Estimates After SQLite Conversion

| Source | Current | After SQLite | Savings |
|--------|---------|--------------|---------|
| Excel (NSF raw) | 98 MB | ~15 MB | 85% |
| CSV | 33 MB | ~12 MB | 65% |
| Stata (processed) | 665 MB | ~580 MB | 13% |
| Stata (source) | 141 MB | ~120 MB | 15% |
| **Total** | **948 MB** | **~730 MB** | **~23%** |

With deduplication of NSF files (143 unique series from 1,061 files): **~650-700 MB**

---

## Strategy 1: Clean Up Raw Data (NSF)

### Problem
- 1,061 Excel files in 27 index folders
- Only 143 unique publication series (massive redundancy)
- Same publication appears in multiple folders with different suffixes
- Variable structure, merged cells, multi-row headers

### Actions
1. **Parse all NSF Excel files** into a unified Python/pandas pipeline
2. **Deduplicate** - keep only unique (publication_id, page, industry, year) combinations
3. **Extract core variables**: industry code, year, R&D amount, suppression flags
4. **Create normalized SQLite schema**:
   ```sql
   CREATE TABLE nsf_metadata (
     publication_id TEXT, page INTEGER, source_file TEXT, index_folder TEXT
   );
   CREATE TABLE nsf_rd_data (
     publication_id TEXT, industry_code TEXT, industry_name TEXT,
     year INTEGER, rd_amount REAL, suppression_flag TEXT
   );
   ```
5. **Archive raw Excel files** to `archive/nsf_raw_excel/` (or delete after verification)

### Note on NSF Usage
Key finding: **NSF data is NOT used in main firm-level analysis** (AllData.do uses Compustat `xrd`). NSF only appears in industry-level file `[1]_RND_Industry_data_final.do`. Consider whether to:
- Keep minimal NSF for industry-level robustness
- Archive entirely if not needed for publication

---

## Strategy 2: Update to Most Recent Dates

### Current Coverage Gaps

| Source | Current End | Latest Available | Gap |
|--------|-------------|------------------|-----|
| **Compustat** | 2014 | 2024 | 10 years |
| **BEA Industry** | ~2011 | 2023 | 12 years |
| **NSF R&D** | ~2011 | 2022 | 11 years |
| **NBER Manufacturing** | ~2011 | Unclear | Research needed |
| **GDP/Deflators** | ~2011 | 2024 | 13 years |

### Actions
1. **Compustat update** (requires WRDS access)
   - Download 2015-2024 data with same variable set
   - Append to existing AllCompustat.dta

2. **BEA update** (free, bea.gov)
   - Download updated Industry Accounts (value added, gross output, deflators)
   - Match to existing 60-industry classification scheme

3. **NSF update** (free, nsf.gov/statistics)
   - Download latest Business R&D and Innovation Survey tables
   - Note: NSF survey methodology changed in 2008 (BRDIS vs. older surveys)

4. **Macro data** (free, FRED)
   - GDP, deflators, bond yields - straightforward API access

5. **NBER Manufacturing**
   - Check current availability - may need alternative (BLS KLIP or Census)

### Dependency
Compustat update is **blocking** - requires WRDS institutional access

---

## Strategy 3: Convert to SQLite

### Conversion Priority

**High Priority** (biggest savings):
1. NSF raw Excel → SQLite (98 MB → ~15 MB)
2. Export CSV/DTA pairs → SQLite (27 MB → ~10 MB)
3. IO tables (.numbers) → SQLite (10 MB → ~3 MB)

**Medium Priority** (modest savings):
4. Intermediate processed .dta → SQLite (150 MB → ~120 MB)
5. Final AllData.dta → SQLite (222 MB → ~190 MB)

**Low Priority** (already efficient):
6. Source .dta files (Compustat, NBER) - keep as .dta or convert

### Proposed SQLite Schema

```
cyclicality.db
├── raw_compustat          -- firm-year panel (455K rows)
├── raw_bea_industry       -- industry-year (60 industries × 60 years)
├── raw_nber_manufacturing -- industry-year manufacturing data
├── raw_nsf_rd            -- NSF R&D by industry-year
├── raw_exports           -- export instruments 1972-1994
├── raw_io_tables         -- IO coefficients 1997-2013
├── raw_klems             -- EU KLEMS data
├── processed_alldata     -- final merged dataset
├── metadata_sources      -- data provenance tracking
└── metadata_variables    -- variable definitions
```

### Implementation Steps
1. Create Python script `convert_to_sqlite.py`
2. Parse each data source with appropriate handler
3. Infer/document schema from Stata variable labels
4. Write to SQLite with proper indices
5. Verify row counts and key statistics match
6. Archive original files to `archive/original_formats/`

---

## Execution Order

### Phase 1: NSF Cleanup (can start now)
- [ ] Parse all NSF Excel files
- [ ] Identify unique data vs. duplicates
- [ ] Create NSF SQLite table
- [ ] Archive raw Excel files
- **Estimated savings**: 80-85 MB

### Phase 2: SQLite Conversion (can start now)
- [ ] Convert export CSVs to SQLite
- [ ] Convert IO tables (.numbers → export CSV → SQLite)
- [ ] Convert KLEMS .dta files
- [ ] Create unified instruments database
- **Estimated savings**: 30-40 MB

### Phase 3: Data Update (blocked on WRDS access)
- [ ] Secure WRDS access
- [ ] Download Compustat 2015-2024
- [ ] Download BEA/FRED updates
- [ ] Append to existing data
- [ ] Re-run Stata pipeline

### Phase 4: Final SQLite Migration
- [ ] Convert AllData.dta to SQLite
- [ ] Convert intermediate .dta files
- [ ] Verify analysis can run from SQLite
- [ ] Archive .dta files

---

## Files to Create/Modify

| File | Purpose |
|------|---------|
| `code/python/parse_nsf_excel.py` | Parse and deduplicate NSF files |
| `code/python/convert_to_sqlite.py` | Main conversion script |
| `data/cyclicality.db` | Unified SQLite database |
| `data/DATA_DICTIONARY.md` | Variable definitions and provenance |

---

## Verification

1. **Row count checks** - SQLite tables match original file counts
2. **Summary statistics** - means/std match for key variables
3. **Stata compatibility** - test `odbc` or `sqlite` commands in Stata
4. **Replication test** - AllData.do produces same results from SQLite source
