# Cyclicality Data Management Plan

## Strategy Update (February 12, 2026)

### Decision
Adopt a **baseline-first** workflow:
1. Finish and validate a faithful Python/SQLite replication using current project data vintages.
2. Freeze that state as the replication baseline.
3. Run a controlled data refresh, source-by-source, with change attribution.

### Why
- Mixing code-porting changes and data-vintage changes makes failures ambiguous.
- A frozen baseline lets us separate:
  - implementation regressions, from
  - genuine result movement due to newer data.

### Immediate Gates Before Data Refresh
- Gate A: SQLite conversion complete and verified (`meta_verification_log` failures = 0).
- Gate B: Python outputs match baseline Stata outputs for target tables/figures.
- Gate C: Provenance documented per source family (see `data/DATA_PROVENANCE_MAP.md`).

Only after A/B/C are green do we update to newer vintages.

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

## Strategy 2: Complete Baseline Replication (No Vintage Changes)

### Scope
- Keep existing input vintages fixed.
- Port and validate transformation/model code against current data.
- Document all joins/crosswalk behavior (NAICS/SIC/BEA mappings).

### Actions
1. Reconstruct Stata merge lineage in Python (including mapping tables and merge cardinalities).
2. Reproduce baseline analysis outputs from SQLite-backed Python pipeline.
3. Add regression tests:
   - row counts at major pipeline checkpoints,
   - key summary statistics,
   - selected model outputs.
4. Tag and freeze baseline artifacts:
   - code revision,
   - `data/cyclicality.db` snapshot metadata,
   - replication output bundle.

---

## Strategy 3: Update to Most Recent Dates (Post-Baseline Only)

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

## Strategy 4: Convert to SQLite

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

### Phase 1: Baseline Data Layer (complete)
- [x] Convert project data sources into `data/cyclicality.db`
- [x] Verify conversion integrity via `meta_verification_log`
- [x] Keep originals unchanged for auditability

### Phase 2: Baseline Replication (in progress)
- [ ] Port remaining Stata transformations/merges to Python
- [ ] Validate baseline tables/figures against existing Stata outputs
- [ ] Add automated parity checks for key outputs

### Phase 3: Freeze Baseline (required before updates)
- [ ] Create reproducible baseline release marker (code + data metadata + outputs)
- [ ] Write baseline acceptance report (what matches/what deviates)

### Phase 4: Source-by-Source Data Refresh (after Phase 3)
- [ ] Refresh BEA/NIPA and FRED/SSA series first (public, low-friction)
- [ ] Refresh NBER/CES and concordances
- [ ] Refresh Compustat (WRDS-dependent)
- [ ] Re-run pipeline after each source refresh and attribute deltas

### Phase 5: Deferred NSF Modernization
- [ ] Parse/deduplicate NSF raw Excel archive into separate pipeline
- [ ] Integrate only if needed for target outputs

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
