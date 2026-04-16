# Transformation Stage 3 Report

Implements deterministic tail blocks of `AllData.do` (exit variables and returns-prep variables).

## Output

- SQLite table: `processed_alldata_stage3`
- Input rows (`processed_alldata_stage2`): `158321`
- Rows written: `158321`
- Generated variables: `16`
- Skipped formulas: `0`

## Generated Variables

`average_z1`, `average_z2`, `count`, `d_q`, `exit`, `firmid`, `has95`, `has_gaps`, `l_q`, `q_ret`, `r_sale`, `r_xrd`, `survivor`, `t`, `z1`, `z2`

## Skipped Formulas

- None

## Assumptions

- Alias `r_sale` derived from `r_gdp_sale` for returns block.
- Alias `r_xrd` derived from `r_gdp_xrd` for returns block.
- Stored returns block `q` as `q_ret` because SQLite treats `q` and `Q` as duplicate column names.
