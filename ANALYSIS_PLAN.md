# Cyclicality Paper: Analysis Plan

## Objective

Establish a reproducible Python baseline that matches the current Stata-based results, then update data vintages in a controlled second stage.

## Stage 1: Baseline Replication (Current Priority)

### 1. Data Baseline
- Use existing `data/cyclicality.db` as the canonical analysis source.
- Keep source vintages fixed.

### 2. Pipeline Porting
- Port the merge path from `code/stata/supporting/CreatingUniqueDataset.do`.
- Port core variable construction and transformations from `code/stata/AllData.do`.
- Preserve NAICS/SIC/BEA crosswalk behavior exactly.

### 3. Parity Validation
- Validate checkpoint row counts.
- Validate summary statistics for key variables.
- Validate target regression/table outputs against baseline Stata results.

### 4. Baseline Freeze
- Record baseline metadata (`data/BASELINE_SNAPSHOT.md`).
- Record source provenance (`data/DATA_PROVENANCE_MAP.md`).
- Publish baseline acceptance report.

## Stage 2: Data Refresh (After Baseline Freeze)

### Refresh Order
1. BEA/NIPA and FRED/SSA (public sources)
2. NBER/CES and concordances
3. Compustat (WRDS-dependent)

### Refresh Method
- Update one source family at a time.
- Re-run full pipeline after each family update.
- Attribute output changes to specific source vintages.

## Risks to Control

- Do not combine code changes and vintage changes in one step.
- Do not modify crosswalk logic during refresh without explicit impact testing.
- Do not drop original source files before full parity and refresh validation are complete.

## Immediate Next Actions

1. Implement Python merge-lineage parity checks.
2. Produce mapping integrity report for NAICS/SIC/BEA joins.
3. Build baseline acceptance report for target outputs.
