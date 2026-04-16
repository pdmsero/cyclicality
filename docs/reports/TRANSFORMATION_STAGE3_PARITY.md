# Transformation Stage 3 Parity

Parity check between recomputed Stage-3 transforms and stored `processed_alldata_stage3` table.

## Summary

- Row count recomputed: `158321`
- Row count stored: `158321`
- Row count match: `YES`
- Generated variables expected: `16`
- Generated variables present in stored table: `16`
- Missing generated variables in stored table: `0`
- Total numeric tolerance failures (`>1e-09`): `0`
- Skipped formulas during recomputation: `0`

## Assumptions Used

- Alias `r_sale` derived from `r_gdp_sale` for returns block.
- Alias `r_xrd` derived from `r_gdp_xrd` for returns block.
- Stored returns block `q` as `q_ret` because SQLite treats `q` and `Q` as duplicate column names.

## Per-Variable Numeric Parity

| Variable | >tol count | Max abs diff | Mean abs diff |
|---|---:|---:|---:|
| `average_z1` | 0 | 0 | 0 |
| `average_z2` | 0 | 0 | 0 |
| `count` | 0 | 0 | 0 |
| `d_q` | 0 | 0 | 0 |
| `exit` | 0 | 0 | 0 |
| `firmid` | 0 | 0 | 0 |
| `has95` | 0 | 0 | 0 |
| `has_gaps` | 0 | 0 | 0 |
| `l_q` | 0 | 0 | 0 |
| `q_ret` | 0 | 0 | 0 |
| `r_sale` | 0 | 0 | 0 |
| `r_xrd` | 0 | 0 | 0 |
| `survivor` | 0 | 0 | 0 |
| `t` | 0 | 0 | 0 |
| `z1` | 0 | 0 | 0 |
| `z2` | 0 | 0 | 0 |
