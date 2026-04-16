# AllData IV Regression Results Summary

Replication of AllData.do lines 1052–1159.

Estimator: FE IV (within-entity demean + IV2SLS), SIC-cluster-robust SEs.


Note: d_output / d_h_output / d_l_output specs skipped (variable not in cyclicality.db panel; requires BEA national aggregate output growth merged separately).


## Block1_Symm

  b1_sale_d_go:   d_sale: 0.4534*** (0.0606), n=31987
  b1_sale_d_va_i:   d_sale: 0.3678 (0.2422), n=31987
  b1_sale_d_vadd:   d_sale: 0.5646*** (0.0708), n=37762
  b1_sale_d_vship:   d_sale: 0.5643*** (0.0957), n=37762
  b1_va_d_go:   d_va: 0.4758* (0.2685), n=1828
  b1_va_d_va_i:   d_va: 0.5404 (0.3916), n=1828
  b1_va_d_vadd:   d_va: 0.2765 (0.1818), n=3148
  b1_va_d_vship:   d_va: 0.4550*** (0.1320), n=3148
  b1_va_a_d_go:   d_va_a: 1.4442*** (0.4697), n=23093
  b1_va_a_d_va_i:   d_va_a: 6.7354 (54.4893), n=23093
  b1_va_a_d_vadd:   d_va_a: -0.5325 (4.1324), n=30492
  b1_va_a_d_vship:   d_va_a: 0.9640 (1.5846), n=30492

## Block2_DemeanedSymm

  b2_dev_go:   dev_sale: 0.6912*** (0.0521), n=32576
  b2_dev_va_i:   dev_sale: 0.4324*** (0.1546), n=32576
  b2_dev_vadd:   dev_sale: 0.6183*** (0.0878), n=38324
  b2_dev_vship:   dev_sale: 0.6694*** (0.0843), n=38324

## Block3_Asym

  b3_lead_h_go:   d_h_sale: 0.9963*** (0.1527), n=32576
  b3_nolead_h_go:   d_h_sale: 0.8929*** (0.1444), n=37699
  b3_lead_h_va_i:   d_h_sale: 0.9456*** (0.1468), n=32576
  b3_nolead_h_va_i:   d_h_sale: 1.1010*** (0.1455), n=37699
  b3_lead_h_vadd:   d_h_sale: 1.7584*** (0.4868), n=38324
  b3_nolead_h_vadd:   d_h_sale: 1.4980*** (0.3253), n=42433
  b3_lead_h_vship:   d_h_sale: 1.5705*** (0.3141), n=38324
  b3_nolead_h_vship:   d_h_sale: 1.3739*** (0.2365), n=42433

## Block4_DemeanedAsym

  b4_lead_h_go:   dev_h_sale: 1.0924*** (0.2163), n=32574
  b4_nolead_h_go:   dev_h_sale: 0.9453*** (0.2127), n=37396
  b4_lead_h_va_i:   dev_h_sale: 1.0934*** (0.2017), n=32574
  b4_nolead_h_va_i:   dev_h_sale: 1.2757*** (0.1806), n=37396
  b4_lead_h_vadd:   dev_h_sale: 1.7451*** (0.5502), n=38323
  b4_nolead_h_vadd:   dev_h_sale: 1.4398*** (0.3896), n=42421
  b4_lead_h_vship:   dev_h_sale: 1.7151*** (0.3699), n=38323
  b4_nolead_h_vship:   dev_h_sale: 1.4061*** (0.2857), n=42421