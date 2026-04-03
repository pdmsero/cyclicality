# Financial Constraints: Estimation Summary

Replication of [5]_data_financial_constraints.do (FE OLS, cluster key).

| Spec | Dep | Output coef | Est | p-value | n | Wald chi2 | Wald p |
|------|-----|-------------|-----|---------|---|-----------|--------|
| s1_va_dxrd | d_va | d_va | 0.2605*** | 0.000 | 3,730 |  |  |
| s1_va_z | d_va | d_va | -0.0114*** | 0.000 | 4,854 |  |  |
| s1_va_zcapx | d_va | d_va | -0.0291** | 0.012 | 4,840 |  |  |
| s1_sale_dxrd | d_sale | d_sale | 0.5376*** | 0.000 | 36,575 |  |  |
| s1_sale_z | d_sale | d_sale | -0.0257** | 0.024 | 48,002 |  |  |
| s1_sale_zcapx | d_sale | d_sale | -0.0665*** | 0.000 | 46,743 |  |  |
| s1_va_a_dxrd | d_va_a | d_va_a | 0.2304*** | 0.000 | 36,247 |  |  |
| s1_va_a_z | d_va_a | d_va_a | -0.1268*** | 0.000 | 46,231 |  |  |
| s1_va_a_zcapx | d_va_a | d_va_a | -0.0440*** | 0.000 | 46,261 |  |  |
| s1_asym_va_va_dxrd | d_h_va | d_h_va | 0.3746*** | 0.000 | 3,730 |  |  |
| s1_asym_va_va_dxrd | d_l_va | d_l_va | 0.1334 | 0.163 | 3,730 |  |  |
| s1_asym_va_va_z | d_h_va | d_h_va | -0.0128*** | 0.000 | 4,854 |  |  |
| s1_asym_va_va_z | d_l_va | d_l_va | -0.0099*** | 0.006 | 4,854 |  |  |
| s1_asym_va_va_zcapx | d_h_va | d_h_va | -0.0312** | 0.014 | 4,840 |  |  |
| s1_asym_va_va_zcapx | d_l_va | d_l_va | -0.0261 | 0.149 | 4,840 |  |  |
| s1_asym_sale_sale_dxrd | d_h_sale | d_h_sale | 0.5540*** | 0.000 | 36,575 |  |  |
| s1_asym_sale_sale_dxrd | d_l_sale | d_l_sale | 0.5066*** | 0.000 | 36,575 |  |  |
| s1_asym_sale_sale_z | d_h_sale | d_h_sale | -0.0068 | 0.392 | 48,002 |  |  |
| s1_asym_sale_sale_z | d_l_sale | d_l_sale | -0.0624 | 0.200 | 48,002 |  |  |
| s1_asym_sale_sale_zcapx | d_h_sale | d_h_sale | -0.0801*** | 0.000 | 46,743 |  |  |
| s1_asym_sale_sale_zcapx | d_l_sale | d_l_sale | -0.0404*** | 0.000 | 46,743 |  |  |
| s1_asym_va_va_a_dxrd | d_h_va | d_h_va | 0.3856*** | 0.000 | 3,723 |  |  |
| s1_asym_va_va_a_dxrd | d_l_va_a | d_l_va_a | 0.0892 | 0.223 | 3,723 |  |  |
| s1_asym_va_va_a_z | d_h_va | d_h_va | -0.0138*** | 0.000 | 5,029 |  |  |
| s1_asym_va_va_a_z | d_l_va_a | d_l_va_a | -0.0318*** | 0.000 | 5,029 |  |  |
| s1_asym_va_va_a_zcapx | d_h_va | d_h_va | -0.0288** | 0.023 | 4,819 |  |  |
| s1_asym_va_va_a_zcapx | d_l_va_a | d_l_va_a | -0.0345** | 0.031 | 4,819 |  |  |
| s1_asym_va_a_va_a_dxrd | d_h_va_a | d_h_va_a | 0.2843*** | 0.000 | 36,247 |  |  |
| s1_asym_va_a_va_a_dxrd | d_l_va_a | d_l_va_a | 0.1540*** | 0.000 | 36,247 |  |  |
| s1_asym_va_a_va_a_z | d_h_va_a | d_h_va_a | -0.0951*** | 0.000 | 46,231 |  |  |
| s1_asym_va_a_va_a_z | d_l_va_a | d_l_va_a | -0.1707*** | 0.000 | 46,231 |  |  |
| s1_asym_va_a_va_a_zcapx | d_h_va_a | d_h_va_a | -0.0482*** | 0.000 | 46,261 |  |  |
| s1_asym_va_a_va_a_zcapx | d_l_va_a | d_l_va_a | -0.0379*** | 0.000 | 46,261 |  |  |
| s2_kz_sale_dxrd | d_sale_kz1 | d_sale_kz1 | 0.5447*** | 0.000 | 36,575 | 2.33 | 0.127 |
| s2_kz_sale_dxrd | d_sale_kz2 | d_sale_kz2 | 0.4950*** | 0.000 | 36,575 | 2.33 | 0.127 |
| s2_kz_sale_dxrd | d_sale_kz3 | d_sale_kz3 | 0.5475*** | 0.000 | 36,575 | 2.33 | 0.127 |
| s2_kz_sale_dxrd | d_sale_kz4 | d_sale_kz4 | 0.6325*** | 0.000 | 36,575 | 2.33 | 0.127 |
| s2_kz_sale_z | d_sale_kz1 | d_sale_kz1 | -0.0223*** | 0.000 | 48,002 | 49.98 | 0.000 |
| s2_kz_sale_z | d_sale_kz2 | d_sale_kz2 | -0.0176*** | 0.000 | 48,002 | 49.98 | 0.000 |
| s2_kz_sale_z | d_sale_kz3 | d_sale_kz3 | -0.0117*** | 0.000 | 48,002 | 49.98 | 0.000 |
| s2_kz_sale_z | d_sale_kz4 | d_sale_kz4 | -0.0056*** | 0.000 | 48,002 | 49.98 | 0.000 |
| s2_kz_sale_zcapx | d_sale_kz1 | d_sale_kz1 | -0.0894*** | 0.000 | 46,743 | 32.07 | 0.000 |
| s2_kz_sale_zcapx | d_sale_kz2 | d_sale_kz2 | -0.0836*** | 0.000 | 46,743 | 32.07 | 0.000 |
| s2_kz_sale_zcapx | d_sale_kz3 | d_sale_kz3 | -0.0554*** | 0.000 | 46,743 | 32.07 | 0.000 |
| s2_kz_sale_zcapx | d_sale_kz4 | d_sale_kz4 | -0.0305*** | 0.000 | 46,743 | 32.07 | 0.000 |
| s2_kz_va_a_dxrd | d_va_a_kz1 | d_va_a_kz1 | 0.2515*** | 0.000 | 36,247 | 0.04 | 0.832 |
| s2_kz_va_a_dxrd | d_va_a_kz2 | d_va_a_kz2 | 0.2270*** | 0.000 | 36,247 | 0.04 | 0.832 |
| s2_kz_va_a_dxrd | d_va_a_kz3 | d_va_a_kz3 | 0.2363*** | 0.000 | 36,247 | 0.04 | 0.832 |
| s2_kz_va_a_dxrd | d_va_a_kz4 | d_va_a_kz4 | 0.2424*** | 0.000 | 36,247 | 0.04 | 0.832 |
| s2_kz_va_a_z | d_va_a_kz1 | d_va_a_kz1 | -0.2041*** | 0.000 | 46,231 | 83.19 | 0.000 |
| s2_kz_va_a_z | d_va_a_kz2 | d_va_a_kz2 | -0.1549*** | 0.000 | 46,231 | 83.19 | 0.000 |
| s2_kz_va_a_z | d_va_a_kz3 | d_va_a_kz3 | -0.1077*** | 0.000 | 46,231 | 83.19 | 0.000 |
| s2_kz_va_a_z | d_va_a_kz4 | d_va_a_kz4 | -0.0588*** | 0.000 | 46,231 | 83.19 | 0.000 |
| s2_kz_va_a_zcapx | d_va_a_kz1 | d_va_a_kz1 | -0.0543*** | 0.000 | 46,261 | 20.66 | 0.000 |
| s2_kz_va_a_zcapx | d_va_a_kz2 | d_va_a_kz2 | -0.0488*** | 0.000 | 46,261 | 20.66 | 0.000 |
| s2_kz_va_a_zcapx | d_va_a_kz3 | d_va_a_kz3 | -0.0414*** | 0.000 | 46,261 | 20.66 | 0.000 |
| s2_kz_va_a_zcapx | d_va_a_kz4 | d_va_a_kz4 | -0.0194*** | 0.000 | 46,261 | 20.66 | 0.000 |
| s2_kz_va_dxrd | d_va_kz1 | d_va_kz1 | 0.5749*** | 0.000 | 3,730 | 11.59 | 0.001 |
| s2_kz_va_dxrd | d_va_kz2 | d_va_kz2 | 0.2598*** | 0.000 | 3,730 | 11.59 | 0.001 |
| s2_kz_va_dxrd | d_va_kz3 | d_va_kz3 | 0.1948** | 0.013 | 3,730 | 11.59 | 0.001 |
| s2_kz_va_dxrd | d_va_kz4 | d_va_kz4 | 0.1028 | 0.337 | 3,730 | 11.59 | 0.001 |
| s2_kz_va_z | d_va_kz1 | d_va_kz1 | -0.0126*** | 0.005 | 4,854 | 0.14 | 0.708 |
| s2_kz_va_z | d_va_kz2 | d_va_kz2 | -0.0291*** | 0.000 | 4,854 | 0.14 | 0.708 |
| s2_kz_va_z | d_va_kz3 | d_va_kz3 | -0.0270*** | 0.000 | 4,854 | 0.14 | 0.708 |
| s2_kz_va_z | d_va_kz4 | d_va_kz4 | -0.0147*** | 0.000 | 4,854 | 0.14 | 0.708 |
| s2_kz_va_zcapx | d_va_kz1 | d_va_kz1 | 0.0166 | 0.706 | 4,840 | 1.21 | 0.271 |
| s2_kz_va_zcapx | d_va_kz2 | d_va_kz2 | -0.0481*** | 0.005 | 4,840 | 1.21 | 0.271 |
| s2_kz_va_zcapx | d_va_kz3 | d_va_kz3 | -0.0251* | 0.093 | 4,840 | 1.21 | 0.271 |
| s2_kz_va_zcapx | d_va_kz4 | d_va_kz4 | -0.0350** | 0.020 | 4,840 | 1.21 | 0.271 |
| s3_ww_sale_dxrd | d_sale_ww1 | d_sale_ww1 | 0.5770*** | 0.000 | 36,575 | 2.56 | 0.110 |
| s3_ww_sale_dxrd | d_sale_ww2 | d_sale_ww2 | 0.5638*** | 0.000 | 36,575 | 2.56 | 0.110 |
| s3_ww_sale_dxrd | d_sale_ww3 | d_sale_ww3 | 0.5173*** | 0.000 | 36,575 | 2.56 | 0.110 |
| s3_ww_sale_dxrd | d_sale_ww4 | d_sale_ww4 | 0.4904*** | 0.000 | 36,575 | 2.56 | 0.110 |
| s3_ww_sale_z | d_sale_ww1 | d_sale_ww1 | -0.0216*** | 0.000 | 48,002 | 28.49 | 0.000 |
| s3_ww_sale_z | d_sale_ww2 | d_sale_ww2 | -0.0123*** | 0.000 | 48,002 | 28.49 | 0.000 |
| s3_ww_sale_z | d_sale_ww3 | d_sale_ww3 | -0.0118*** | 0.000 | 48,002 | 28.49 | 0.000 |
| s3_ww_sale_z | d_sale_ww4 | d_sale_ww4 | -0.0094*** | 0.000 | 48,002 | 28.49 | 0.000 |
| s3_ww_sale_zcapx | d_sale_ww1 | d_sale_ww1 | -0.0906*** | 0.000 | 46,743 | 22.63 | 0.000 |
| s3_ww_sale_zcapx | d_sale_ww2 | d_sale_ww2 | -0.0734*** | 0.000 | 46,743 | 22.63 | 0.000 |
| s3_ww_sale_zcapx | d_sale_ww3 | d_sale_ww3 | -0.0576*** | 0.000 | 46,743 | 22.63 | 0.000 |
| s3_ww_sale_zcapx | d_sale_ww4 | d_sale_ww4 | -0.0415*** | 0.000 | 46,743 | 22.63 | 0.000 |
| s3_ww_va_a_dxrd | d_va_a_ww1 | d_va_a_ww1 | 0.3260*** | 0.000 | 36,247 | 40.21 | 0.000 |
| s3_ww_va_a_dxrd | d_va_a_ww2 | d_va_a_ww2 | 0.2837*** | 0.000 | 36,247 | 40.21 | 0.000 |
| s3_ww_va_a_dxrd | d_va_a_ww3 | d_va_a_ww3 | 0.1994*** | 0.000 | 36,247 | 40.21 | 0.000 |
| s3_ww_va_a_dxrd | d_va_a_ww4 | d_va_a_ww4 | 0.1008*** | 0.000 | 36,247 | 40.21 | 0.000 |
| s3_ww_va_a_z | d_va_a_ww1 | d_va_a_ww1 | -0.1540*** | 0.000 | 46,231 | 12.41 | 0.000 |
| s3_ww_va_a_z | d_va_a_ww2 | d_va_a_ww2 | -0.1332*** | 0.000 | 46,231 | 12.41 | 0.000 |
| s3_ww_va_a_z | d_va_a_ww3 | d_va_a_ww3 | -0.1400*** | 0.000 | 46,231 | 12.41 | 0.000 |
| s3_ww_va_a_z | d_va_a_ww4 | d_va_a_ww4 | -0.1074*** | 0.000 | 46,231 | 12.41 | 0.000 |
| s3_ww_va_a_zcapx | d_va_a_ww1 | d_va_a_ww1 | -0.0587*** | 0.000 | 46,261 | 8.96 | 0.003 |
| s3_ww_va_a_zcapx | d_va_a_ww2 | d_va_a_ww2 | -0.0437*** | 0.000 | 46,261 | 8.96 | 0.003 |
| s3_ww_va_a_zcapx | d_va_a_ww3 | d_va_a_ww3 | -0.0371*** | 0.000 | 46,261 | 8.96 | 0.003 |
| s3_ww_va_a_zcapx | d_va_a_ww4 | d_va_a_ww4 | -0.0358*** | 0.000 | 46,261 | 8.96 | 0.003 |
| s3_ww_va_dxrd | d_va_ww1 | d_va_ww1 | 0.2904*** | 0.000 | 3,730 | 3.68 | 0.055 |
| s3_ww_va_dxrd | d_va_ww2 | d_va_ww2 | 0.2710*** | 0.005 | 3,730 | 3.68 | 0.055 |
| s3_ww_va_dxrd | d_va_ww3 | d_va_ww3 | 0.5457*** | 0.002 | 3,730 | 3.68 | 0.055 |
| s3_ww_va_dxrd | d_va_ww4 | d_va_ww4 | -0.0125 | 0.933 | 3,730 | 3.68 | 0.055 |
| s3_ww_va_z | d_va_ww1 | d_va_ww1 | -0.0219*** | 0.000 | 4,854 | 1.97 | 0.161 |
| s3_ww_va_z | d_va_ww2 | d_va_ww2 | -0.0224*** | 0.000 | 4,854 | 1.97 | 0.161 |
| s3_ww_va_z | d_va_ww3 | d_va_ww3 | -0.0179** | 0.023 | 4,854 | 1.97 | 0.161 |
| s3_ww_va_z | d_va_ww4 | d_va_ww4 | -0.0123** | 0.024 | 4,854 | 1.97 | 0.161 |
| s3_ww_va_zcapx | d_va_ww1 | d_va_ww1 | -0.0271** | 0.048 | 4,840 | 0.14 | 0.703 |
| s3_ww_va_zcapx | d_va_ww2 | d_va_ww2 | -0.0660*** | 0.002 | 4,840 | 0.14 | 0.703 |
| s3_ww_va_zcapx | d_va_ww3 | d_va_ww3 | 0.0013 | 0.972 | 4,840 | 0.14 | 0.703 |
| s3_ww_va_zcapx | d_va_ww4 | d_va_ww4 | -0.0180 | 0.276 | 4,840 | 0.14 | 0.703 |
| s3_ag_sale_dxrd | d_h_ag_fc_sale | d_h_ag_fc_sale | 0.5469*** | 0.000 | 36,575 |  |  |
| s3_ag_sale_dxrd | d_l_ag_fc_sale | d_l_ag_fc_sale | 0.5292*** | 0.000 | 36,575 |  |  |
| s3_ag_sale_z | d_h_ag_fc_sale | d_h_ag_fc_sale | -0.0391 | 0.113 | 48,002 |  |  |
| s3_ag_sale_z | d_l_ag_fc_sale | d_l_ag_fc_sale | -0.0131*** | 0.000 | 48,002 |  |  |
| s3_ag_sale_zcapx | d_h_ag_fc_sale | d_h_ag_fc_sale | -0.0666*** | 0.000 | 46,743 |  |  |
| s3_ag_sale_zcapx | d_l_ag_fc_sale | d_l_ag_fc_sale | -0.0664*** | 0.000 | 46,743 |  |  |
| s3_ag_va_a_dxrd | d_h_ag_fc_va_a | d_h_ag_fc_va_a | 0.2520*** | 0.000 | 36,247 |  |  |
| s3_ag_va_a_dxrd | d_l_ag_fc_va_a | d_l_ag_fc_va_a | 0.2114*** | 0.000 | 36,247 |  |  |
| s3_ag_va_a_z | d_h_ag_fc_va_a | d_h_ag_fc_va_a | -0.1259*** | 0.000 | 46,231 |  |  |
| s3_ag_va_a_z | d_l_ag_fc_va_a | d_l_ag_fc_va_a | -0.1277*** | 0.000 | 46,231 |  |  |
| s3_ag_va_a_zcapx | d_h_ag_fc_va_a | d_h_ag_fc_va_a | -0.0449*** | 0.000 | 46,261 |  |  |
| s3_ag_va_a_zcapx | d_l_ag_fc_va_a | d_l_ag_fc_va_a | -0.0432*** | 0.000 | 46,261 |  |  |
| s3_ag_va_dxrd | d_h_ag_fc_va | d_h_ag_fc_va | 0.2912*** | 0.000 | 3,730 |  |  |
| s3_ag_va_dxrd | d_l_ag_fc_va | d_l_ag_fc_va | 0.2380** | 0.019 | 3,730 |  |  |
| s3_ag_va_z | d_h_ag_fc_va | d_h_ag_fc_va | -0.0112*** | 0.000 | 4,854 |  |  |
| s3_ag_va_z | d_l_ag_fc_va | d_l_ag_fc_va | -0.0116*** | 0.000 | 4,854 |  |  |
| s3_ag_va_zcapx | d_h_ag_fc_va | d_h_ag_fc_va | -0.0150 | 0.527 | 4,840 |  |  |
| s3_ag_va_zcapx | d_l_ag_fc_va | d_l_ag_fc_va | -0.0393*** | 0.000 | 4,840 |  |  |
| s3_bg_sale_dxrd | d_h_bg_fc_sale | d_h_bg_fc_sale | 0.5315*** | 0.000 | 36,575 |  |  |
| s3_bg_sale_dxrd | d_l_bg_fc_sale | d_l_bg_fc_sale | 0.5437*** | 0.000 | 36,575 |  |  |
| s3_bg_sale_z | d_h_bg_fc_sale | d_h_bg_fc_sale | -0.0380 | 0.103 | 48,002 |  |  |
| s3_bg_sale_z | d_l_bg_fc_sale | d_l_bg_fc_sale | -0.0127*** | 0.000 | 48,002 |  |  |
| s3_bg_sale_zcapx | d_h_bg_fc_sale | d_h_bg_fc_sale | -0.0663*** | 0.000 | 46,743 |  |  |
| s3_bg_sale_zcapx | d_l_bg_fc_sale | d_l_bg_fc_sale | -0.0667*** | 0.000 | 46,743 |  |  |
| s3_bg_va_a_dxrd | d_h_bg_fc_va_a | d_h_bg_fc_va_a | 0.2388*** | 0.000 | 36,247 |  |  |
| s3_bg_va_a_dxrd | d_l_bg_fc_va_a | d_l_bg_fc_va_a | 0.2224*** | 0.000 | 36,247 |  |  |
| s3_bg_va_a_z | d_h_bg_fc_va_a | d_h_bg_fc_va_a | -0.1300*** | 0.000 | 46,231 |  |  |
| s3_bg_va_a_z | d_l_bg_fc_va_a | d_l_bg_fc_va_a | -0.1238*** | 0.000 | 46,231 |  |  |
| s3_bg_va_a_zcapx | d_h_bg_fc_va_a | d_h_bg_fc_va_a | -0.0442*** | 0.000 | 46,261 |  |  |
| s3_bg_va_a_zcapx | d_l_bg_fc_va_a | d_l_bg_fc_va_a | -0.0439*** | 0.000 | 46,261 |  |  |
| s3_bg_va_dxrd | d_h_bg_fc_va | d_h_bg_fc_va | 0.2268*** | 0.004 | 3,730 |  |  |
| s3_bg_va_dxrd | d_l_bg_fc_va | d_l_bg_fc_va | 0.2852*** | 0.000 | 3,730 |  |  |
| s3_bg_va_z | d_h_bg_fc_va | d_h_bg_fc_va | -0.0106*** | 0.000 | 4,854 |  |  |
| s3_bg_va_z | d_l_bg_fc_va | d_l_bg_fc_va | -0.0123*** | 0.000 | 4,854 |  |  |
| s3_bg_va_zcapx | d_h_bg_fc_va | d_h_bg_fc_va | -0.0286* | 0.087 | 4,840 |  |  |
| s3_bg_va_zcapx | d_l_bg_fc_va | d_l_bg_fc_va | -0.0296** | 0.018 | 4,840 |  |  |
| s3_ba_sale_dxrd | d_h_ba_fc_sale | d_h_ba_fc_sale | 0.5264*** | 0.000 | 36,575 |  |  |
| s3_ba_sale_dxrd | d_l_ba_fc_sale | d_l_ba_fc_sale | 0.5524*** | 0.000 | 36,575 |  |  |
| s3_ba_sale_z | d_h_ba_fc_sale | d_h_ba_fc_sale | -0.0360* | 0.093 | 48,002 |  |  |
| s3_ba_sale_z | d_l_ba_fc_sale | d_l_ba_fc_sale | -0.0119*** | 0.000 | 48,002 |  |  |
| s3_ba_sale_zcapx | d_h_ba_fc_sale | d_h_ba_fc_sale | -0.0681*** | 0.000 | 46,743 |  |  |
| s3_ba_sale_zcapx | d_l_ba_fc_sale | d_l_ba_fc_sale | -0.0645*** | 0.000 | 46,743 |  |  |
| s3_ba_va_a_dxrd | d_h_ba_fc_va_a | d_h_ba_fc_va_a | 0.2306*** | 0.000 | 36,247 |  |  |
| s3_ba_va_a_dxrd | d_l_ba_fc_va_a | d_l_ba_fc_va_a | 0.2301*** | 0.000 | 36,247 |  |  |
| s3_ba_va_a_z | d_h_ba_fc_va_a | d_h_ba_fc_va_a | -0.1220*** | 0.000 | 46,231 |  |  |
| s3_ba_va_a_z | d_l_ba_fc_va_a | d_l_ba_fc_va_a | -0.1334*** | 0.000 | 46,231 |  |  |
| s3_ba_va_a_zcapx | d_h_ba_fc_va_a | d_h_ba_fc_va_a | -0.0429*** | 0.000 | 46,261 |  |  |
| s3_ba_va_a_zcapx | d_l_ba_fc_va_a | d_l_ba_fc_va_a | -0.0454*** | 0.000 | 46,261 |  |  |
| s3_ba_va_dxrd | d_h_ba_fc_va | d_h_ba_fc_va | 0.1984** | 0.024 | 3,730 |  |  |
| s3_ba_va_dxrd | d_l_ba_fc_va | d_l_ba_fc_va | 0.3899*** | 0.000 | 3,730 |  |  |
| s3_ba_va_z | d_h_ba_fc_va | d_h_ba_fc_va | -0.0107*** | 0.000 | 4,854 |  |  |
| s3_ba_va_z | d_l_ba_fc_va | d_l_ba_fc_va | -0.0130*** | 0.000 | 4,854 |  |  |
| s3_ba_va_zcapx | d_h_ba_fc_va | d_h_ba_fc_va | -0.0438*** | 0.000 | 4,840 |  |  |
| s3_ba_va_zcapx | d_l_ba_fc_va | d_l_ba_fc_va | -0.0056 | 0.752 | 4,840 |  |  |
| s4_va_dxrd | dev_va | dev_va | 0.2605*** | 0.000 | 3,730 |  |  |
| s4_va_z | dev_va | dev_va | -0.0114*** | 0.000 | 4,854 |  |  |
| s4_va_zcapx | dev_va | dev_va | -0.0291** | 0.012 | 4,840 |  |  |
| s4_sale_dxrd | dev_sale | dev_sale | 0.5376*** | 0.000 | 36,575 |  |  |
| s4_sale_z | dev_sale | dev_sale | -0.0257** | 0.024 | 48,002 |  |  |
| s4_sale_zcapx | dev_sale | dev_sale | -0.0665*** | 0.000 | 46,743 |  |  |
| s4_va_a_dxrd | dev_va_a | dev_va_a | 0.2304*** | 0.000 | 36,247 |  |  |
| s4_va_a_z | dev_va_a | dev_va_a | -0.1268*** | 0.000 | 46,231 |  |  |
| s4_va_a_zcapx | dev_va_a | dev_va_a | -0.0440*** | 0.000 | 46,261 |  |  |
| s4_asym_va_va_dxrd | dev_g_h_va | dev_g_h_va | 0.4026*** | 0.000 | 3,710 |  |  |
| s4_asym_va_va_dxrd | dev_g_l_va | dev_g_l_va | 0.1544* | 0.060 | 3,710 |  |  |
| s4_asym_va_va_z | dev_g_h_va | dev_g_h_va | -0.0093*** | 0.001 | 4,854 |  |  |
| s4_asym_va_va_z | dev_g_l_va | dev_g_l_va | -0.0132*** | 0.001 | 4,854 |  |  |
| s4_asym_va_va_zcapx | dev_g_h_va | dev_g_h_va | -0.0169 | 0.221 | 4,802 |  |  |
| s4_asym_va_va_zcapx | dev_g_l_va | dev_g_l_va | -0.0402** | 0.021 | 4,802 |  |  |
| s4_asym_sale_sale_dxrd | dev_g_h_sale | dev_g_h_sale | 0.5701*** | 0.000 | 36,573 |  |  |
| s4_asym_sale_sale_dxrd | dev_g_l_sale | dev_g_l_sale | 0.5076*** | 0.000 | 36,573 |  |  |
| s4_asym_sale_sale_z | dev_g_h_sale | dev_g_h_sale | 0.0053 | 0.706 | 48,002 |  |  |
| s4_asym_sale_sale_z | dev_g_l_sale | dev_g_l_sale | -0.0559 | 0.120 | 48,002 |  |  |
| s4_asym_sale_sale_zcapx | dev_g_h_sale | dev_g_h_sale | -0.0722*** | 0.000 | 46,740 |  |  |
| s4_asym_sale_sale_zcapx | dev_g_l_sale | dev_g_l_sale | -0.0611*** | 0.000 | 46,740 |  |  |
| s4_asym_va_va_a_dxrd | dev_g_h_va | dev_g_h_va | 0.4263*** | 0.000 | 3,702 |  |  |
| s4_asym_va_va_a_dxrd | dev_g_l_va_a | dev_g_l_va_a | 0.1029 | 0.116 | 3,702 |  |  |
| s4_asym_va_va_a_z | dev_g_h_va | dev_g_h_va | -0.0075** | 0.014 | 4,990 |  |  |
| s4_asym_va_va_a_z | dev_g_l_va_a | dev_g_l_va_a | -0.0352*** | 0.000 | 4,990 |  |  |
| s4_asym_va_va_a_zcapx | dev_g_h_va | dev_g_h_va | -0.0177 | 0.219 | 4,779 |  |  |
| s4_asym_va_va_a_zcapx | dev_g_l_va_a | dev_g_l_va_a | -0.0404*** | 0.010 | 4,779 |  |  |
| s4_asym_va_a_va_a_dxrd | dev_g_h_va_a | dev_g_h_va_a | 0.3003*** | 0.000 | 36,159 |  |  |
| s4_asym_va_a_va_a_dxrd | dev_g_l_va_a | dev_g_l_va_a | 0.1722*** | 0.000 | 36,159 |  |  |
| s4_asym_va_a_va_a_z | dev_g_h_va_a | dev_g_h_va_a | -0.0608*** | 0.000 | 46,231 |  |  |
| s4_asym_va_a_va_a_z | dev_g_l_va_a | dev_g_l_va_a | -0.1827*** | 0.000 | 46,231 |  |  |
| s4_asym_va_a_va_a_zcapx | dev_g_h_va_a | dev_g_h_va_a | -0.0414*** | 0.000 | 46,124 |  |  |
| s4_asym_va_a_va_a_zcapx | dev_g_l_va_a | dev_g_l_va_a | -0.0463*** | 0.000 | 46,124 |  |  |
| s4_kz_sale_dxrd | d_sale_kz1 | d_sale_kz1 | 0.5447*** | 0.000 | 36,575 | 2.33 | 0.127 |
| s4_kz_sale_dxrd | d_sale_kz2 | d_sale_kz2 | 0.4950*** | 0.000 | 36,575 | 2.33 | 0.127 |
| s4_kz_sale_dxrd | d_sale_kz3 | d_sale_kz3 | 0.5475*** | 0.000 | 36,575 | 2.33 | 0.127 |
| s4_kz_sale_dxrd | d_sale_kz4 | d_sale_kz4 | 0.6325*** | 0.000 | 36,575 | 2.33 | 0.127 |
| s4_kz_sale_z | d_sale_kz1 | d_sale_kz1 | -0.0223*** | 0.000 | 48,002 | 49.98 | 0.000 |
| s4_kz_sale_z | d_sale_kz2 | d_sale_kz2 | -0.0176*** | 0.000 | 48,002 | 49.98 | 0.000 |
| s4_kz_sale_z | d_sale_kz3 | d_sale_kz3 | -0.0117*** | 0.000 | 48,002 | 49.98 | 0.000 |
| s4_kz_sale_z | d_sale_kz4 | d_sale_kz4 | -0.0056*** | 0.000 | 48,002 | 49.98 | 0.000 |
| s4_kz_sale_zcapx | d_sale_kz1 | d_sale_kz1 | -0.0894*** | 0.000 | 46,743 | 32.07 | 0.000 |
| s4_kz_sale_zcapx | d_sale_kz2 | d_sale_kz2 | -0.0836*** | 0.000 | 46,743 | 32.07 | 0.000 |
| s4_kz_sale_zcapx | d_sale_kz3 | d_sale_kz3 | -0.0554*** | 0.000 | 46,743 | 32.07 | 0.000 |
| s4_kz_sale_zcapx | d_sale_kz4 | d_sale_kz4 | -0.0305*** | 0.000 | 46,743 | 32.07 | 0.000 |
| s4_kz_va_a_dxrd | d_va_a_kz1 | d_va_a_kz1 | 0.2515*** | 0.000 | 36,247 | 0.04 | 0.832 |
| s4_kz_va_a_dxrd | d_va_a_kz2 | d_va_a_kz2 | 0.2270*** | 0.000 | 36,247 | 0.04 | 0.832 |
| s4_kz_va_a_dxrd | d_va_a_kz3 | d_va_a_kz3 | 0.2363*** | 0.000 | 36,247 | 0.04 | 0.832 |
| s4_kz_va_a_dxrd | d_va_a_kz4 | d_va_a_kz4 | 0.2424*** | 0.000 | 36,247 | 0.04 | 0.832 |
| s4_kz_va_a_z | d_va_a_kz1 | d_va_a_kz1 | -0.2041*** | 0.000 | 46,231 | 83.19 | 0.000 |
| s4_kz_va_a_z | d_va_a_kz2 | d_va_a_kz2 | -0.1549*** | 0.000 | 46,231 | 83.19 | 0.000 |
| s4_kz_va_a_z | d_va_a_kz3 | d_va_a_kz3 | -0.1077*** | 0.000 | 46,231 | 83.19 | 0.000 |
| s4_kz_va_a_z | d_va_a_kz4 | d_va_a_kz4 | -0.0588*** | 0.000 | 46,231 | 83.19 | 0.000 |
| s4_kz_va_a_zcapx | d_va_a_kz1 | d_va_a_kz1 | -0.0543*** | 0.000 | 46,261 | 20.66 | 0.000 |
| s4_kz_va_a_zcapx | d_va_a_kz2 | d_va_a_kz2 | -0.0488*** | 0.000 | 46,261 | 20.66 | 0.000 |
| s4_kz_va_a_zcapx | d_va_a_kz3 | d_va_a_kz3 | -0.0414*** | 0.000 | 46,261 | 20.66 | 0.000 |
| s4_kz_va_a_zcapx | d_va_a_kz4 | d_va_a_kz4 | -0.0194*** | 0.000 | 46,261 | 20.66 | 0.000 |
| s4_kz_va_dxrd | d_va_kz1 | d_va_kz1 | 0.5749*** | 0.000 | 3,730 | 11.59 | 0.001 |
| s4_kz_va_dxrd | d_va_kz2 | d_va_kz2 | 0.2598*** | 0.000 | 3,730 | 11.59 | 0.001 |
| s4_kz_va_dxrd | d_va_kz3 | d_va_kz3 | 0.1948** | 0.013 | 3,730 | 11.59 | 0.001 |
| s4_kz_va_dxrd | d_va_kz4 | d_va_kz4 | 0.1028 | 0.337 | 3,730 | 11.59 | 0.001 |
| s4_kz_va_z | d_va_kz1 | d_va_kz1 | -0.0126*** | 0.005 | 4,854 | 0.14 | 0.708 |
| s4_kz_va_z | d_va_kz2 | d_va_kz2 | -0.0291*** | 0.000 | 4,854 | 0.14 | 0.708 |
| s4_kz_va_z | d_va_kz3 | d_va_kz3 | -0.0270*** | 0.000 | 4,854 | 0.14 | 0.708 |
| s4_kz_va_z | d_va_kz4 | d_va_kz4 | -0.0147*** | 0.000 | 4,854 | 0.14 | 0.708 |
| s4_kz_va_zcapx | d_va_kz1 | d_va_kz1 | 0.0166 | 0.706 | 4,840 | 1.21 | 0.271 |
| s4_kz_va_zcapx | d_va_kz2 | d_va_kz2 | -0.0481*** | 0.005 | 4,840 | 1.21 | 0.271 |
| s4_kz_va_zcapx | d_va_kz3 | d_va_kz3 | -0.0251* | 0.093 | 4,840 | 1.21 | 0.271 |
| s4_kz_va_zcapx | d_va_kz4 | d_va_kz4 | -0.0350** | 0.020 | 4,840 | 1.21 | 0.271 |
