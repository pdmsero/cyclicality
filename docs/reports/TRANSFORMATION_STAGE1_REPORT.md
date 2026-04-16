# Transformation Stage 1 Report

Implements initial `AllData.do` cleaning and transformation blocks in Python.

## Output

- SQLite table: `processed_alldata_stage1`
- Rows written: `158321`

## Row Filters

- Input rows (`processed_alldata`): `455830`
- After nonnegative filter block: `455345`
- After missingness filter block: `158321`
- Total dropped: `297509`

## Variables Generated in Stage 1

- Count: `131`

`va`, `averagesalary`, `meansalary`, `wagebill`, `va_a`, `payroll`, `va_e`, `tex`, `materials`, `va_o`, `cf`, `cfmxrd`, `r_gdp_cf`, `r_gdp_cfmxrd`, `r_gdp_at`, `r_gdp_capx`, `r_gdp_ceq`, `r_gdp_che`, `r_gdp_dd1`, `r_gdp_dlc`, `r_gdp_dltt`, `r_gdp_dp`, `r_gdp_dvc`, `r_gdp_dvp`, `r_gdp_ib`, `r_gdp_lt`, `r_gdp_oibdp`, `r_gdp_ppent`, `r_gdp_ppegt`, `r_gdp_sale`, `r_gdp_sale_i`, `r_gdp_seq`, `r_gdp_txdb`, `r_gdp_xlr`, `r_gdp_xrd`, `r_gdp_va`, `r_gdp_va_a`, `r_gdp_va_e`, `r_gdp_tex`, `r_gdp_materials`, `r_va_cf`, `r_va_cfmxrd`, `r_va_at`, `r_va_capx`, `r_va_ceq`, `r_va_che`, `r_va_dd1`, `r_va_dlc`, `r_va_dltt`, `r_va_dp`, `r_va_dvc`, `r_va_dvp`, `r_va_ib`, `r_va_lt`, `r_va_oibdp`, `r_va_ppent`, `r_va_ppegt`, `r_va_sale`, `r_va_sale_i`, `r_va_seq`, `r_va_txdb`, `r_va_xlr`, `r_va_xrd`, `r_va_va`, `r_va_va_a`, `r_va_va_e`, `r_va_tex`, `r_va_materials`, `r_go_cf`, `r_go_cfmxrd`, `r_go_at`, `r_go_capx`, `r_go_ceq`, `r_go_che`, `r_go_dd1`, `r_go_dlc`, `r_go_dltt`, `r_go_dp`, `r_go_dvc`, `r_go_dvp`, `r_go_ib`, `r_go_lt`, `r_go_oibdp`, `r_go_ppent`, `r_go_ppegt`, `r_go_sale`, `r_go_sale_i`, `r_go_seq`, `r_go_txdb`, `r_go_xlr`, `r_go_xrd`, `r_go_va`, `r_go_va_a`, `r_go_va_e`, `r_go_tex`, `r_go_materials`, `r_nber_cf`, `r_nber_cfmxrd`, `r_nber_at`, `r_nber_capx`, `r_nber_ceq`, `r_nber_che`, `r_nber_dd1`, `r_nber_dlc`, `r_nber_dltt`, `r_nber_dp`, `r_nber_dvc`, `r_nber_dvp`, `r_nber_ib`, `r_nber_lt`, `r_nber_oibdp`, `r_nber_ppent`, `r_nber_ppegt`, `r_nber_sale`, `r_nber_sale_i`, `r_nber_seq`, `r_nber_txdb`, `r_nber_xlr`, `r_nber_xrd`, `r_nber_va`, `r_nber_va_a`, `r_nber_va_e`, `r_nber_tex`, `r_nber_materials`, `r_ipr_xrd`, `r_inv_capx`, `r_inv_ppent`, `r_inv_ppegt`, `r_nberinv_capx`, `r_nberinv_ppent`, `r_nberinv_ppegt`

## Notes

- This stage focuses on the early and repetitive transformation blocks from `AllData.do`.
- Remaining sections (growth rates, ratios, constraints indices, regressions) are not yet ported.
