# Parity Checkpoints

First-pass row-count parity diagnostics for the merge sequence in `code/stata/supporting/CreatingUniqueDataset.do`.

## Baseline

- `raw_compustat` rows: `455830`
- `processed_alldata` rows (reference target): `455830`

## Merge Diagnostics

| Step | Merge | Master rows before | Matched master | Unmatched master | Using-only rows | Rows after drop `_merge==2` | Master dup key groups | Using dup key groups | Master null join keys | Using null join keys |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 | 1:1 key year with raw_stock_market | 455830 | 331855 | 123975 | 101137 | 455830 | 0 | 0 | 336 | 0 |
| 2 | m:1 code year with processed_bea_value_added | 455830 | 189423 | 266407 | 23 | 455830 | 0 | 0 | 82067 | 17 |
| 3 | m:1 sic year with processed_nber_exports | 455830 | 103115 | 352715 | 17144 | 455830 | 0 | 0 | 336 | 0 |
| 4 | m:1 year with raw_bond_yields | 455830 | 455494 | 336 | 12 | 455830 | 0 | 0 | 336 | 0 |
| 5 | m:1 year with raw_social_security_wage | 455830 | 454829 | 1001 | 10 | 455830 | 0 | 0 | 336 | 0 |
| 6 | m:1 year with processed_gdp | 455830 | 455494 | 336 | 21 | 455830 | 0 | 0 | 336 | 0 |

## Notes

- Drops of `_merge==2` remove using-only rows; master row count should remain constant.
- This is a checkpoint report, not full variable-level parity yet.
- Step 2 uses the exact NAICS3->code mapping from the Stata script.
