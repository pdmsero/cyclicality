# AllData Regression Results Summary

Replication of AllData.do lines 816–1050.

Estimator: Two-way FE OLS, SIC-cluster-robust SEs.


## Table 9 — Baseline (primary GDP spec, models A-F)

  Model A:   d_gdp_sale: 0.2783*** (0.0183), n=81819
  Model B:   d_gdp_sale: -0.0991*** (0.0101), n=81819
  Model C:   d_gdp_sale: -0.0612*** (0.0043), n=80546
  Model D:   d_gdp_va: 0.3034*** (0.0448), n=6665
  Model E:   d_gdp_va: -0.0810*** (0.0139), n=6665
  Model F:   d_gdp_va: -0.0365*** (0.0091), n=6518


## Table 10 — Asymmetric growth (models A-F)

  Model A:   d_h_sale: 0.2848*** (0.0316), n=81819
  Model B:   d_h_sale: -0.0645*** (0.0162), n=81819
  Model C:   d_h_sale: -0.0610*** (0.0064), n=80546
  Model D:   d_h_va: 0.3882*** (0.0646), n=6665
  Model E:   d_h_va: -0.0720*** (0.0148), n=6665
  Model F:   d_h_va: -0.0456*** (0.0146), n=6518


## Endogeneity checks — GDP spec with d_va_ind

  endo_gdp_d_va_ind_sale:   d_gdp_sale: 0.2752*** (0.0286), n=36971
  endo_gdp_d_va_ind_va:   d_gdp_va: 0.2581*** (0.0622), n=2124
