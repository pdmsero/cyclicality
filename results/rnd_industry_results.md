# R&D Industry Analysis: Cyclicality Coefficient Summary

Replication of `[1]_RND_Industry_data_final.do`.

## Key cyclicality coefficients

| Block | Label | Estimator | Cycle variable | Coef | SE | p | Sig | N |
|-------|-------|-----------|---------------|------|----|---|-----|---|
| raw_ols_vadd_sym | raw_ols_vadd_sym_A | Pooled OLS | g_vadd | 0.1445 | 0.0602 | 0.0163 | ** | 651 |
| raw_ols_vadd_sym | raw_ols_vadd_sym_B | FE OLS | g_vadd | 0.0752 | 0.0532 | 0.1578 |  | 651 |
| raw_ols_vadd_sym | raw_ols_vadd_sym_C | Pooled OLS | g_vadd | -0.0494 | 0.0094 | 0.0 | *** | 609 |
| raw_ols_vadd_sym | raw_ols_vadd_sym_D | FE OLS | g_vadd | -0.0474 | 0.0075 | 0.0 | *** | 609 |
| raw_ols_vadd_sym | raw_ols_vadd_sym_E | Pooled OLS | g_vadd | -0.0817 | 0.0235 | 0.0005 | *** | 609 |
| raw_ols_vadd_sym | raw_ols_vadd_sym_F | FE OLS | g_vadd | -0.073 | 0.0203 | 0.0004 | *** | 609 |
| raw_ols_ship_sym | raw_ols_ship_sym_A | Pooled OLS | g_ship | 0.2832 | 0.0728 | 0.0001 | *** | 651 |
| raw_ols_ship_sym | raw_ols_ship_sym_B | FE OLS | g_ship | 0.1953 | 0.0625 | 0.0019 | *** | 651 |
| raw_ols_ship_sym | raw_ols_ship_sym_C | Pooled OLS | g_ship | -0.0134 | 0.0021 | 0.0 | *** | 609 |
| raw_ols_ship_sym | raw_ols_ship_sym_D | FE OLS | g_ship | -0.0147 | 0.0018 | 0.0 | *** | 609 |
| raw_ols_ship_sym | raw_ols_ship_sym_E | Pooled OLS | g_ship | -0.116 | 0.0336 | 0.0006 | *** | 609 |
| raw_ols_ship_sym | raw_ols_ship_sym_F | FE OLS | g_ship | -0.1306 | 0.0267 | 0.0 | *** | 609 |
| raw_ols_vadd_asym | raw_ols_vadd_asym_A | Pooled OLS | g_h_vadd | 0.1564 | 0.0859 | 0.0685 | * | 651 |
| raw_ols_vadd_asym | raw_ols_vadd_asym_A | Pooled OLS | g_l_vadd | 0.1213 | 0.1111 | 0.2748 |  | 651 |
| raw_ols_vadd_asym | raw_ols_vadd_asym_B | FE OLS | g_h_vadd | 0.1376 | 0.0784 | 0.0796 | * | 651 |
| raw_ols_vadd_asym | raw_ols_vadd_asym_B | FE OLS | g_l_vadd | -0.0281 | 0.0999 | 0.7783 |  | 651 |
| raw_ols_vadd_asym | raw_ols_vadd_asym_C | Pooled OLS | g_h_vadd | -0.0461 | 0.0097 | 0.0 | *** | 609 |
| raw_ols_vadd_asym | raw_ols_vadd_asym_C | Pooled OLS | g_l_vadd | -0.0558 | 0.0212 | 0.0084 | *** | 609 |
| raw_ols_vadd_asym | raw_ols_vadd_asym_D | FE OLS | g_h_vadd | -0.0434 | 0.0086 | 0.0 | *** | 609 |
| raw_ols_vadd_asym | raw_ols_vadd_asym_D | FE OLS | g_l_vadd | -0.0539 | 0.0203 | 0.0081 | *** | 609 |
| raw_ols_vadd_asym | raw_ols_vadd_asym_E | Pooled OLS | g_h_vadd | -0.0696 | 0.0284 | 0.0141 | ** | 609 |
| raw_ols_vadd_asym | raw_ols_vadd_asym_E | Pooled OLS | g_l_vadd | -0.105 | 0.0448 | 0.0191 | ** | 609 |
| raw_ols_vadd_asym | raw_ols_vadd_asym_F | FE OLS | g_h_vadd | -0.0807 | 0.0311 | 0.0096 | *** | 609 |
| raw_ols_vadd_asym | raw_ols_vadd_asym_F | FE OLS | g_l_vadd | -0.0603 | 0.0324 | 0.0629 | * | 609 |
| raw_ols_ship_asym | raw_ols_ship_asym_A | Pooled OLS | g_h_ship | 0.2487 | 0.0934 | 0.0078 | *** | 651 |
| raw_ols_ship_asym | raw_ols_ship_asym_A | Pooled OLS | g_l_ship | 0.3693 | 0.1662 | 0.0263 | ** | 651 |
| raw_ols_ship_asym | raw_ols_ship_asym_B | FE OLS | g_h_ship | 0.2175 | 0.0866 | 0.0123 | ** | 651 |
| raw_ols_ship_asym | raw_ols_ship_asym_B | FE OLS | g_l_ship | 0.1501 | 0.1403 | 0.2853 |  | 651 |
| raw_ols_ship_asym | raw_ols_ship_asym_C | Pooled OLS | g_h_ship | -0.0179 | 0.0025 | 0.0 | *** | 609 |
| raw_ols_ship_asym | raw_ols_ship_asym_C | Pooled OLS | g_l_ship | -0.0022 | 0.0033 | 0.5075 |  | 609 |
| raw_ols_ship_asym | raw_ols_ship_asym_D | FE OLS | g_h_ship | -0.0193 | 0.0024 | 0.0 | *** | 609 |
| raw_ols_ship_asym | raw_ols_ship_asym_D | FE OLS | g_l_ship | -0.0058 | 0.0035 | 0.0997 | * | 609 |
| raw_ols_ship_asym | raw_ols_ship_asym_E | Pooled OLS | g_h_ship | -0.082 | 0.0379 | 0.0306 | ** | 609 |
| raw_ols_ship_asym | raw_ols_ship_asym_E | Pooled OLS | g_l_ship | -0.2009 | 0.083 | 0.0155 | ** | 609 |
| raw_ols_ship_asym | raw_ols_ship_asym_F | FE OLS | g_h_ship | -0.126 | 0.0359 | 0.0005 | *** | 609 |
| raw_ols_ship_asym | raw_ols_ship_asym_F | FE OLS | g_l_ship | -0.1398 | 0.0556 | 0.0122 | ** | 609 |
| mi_ols_vadd_sym | mi_ols_vadd_sym_A | Pooled OLS | g_vadd | 0.1649 | 0.0554 | 0.0029 | *** | 800 |
| mi_ols_vadd_sym | mi_ols_vadd_sym_B | FE OLS | g_vadd | 0.0874 | 0.0485 | 0.0723 | * | 800 |
| mi_ols_vadd_sym | mi_ols_vadd_sym_C | Pooled OLS | g_vadd | -0.045 | 0.0081 | 0.0 | *** | 780 |
| mi_ols_vadd_sym | mi_ols_vadd_sym_D | FE OLS | g_vadd | -0.0435 | 0.0063 | 0.0 | *** | 780 |
| mi_ols_vadd_sym | mi_ols_vadd_sym_E | Pooled OLS | g_vadd | -0.0811 | 0.0201 | 0.0001 | *** | 780 |
| mi_ols_vadd_sym | mi_ols_vadd_sym_F | FE OLS | g_vadd | -0.0679 | 0.0177 | 0.0001 | *** | 780 |
| mi_ols_ship_sym | mi_ols_ship_sym_A | Pooled OLS | g_ship | 0.2762 | 0.064 | 0.0 | *** | 800 |
| mi_ols_ship_sym | mi_ols_ship_sym_B | FE OLS | g_ship | 0.1803 | 0.0553 | 0.0011 | *** | 800 |
| mi_ols_ship_sym | mi_ols_ship_sym_C | Pooled OLS | g_ship | -0.013 | 0.0018 | 0.0 | *** | 780 |
| mi_ols_ship_sym | mi_ols_ship_sym_D | FE OLS | g_ship | -0.0142 | 0.0015 | 0.0 | *** | 780 |
| mi_ols_ship_sym | mi_ols_ship_sym_E | Pooled OLS | g_ship | -0.1157 | 0.0282 | 0.0 | *** | 780 |
| mi_ols_ship_sym | mi_ols_ship_sym_F | FE OLS | g_ship | -0.119 | 0.0231 | 0.0 | *** | 780 |
| mi_ols_vadd_asym | mi_ols_vadd_asym_A | Pooled OLS | g_h_vadd | 0.1819 | 0.0805 | 0.0238 | ** | 800 |
| mi_ols_vadd_asym | mi_ols_vadd_asym_A | Pooled OLS | g_l_vadd | 0.1355 | 0.0968 | 0.1615 |  | 800 |
| mi_ols_vadd_asym | mi_ols_vadd_asym_B | FE OLS | g_h_vadd | 0.158 | 0.0746 | 0.0344 | ** | 800 |
| mi_ols_vadd_asym | mi_ols_vadd_asym_B | FE OLS | g_l_vadd | -0.0184 | 0.0871 | 0.8325 |  | 800 |
| mi_ols_vadd_asym | mi_ols_vadd_asym_C | Pooled OLS | g_h_vadd | -0.0429 | 0.0085 | 0.0 | *** | 780 |
| mi_ols_vadd_asym | mi_ols_vadd_asym_C | Pooled OLS | g_l_vadd | -0.0483 | 0.0169 | 0.0044 | *** | 780 |
| mi_ols_vadd_asym | mi_ols_vadd_asym_D | FE OLS | g_h_vadd | -0.0414 | 0.0075 | 0.0 | *** | 780 |
| mi_ols_vadd_asym | mi_ols_vadd_asym_D | FE OLS | g_l_vadd | -0.0465 | 0.0155 | 0.0028 | *** | 780 |
| mi_ols_vadd_asym | mi_ols_vadd_asym_E | Pooled OLS | g_h_vadd | -0.0676 | 0.0255 | 0.0079 | *** | 780 |
| mi_ols_vadd_asym | mi_ols_vadd_asym_E | Pooled OLS | g_l_vadd | -0.1034 | 0.0351 | 0.0032 | *** | 780 |
| mi_ols_vadd_asym | mi_ols_vadd_asym_F | FE OLS | g_h_vadd | -0.0712 | 0.0278 | 0.0106 | ** | 780 |
| mi_ols_vadd_asym | mi_ols_vadd_asym_F | FE OLS | g_l_vadd | -0.0631 | 0.0289 | 0.0291 | ** | 780 |
| mi_ols_ship_asym | mi_ols_ship_asym_A | Pooled OLS | g_h_ship | 0.2759 | 0.0865 | 0.0014 | *** | 800 |
| mi_ols_ship_asym | mi_ols_ship_asym_A | Pooled OLS | g_l_ship | 0.2767 | 0.1247 | 0.0265 | ** | 800 |
| mi_ols_ship_asym | mi_ols_ship_asym_B | FE OLS | g_h_ship | 0.2306 | 0.0812 | 0.0046 | *** | 800 |
| mi_ols_ship_asym | mi_ols_ship_asym_B | FE OLS | g_l_ship | 0.0909 | 0.1118 | 0.4164 |  | 800 |
| mi_ols_ship_asym | mi_ols_ship_asym_C | Pooled OLS | g_h_ship | -0.0169 | 0.0023 | 0.0 | *** | 780 |
| mi_ols_ship_asym | mi_ols_ship_asym_C | Pooled OLS | g_l_ship | -0.0052 | 0.0027 | 0.0567 | * | 780 |
| mi_ols_ship_asym | mi_ols_ship_asym_D | FE OLS | g_h_ship | -0.0182 | 0.0022 | 0.0 | *** | 780 |
| mi_ols_ship_asym | mi_ols_ship_asym_D | FE OLS | g_l_ship | -0.0075 | 0.0029 | 0.0092 | *** | 780 |
| mi_ols_ship_asym | mi_ols_ship_asym_E | Pooled OLS | g_h_ship | -0.0864 | 0.034 | 0.0111 | ** | 780 |
| mi_ols_ship_asym | mi_ols_ship_asym_E | Pooled OLS | g_l_ship | -0.1733 | 0.0575 | 0.0026 | *** | 780 |
| mi_ols_ship_asym | mi_ols_ship_asym_F | FE OLS | g_h_ship | -0.1228 | 0.0322 | 0.0001 | *** | 780 |
| mi_ols_ship_asym | mi_ols_ship_asym_F | FE OLS | g_l_ship | -0.1126 | 0.044 | 0.0107 | ** | 780 |
| raw_iv_vadd_sym | raw_iv_vadd_sym_A | Pooled IV | g_vadd | 0.1312 | 0.1295 | 0.3111 |  | 632 |
| raw_iv_vadd_sym | raw_iv_vadd_sym_B | FE IV | g_vadd | 0.148 | 0.0891 | 0.0965 | * | 632 |
| raw_iv_vadd_sym | raw_iv_vadd_sym_C | Pooled IV | g_vadd | -0.0326 | 0.008 | 0.0001 | *** | 590 |
| raw_iv_vadd_sym | raw_iv_vadd_sym_D | FE IV | g_vadd | -0.0294 | 0.007 | 0.0 | *** | 590 |
| raw_iv_vadd_sym | raw_iv_vadd_sym_E | Pooled IV | g_vadd | -0.1237 | 0.0399 | 0.002 | *** | 590 |
| raw_iv_vadd_sym | raw_iv_vadd_sym_F | FE IV | g_vadd | -0.0688 | 0.0559 | 0.2189 |  | 590 |
| raw_iv_ship_sym | raw_iv_ship_sym_A | Pooled IV | g_ship | 0.1828 | 0.1672 | 0.2742 |  | 632 |
| raw_iv_ship_sym | raw_iv_ship_sym_B | FE IV | g_ship | 0.1975 | 0.1097 | 0.0719 | * | 632 |
| raw_iv_ship_sym | raw_iv_ship_sym_C | Pooled IV | g_ship | -0.014 | 0.0038 | 0.0002 | *** | 590 |
| raw_iv_ship_sym | raw_iv_ship_sym_D | FE IV | g_ship | -0.0131 | 0.0039 | 0.0008 | *** | 590 |
| raw_iv_ship_sym | raw_iv_ship_sym_E | Pooled IV | g_ship | -0.1735 | 0.0506 | 0.0006 | *** | 590 |
| raw_iv_ship_sym | raw_iv_ship_sym_F | FE IV | g_ship | -0.0972 | 0.0689 | 0.1585 |  | 590 |
| raw_iv_vadd_asym_split | raw_iv_vadd_asym_split_A | Pooled IV | g_h_vadd | 0.0335 | 0.376 | 0.929 |  | 632 |
| raw_iv_vadd_asym_split | raw_iv_vadd_asym_split_A | Pooled IV | g_l_vadd | 0.2565 | 0.4614 | 0.5783 |  | 632 |
| raw_iv_vadd_asym_split | raw_iv_vadd_asym_split_B | FE IV | g_h_vadd | 0.1158 | 0.4308 | 0.788 |  | 632 |
| raw_iv_vadd_asym_split | raw_iv_vadd_asym_split_B | FE IV | g_l_vadd | 0.1937 | 0.4753 | 0.6836 |  | 632 |
| raw_iv_vadd_asym_split | raw_iv_vadd_asym_split_C | Pooled IV | g_h_vadd | -0.0111 | 0.0231 | 0.6299 |  | 590 |
| raw_iv_vadd_asym_split | raw_iv_vadd_asym_split_C | Pooled IV | g_l_vadd | -0.0571 | 0.0324 | 0.0782 | * | 590 |
| raw_iv_vadd_asym_split | raw_iv_vadd_asym_split_D | FE IV | g_h_vadd | -0.0091 | 0.016 | 0.5689 |  | 590 |
| raw_iv_vadd_asym_split | raw_iv_vadd_asym_split_D | FE IV | g_l_vadd | -0.0535 | 0.0276 | 0.0531 | * | 590 |
| raw_iv_vadd_asym_split | raw_iv_vadd_asym_split_E | Pooled IV | g_h_vadd | -0.0035 | 0.1363 | 0.9796 |  | 590 |
| raw_iv_vadd_asym_split | raw_iv_vadd_asym_split_E | Pooled IV | g_l_vadd | -0.2494 | 0.1607 | 0.1207 |  | 590 |
| raw_iv_vadd_asym_split | raw_iv_vadd_asym_split_F | FE IV | g_h_vadd | 0.0362 | 0.133 | 0.7853 |  | 590 |
| raw_iv_vadd_asym_split | raw_iv_vadd_asym_split_F | FE IV | g_l_vadd | -0.1874 | 0.09 | 0.0373 | ** | 590 |
| raw_iv_ship_asym_split | raw_iv_ship_asym_split_A | Pooled IV | g_h_ship | 0.0793 | 0.4287 | 0.8533 |  | 632 |
| raw_iv_ship_asym_split | raw_iv_ship_asym_split_A | Pooled IV | g_l_ship | 0.3194 | 0.5401 | 0.5543 |  | 632 |
| raw_iv_ship_asym_split | raw_iv_ship_asym_split_B | FE IV | g_h_ship | 0.1961 | 0.4982 | 0.6939 |  | 632 |
| raw_iv_ship_asym_split | raw_iv_ship_asym_split_B | FE IV | g_l_ship | 0.2041 | 0.5836 | 0.7266 |  | 632 |
| raw_iv_ship_asym_split | raw_iv_ship_asym_split_C | Pooled IV | g_h_ship | -0.0063 | 0.0094 | 0.5036 |  | 590 |
| raw_iv_ship_asym_split | raw_iv_ship_asym_split_C | Pooled IV | g_l_ship | -0.023 | 0.015 | 0.1258 |  | 590 |
| raw_iv_ship_asym_split | raw_iv_ship_asym_split_D | FE IV | g_h_ship | -0.0055 | 0.0094 | 0.5553 |  | 590 |
| raw_iv_ship_asym_split | raw_iv_ship_asym_split_D | FE IV | g_l_ship | -0.0226 | 0.0151 | 0.1332 |  | 590 |
| raw_iv_ship_asym_split | raw_iv_ship_asym_split_E | Pooled IV | g_h_ship | -0.0192 | 0.1374 | 0.8888 |  | 590 |
| raw_iv_ship_asym_split | raw_iv_ship_asym_split_E | Pooled IV | g_l_ship | -0.3389 | 0.1701 | 0.0463 | ** | 590 |
| raw_iv_ship_asym_split | raw_iv_ship_asym_split_F | FE IV | g_h_ship | 0.0225 | 0.1532 | 0.8834 |  | 590 |
| raw_iv_ship_asym_split | raw_iv_ship_asym_split_F | FE IV | g_l_ship | -0.24 | 0.1004 | 0.0169 | ** | 590 |
| raw_iv_vadd_asym_sym_iv | raw_iv_vadd_asym_sym_iv_A | Pooled IV | g_h_vadd | -0.634 | 0.5334 | 0.2345 |  | 632 |
| raw_iv_vadd_asym_sym_iv | raw_iv_vadd_asym_sym_iv_A | Pooled IV | g_l_vadd | 1.0888 | 0.7013 | 0.1205 |  | 632 |
| raw_iv_vadd_asym_sym_iv | raw_iv_vadd_asym_sym_iv_B | FE IV | g_h_vadd | -0.3693 | 0.5939 | 0.5341 |  | 632 |
| raw_iv_vadd_asym_sym_iv | raw_iv_vadd_asym_sym_iv_B | FE IV | g_l_vadd | 0.8182 | 0.719 | 0.2551 |  | 632 |
| raw_iv_vadd_asym_sym_iv | raw_iv_vadd_asym_sym_iv_C | Pooled IV | g_h_vadd | -0.0531 | 0.0249 | 0.0329 | ** | 590 |
| raw_iv_vadd_asym_sym_iv | raw_iv_vadd_asym_sym_iv_C | Pooled IV | g_l_vadd | -0.0091 | 0.0314 | 0.7716 |  | 590 |
| raw_iv_vadd_asym_sym_iv | raw_iv_vadd_asym_sym_iv_D | FE IV | g_h_vadd | -0.0366 | 0.021 | 0.0818 | * | 590 |
| raw_iv_vadd_asym_sym_iv | raw_iv_vadd_asym_sym_iv_D | FE IV | g_l_vadd | -0.0208 | 0.0256 | 0.4159 |  | 590 |
| raw_iv_vadd_asym_sym_iv | raw_iv_vadd_asym_sym_iv_E | Pooled IV | g_h_vadd | 0.6572 | 0.3121 | 0.0352 | ** | 590 |
| raw_iv_vadd_asym_sym_iv | raw_iv_vadd_asym_sym_iv_E | Pooled IV | g_l_vadd | -0.9905 | 0.3881 | 0.0107 | ** | 590 |
| raw_iv_vadd_asym_sym_iv | raw_iv_vadd_asym_sym_iv_F | FE IV | g_h_vadd | 0.6095 | 0.2566 | 0.0176 | ** | 590 |
| raw_iv_vadd_asym_sym_iv | raw_iv_vadd_asym_sym_iv_F | FE IV | g_l_vadd | -0.8681 | 0.3473 | 0.0124 | ** | 590 |
| raw_iv_ship_asym_sym_iv | raw_iv_ship_asym_sym_iv_A | Pooled IV | g_h_ship | -0.5052 | 0.4824 | 0.295 |  | 632 |
| raw_iv_ship_asym_sym_iv | raw_iv_ship_asym_sym_iv_A | Pooled IV | g_l_ship | 1.0893 | 0.6539 | 0.0957 | * | 632 |
| raw_iv_ship_asym_sym_iv | raw_iv_ship_asym_sym_iv_B | FE IV | g_h_ship | -0.3104 | 0.5955 | 0.6022 |  | 632 |
| raw_iv_ship_asym_sym_iv | raw_iv_ship_asym_sym_iv_B | FE IV | g_l_ship | 0.8953 | 0.7863 | 0.2549 |  | 632 |
| raw_iv_ship_asym_sym_iv | raw_iv_ship_asym_sym_iv_C | Pooled IV | g_h_ship | -0.0123 | 0.0101 | 0.2223 |  | 590 |
| raw_iv_ship_asym_sym_iv | raw_iv_ship_asym_sym_iv_C | Pooled IV | g_l_ship | -0.016 | 0.0134 | 0.2311 |  | 590 |
| raw_iv_ship_asym_sym_iv | raw_iv_ship_asym_sym_iv_D | FE IV | g_h_ship | -0.0089 | 0.01 | 0.3737 |  | 590 |
| raw_iv_ship_asym_sym_iv | raw_iv_ship_asym_sym_iv_D | FE IV | g_l_ship | -0.0185 | 0.019 | 0.3308 |  | 590 |
| raw_iv_ship_asym_sym_iv | raw_iv_ship_asym_sym_iv_E | Pooled IV | g_h_ship | 0.5042 | 0.2355 | 0.0323 | ** | 590 |
| raw_iv_ship_asym_sym_iv | raw_iv_ship_asym_sym_iv_E | Pooled IV | g_l_ship | -0.9659 | 0.3142 | 0.0021 | *** | 590 |
| raw_iv_ship_asym_sym_iv | raw_iv_ship_asym_sym_iv_F | FE IV | g_h_ship | 0.5767 | 0.2485 | 0.0203 | ** | 590 |
| raw_iv_ship_asym_sym_iv | raw_iv_ship_asym_sym_iv_F | FE IV | g_l_ship | -0.9436 | 0.3321 | 0.0045 | *** | 590 |
| mi_iv_vadd_sym | mi_iv_vadd_sym_A | Pooled IV | g_vadd | 0.1398 | 0.1107 | 0.2067 |  | 780 |
| mi_iv_vadd_sym | mi_iv_vadd_sym_B | FE IV | g_vadd | 0.149 | 0.0939 | 0.1127 |  | 780 |
| mi_iv_vadd_sym | mi_iv_vadd_sym_C | Pooled IV | g_vadd | -0.0296 | 0.0062 | 0.0 | *** | 760 |
| mi_iv_vadd_sym | mi_iv_vadd_sym_D | FE IV | g_vadd | -0.0272 | 0.0059 | 0.0 | *** | 760 |
| mi_iv_vadd_sym | mi_iv_vadd_sym_E | Pooled IV | g_vadd | -0.0903 | 0.033 | 0.0061 | *** | 760 |
| mi_iv_vadd_sym | mi_iv_vadd_sym_F | FE IV | g_vadd | -0.0479 | 0.0456 | 0.2939 |  | 760 |
| mi_iv_ship_sym | mi_iv_ship_sym_A | Pooled IV | g_ship | 0.1852 | 0.14 | 0.1859 |  | 780 |
| mi_iv_ship_sym | mi_iv_ship_sym_B | FE IV | g_ship | 0.1926 | 0.1138 | 0.0906 | * | 780 |
| mi_iv_ship_sym | mi_iv_ship_sym_C | Pooled IV | g_ship | -0.0122 | 0.003 | 0.0 | *** | 760 |
| mi_iv_ship_sym | mi_iv_ship_sym_D | FE IV | g_ship | -0.0117 | 0.003 | 0.0001 | *** | 760 |
| mi_iv_ship_sym | mi_iv_ship_sym_E | Pooled IV | g_ship | -0.1178 | 0.041 | 0.004 | *** | 760 |
| mi_iv_ship_sym | mi_iv_ship_sym_F | FE IV | g_ship | -0.0623 | 0.055 | 0.2574 |  | 760 |
| mi_iv_vadd_asym_split | mi_iv_vadd_asym_split_A | Pooled IV | g_h_vadd | -0.1019 | 0.3456 | 0.7681 |  | 780 |
| mi_iv_vadd_asym_split | mi_iv_vadd_asym_split_A | Pooled IV | g_l_vadd | 0.4445 | 0.428 | 0.299 |  | 780 |
| mi_iv_vadd_asym_split | mi_iv_vadd_asym_split_B | FE IV | g_h_vadd | -0.0369 | 0.4418 | 0.9333 |  | 780 |
| mi_iv_vadd_asym_split | mi_iv_vadd_asym_split_B | FE IV | g_l_vadd | 0.3956 | 0.4713 | 0.4012 |  | 780 |
| mi_iv_vadd_asym_split | mi_iv_vadd_asym_split_C | Pooled IV | g_h_vadd | -0.0218 | 0.017 | 0.1993 |  | 760 |
| mi_iv_vadd_asym_split | mi_iv_vadd_asym_split_C | Pooled IV | g_l_vadd | -0.0378 | 0.0235 | 0.107 |  | 760 |
| mi_iv_vadd_asym_split | mi_iv_vadd_asym_split_D | FE IV | g_h_vadd | -0.0148 | 0.0125 | 0.2368 |  | 760 |
| mi_iv_vadd_asym_split | mi_iv_vadd_asym_split_D | FE IV | g_l_vadd | -0.0417 | 0.0213 | 0.0505 | * | 760 |
| mi_iv_vadd_asym_split | mi_iv_vadd_asym_split_E | Pooled IV | g_h_vadd | 0.0933 | 0.1116 | 0.4031 |  | 760 |
| mi_iv_vadd_asym_split | mi_iv_vadd_asym_split_E | Pooled IV | g_l_vadd | -0.3072 | 0.135 | 0.0229 | ** | 760 |
| mi_iv_vadd_asym_split | mi_iv_vadd_asym_split_F | FE IV | g_h_vadd | 0.1191 | 0.1287 | 0.3545 |  | 760 |
| mi_iv_vadd_asym_split | mi_iv_vadd_asym_split_F | FE IV | g_l_vadd | -0.2593 | 0.1136 | 0.0225 | ** | 760 |
| mi_iv_ship_asym_split | mi_iv_ship_asym_split_A | Pooled IV | g_h_ship | -0.092 | 0.3911 | 0.814 |  | 780 |
| mi_iv_ship_asym_split | mi_iv_ship_asym_split_A | Pooled IV | g_l_ship | 0.5602 | 0.5124 | 0.2742 |  | 780 |
| mi_iv_ship_asym_split | mi_iv_ship_asym_split_B | FE IV | g_h_ship | 0.0058 | 0.5104 | 0.9909 |  | 780 |
| mi_iv_ship_asym_split | mi_iv_ship_asym_split_B | FE IV | g_l_ship | 0.4674 | 0.5843 | 0.4238 |  | 780 |
| mi_iv_ship_asym_split | mi_iv_ship_asym_split_C | Pooled IV | g_h_ship | -0.0088 | 0.0078 | 0.2566 |  | 760 |
| mi_iv_ship_asym_split | mi_iv_ship_asym_split_C | Pooled IV | g_l_ship | -0.0162 | 0.0121 | 0.1792 |  | 760 |
| mi_iv_ship_asym_split | mi_iv_ship_asym_split_D | FE IV | g_h_ship | -0.0075 | 0.008 | 0.3534 |  | 760 |
| mi_iv_ship_asym_split | mi_iv_ship_asym_split_D | FE IV | g_l_ship | -0.0174 | 0.0129 | 0.1775 |  | 760 |
| mi_iv_ship_asym_split | mi_iv_ship_asym_split_E | Pooled IV | g_h_ship | 0.1005 | 0.1232 | 0.4148 |  | 760 |
| mi_iv_ship_asym_split | mi_iv_ship_asym_split_E | Pooled IV | g_l_ship | -0.3932 | 0.1567 | 0.0121 | ** | 760 |
| mi_iv_ship_asym_split | mi_iv_ship_asym_split_F | FE IV | g_h_ship | 0.1267 | 0.1501 | 0.3984 |  | 760 |
| mi_iv_ship_asym_split | mi_iv_ship_asym_split_F | FE IV | g_l_ship | -0.3258 | 0.1369 | 0.0174 | ** | 760 |
| mi_iv_vadd_asym_sym_iv | mi_iv_vadd_asym_sym_iv_A | Pooled IV | g_h_vadd | -0.6637 | 0.4321 | 0.1245 |  | 780 |
| mi_iv_vadd_asym_sym_iv | mi_iv_vadd_asym_sym_iv_A | Pooled IV | g_l_vadd | 1.1523 | 0.5674 | 0.0423 | ** | 780 |
| mi_iv_vadd_asym_sym_iv | mi_iv_vadd_asym_sym_iv_B | FE IV | g_h_vadd | -0.5597 | 0.494 | 0.2572 |  | 780 |
| mi_iv_vadd_asym_sym_iv | mi_iv_vadd_asym_sym_iv_B | FE IV | g_l_vadd | 1.0726 | 0.6092 | 0.0783 | * | 780 |
| mi_iv_vadd_asym_sym_iv | mi_iv_vadd_asym_sym_iv_C | Pooled IV | g_h_vadd | -0.0456 | 0.0158 | 0.0038 | *** | 760 |
| mi_iv_vadd_asym_sym_iv | mi_iv_vadd_asym_sym_iv_C | Pooled IV | g_l_vadd | -0.011 | 0.0206 | 0.5914 |  | 760 |
| mi_iv_vadd_asym_sym_iv | mi_iv_vadd_asym_sym_iv_D | FE IV | g_h_vadd | -0.0328 | 0.0129 | 0.0112 | ** | 760 |
| mi_iv_vadd_asym_sym_iv | mi_iv_vadd_asym_sym_iv_D | FE IV | g_l_vadd | -0.0204 | 0.018 | 0.2587 |  | 760 |
| mi_iv_vadd_asym_sym_iv | mi_iv_vadd_asym_sym_iv_E | Pooled IV | g_h_vadd | 0.3664 | 0.1596 | 0.0217 | ** | 760 |
| mi_iv_vadd_asym_sym_iv | mi_iv_vadd_asym_sym_iv_E | Pooled IV | g_l_vadd | -0.6112 | 0.1917 | 0.0014 | *** | 760 |
| mi_iv_vadd_asym_sym_iv | mi_iv_vadd_asym_sym_iv_F | FE IV | g_h_vadd | 0.3822 | 0.1563 | 0.0145 | ** | 760 |
| mi_iv_vadd_asym_sym_iv | mi_iv_vadd_asym_sym_iv_F | FE IV | g_l_vadd | -0.5674 | 0.1959 | 0.0038 | *** | 760 |
| mi_iv_ship_asym_sym_iv | mi_iv_ship_asym_sym_iv_A | Pooled IV | g_h_ship | -0.641 | 0.4414 | 0.1465 |  | 780 |
| mi_iv_ship_asym_sym_iv | mi_iv_ship_asym_sym_iv_A | Pooled IV | g_l_ship | 1.2962 | 0.6175 | 0.0358 | ** | 780 |
| mi_iv_ship_asym_sym_iv | mi_iv_ship_asym_sym_iv_B | FE IV | g_h_ship | -0.5739 | 0.5227 | 0.2723 |  | 780 |
| mi_iv_ship_asym_sym_iv | mi_iv_ship_asym_sym_iv_B | FE IV | g_l_ship | 1.2676 | 0.7257 | 0.0807 | * | 780 |
| mi_iv_ship_asym_sym_iv | mi_iv_ship_asym_sym_iv_C | Pooled IV | g_h_ship | -0.0147 | 0.0076 | 0.0521 | * | 760 |
| mi_iv_ship_asym_sym_iv | mi_iv_ship_asym_sym_iv_C | Pooled IV | g_l_ship | -0.0091 | 0.0106 | 0.3896 |  | 760 |
| mi_iv_ship_asym_sym_iv | mi_iv_ship_asym_sym_iv_D | FE IV | g_h_ship | -0.0113 | 0.0069 | 0.0998 | * | 760 |
| mi_iv_ship_asym_sym_iv | mi_iv_ship_asym_sym_iv_D | FE IV | g_l_ship | -0.0123 | 0.0135 | 0.3596 |  | 760 |
| mi_iv_ship_asym_sym_iv | mi_iv_ship_asym_sym_iv_E | Pooled IV | g_h_ship | 0.3674 | 0.1669 | 0.0277 | ** | 760 |
| mi_iv_ship_asym_sym_iv | mi_iv_ship_asym_sym_iv_E | Pooled IV | g_l_ship | -0.7153 | 0.214 | 0.0008 | *** | 760 |
| mi_iv_ship_asym_sym_iv | mi_iv_ship_asym_sym_iv_F | FE IV | g_h_ship | 0.4078 | 0.168 | 0.0152 | ** | 760 |
| mi_iv_ship_asym_sym_iv | mi_iv_ship_asym_sym_iv_F | FE IV | g_l_ship | -0.6856 | 0.2289 | 0.0027 | *** | 760 |
| raw_gmm2_vadd_sym | raw_gmm2_vadd_sym_A | Pooled GMM2 | g_vadd | 0.1207 | 0.1296 | 0.3517 |  | 632 |
| raw_gmm2_vadd_sym | raw_gmm2_vadd_sym_B | FE GMM2 | g_vadd | 0.1452 | 0.0893 | 0.104 |  | 632 |
| raw_gmm2_vadd_sym | raw_gmm2_vadd_sym_C | Pooled GMM2 | g_vadd | -0.034 | 0.0078 | 0.0 | *** | 590 |
| raw_gmm2_vadd_sym | raw_gmm2_vadd_sym_D | FE GMM2 | g_vadd | -0.0301 | 0.007 | 0.0 | *** | 590 |
| raw_gmm2_vadd_sym | raw_gmm2_vadd_sym_E | Pooled GMM2 | g_vadd | -0.1346 | 0.0397 | 0.0007 | *** | 590 |
| raw_gmm2_vadd_sym | raw_gmm2_vadd_sym_F | FE GMM2 | g_vadd | -0.0859 | 0.0572 | 0.1334 |  | 590 |
| raw_gmm2_ship_sym | raw_gmm2_ship_sym_A | Pooled GMM2 | g_ship | 0.1831 | 0.1676 | 0.2745 |  | 632 |
| raw_gmm2_ship_sym | raw_gmm2_ship_sym_B | FE GMM2 | g_ship | 0.1995 | 0.1086 | 0.0662 | * | 632 |
| raw_gmm2_ship_sym | raw_gmm2_ship_sym_C | Pooled GMM2 | g_ship | -0.0138 | 0.0037 | 0.0002 | *** | 590 |
| raw_gmm2_ship_sym | raw_gmm2_ship_sym_D | FE GMM2 | g_ship | -0.0129 | 0.0036 | 0.0003 | *** | 590 |
| raw_gmm2_ship_sym | raw_gmm2_ship_sym_E | Pooled GMM2 | g_ship | -0.1858 | 0.0503 | 0.0002 | *** | 590 |
| raw_gmm2_ship_sym | raw_gmm2_ship_sym_F | FE GMM2 | g_ship | -0.1187 | 0.0696 | 0.0882 | * | 590 |
| raw_gmm2_vadd_asym | raw_gmm2_vadd_asym_A | Pooled GMM2 | g_h_vadd | -0.2584 | 0.3546 | 0.4662 |  | 632 |
| raw_gmm2_vadd_asym | raw_gmm2_vadd_asym_A | Pooled GMM2 | g_l_vadd | 0.5475 | 0.4618 | 0.2357 |  | 632 |
| raw_gmm2_vadd_asym | raw_gmm2_vadd_asym_B | FE GMM2 | g_h_vadd | -0.104 | 0.4023 | 0.796 |  | 632 |
| raw_gmm2_vadd_asym | raw_gmm2_vadd_asym_B | FE GMM2 | g_l_vadd | 0.4141 | 0.4513 | 0.3589 |  | 632 |
| raw_gmm2_vadd_asym | raw_gmm2_vadd_asym_C | Pooled GMM2 | g_h_vadd | -0.0251 | 0.0194 | 0.1953 |  | 590 |
| raw_gmm2_vadd_asym | raw_gmm2_vadd_asym_C | Pooled GMM2 | g_l_vadd | -0.0369 | 0.0266 | 0.1646 |  | 590 |
| raw_gmm2_vadd_asym | raw_gmm2_vadd_asym_D | FE GMM2 | g_h_vadd | -0.0185 | 0.0103 | 0.0739 | * | 590 |
| raw_gmm2_vadd_asym | raw_gmm2_vadd_asym_D | FE GMM2 | g_l_vadd | -0.0391 | 0.0203 | 0.0538 | * | 590 |
| raw_gmm2_vadd_asym | raw_gmm2_vadd_asym_E | Pooled GMM2 | g_h_vadd | 0.0161 | 0.1402 | 0.9085 |  | 590 |
| raw_gmm2_vadd_asym | raw_gmm2_vadd_asym_E | Pooled GMM2 | g_l_vadd | -0.3202 | 0.1697 | 0.0591 | * | 590 |
| raw_gmm2_vadd_asym | raw_gmm2_vadd_asym_F | FE GMM2 | g_h_vadd | 0.0375 | 0.1415 | 0.7908 |  | 590 |
| raw_gmm2_vadd_asym | raw_gmm2_vadd_asym_F | FE GMM2 | g_l_vadd | -0.2119 | 0.0984 | 0.0314 | ** | 590 |
| raw_gmm2_ship_asym | raw_gmm2_ship_asym_A | Pooled GMM2 | g_h_ship | -0.255 | 0.3941 | 0.5176 |  | 632 |
| raw_gmm2_ship_asym | raw_gmm2_ship_asym_A | Pooled GMM2 | g_l_ship | 0.6796 | 0.5286 | 0.1986 |  | 632 |
| raw_gmm2_ship_asym | raw_gmm2_ship_asym_B | FE GMM2 | g_h_ship | -0.0469 | 0.4664 | 0.9199 |  | 632 |
| raw_gmm2_ship_asym | raw_gmm2_ship_asym_B | FE GMM2 | g_l_ship | 0.469 | 0.5634 | 0.4051 |  | 632 |
| raw_gmm2_ship_asym | raw_gmm2_ship_asym_C | Pooled GMM2 | g_h_ship | -0.009 | 0.0085 | 0.2858 |  | 590 |
| raw_gmm2_ship_asym | raw_gmm2_ship_asym_C | Pooled GMM2 | g_l_ship | -0.0173 | 0.0128 | 0.175 |  | 590 |
| raw_gmm2_ship_asym | raw_gmm2_ship_asym_D | FE GMM2 | g_h_ship | -0.0077 | 0.0075 | 0.3011 |  | 590 |
| raw_gmm2_ship_asym | raw_gmm2_ship_asym_D | FE GMM2 | g_l_ship | -0.018 | 0.0149 | 0.2253 |  | 590 |
| raw_gmm2_ship_asym | raw_gmm2_ship_asym_E | Pooled GMM2 | g_h_ship | -0.0069 | 0.1403 | 0.9608 |  | 590 |
| raw_gmm2_ship_asym | raw_gmm2_ship_asym_E | Pooled GMM2 | g_l_ship | -0.4107 | 0.1777 | 0.0208 | ** | 590 |
| raw_gmm2_ship_asym | raw_gmm2_ship_asym_F | FE GMM2 | g_h_ship | 0.0095 | 0.163 | 0.9535 |  | 590 |
| raw_gmm2_ship_asym | raw_gmm2_ship_asym_F | FE GMM2 | g_l_ship | -0.2519 | 0.1098 | 0.0219 | ** | 590 |
| mi_gmm2_vadd_sym | mi_gmm2_vadd_sym_A | Pooled GMM2 | g_vadd | 0.1278 | 0.1107 | 0.2482 |  | 780 |
| mi_gmm2_vadd_sym | mi_gmm2_vadd_sym_B | FE GMM2 | g_vadd | 0.1448 | 0.0945 | 0.1255 |  | 780 |
| mi_gmm2_vadd_sym | mi_gmm2_vadd_sym_C | Pooled GMM2 | g_vadd | -0.0309 | 0.0061 | 0.0 | *** | 760 |
| mi_gmm2_vadd_sym | mi_gmm2_vadd_sym_D | FE GMM2 | g_vadd | -0.0278 | 0.0057 | 0.0 | *** | 760 |
| mi_gmm2_vadd_sym | mi_gmm2_vadd_sym_E | Pooled GMM2 | g_vadd | -0.0985 | 0.0328 | 0.0027 | *** | 760 |
| mi_gmm2_vadd_sym | mi_gmm2_vadd_sym_F | FE GMM2 | g_vadd | -0.0585 | 0.0461 | 0.2043 |  | 760 |
| mi_gmm2_ship_sym | mi_gmm2_ship_sym_A | Pooled GMM2 | g_ship | 0.1772 | 0.1402 | 0.2061 |  | 780 |
| mi_gmm2_ship_sym | mi_gmm2_ship_sym_B | FE GMM2 | g_ship | 0.1917 | 0.1137 | 0.0919 | * | 780 |
| mi_gmm2_ship_sym | mi_gmm2_ship_sym_C | Pooled GMM2 | g_ship | -0.0124 | 0.0029 | 0.0 | *** | 760 |
| mi_gmm2_ship_sym | mi_gmm2_ship_sym_D | FE GMM2 | g_ship | -0.0117 | 0.0027 | 0.0 | *** | 760 |
| mi_gmm2_ship_sym | mi_gmm2_ship_sym_E | Pooled GMM2 | g_ship | -0.1281 | 0.0407 | 0.0017 | *** | 760 |
| mi_gmm2_ship_sym | mi_gmm2_ship_sym_F | FE GMM2 | g_ship | -0.0754 | 0.0551 | 0.1716 |  | 760 |
| mi_gmm2_vadd_asym | mi_gmm2_vadd_asym_A | Pooled GMM2 | g_h_vadd | -0.2777 | 0.333 | 0.4043 |  | 780 |
| mi_gmm2_vadd_asym | mi_gmm2_vadd_asym_A | Pooled GMM2 | g_l_vadd | 0.6141 | 0.4248 | 0.1482 |  | 780 |
| mi_gmm2_vadd_asym | mi_gmm2_vadd_asym_B | FE GMM2 | g_h_vadd | -0.1701 | 0.4245 | 0.6886 |  | 780 |
| mi_gmm2_vadd_asym | mi_gmm2_vadd_asym_B | FE GMM2 | g_l_vadd | 0.5219 | 0.4654 | 0.2621 |  | 780 |
| mi_gmm2_vadd_asym | mi_gmm2_vadd_asym_C | Pooled GMM2 | g_h_vadd | -0.0332 | 0.0146 | 0.0225 | ** | 760 |
| mi_gmm2_vadd_asym | mi_gmm2_vadd_asym_C | Pooled GMM2 | g_l_vadd | -0.0196 | 0.0199 | 0.3253 |  | 760 |
| mi_gmm2_vadd_asym | mi_gmm2_vadd_asym_D | FE GMM2 | g_h_vadd | -0.0241 | 0.0095 | 0.0111 | ** | 760 |
| mi_gmm2_vadd_asym | mi_gmm2_vadd_asym_D | FE GMM2 | g_l_vadd | -0.0256 | 0.0171 | 0.1328 |  | 760 |
| mi_gmm2_vadd_asym | mi_gmm2_vadd_asym_E | Pooled GMM2 | g_h_vadd | 0.0917 | 0.1114 | 0.4104 |  | 760 |
| mi_gmm2_vadd_asym | mi_gmm2_vadd_asym_E | Pooled GMM2 | g_l_vadd | -0.3388 | 0.1349 | 0.012 | ** | 760 |
| mi_gmm2_vadd_asym | mi_gmm2_vadd_asym_F | FE GMM2 | g_h_vadd | 0.1072 | 0.1318 | 0.4162 |  | 760 |
| mi_gmm2_vadd_asym | mi_gmm2_vadd_asym_F | FE GMM2 | g_l_vadd | -0.2608 | 0.1159 | 0.0244 | ** | 760 |
| mi_gmm2_ship_asym | mi_gmm2_ship_asym_A | Pooled GMM2 | g_h_ship | -0.2945 | 0.3706 | 0.4269 |  | 780 |
| mi_gmm2_ship_asym | mi_gmm2_ship_asym_A | Pooled GMM2 | g_l_ship | 0.7761 | 0.5024 | 0.1224 |  | 780 |
| mi_gmm2_ship_asym | mi_gmm2_ship_asym_B | FE GMM2 | g_h_ship | -0.147 | 0.4851 | 0.762 |  | 780 |
| mi_gmm2_ship_asym | mi_gmm2_ship_asym_B | FE GMM2 | g_l_ship | 0.6292 | 0.5776 | 0.276 |  | 780 |
| mi_gmm2_ship_asym | mi_gmm2_ship_asym_C | Pooled GMM2 | g_h_ship | -0.0129 | 0.0069 | 0.0629 | * | 760 |
| mi_gmm2_ship_asym | mi_gmm2_ship_asym_C | Pooled GMM2 | g_l_ship | -0.0078 | 0.0104 | 0.4546 |  | 760 |
| mi_gmm2_ship_asym | mi_gmm2_ship_asym_D | FE GMM2 | g_h_ship | -0.0111 | 0.0066 | 0.0896 | * | 760 |
| mi_gmm2_ship_asym | mi_gmm2_ship_asym_D | FE GMM2 | g_l_ship | -0.01 | 0.0119 | 0.4032 |  | 760 |
| mi_gmm2_ship_asym | mi_gmm2_ship_asym_E | Pooled GMM2 | g_h_ship | 0.1075 | 0.1247 | 0.3888 |  | 760 |
| mi_gmm2_ship_asym | mi_gmm2_ship_asym_E | Pooled GMM2 | g_l_ship | -0.4358 | 0.1595 | 0.0063 | *** | 760 |
| mi_gmm2_ship_asym | mi_gmm2_ship_asym_F | FE GMM2 | g_h_ship | 0.1176 | 0.1528 | 0.4414 |  | 760 |
| mi_gmm2_ship_asym | mi_gmm2_ship_asym_F | FE GMM2 | g_l_ship | -0.3316 | 0.1396 | 0.0175 | ** | 760 |
| dev_mi_ols_vadd_sym | dev_mi_ols_vadd_sym_A | Pooled OLS | dev_vadd | 0.1045 | 0.0535 | 0.0509 | * | 800 |
| dev_mi_ols_vadd_sym | dev_mi_ols_vadd_sym_B | FE OLS | dev_vadd | 0.0345 | 0.0439 | 0.4326 |  | 800 |
| dev_mi_ols_vadd_sym | dev_mi_ols_vadd_sym_C | Pooled OLS | dev_vadd | -0.0344 | 0.0113 | 0.0024 | *** | 780 |
| dev_mi_ols_vadd_sym | dev_mi_ols_vadd_sym_D | FE OLS | dev_vadd | -0.0299 | 0.0076 | 0.0001 | *** | 780 |
| dev_mi_ols_vadd_sym | dev_mi_ols_vadd_sym_E | Pooled OLS | dev_vadd | -0.1201 | 0.0336 | 0.0004 | *** | 780 |
| dev_mi_ols_vadd_sym | dev_mi_ols_vadd_sym_F | FE OLS | dev_vadd | -0.1418 | 0.0233 | 0.0 | *** | 780 |
| dev_mi_ols_ship_sym | dev_mi_ols_ship_sym_A | Pooled OLS | dev_vship | 0.2101 | 0.0683 | 0.0021 | *** | 800 |
| dev_mi_ols_ship_sym | dev_mi_ols_ship_sym_B | FE OLS | dev_vship | 0.1186 | 0.0529 | 0.0252 | ** | 800 |
| dev_mi_ols_ship_sym | dev_mi_ols_ship_sym_C | Pooled OLS | dev_vship | -0.0073 | 0.0028 | 0.0105 | ** | 780 |
| dev_mi_ols_ship_sym | dev_mi_ols_ship_sym_D | FE OLS | dev_vship | -0.0099 | 0.0022 | 0.0 | *** | 780 |
| dev_mi_ols_ship_sym | dev_mi_ols_ship_sym_E | Pooled OLS | dev_vship | -0.125 | 0.045 | 0.0055 | *** | 780 |
| dev_mi_ols_ship_sym | dev_mi_ols_ship_sym_F | FE OLS | dev_vship | -0.1894 | 0.0311 | 0.0 | *** | 780 |
| dev_mi_ols_vadd_asym | dev_mi_ols_vadd_asym_A | Pooled OLS | dev_h_g_vadd | 0.1122 | 0.0843 | 0.1831 |  | 800 |
| dev_mi_ols_vadd_asym | dev_mi_ols_vadd_asym_A | Pooled OLS | dev_l_g_vadd | 0.0969 | 0.0887 | 0.2748 |  | 800 |
| dev_mi_ols_vadd_asym | dev_mi_ols_vadd_asym_B | FE OLS | dev_h_g_vadd | 0.0126 | 0.0831 | 0.8794 |  | 800 |
| dev_mi_ols_vadd_asym | dev_mi_ols_vadd_asym_B | FE OLS | dev_l_g_vadd | 0.056 | 0.0859 | 0.5143 |  | 800 |
| dev_mi_ols_vadd_asym | dev_mi_ols_vadd_asym_C | Pooled OLS | dev_h_g_vadd | -0.0373 | 0.01 | 0.0002 | *** | 780 |
| dev_mi_ols_vadd_asym | dev_mi_ols_vadd_asym_C | Pooled OLS | dev_l_g_vadd | -0.0315 | 0.0205 | 0.124 |  | 780 |
| dev_mi_ols_vadd_asym | dev_mi_ols_vadd_asym_D | FE OLS | dev_h_g_vadd | -0.0269 | 0.0101 | 0.008 | *** | 780 |
| dev_mi_ols_vadd_asym | dev_mi_ols_vadd_asym_D | FE OLS | dev_l_g_vadd | -0.0329 | 0.0171 | 0.0552 | * | 780 |
| dev_mi_ols_vadd_asym | dev_mi_ols_vadd_asym_E | Pooled OLS | dev_h_g_vadd | -0.0954 | 0.0352 | 0.0068 | *** | 780 |
| dev_mi_ols_vadd_asym | dev_mi_ols_vadd_asym_E | Pooled OLS | dev_l_g_vadd | -0.1441 | 0.0561 | 0.0102 | ** | 780 |
| dev_mi_ols_vadd_asym | dev_mi_ols_vadd_asym_F | FE OLS | dev_h_g_vadd | -0.115 | 0.0396 | 0.0038 | *** | 780 |
| dev_mi_ols_vadd_asym | dev_mi_ols_vadd_asym_F | FE OLS | dev_l_g_vadd | -0.1679 | 0.0435 | 0.0001 | *** | 780 |
| dev_mi_ols_ship_asym | dev_mi_ols_ship_asym_A | Pooled OLS | dev_h_g_ship | 0.2781 | 0.1121 | 0.0131 | ** | 800 |
| dev_mi_ols_ship_asym | dev_mi_ols_ship_asym_A | Pooled OLS | dev_l_g_ship | 0.1487 | 0.1045 | 0.1548 |  | 800 |
| dev_mi_ols_ship_asym | dev_mi_ols_ship_asym_B | FE OLS | dev_h_g_ship | 0.1784 | 0.1072 | 0.0963 | * | 800 |
| dev_mi_ols_ship_asym | dev_mi_ols_ship_asym_B | FE OLS | dev_l_g_ship | 0.0641 | 0.0981 | 0.5132 |  | 800 |
| dev_mi_ols_ship_asym | dev_mi_ols_ship_asym_C | Pooled OLS | dev_h_g_ship | -0.004 | 0.0043 | 0.3555 |  | 780 |
| dev_mi_ols_ship_asym | dev_mi_ols_ship_asym_C | Pooled OLS | dev_l_g_ship | -0.0101 | 0.0043 | 0.0182 | ** | 780 |
| dev_mi_ols_ship_asym | dev_mi_ols_ship_asym_D | FE OLS | dev_h_g_ship | 0.0 | 0.0036 | 0.9932 |  | 780 |
| dev_mi_ols_ship_asym | dev_mi_ols_ship_asym_D | FE OLS | dev_l_g_ship | -0.0187 | 0.004 | 0.0 | *** | 780 |
| dev_mi_ols_ship_asym | dev_mi_ols_ship_asym_E | Pooled OLS | dev_h_g_ship | -0.0218 | 0.0555 | 0.6942 |  | 780 |
| dev_mi_ols_ship_asym | dev_mi_ols_ship_asym_E | Pooled OLS | dev_l_g_ship | -0.2154 | 0.0668 | 0.0013 | *** | 780 |
| dev_mi_ols_ship_asym | dev_mi_ols_ship_asym_F | FE OLS | dev_h_g_ship | -0.1217 | 0.0595 | 0.0412 | ** | 780 |
| dev_mi_ols_ship_asym | dev_mi_ols_ship_asym_F | FE OLS | dev_l_g_ship | -0.2491 | 0.0549 | 0.0 | *** | 780 |
| dev_mi_iv_vadd_sym | dev_mi_iv_vadd_sym_A | Pooled IV | dev_vadd | 0.1806 | 0.0836 | 0.0307 | ** | 780 |
| dev_mi_iv_vadd_sym | dev_mi_iv_vadd_sym_B | FE IV | dev_vadd | 0.1682 | 0.0904 | 0.0627 | * | 780 |
| dev_mi_iv_vadd_sym | dev_mi_iv_vadd_sym_C | Pooled IV | dev_vadd | -0.0195 | 0.0092 | 0.0335 | ** | 760 |
| dev_mi_iv_vadd_sym | dev_mi_iv_vadd_sym_D | FE IV | dev_vadd | -0.0231 | 0.0084 | 0.0058 | *** | 760 |
| dev_mi_iv_vadd_sym | dev_mi_iv_vadd_sym_E | Pooled IV | dev_vadd | -0.2245 | 0.0473 | 0.0 | *** | 760 |
| dev_mi_iv_vadd_sym | dev_mi_iv_vadd_sym_F | FE IV | dev_vadd | -0.1937 | 0.0559 | 0.0005 | *** | 760 |
| dev_mi_iv_ship_sym | dev_mi_iv_ship_sym_A | Pooled IV | dev_vship | 0.239 | 0.1029 | 0.0203 | ** | 780 |
| dev_mi_iv_ship_sym | dev_mi_iv_ship_sym_B | FE IV | dev_vship | 0.2271 | 0.1099 | 0.0387 | ** | 780 |
| dev_mi_iv_ship_sym | dev_mi_iv_ship_sym_C | Pooled IV | dev_vship | -0.0087 | 0.0046 | 0.0569 | * | 760 |
| dev_mi_iv_ship_sym | dev_mi_iv_ship_sym_D | FE IV | dev_vship | -0.0108 | 0.0062 | 0.08 | * | 760 |
| dev_mi_iv_ship_sym | dev_mi_iv_ship_sym_E | Pooled IV | dev_vship | -0.2836 | 0.0592 | 0.0 | *** | 760 |
| dev_mi_iv_ship_sym | dev_mi_iv_ship_sym_F | FE IV | dev_vship | -0.2495 | 0.0658 | 0.0002 | *** | 760 |
| dev_mi_iv_vadd_asym | dev_mi_iv_vadd_asym_A | Pooled IV | dev_h_g_vadd | 0.4427 | 0.4357 | 0.3096 |  | 780 |
| dev_mi_iv_vadd_asym | dev_mi_iv_vadd_asym_A | Pooled IV | dev_l_g_vadd | -0.1043 | 0.4095 | 0.799 |  | 780 |
| dev_mi_iv_vadd_asym | dev_mi_iv_vadd_asym_B | FE IV | dev_h_g_vadd | 0.4258 | 0.4043 | 0.2922 |  | 780 |
| dev_mi_iv_vadd_asym | dev_mi_iv_vadd_asym_B | FE IV | dev_l_g_vadd | -0.11 | 0.3868 | 0.7762 |  | 780 |
| dev_mi_iv_vadd_asym | dev_mi_iv_vadd_asym_C | Pooled IV | dev_h_g_vadd | 0.1536 | 0.0903 | 0.089 | * | 760 |
| dev_mi_iv_vadd_asym | dev_mi_iv_vadd_asym_C | Pooled IV | dev_l_g_vadd | -0.1673 | 0.0849 | 0.0487 | ** | 760 |
| dev_mi_iv_vadd_asym | dev_mi_iv_vadd_asym_D | FE IV | dev_h_g_vadd | 0.1429 | 0.068 | 0.0356 | ** | 760 |
| dev_mi_iv_vadd_asym | dev_mi_iv_vadd_asym_D | FE IV | dev_l_g_vadd | -0.16 | 0.0736 | 0.0296 | ** | 760 |
| dev_mi_iv_vadd_asym | dev_mi_iv_vadd_asym_E | Pooled IV | dev_h_g_vadd | -0.6749 | 0.3432 | 0.0492 | ** | 760 |
| dev_mi_iv_vadd_asym | dev_mi_iv_vadd_asym_E | Pooled IV | dev_l_g_vadd | 0.1416 | 0.2839 | 0.618 |  | 760 |
| dev_mi_iv_vadd_asym | dev_mi_iv_vadd_asym_F | FE IV | dev_h_g_vadd | -0.69 | 0.3176 | 0.0298 | ** | 760 |
| dev_mi_iv_vadd_asym | dev_mi_iv_vadd_asym_F | FE IV | dev_l_g_vadd | 0.2152 | 0.2324 | 0.3544 |  | 760 |
| dev_mi_iv_ship_asym | dev_mi_iv_ship_asym_A | Pooled IV | dev_h_g_ship | 0.6041 | 0.5885 | 0.3046 |  | 780 |
| dev_mi_iv_ship_asym | dev_mi_iv_ship_asym_A | Pooled IV | dev_l_g_ship | -0.1266 | 0.5241 | 0.809 |  | 780 |
| dev_mi_iv_ship_asym | dev_mi_iv_ship_asym_B | FE IV | dev_h_g_ship | 0.6121 | 0.5293 | 0.2475 |  | 780 |
| dev_mi_iv_ship_asym | dev_mi_iv_ship_asym_B | FE IV | dev_l_g_ship | -0.1612 | 0.4924 | 0.7434 |  | 780 |
| dev_mi_iv_ship_asym | dev_mi_iv_ship_asym_C | Pooled IV | dev_h_g_ship | 0.0658 | 0.0499 | 0.1875 |  | 760 |
| dev_mi_iv_ship_asym | dev_mi_iv_ship_asym_C | Pooled IV | dev_l_g_ship | -0.0681 | 0.0423 | 0.1078 |  | 760 |
| dev_mi_iv_ship_asym | dev_mi_iv_ship_asym_D | FE IV | dev_h_g_ship | 0.0586 | 0.0361 | 0.1044 |  | 760 |
| dev_mi_iv_ship_asym | dev_mi_iv_ship_asym_D | FE IV | dev_l_g_ship | -0.0662 | 0.0334 | 0.0478 | ** | 760 |
| dev_mi_iv_ship_asym | dev_mi_iv_ship_asym_E | Pooled IV | dev_h_g_ship | -0.8846 | 0.4963 | 0.0747 | * | 760 |
| dev_mi_iv_ship_asym | dev_mi_iv_ship_asym_E | Pooled IV | dev_l_g_ship | 0.1644 | 0.3792 | 0.6646 |  | 760 |
| dev_mi_iv_ship_asym | dev_mi_iv_ship_asym_F | FE IV | dev_h_g_ship | -0.9119 | 0.4523 | 0.0438 | ** | 760 |
| dev_mi_iv_ship_asym | dev_mi_iv_ship_asym_F | FE IV | dev_l_g_ship | 0.2666 | 0.2947 | 0.3657 |  | 760 |
| dev_mi_gmm2_vadd_sym | dev_mi_gmm2_vadd_sym_A | Pooled GMM2 | dev_vadd | 0.1918 | 0.0837 | 0.0219 | ** | 780 |
| dev_mi_gmm2_vadd_sym | dev_mi_gmm2_vadd_sym_B | FE GMM2 | dev_vadd | 0.1735 | 0.0898 | 0.0535 | * | 780 |
| dev_mi_gmm2_vadd_sym | dev_mi_gmm2_vadd_sym_C | Pooled GMM2 | dev_vadd | -0.0019 | 0.0084 | 0.8171 |  | 760 |
| dev_mi_gmm2_vadd_sym | dev_mi_gmm2_vadd_sym_D | FE GMM2 | dev_vadd | -0.0058 | 0.007 | 0.4131 |  | 760 |
| dev_mi_gmm2_vadd_sym | dev_mi_gmm2_vadd_sym_E | Pooled GMM2 | dev_vadd | -0.2245 | 0.0473 | 0.0 | *** | 760 |
| dev_mi_gmm2_vadd_sym | dev_mi_gmm2_vadd_sym_F | FE GMM2 | dev_vadd | -0.1915 | 0.0576 | 0.0009 | *** | 760 |
| dev_mi_gmm2_ship_sym | dev_mi_gmm2_ship_sym_A | Pooled GMM2 | dev_vship | 0.2525 | 0.1031 | 0.0143 | ** | 780 |
| dev_mi_gmm2_ship_sym | dev_mi_gmm2_ship_sym_B | FE GMM2 | dev_vship | 0.2336 | 0.1095 | 0.0328 | ** | 780 |
| dev_mi_gmm2_ship_sym | dev_mi_gmm2_ship_sym_C | Pooled GMM2 | dev_vship | -0.004 | 0.0044 | 0.3636 |  | 760 |
| dev_mi_gmm2_ship_sym | dev_mi_gmm2_ship_sym_D | FE GMM2 | dev_vship | -0.0072 | 0.0058 | 0.2102 |  | 760 |
| dev_mi_gmm2_ship_sym | dev_mi_gmm2_ship_sym_E | Pooled GMM2 | dev_vship | -0.2842 | 0.0591 | 0.0 | *** | 760 |
| dev_mi_gmm2_ship_sym | dev_mi_gmm2_ship_sym_F | FE GMM2 | dev_vship | -0.2474 | 0.0677 | 0.0003 | *** | 760 |
| dev_mi_gmm2_vadd_asym | dev_mi_gmm2_vadd_asym_A | Pooled GMM2 | dev_h_g_vadd | 0.6344 | 0.4369 | 0.1465 |  | 780 |
| dev_mi_gmm2_vadd_asym | dev_mi_gmm2_vadd_asym_A | Pooled GMM2 | dev_l_g_vadd | -0.2664 | 0.4117 | 0.5176 |  | 780 |
| dev_mi_gmm2_vadd_asym | dev_mi_gmm2_vadd_asym_B | FE GMM2 | dev_h_g_vadd | 0.605 | 0.4116 | 0.1417 |  | 780 |
| dev_mi_gmm2_vadd_asym | dev_mi_gmm2_vadd_asym_B | FE GMM2 | dev_l_g_vadd | -0.2641 | 0.4222 | 0.5317 |  | 780 |
| dev_mi_gmm2_vadd_asym | dev_mi_gmm2_vadd_asym_C | Pooled GMM2 | dev_h_g_vadd | 0.1952 | 0.0966 | 0.0433 | ** | 760 |
| dev_mi_gmm2_vadd_asym | dev_mi_gmm2_vadd_asym_C | Pooled GMM2 | dev_l_g_vadd | -0.2022 | 0.0901 | 0.0248 | ** | 760 |
| dev_mi_gmm2_vadd_asym | dev_mi_gmm2_vadd_asym_D | FE GMM2 | dev_h_g_vadd | 0.1827 | 0.0642 | 0.0044 | *** | 760 |
| dev_mi_gmm2_vadd_asym | dev_mi_gmm2_vadd_asym_D | FE GMM2 | dev_l_g_vadd | -0.194 | 0.073 | 0.0079 | *** | 760 |
| dev_mi_gmm2_vadd_asym | dev_mi_gmm2_vadd_asym_E | Pooled GMM2 | dev_h_g_vadd | -0.6827 | 0.3431 | 0.0466 | ** | 760 |
| dev_mi_gmm2_vadd_asym | dev_mi_gmm2_vadd_asym_E | Pooled GMM2 | dev_l_g_vadd | 0.1434 | 0.2843 | 0.6141 |  | 760 |
| dev_mi_gmm2_vadd_asym | dev_mi_gmm2_vadd_asym_F | FE GMM2 | dev_h_g_vadd | -0.6884 | 0.3217 | 0.0324 | ** | 760 |
| dev_mi_gmm2_vadd_asym | dev_mi_gmm2_vadd_asym_F | FE GMM2 | dev_l_g_vadd | 0.2169 | 0.2336 | 0.3531 |  | 760 |
| dev_mi_gmm2_ship_asym | dev_mi_gmm2_ship_asym_A | Pooled GMM2 | dev_h_g_ship | 0.826 | 0.5941 | 0.1644 |  | 780 |
| dev_mi_gmm2_ship_asym | dev_mi_gmm2_ship_asym_A | Pooled GMM2 | dev_l_g_ship | -0.3035 | 0.531 | 0.5676 |  | 780 |
| dev_mi_gmm2_ship_asym | dev_mi_gmm2_ship_asym_B | FE GMM2 | dev_h_g_ship | 0.7917 | 0.5446 | 0.1461 |  | 780 |
| dev_mi_gmm2_ship_asym | dev_mi_gmm2_ship_asym_B | FE GMM2 | dev_l_g_ship | -0.3096 | 0.5283 | 0.5578 |  | 780 |
| dev_mi_gmm2_ship_asym | dev_mi_gmm2_ship_asym_C | Pooled GMM2 | dev_h_g_ship | 0.0865 | 0.0518 | 0.0947 | * | 760 |
| dev_mi_gmm2_ship_asym | dev_mi_gmm2_ship_asym_C | Pooled GMM2 | dev_l_g_ship | -0.0849 | 0.0441 | 0.054 | * | 760 |
| dev_mi_gmm2_ship_asym | dev_mi_gmm2_ship_asym_D | FE GMM2 | dev_h_g_ship | 0.0801 | 0.0322 | 0.0128 | ** | 760 |
| dev_mi_gmm2_ship_asym | dev_mi_gmm2_ship_asym_D | FE GMM2 | dev_l_g_ship | -0.0849 | 0.0332 | 0.0106 | ** | 760 |
| dev_mi_gmm2_ship_asym | dev_mi_gmm2_ship_asym_E | Pooled GMM2 | dev_h_g_ship | -0.8855 | 0.4959 | 0.0742 | * | 760 |
| dev_mi_gmm2_ship_asym | dev_mi_gmm2_ship_asym_E | Pooled GMM2 | dev_l_g_ship | 0.1605 | 0.3789 | 0.6719 |  | 760 |
| dev_mi_gmm2_ship_asym | dev_mi_gmm2_ship_asym_F | FE GMM2 | dev_h_g_ship | -0.9236 | 0.4641 | 0.0466 | ** | 760 |
| dev_mi_gmm2_ship_asym | dev_mi_gmm2_ship_asym_F | FE GMM2 | dev_l_g_ship | 0.2789 | 0.3039 | 0.3587 |  | 760 |
