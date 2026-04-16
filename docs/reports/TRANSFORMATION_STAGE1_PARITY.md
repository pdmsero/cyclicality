# Transformation Stage 1 Parity

Parity check between recomputed Stage-1 transforms and stored `processed_alldata_stage1` table.

## Summary

- Row count recomputed: `158321`
- Row count stored: `158321`
- Row count match: `YES`
- Generated variables expected: `131`
- Generated variables present in stored table: `131`
- Missing generated variables in stored table: `0`
- Total numeric tolerance failures (`>1e-09`): `250434`

## Per-Variable Numeric Parity

| Variable | >tol count | Max abs diff | Mean abs diff |
|---|---:|---:|---:|
| `va` | 0 | 0 | 0 |
| `averagesalary` | 0 | 0 | 0 |
| `meansalary` | 0 | 0 | 0 |
| `wagebill` | 23272 | 39561.4 | 38.2925 |
| `va_a` | 23272 | 39561.4 | 38.2925 |
| `payroll` | 0 | 0 | 0 |
| `va_e` | 0 | 0 | 0 |
| `tex` | 0 | 0 | 0 |
| `materials` | 23272 | 39561.4 | 38.2925 |
| `va_o` | 23272 | 39561.4 | 38.2925 |
| `cf` | 0 | 0 | 0 |
| `cfmxrd` | 0 | 0 | 0 |
| `r_gdp_cf` | 0 | 0 | 0 |
| `r_gdp_cfmxrd` | 0 | 0 | 0 |
| `r_gdp_at` | 0 | 0 | 0 |
| `r_gdp_capx` | 0 | 0 | 0 |
| `r_gdp_ceq` | 0 | 0 | 0 |
| `r_gdp_che` | 0 | 0 | 0 |
| `r_gdp_dd1` | 0 | 0 | 0 |
| `r_gdp_dlc` | 0 | 0 | 0 |
| `r_gdp_dltt` | 0 | 0 | 0 |
| `r_gdp_dp` | 0 | 0 | 0 |
| `r_gdp_dvc` | 0 | 0 | 0 |
| `r_gdp_dvp` | 0 | 0 | 0 |
| `r_gdp_ib` | 0 | 0 | 0 |
| `r_gdp_lt` | 0 | 0 | 0 |
| `r_gdp_oibdp` | 0 | 0 | 0 |
| `r_gdp_ppent` | 0 | 0 | 0 |
| `r_gdp_ppegt` | 0 | 0 | 0 |
| `r_gdp_sale` | 0 | 0 | 0 |
| `r_gdp_sale_i` | 0 | 0 | 0 |
| `r_gdp_seq` | 0 | 0 | 0 |
| `r_gdp_txdb` | 0 | 0 | 0 |
| `r_gdp_xlr` | 0 | 0 | 0 |
| `r_gdp_xrd` | 0 | 0 | 0 |
| `r_gdp_va` | 0 | 0 | 0 |
| `r_gdp_va_a` | 23272 | 41726.1 | 43.0803 |
| `r_gdp_va_e` | 0 | 0 | 0 |
| `r_gdp_tex` | 0 | 0 | 0 |
| `r_gdp_materials` | 23272 | 41726.1 | 43.0803 |
| `r_va_cf` | 0 | 0 | 0 |
| `r_va_cfmxrd` | 0 | 0 | 0 |
| `r_va_at` | 0 | 0 | 0 |
| `r_va_capx` | 0 | 0 | 0 |
| `r_va_ceq` | 0 | 0 | 0 |
| `r_va_che` | 0 | 0 | 0 |
| `r_va_dd1` | 0 | 0 | 0 |
| `r_va_dlc` | 0 | 0 | 0 |
| `r_va_dltt` | 0 | 0 | 0 |
| `r_va_dp` | 0 | 0 | 0 |
| `r_va_dvc` | 0 | 0 | 0 |
| `r_va_dvp` | 0 | 0 | 0 |
| `r_va_ib` | 0 | 0 | 0 |
| `r_va_lt` | 0 | 0 | 0 |
| `r_va_oibdp` | 0 | 0 | 0 |
| `r_va_ppent` | 0 | 0 | 0 |
| `r_va_ppegt` | 0 | 0 | 0 |
| `r_va_sale` | 0 | 0 | 0 |
| `r_va_sale_i` | 0 | 0 | 0 |
| `r_va_seq` | 0 | 0 | 0 |
| `r_va_txdb` | 0 | 0 | 0 |
| `r_va_xlr` | 0 | 0 | 0 |
| `r_va_xrd` | 0 | 0 | 0 |
| `r_va_va` | 0 | 0 | 0 |
| `r_va_va_a` | 22297 | 39236.5 | 80.0527 |
| `r_va_va_e` | 0 | 0 | 0 |
| `r_va_tex` | 0 | 0 | 0 |
| `r_va_materials` | 22297 | 39236.5 | 80.0527 |
| `r_go_cf` | 0 | 0 | 0 |
| `r_go_cfmxrd` | 0 | 0 | 0 |
| `r_go_at` | 0 | 0 | 0 |
| `r_go_capx` | 0 | 0 | 0 |
| `r_go_ceq` | 0 | 0 | 0 |
| `r_go_che` | 0 | 0 | 0 |
| `r_go_dd1` | 0 | 0 | 0 |
| `r_go_dlc` | 0 | 0 | 0 |
| `r_go_dltt` | 0 | 0 | 0 |
| `r_go_dp` | 0 | 0 | 0 |
| `r_go_dvc` | 0 | 0 | 0 |
| `r_go_dvp` | 0 | 0 | 0 |
| `r_go_ib` | 0 | 0 | 0 |
| `r_go_lt` | 0 | 0 | 0 |
| `r_go_oibdp` | 0 | 0 | 0 |
| `r_go_ppent` | 0 | 0 | 0 |
| `r_go_ppegt` | 0 | 0 | 0 |
| `r_go_sale` | 0 | 0 | 0 |
| `r_go_sale_i` | 0 | 0 | 0 |
| `r_go_seq` | 0 | 0 | 0 |
| `r_go_txdb` | 0 | 0 | 0 |
| `r_go_xlr` | 0 | 0 | 0 |
| `r_go_xrd` | 0 | 0 | 0 |
| `r_go_va` | 0 | 0 | 0 |
| `r_go_va_a` | 22297 | 40286.1 | 85.9726 |
| `r_go_va_e` | 0 | 0 | 0 |
| `r_go_tex` | 0 | 0 | 0 |
| `r_go_materials` | 22297 | 40286.1 | 85.9726 |
| `r_nber_cf` | 0 | 0 | 0 |
| `r_nber_cfmxrd` | 0 | 0 | 0 |
| `r_nber_at` | 0 | 0 | 0 |
| `r_nber_capx` | 0 | 0 | 0 |
| `r_nber_ceq` | 0 | 0 | 0 |
| `r_nber_che` | 0 | 0 | 0 |
| `r_nber_dd1` | 0 | 0 | 0 |
| `r_nber_dlc` | 0 | 0 | 0 |
| `r_nber_dltt` | 0 | 0 | 0 |
| `r_nber_dp` | 0 | 0 | 0 |
| `r_nber_dvc` | 0 | 0 | 0 |
| `r_nber_dvp` | 0 | 0 | 0 |
| `r_nber_ib` | 0 | 0 | 0 |
| `r_nber_lt` | 0 | 0 | 0 |
| `r_nber_oibdp` | 0 | 0 | 0 |
| `r_nber_ppent` | 0 | 0 | 0 |
| `r_nber_ppegt` | 0 | 0 | 0 |
| `r_nber_sale` | 0 | 0 | 0 |
| `r_nber_sale_i` | 0 | 0 | 0 |
| `r_nber_seq` | 0 | 0 | 0 |
| `r_nber_txdb` | 0 | 0 | 0 |
| `r_nber_xlr` | 0 | 0 | 0 |
| `r_nber_xrd` | 0 | 0 | 0 |
| `r_nber_va` | 0 | 0 | 0 |
| `r_nber_va_a` | 10807 | 682222 | 252.305 |
| `r_nber_va_e` | 0 | 0 | 0 |
| `r_nber_tex` | 0 | 0 | 0 |
| `r_nber_materials` | 10807 | 682222 | 252.305 |
| `r_ipr_xrd` | 0 | 0 | 0 |
| `r_inv_capx` | 0 | 0 | 0 |
| `r_inv_ppent` | 0 | 0 | 0 |
| `r_inv_ppegt` | 0 | 0 | 0 |
| `r_nberinv_capx` | 0 | 0 | 0 |
| `r_nberinv_ppent` | 0 | 0 | 0 |
| `r_nberinv_ppegt` | 0 | 0 | 0 |
