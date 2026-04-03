# Compustat × NBER Analysis: Cyclicality Coefficient Summary

Replication of `[2]_final_data_compustat_NBER.do`.

| Block | Label | Estimator | Cycle variable | Coef | SE | p | Sig | N |
|-------|-------|-----------|---------------|------|----|---|-----|---|
| ols_sym_1a_vadd | ols_sym_1a_vadd_A | FE OLS | d_vadd | 0.0566 | 0.0237 | 0.0167 | ** | 22515 |
| ols_sym_1a_vadd | ols_sym_1a_vadd_B | FE OLS | d_vadd | -0.0124 | 0.0035 | 0.0004 | *** | 23028 |
| ols_sym_1a_vadd | ols_sym_1a_vadd_C | FE OLS | d_vadd | -0.0521 | 0.0072 | 0.0 | *** | 22627 |
| ols_sym_1b_vship | ols_sym_1b_vship_A | FE OLS | d_vship | 0.0916 | 0.0278 | 0.001 | *** | 22515 |
| ols_sym_1b_vship | ols_sym_1b_vship_B | FE OLS | d_vship | -0.0062 | 0.0019 | 0.0014 | *** | 23028 |
| ols_sym_1b_vship | ols_sym_1b_vship_C | FE OLS | d_vship | -0.0688 | 0.0087 | 0.0 | *** | 22627 |
| ols_sym_1c_sale | ols_sym_1c_sale_A | FE OLS | d_sale | 0.5399 | 0.0234 | 0.0 | *** | 22521 |
| ols_sym_1c_sale | ols_sym_1c_sale_B | FE OLS | d_sale | -0.0408 | 0.0221 | 0.0646 | * | 23028 |
| ols_sym_1c_sale | ols_sym_1c_sale_C | FE OLS | d_sale | -0.088 | 0.0062 | 0.0 | *** | 22635 |
| ols_sym_1d_va_a | ols_sym_1d_va_a_A | FE OLS | d_va_a | 0.2251 | 0.0159 | 0.0 | *** | 22312 |
| ols_sym_1d_va_a | ols_sym_1d_va_a_B | FE OLS | d_va_a | -0.1835 | 0.0113 | 0.0 | *** | 22326 |
| ols_sym_1d_va_a | ols_sym_1d_va_a_C | FE OLS | d_va_a | -0.0563 | 0.0041 | 0.0 | *** | 22428 |
| ols_asym_2a_vadd | ols_asym_2a_vadd_A | FE OLS | g_h_vadd | 0.0879 | 0.0336 | 0.0089 | *** | 22515 |
| ols_asym_2a_vadd | ols_asym_2a_vadd_A | FE OLS | g_l_vadd | -0.0019 | 0.0479 | 0.969 |  | 22515 |
| ols_asym_2a_vadd | ols_asym_2a_vadd_B | FE OLS | g_h_vadd | -0.0117 | 0.0043 | 0.0062 | *** | 23028 |
| ols_asym_2a_vadd | ols_asym_2a_vadd_B | FE OLS | g_l_vadd | -0.0138 | 0.0038 | 0.0002 | *** | 23028 |
| ols_asym_2a_vadd | ols_asym_2a_vadd_C | FE OLS | g_h_vadd | -0.0474 | 0.0106 | 0.0 | *** | 22627 |
| ols_asym_2a_vadd | ols_asym_2a_vadd_C | FE OLS | g_l_vadd | -0.061 | 0.0138 | 0.0 | *** | 22627 |
| ols_asym_2b_vship | ols_asym_2b_vship_A | FE OLS | g_h_vship | 0.1035 | 0.0385 | 0.0072 | *** | 22515 |
| ols_asym_2b_vship | ols_asym_2b_vship_A | FE OLS | g_l_vship | 0.0668 | 0.0522 | 0.201 |  | 22515 |
| ols_asym_2b_vship | ols_asym_2b_vship_B | FE OLS | g_h_vship | -0.0065 | 0.0026 | 0.013 | ** | 23028 |
| ols_asym_2b_vship | ols_asym_2b_vship_B | FE OLS | g_l_vship | -0.0057 | 0.002 | 0.004 | *** | 23028 |
| ols_asym_2b_vship | ols_asym_2b_vship_C | FE OLS | g_h_vship | -0.0577 | 0.0121 | 0.0 | *** | 22627 |
| ols_asym_2b_vship | ols_asym_2b_vship_C | FE OLS | g_l_vship | -0.0924 | 0.0179 | 0.0 | *** | 22627 |
| ols_asym_2c_sale | ols_asym_2c_sale_A | FE OLS | g_h_sale | 0.5533 | 0.0301 | 0.0 | *** | 22521 |
| ols_asym_2c_sale | ols_asym_2c_sale_A | FE OLS | g_l_sale | 0.5139 | 0.0588 | 0.0 | *** | 22521 |
| ols_asym_2c_sale | ols_asym_2c_sale_B | FE OLS | g_h_sale | -0.0038 | 0.0151 | 0.8002 |  | 23028 |
| ols_asym_2c_sale | ols_asym_2c_sale_B | FE OLS | g_l_sale | -0.109 | 0.0898 | 0.2249 |  | 23028 |
| ols_asym_2c_sale | ols_asym_2c_sale_C | FE OLS | g_h_sale | -0.1062 | 0.008 | 0.0 | *** | 22635 |
| ols_asym_2c_sale | ols_asym_2c_sale_C | FE OLS | g_l_sale | -0.0549 | 0.0139 | 0.0001 | *** | 22635 |
| ols_asym_2d_va_a | ols_asym_2d_va_a_A | FE OLS | g_h_va_a | 0.2935 | 0.0264 | 0.0 | *** | 22312 |
| ols_asym_2d_va_a | ols_asym_2d_va_a_A | FE OLS | g_l_va_a | 0.1344 | 0.0276 | 0.0 | *** | 22312 |
| ols_asym_2d_va_a | ols_asym_2d_va_a_B | FE OLS | g_h_va_a | -0.1288 | 0.0124 | 0.0 | *** | 22326 |
| ols_asym_2d_va_a | ols_asym_2d_va_a_B | FE OLS | g_l_va_a | -0.2521 | 0.0177 | 0.0 | *** | 22326 |
| ols_asym_2d_va_a | ols_asym_2d_va_a_C | FE OLS | g_h_va_a | -0.0668 | 0.0067 | 0.0 | *** | 22428 |
| ols_asym_2d_va_a | ols_asym_2d_va_a_C | FE OLS | g_l_va_a | -0.0427 | 0.0079 | 0.0 | *** | 22428 |
| dev_ols_sym_5a_dev_vadd | dev_ols_sym_5a_dev_vadd_A | FE OLS | dev_vadd | 0.0566 | 0.0237 | 0.0167 | ** | 22515 |
| dev_ols_sym_5a_dev_vadd | dev_ols_sym_5a_dev_vadd_B | FE OLS | dev_vadd | -0.0124 | 0.0035 | 0.0004 | *** | 23028 |
| dev_ols_sym_5a_dev_vadd | dev_ols_sym_5a_dev_vadd_C | FE OLS | dev_vadd | -0.0521 | 0.0072 | 0.0 | *** | 22627 |
| dev_ols_sym_5b_dev_vship | dev_ols_sym_5b_dev_vship_A | FE OLS | dev_vship | 0.0916 | 0.0278 | 0.001 | *** | 22515 |
| dev_ols_sym_5b_dev_vship | dev_ols_sym_5b_dev_vship_B | FE OLS | dev_vship | -0.0062 | 0.0019 | 0.0014 | *** | 23028 |
| dev_ols_sym_5b_dev_vship | dev_ols_sym_5b_dev_vship_C | FE OLS | dev_vship | -0.0688 | 0.0087 | 0.0 | *** | 22627 |
| dev_ols_sym_5c_dev_sale | dev_ols_sym_5c_dev_sale_A | FE OLS | dev_sale | 0.5399 | 0.0234 | 0.0 | *** | 22521 |
| dev_ols_sym_5c_dev_sale | dev_ols_sym_5c_dev_sale_B | FE OLS | dev_sale | -0.0408 | 0.0221 | 0.0646 | * | 23028 |
| dev_ols_sym_5c_dev_sale | dev_ols_sym_5c_dev_sale_C | FE OLS | dev_sale | -0.088 | 0.0062 | 0.0 | *** | 22635 |
| dev_ols_sym_5d_dev_va_a | dev_ols_sym_5d_dev_va_a_A | FE OLS | dev_va_a | 0.2251 | 0.0159 | 0.0 | *** | 22312 |
| dev_ols_sym_5d_dev_va_a | dev_ols_sym_5d_dev_va_a_B | FE OLS | dev_va_a | -0.1835 | 0.0113 | 0.0 | *** | 22326 |
| dev_ols_sym_5d_dev_va_a | dev_ols_sym_5d_dev_va_a_C | FE OLS | dev_va_a | -0.0563 | 0.0041 | 0.0 | *** | 22428 |
| dev_ols_asym_5e_dev_vadd | dev_ols_asym_5e_dev_vadd_A | FE OLS | dev_g_h_vadd | 0.0894 | 0.045 | 0.0469 | ** | 22515 |
| dev_ols_asym_5e_dev_vadd | dev_ols_asym_5e_dev_vadd_A | FE OLS | dev_g_l_vadd | 0.0246 | 0.0404 | 0.5428 |  | 22515 |
| dev_ols_asym_5e_dev_vadd | dev_ols_asym_5e_dev_vadd_B | FE OLS | dev_g_h_vadd | -0.0112 | 0.0037 | 0.0026 | *** | 23028 |
| dev_ols_asym_5e_dev_vadd | dev_ols_asym_5e_dev_vadd_B | FE OLS | dev_g_l_vadd | -0.0136 | 0.0036 | 0.0001 | *** | 23028 |
| dev_ols_asym_5e_dev_vadd | dev_ols_asym_5e_dev_vadd_C | FE OLS | dev_g_h_vadd | -0.0325 | 0.0128 | 0.0109 | ** | 22627 |
| dev_ols_asym_5e_dev_vadd | dev_ols_asym_5e_dev_vadd_C | FE OLS | dev_g_l_vadd | -0.0713 | 0.0119 | 0.0 | *** | 22627 |
| dev_ols_asym_5g_dev_sale | dev_ols_asym_5g_dev_sale_A | FE OLS | dev_g_h_sale | 0.5924 | 0.0416 | 0.0 | *** | 22520 |
| dev_ols_asym_5g_dev_sale | dev_ols_asym_5g_dev_sale_A | FE OLS | dev_g_l_sale | 0.4923 | 0.0411 | 0.0 | *** | 22520 |
| dev_ols_asym_5g_dev_sale | dev_ols_asym_5g_dev_sale_B | FE OLS | dev_g_h_sale | 0.0098 | 0.0219 | 0.6549 |  | 23028 |
| dev_ols_asym_5g_dev_sale | dev_ols_asym_5g_dev_sale_B | FE OLS | dev_g_l_sale | -0.0858 | 0.0607 | 0.1578 |  | 23028 |
| dev_ols_asym_5g_dev_sale | dev_ols_asym_5g_dev_sale_C | FE OLS | dev_g_h_sale | -0.0916 | 0.011 | 0.0 | *** | 22634 |
| dev_ols_asym_5g_dev_sale | dev_ols_asym_5g_dev_sale_C | FE OLS | dev_g_l_sale | -0.0849 | 0.0111 | 0.0 | *** | 22634 |
