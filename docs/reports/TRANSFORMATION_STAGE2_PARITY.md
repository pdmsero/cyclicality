# Transformation Stage 2 Parity

Parity check between recomputed Stage-2 transforms and stored `processed_alldata_stage2` table.

## Summary

- Row count recomputed: `158321`
- Row count stored: `158321`
- Row count match: `YES`
- Generated variables expected: `185`
- Generated variables present in stored table: `185`
- Missing generated variables in stored table: `0`
- Total numeric tolerance failures (`>1e-09`): `0`
- Skipped formulas during recomputation: `0`

## Assumptions Used

- Reused existing `d_gdp` (case-insensitive equivalent of Stata `d_GDP`).
- Alias `d_xrd` derived from `d_gdp_xrd` for deviation block parity.
- Alias `d_sale` derived from `d_gdp_sale` for deviation block parity.
- Alias `d_va` derived from `d_gdp_va` for deviation block parity.
- Alias `d_va_a` derived from `d_gdp_va_a` for deviation block parity.
- Alias `d_va_i` derived from `d_va_ind` for deviation block parity.

## Per-Variable Numeric Parity

| Variable | >tol count | Max abs diff | Mean abs diff |
|---|---:|---:|---:|
| `KZ` | 0 | 0 | 0 |
| `KZ_1` | 0 | 0 | 0 |
| `KZ_2` | 0 | 0 | 0 |
| `KZ_3` | 0 | 0 | 0 |
| `KZ_4` | 0 | 0 | 0 |
| `Q` | 0 | 0 | 0 |
| `WW` | 0 | 0 | 0 |
| `WW_1` | 0 | 0 | 0 |
| `WW_2` | 0 | 0 | 0 |
| `WW_3` | 0 | 0 | 0 |
| `WW_4` | 0 | 0 | 0 |
| `cash` | 0 | 0 | 0 |
| `cfratio` | 0 | 0 | 0 |
| `d_gdp_sale` | 0 | 0 | 0 |
| `d_gdp_sale_i` | 0 | 0 | 0 |
| `d_gdp_va` | 0 | 0 | 0 |
| `d_gdp_va_a` | 0 | 0 | 0 |
| `d_gdp_va_e` | 0 | 0 | 0 |
| `d_gdp_xrd` | 0 | 0 | 0 |
| `d_go_KZ1` | 0 | 0 | 0 |
| `d_go_KZ2` | 0 | 0 | 0 |
| `d_go_KZ3` | 0 | 0 | 0 |
| `d_go_KZ4` | 0 | 0 | 0 |
| `d_go_WW1` | 0 | 0 | 0 |
| `d_go_WW2` | 0 | 0 | 0 |
| `d_go_WW3` | 0 | 0 | 0 |
| `d_go_WW4` | 0 | 0 | 0 |
| `d_go_sale` | 0 | 0 | 0 |
| `d_go_sale_i` | 0 | 0 | 0 |
| `d_go_va` | 0 | 0 | 0 |
| `d_go_va_a` | 0 | 0 | 0 |
| `d_go_va_e` | 0 | 0 | 0 |
| `d_go_xrd` | 0 | 0 | 0 |
| `d_h_GDP` | 0 | 0 | 0 |
| `d_h_ag` | 0 | 0 | 0 |
| `d_h_ag_fc_sale` | 0 | 0 | 0 |
| `d_h_ag_fc_va` | 0 | 0 | 0 |
| `d_h_ag_fc_va_a` | 0 | 0 | 0 |
| `d_h_ba` | 0 | 0 | 0 |
| `d_h_ba_fc_sale` | 0 | 0 | 0 |
| `d_h_ba_fc_va` | 0 | 0 | 0 |
| `d_h_ba_fc_va_a` | 0 | 0 | 0 |
| `d_h_bg` | 0 | 0 | 0 |
| `d_h_bg_fc_sale` | 0 | 0 | 0 |
| `d_h_bg_fc_va` | 0 | 0 | 0 |
| `d_h_bg_fc_va_a` | 0 | 0 | 0 |
| `d_h_go` | 0 | 0 | 0 |
| `d_h_sale` | 0 | 0 | 0 |
| `d_h_va` | 0 | 0 | 0 |
| `d_h_va_a` | 0 | 0 | 0 |
| `d_h_va_i` | 0 | 0 | 0 |
| `d_h_vadd` | 0 | 0 | 0 |
| `d_h_vship` | 0 | 0 | 0 |
| `d_ipr_xrd` | 0 | 0 | 0 |
| `d_l_GDP` | 0 | 0 | 0 |
| `d_l_ag` | 0 | 0 | 0 |
| `d_l_ag_fc_sale` | 0 | 0 | 0 |
| `d_l_ag_fc_va` | 0 | 0 | 0 |
| `d_l_ag_fc_va_a` | 0 | 0 | 0 |
| `d_l_ba` | 0 | 0 | 0 |
| `d_l_ba_fc_sale` | 0 | 0 | 0 |
| `d_l_ba_fc_va` | 0 | 0 | 0 |
| `d_l_ba_fc_va_a` | 0 | 0 | 0 |
| `d_l_bg` | 0 | 0 | 0 |
| `d_l_bg_fc_sale` | 0 | 0 | 0 |
| `d_l_bg_fc_va` | 0 | 0 | 0 |
| `d_l_bg_fc_va_a` | 0 | 0 | 0 |
| `d_l_go` | 0 | 0 | 0 |
| `d_l_sale` | 0 | 0 | 0 |
| `d_l_va` | 0 | 0 | 0 |
| `d_l_va_a` | 0 | 0 | 0 |
| `d_l_va_i` | 0 | 0 | 0 |
| `d_l_vadd` | 0 | 0 | 0 |
| `d_l_vship` | 0 | 0 | 0 |
| `d_nber_sale` | 0 | 0 | 0 |
| `d_nber_sale_i` | 0 | 0 | 0 |
| `d_nber_va` | 0 | 0 | 0 |
| `d_nber_va_a` | 0 | 0 | 0 |
| `d_nber_va_e` | 0 | 0 | 0 |
| `d_nber_xrd` | 0 | 0 | 0 |
| `d_sale` | 0 | 0 | 0 |
| `d_sale_KZ1` | 0 | 0 | 0 |
| `d_sale_KZ2` | 0 | 0 | 0 |
| `d_sale_KZ3` | 0 | 0 | 0 |
| `d_sale_KZ4` | 0 | 0 | 0 |
| `d_sale_WW1` | 0 | 0 | 0 |
| `d_sale_WW2` | 0 | 0 | 0 |
| `d_sale_WW3` | 0 | 0 | 0 |
| `d_sale_WW4` | 0 | 0 | 0 |
| `d_va` | 0 | 0 | 0 |
| `d_va_KZ1` | 0 | 0 | 0 |
| `d_va_KZ2` | 0 | 0 | 0 |
| `d_va_KZ3` | 0 | 0 | 0 |
| `d_va_KZ4` | 0 | 0 | 0 |
| `d_va_WW1` | 0 | 0 | 0 |
| `d_va_WW2` | 0 | 0 | 0 |
| `d_va_WW3` | 0 | 0 | 0 |
| `d_va_WW4` | 0 | 0 | 0 |
| `d_va_a` | 0 | 0 | 0 |
| `d_va_a_KZ1` | 0 | 0 | 0 |
| `d_va_a_KZ2` | 0 | 0 | 0 |
| `d_va_a_KZ3` | 0 | 0 | 0 |
| `d_va_a_KZ4` | 0 | 0 | 0 |
| `d_va_a_WW1` | 0 | 0 | 0 |
| `d_va_a_WW2` | 0 | 0 | 0 |
| `d_va_a_WW3` | 0 | 0 | 0 |
| `d_va_a_WW4` | 0 | 0 | 0 |
| `d_va_i` | 0 | 0 | 0 |
| `d_va_i_KZ1` | 0 | 0 | 0 |
| `d_va_i_KZ2` | 0 | 0 | 0 |
| `d_va_i_KZ3` | 0 | 0 | 0 |
| `d_va_i_KZ4` | 0 | 0 | 0 |
| `d_va_i_WW1` | 0 | 0 | 0 |
| `d_va_i_WW2` | 0 | 0 | 0 |
| `d_va_i_WW3` | 0 | 0 | 0 |
| `d_va_i_WW4` | 0 | 0 | 0 |
| `d_va_sale` | 0 | 0 | 0 |
| `d_va_sale_i` | 0 | 0 | 0 |
| `d_va_va` | 0 | 0 | 0 |
| `d_va_va_a` | 0 | 0 | 0 |
| `d_va_va_e` | 0 | 0 | 0 |
| `d_va_xrd` | 0 | 0 | 0 |
| `d_vadd_KZ1` | 0 | 0 | 0 |
| `d_vadd_KZ2` | 0 | 0 | 0 |
| `d_vadd_KZ3` | 0 | 0 | 0 |
| `d_vadd_KZ4` | 0 | 0 | 0 |
| `d_vadd_WW1` | 0 | 0 | 0 |
| `d_vadd_WW2` | 0 | 0 | 0 |
| `d_vadd_WW3` | 0 | 0 | 0 |
| `d_vadd_WW4` | 0 | 0 | 0 |
| `d_vship_KZ1` | 0 | 0 | 0 |
| `d_vship_KZ2` | 0 | 0 | 0 |
| `d_vship_KZ3` | 0 | 0 | 0 |
| `d_vship_KZ4` | 0 | 0 | 0 |
| `d_vship_WW1` | 0 | 0 | 0 |
| `d_vship_WW2` | 0 | 0 | 0 |
| `d_vship_WW3` | 0 | 0 | 0 |
| `d_vship_WW4` | 0 | 0 | 0 |
| `d_xrd` | 0 | 0 | 0 |
| `debt` | 0 | 0 | 0 |
| `dev_gdp` | 0 | 0 | 0 |
| `dev_go` | 0 | 0 | 0 |
| `dev_h_gdp` | 0 | 0 | 0 |
| `dev_h_go` | 0 | 0 | 0 |
| `dev_h_sale` | 0 | 0 | 0 |
| `dev_h_va` | 0 | 0 | 0 |
| `dev_h_va_a` | 0 | 0 | 0 |
| `dev_h_va_i` | 0 | 0 | 0 |
| `dev_h_vadd` | 0 | 0 | 0 |
| `dev_h_vship` | 0 | 0 | 0 |
| `dev_l_gdp` | 0 | 0 | 0 |
| `dev_l_go` | 0 | 0 | 0 |
| `dev_l_sale` | 0 | 0 | 0 |
| `dev_l_va` | 0 | 0 | 0 |
| `dev_l_va_a` | 0 | 0 | 0 |
| `dev_l_va_i` | 0 | 0 | 0 |
| `dev_l_vadd` | 0 | 0 | 0 |
| `dev_l_vship` | 0 | 0 | 0 |
| `dev_sale` | 0 | 0 | 0 |
| `dev_va` | 0 | 0 | 0 |
| `dev_va_a` | 0 | 0 | 0 |
| `dev_va_i` | 0 | 0 | 0 |
| `dev_vadd` | 0 | 0 | 0 |
| `dev_vship` | 0 | 0 | 0 |
| `dev_xrd` | 0 | 0 | 0 |
| `div` | 0 | 0 | 0 |
| `divpos` | 0 | 0 | 0 |
| `ln_go_ta` | 0 | 0 | 0 |
| `ln_nber_ta` | 0 | 0 | 0 |
| `ln_va_ta` | 0 | 0 | 0 |
| `lnta` | 0 | 0 | 0 |
| `mean_d_gdp` | 0 | 0 | 0 |
| `mean_d_go` | 0 | 0 | 0 |
| `mean_d_sale` | 0 | 0 | 0 |
| `mean_d_va` | 0 | 0 | 0 |
| `mean_d_va_a` | 0 | 0 | 0 |
| `mean_d_va_i` | 0 | 0 | 0 |
| `mean_d_vadd` | 0 | 0 | 0 |
| `mean_d_vship` | 0 | 0 | 0 |
| `mean_d_xrd` | 0 | 0 | 0 |
| `mkv` | 0 | 0 | 0 |
| `z_xrd_capx` | 0 | 0 | 0 |
| `z_xrd_sale` | 0 | 0 | 0 |
| `z_xrd_va` | 0 | 0 | 0 |
| `z_xrd_va_a` | 0 | 0 | 0 |
