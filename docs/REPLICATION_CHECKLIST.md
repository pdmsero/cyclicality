# Replication Checklist: Cyclicality Project

## Gate-Based Workflow

### Gate A: Data Layer Integrity
- [x] Convert project sources into `data/cyclicality.db`
- [x] Verify conversion checks (`meta_verification_log` failures = 0)
- [x] Confirm key row counts (`raw_compustat`, `processed_alldata`)
- [x] Preserve original source files in `data/`

### Gate B: Baseline Parity (Stata -> Python)
- [x] Port merge lineage checkpoints from `code/stata/supporting/CreatingUniqueDataset.do`
- [x] Port baseline transformations from `code/stata/AllData.do`
      (stages 1–4: scripts 10–13; stage3 coverage 83.78% of AllData.do gen/egen vars)
- [x] Validate merge checkpoint row counts against baseline outputs (`data/PARITY_CHECKPOINTS.md`)
- [x] Reproduce target tables/figures from the paper using Python pipeline
      (scripts 30–40; results in results/; model Table 4 reproduced via perturbation/VFI/projection)


### Baseline Parity Artifacts
- [x] `data/PARITY_CHECKPOINTS.md`
- [x] `data/PARITY_VARIABLE_CHECKS.md`
- [x] `data/MAPPING_INTEGRITY_REPORT.md`
- [x] `data/TRANSFORMATION_COVERAGE_AUDIT.md`
- [x] `data/BASELINE_ACCEPTANCE_REPORT.md`
- [x] `data/TRANSFORMATION_STAGE1_PARITY.md`
- [x] `data/TRANSFORMATION_STAGE1_REPORT.md`

### Gate C: Baseline Documentation
- [x] Create provenance map (`data/DATA_PROVENANCE_MAP.md`)
- [x] Create baseline snapshot metadata (`data/BASELINE_SNAPSHOT.md`)
- [x] Create/complete data dictionary (`data/DATA_DICTIONARY.md`)
- [x] Write baseline acceptance report (`data/BASELINE_ACCEPTANCE_REPORT.md`)

## Post-Gate Refresh Plan (Only After A/B/C)

### Public Data Refresh
- [ ] Refresh BEA/NIPA series
- [ ] Refresh FRED/SSA series
- [ ] Refresh NBER/CES and concordances

### Licensed Data Refresh
- [ ] Refresh Compustat via WRDS

### Controlled Re-run
- [ ] Re-run pipeline source-by-source
- [ ] Attribute result changes by source vintage
- [ ] Document deltas vs baseline

## Deferred

- [ ] NSF raw modernization pipeline (`code/python/parse_nsf_excel.py`) if needed for target outputs
