# Baseline Snapshot

Date: 2026-02-12

## Artifact

- File: `data/cyclicality.db`
- Size: `1114660864` bytes (`~1.04 GiB`, `~1063.0 MB`)
- Modified (system): `2026-02-12 23:06:29 GMT`
- SHA-256: `7b6821d227ffc1596eced7af83b0eee3cc63aa661f6df3fd3e879110f4e6994a`

## Conversion Integrity Snapshot

- Non-internal SQLite tables: `183`
- `meta_sources` rows: `181`
- `meta_variables` rows: `22676`
- `meta_verification_log` rows: `42804`
- Verification failures (`passed=0`): `0`

## Key Baseline Row Counts

- `raw_compustat`: `455830`
- `processed_alldata`: `455830`

## Notes

- This snapshot defines the baseline data layer for Stage 1 parity work.
- Do not run data-vintage refresh until baseline parity gates are complete.
- Source-family provenance is documented in `data/DATA_PROVENANCE_MAP.md`.
