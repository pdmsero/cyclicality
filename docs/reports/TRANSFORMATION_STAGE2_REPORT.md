# Transformation Stage 2 Report

Implements deterministic `AllData.do` transformation blocks after Stage 1.

## Output

- SQLite table: `processed_alldata_stage2`
- Input rows (`processed_alldata_stage1`): `158321`
- Rows written: `158321`
- Generated variables: `185`
- Skipped formulas: `0`

## Generated Variables

`KZ`, `KZ_1`, `KZ_2`, `KZ_3`, `KZ_4`, `Q`, `WW`, `WW_1`, `WW_2`, `WW_3`, `WW_4`, `cash`, `cfratio`, `d_gdp_sale`, `d_gdp_sale_i`, `d_gdp_va`, `d_gdp_va_a`, `d_gdp_va_e`, `d_gdp_xrd`, `d_go_KZ1`, `d_go_KZ2`, `d_go_KZ3`, `d_go_KZ4`, `d_go_WW1`, `d_go_WW2`, `d_go_WW3`, `d_go_WW4`, `d_go_sale`, `d_go_sale_i`, `d_go_va`, `d_go_va_a`, `d_go_va_e`, `d_go_xrd`, `d_h_GDP`, `d_h_ag`, `d_h_ag_fc_sale`, `d_h_ag_fc_va`, `d_h_ag_fc_va_a`, `d_h_ba`, `d_h_ba_fc_sale`, `d_h_ba_fc_va`, `d_h_ba_fc_va_a`, `d_h_bg`, `d_h_bg_fc_sale`, `d_h_bg_fc_va`, `d_h_bg_fc_va_a`, `d_h_go`, `d_h_sale`, `d_h_va`, `d_h_va_a`, `d_h_va_i`, `d_h_vadd`, `d_h_vship`, `d_ipr_xrd`, `d_l_GDP`, `d_l_ag`, `d_l_ag_fc_sale`, `d_l_ag_fc_va`, `d_l_ag_fc_va_a`, `d_l_ba`, `d_l_ba_fc_sale`, `d_l_ba_fc_va`, `d_l_ba_fc_va_a`, `d_l_bg`, `d_l_bg_fc_sale`, `d_l_bg_fc_va`, `d_l_bg_fc_va_a`, `d_l_go`, `d_l_sale`, `d_l_va`, `d_l_va_a`, `d_l_va_i`, `d_l_vadd`, `d_l_vship`, `d_nber_sale`, `d_nber_sale_i`, `d_nber_va`, `d_nber_va_a`, `d_nber_va_e`, `d_nber_xrd`, `d_sale`, `d_sale_KZ1`, `d_sale_KZ2`, `d_sale_KZ3`, `d_sale_KZ4`, `d_sale_WW1`, `d_sale_WW2`, `d_sale_WW3`, `d_sale_WW4`, `d_va`, `d_va_KZ1`, `d_va_KZ2`, `d_va_KZ3`, `d_va_KZ4`, `d_va_WW1`, `d_va_WW2`, `d_va_WW3`, `d_va_WW4`, `d_va_a`, `d_va_a_KZ1`, `d_va_a_KZ2`, `d_va_a_KZ3`, `d_va_a_KZ4`, `d_va_a_WW1`, `d_va_a_WW2`, `d_va_a_WW3`, `d_va_a_WW4`, `d_va_i`, `d_va_i_KZ1`, `d_va_i_KZ2`, `d_va_i_KZ3`, `d_va_i_KZ4`, `d_va_i_WW1`, `d_va_i_WW2`, `d_va_i_WW3`, `d_va_i_WW4`, `d_va_sale`, `d_va_sale_i`, `d_va_va`, `d_va_va_a`, `d_va_va_e`, `d_va_xrd`, `d_vadd_KZ1`, `d_vadd_KZ2`, `d_vadd_KZ3`, `d_vadd_KZ4`, `d_vadd_WW1`, `d_vadd_WW2`, `d_vadd_WW3`, `d_vadd_WW4`, `d_vship_KZ1`, `d_vship_KZ2`, `d_vship_KZ3`, `d_vship_KZ4`, `d_vship_WW1`, `d_vship_WW2`, `d_vship_WW3`, `d_vship_WW4`, `d_xrd`, `debt`, `dev_gdp`, `dev_go`, `dev_h_gdp`, `dev_h_go`, `dev_h_sale`, `dev_h_va`, `dev_h_va_a`, `dev_h_va_i`, `dev_h_vadd`, `dev_h_vship`, `dev_l_gdp`, `dev_l_go`, `dev_l_sale`, `dev_l_va`, `dev_l_va_a`, `dev_l_va_i`, `dev_l_vadd`, `dev_l_vship`, `dev_sale`, `dev_va`, `dev_va_a`, `dev_va_i`, `dev_vadd`, `dev_vship`, `dev_xrd`, `div`, `divpos`, `ln_go_ta`, `ln_nber_ta`, `ln_va_ta`, `lnta`, `mean_d_gdp`, `mean_d_go`, `mean_d_sale`, `mean_d_va`, `mean_d_va_a`, `mean_d_va_i`, `mean_d_vadd`, `mean_d_vship`, `mean_d_xrd`, `mkv`, `z_xrd_capx`, `z_xrd_sale`, `z_xrd_va`, `z_xrd_va_a`

## Skipped Formulas

- None

## Assumptions

- Reused existing `d_gdp` (case-insensitive equivalent of Stata `d_GDP`).
- Alias `d_xrd` derived from `d_gdp_xrd` for deviation block parity.
- Alias `d_sale` derived from `d_gdp_sale` for deviation block parity.
- Alias `d_va` derived from `d_gdp_va` for deviation block parity.
- Alias `d_va_a` derived from `d_gdp_va_a` for deviation block parity.
- Alias `d_va_i` derived from `d_va_ind` for deviation block parity.
