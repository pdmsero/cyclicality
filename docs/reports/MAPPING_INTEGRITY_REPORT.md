# Mapping Integrity Report

Generated from `data/cyclicality.db` to audit NAICS/SIC/BEA mapping and merge integrity.

## Baseline Scope

- `raw_compustat` rows: `455830`
- `processed_alldata` rows: `455830`

## Lookup Table Uniqueness

| Table | Rows | Distinct key-pairs | Duplicate rows (rows - distinct) |
|---|---:|---:|---:|
| `lookup_naics_to_sic` | 2167 | 2166 | 1 |
| `lookup_codes_naics_sic` | 2165 | 1414 | 751 |
| `lookup_bea_naics_two_digit` | 1300 | 1300 | 0 |
| `lookup_bea_naics_three_digit` | 3315 | 3315 | 0 |
| `lookup_two_digit_bea_naics` | 1430 | 1430 | 0 |

- `lookup_naics_to_sic`: NAICS codes mapping to multiple SIC values: `461`
- `lookup_codes_naics_sic`: NAICS3 codes mapping to multiple SIC values: `97`

## Merge Key Cardinality Checks

- `processed_bea_value_added` duplicate `(code, year)` keys: `0`
- `processed_nber_exports` duplicate `(sic, year)` keys: `0`
- `processed_bea_value_added` null join keys: `code=17`, `year=0`
- `processed_nber_exports` null join keys: `sic=0`, `year=0`

## Coverage in `processed_alldata`

- BEA join proxy (`pva` non-null): `189423` matched / `266407` unmatched (`41.56%` match)
- NBER join proxy (`exports` non-null): `36749` matched / `419081` unmatched (`8.06%` match)

Worst BEA unmatched years (top 10):

| year | total_rows | unmatched_rows | unmatched_pct |
|---:|---:|---:|---:|
| None | 336 | 336 | 100.0% |
| 1950 | 665 | 665 | 100.0% |
| 1951 | 808 | 808 | 100.0% |
| 1952 | 814 | 814 | 100.0% |
| 1953 | 824 | 824 | 100.0% |
| 1954 | 840 | 840 | 100.0% |
| 1955 | 856 | 856 | 100.0% |
| 1956 | 876 | 876 | 100.0% |
| 1957 | 950 | 950 | 100.0% |
| 1958 | 1062 | 1062 | 100.0% |

Worst NBER unmatched years (top 10):

| year | total_rows | unmatched_rows | unmatched_pct |
|---:|---:|---:|---:|
| None | 336 | 336 | 100.0% |
| 1950 | 665 | 665 | 100.0% |
| 1951 | 808 | 808 | 100.0% |
| 1952 | 814 | 814 | 100.0% |
| 1953 | 824 | 824 | 100.0% |
| 1954 | 840 | 840 | 100.0% |
| 1955 | 856 | 856 | 100.0% |
| 1956 | 876 | 876 | 100.0% |
| 1957 | 950 | 950 | 100.0% |
| 1958 | 1062 | 1062 | 100.0% |

## Compustat Key Completeness

- Missing/blank `naics` in `raw_compustat`: `46535`
- Missing/blank `sic` in `raw_compustat`: `0`
- Rows covered by `lookup_naics_to_sic` join (via first 6 NAICS digits): `332552` / `455830`
- Raw join hit count (`raw_compustat` x `lookup_naics_to_sic`): `644624`

## Must-Fix Before Full Python Parity

- Handle null BEA join keys (`code`/`year`) before strict merge parity checks.
- Document one-to-many NAICS->SIC mapping policy to avoid row explosion during crosswalk joins.
- Investigate BEA unmatched records (`pva` null) and decide whether to drop, impute, or re-map before model parity checks.
- Investigate NBER unmatched records (`exports` null) and ensure this matches intended sample restrictions from Stata.
