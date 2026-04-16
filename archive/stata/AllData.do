/* 0. Loading and sorting data */

use "/Users/pedroserodio/Dropbox/Working folder/Papers/Cyclicality of R&D at the Firm Level/Data files/AllData.dta", clear
sort key year sic naics
xtset key year, yearly

/* 1. Housecleaning: removing observations where total assets, capital expenditure, debt, 
employees, physical capital, sales, R&D spending and payroll are negative  and
removing missing observations for firm sales, operating income before depreciation and
research spending */

drop if at<0 | capx<0 | dd1<0 | dlc<0 | dltt<0 | emp<0 | ppent<0 | sale<0 | xrd<0 | xlr<0
/* Less than 300 */

drop if missing(xrd) | missing(sale) | missing(oibdp)

/* 2. Generating auxiliary variables */

gen va= oibdp+xlr
label variable va "Value Added"

gen averagesalary=xlr/(emp)*1000
label variable averagesalary "Average pay for firm i in period t"

sort year sic key
by year: egen meansalary=mean(averagesalary)
label variable meansalary "Average industry pay"

sort key year sic naics

gen wagebill=emp*averagewage/1000
label variable wagebill "Approximate wage bill using mean annual wage"

gen va_a=oibdp+wagebill
label variable va_a "Value added, approximated using average wage"

gen payroll=emp*meansalary/1000
label variable payroll "Estimated size of firm payroll"

gen va_e=oibdp+payroll
label variable va_e "Value added, approximated using Compustat average wage"

gen tex=sale-oibdp
label variable tex "Total expenses, approximated"

gen materials=tex-wagebill
label variable materials "Total value of materials"

gen va_o=sale-materials
label variable va_o "Value added, approximated using average wage"

gen cf=ib+dp
label variable cf "Cash Flow"

gen cfmxrd=cf-xrd
label variable cfmxrd "Cash Flow minus R&D Spending"

/* Firm variables, GDP deflator */

gen r_gdp_cf=cf/P_GDP
label variable r_gdp_cf "Cash Flow, deflated"

gen r_gdp_cfmxrd=cfmxrd/P_GDP
label variable r_gdp_cfmxrd "Cash Flow minus R&D Spending, deflated"

gen r_gdp_at=at/P_GDP
label variable r_gdp_at "Assets - Total, deflated"

gen r_gdp_capx=capx/P_GDP
label variable r_gdp_capx "Capital Expenditures, deflated"

gen r_gdp_ceq=ceq/P_GDP
label variable r_gdp_ceq "Common/Ordinary Equity - Total, deflated"

gen r_gdp_che=che/P_GDP
label variable r_gdp_che "Cash and Short-Term Investments, deflated"

gen r_gdp_dd1=dd1/P_GDP
label variable r_gdp_dd1 "Long-Term Debt Due in One Year, deflated"

gen r_gdp_dlc=dlc/P_GDP
label variable r_gdp_dlc "Debt in Current Liabilities - Total, deflated"

gen r_gdp_dltt=dltt/P_GDP
label variable r_gdp_dltt "Long-Term Debt - Total, deflated"

gen r_gdp_dp=dp/P_GDP
label variable r_gdp_dp "Depreciation and Amortization, deflated"

gen r_gdp_dvc=dvc/P_GDP
label variable r_gdp_dvc "Dividends Common/Ordinary, deflated"

gen r_gdp_dvp=dvp/P_GDP
label variable r_gdp_dvp "Dividends - Preferred/Preference, deflated"

gen r_gdp_ib=ib/P_GDP
label variable r_gdp_ib "Income Before Extraordinary Items, deflated"

gen r_gdp_lt=lt/P_GDP
label variable r_gdp_lt "Liabilities - Total, deflated"

gen r_gdp_oibdp=oibdp/P_GDP
label variable r_gdp_oibdp "Operating Income Before Depreciation, deflated"

gen r_gdp_ppent=ppent/P_GDP
label variable r_gdp_ppent "Property, Plant and Equipment - Total (Net), deflated"

gen r_gdp_ppegt=ppegt/P_GDP
label variable r_gdp_ppegt "Property, Plant and Equipment - Total (Gross), deflated"

gen r_gdp_sale=sale/P_GDP
label variable r_gdp_sale "Sales/Turnover (Net), deflated"

gen r_gdp_sale_i=sale_i/P_GDP
label variable r_gdp_sale_i "Industry Sales, deflated"

gen r_gdp_seq=seq/P_GDP
label variable r_gdp_seq "Stockholders Equity - Parent, deflated"

gen r_gdp_txdb=txdb/P_GDP
label variable r_gdp_txdb "Deferred Taxes (Balance Sheet), deflated"

gen r_gdp_xlr=xlr/P_GDP
label variable r_gdp_xlr "Staff Expense - Total, deflated"

gen r_gdp_xrd=xrd/P_GDP
label variable r_gdp_xrd "Research and Development Expense, deflated"

gen r_gdp_va= va/P_GDP
label variable r_gdp_va "Value Added, deflated"

gen r_gdp_va_a= va_a/P_GDP
label variable r_gdp_va_a "Value Added, deflated"

gen r_gdp_va_e=va_e/P_GDP
label variable r_gdp_va_e "Value Added, deflated"

gen r_gdp_tex=tex/P_GDP

gen r_gdp_materials=materials/P_GDP

/* Firm variables, Value Added BEA deflator */

gen r_va_cf=cf/PVA
label variable r_va_cf "Cash Flow, deflated"

gen r_va_cfmxrd=cfmxrd/PVA
label variable r_va_cfmxrd "Cash Flow minus R&D Spending, deflated"

gen r_va_at=at/PVA
label variable r_va_at "Assets - Total, deflated"

gen r_va_capx=capx/PVA
label variable r_va_capx "Capital Expenditures, deflated"

gen r_va_ceq=ceq/PVA
label variable r_va_ceq "Common/Ordinary Equity - Total, deflated"

gen r_va_che=che/PVA
label variable r_va_che "Cash and Short-Term Investments, deflated"

gen r_va_dd1=dd1/PVA
label variable r_va_dd1 "Long-Term Debt Due in One Year, deflated"

gen r_va_dlc=dlc/PVA
label variable r_va_dlc "Debt in Current Liabilities - Total, deflated"

gen r_va_dltt=dltt/PVA
label variable r_va_dltt "Long-Term Debt - Total, deflated"

gen r_va_dp=dp/PVA
label variable r_va_dp "Depreciation and Amortization, deflated"

gen r_va_dvc=dvc/PVA
label variable r_va_dvc "Dividends Common/Ordinary, deflated"

gen r_va_dvp=dvp/PVA
label variable r_va_dvp "Dividends - Preferred/Preference, deflated"

gen r_va_ib=ib/PVA
label variable r_va_ib "Income Before Extraordinary Items, deflated"

gen r_va_lt=lt/PVA
label variable r_va_lt "Liabilities - Total, deflated"

gen r_va_oibdp=oibdp/PVA
label variable r_va_oibdp "Operating Income Before Depreciation, deflated"

gen r_va_ppent=ppent/PVA
label variable r_va_ppent "Property, Plant and Equipment - Total (Net), deflated"

gen r_va_ppegt=ppegt/PVA
label variable r_va_ppegt "Property, Plant and Equipment - Total (Gross), deflated"

gen r_va_sale=sale/PVA
label variable r_va_sale "Sales/Turnover (Net), deflated"

gen r_va_sale_i=sale_i/PVA
label variable r_va_sale_i "Industry Sales, deflated"

gen r_va_seq=seq/PVA
label variable r_va_seq "Stockholders Equity - Parent, deflated"

gen r_va_txdb=txdb/PVA
label variable r_va_txdb "Deferred Taxes (Balance Sheet), deflated"

gen r_va_xlr=xlr/PVA
label variable r_va_xlr "Staff Expense - Total, deflated"

gen r_va_xrd=xrd/PVA
label variable r_va_xrd "Research and Development Expense, deflated"

gen r_va_va= va/PVA
label variable r_va_va "Value Added, deflated"

gen r_va_va_a= va_a/PVA
label variable r_va_va_a "Value Added, deflated"

gen r_va_va_e=va_e/PVA
label variable r_va_va_e "Value Added, deflated"

gen r_va_tex=tex/PVA

gen r_va_materials=materials/PVA

/* Firm variables, Gross Output BEA deflator */

gen r_go_cf=cf/PGO
label variable r_go_cf "Cash Flow, deflated"

gen r_go_cfmxrd=cfmxrd/PGO
label variable r_go_cfmxrd "Cash Flow minus R&D Spending, deflated"

gen r_go_at=at/PGO
label variable r_go_at "Assets - Total, deflated"

gen r_go_capx=capx/PGO
label variable r_go_capx "Capital Expenditures, deflated"

gen r_go_ceq=ceq/PGO
label variable r_go_ceq "Common/Ordinary Equity - Total, deflated"

gen r_go_che=che/PGO
label variable r_go_che "Cash and Short-Term Investments, deflated"

gen r_go_dd1=dd1/PGO
label variable r_go_dd1 "Long-Term Debt Due in One Year, deflated"

gen r_go_dlc=dlc/PGO
label variable r_go_dlc "Debt in Current Liabilities - Total, deflated"

gen r_go_dltt=dltt/PGO
label variable r_go_dltt "Long-Term Debt - Total, deflated"

gen r_go_dp=dp/PGO
label variable r_go_dp "Depreciation and Amortization, deflated"

gen r_go_dvc=dvc/PGO
label variable r_go_dvc "Dividends Common/Ordinary, deflated"

gen r_go_dvp=dvp/PGO
label variable r_go_dvp "Dividends - Preferred/Preference, deflated"

gen r_go_ib=ib/PGO
label variable r_go_ib "Income Before Extraordinary Items, deflated"

gen r_go_lt=lt/PGO
label variable r_go_lt "Liabilities - Total, deflated"

gen r_go_oibdp=oibdp/PGO
label variable r_go_oibdp "Operating Income Before Depreciation, deflated"

gen r_go_ppent=ppent/PGO
label variable r_go_ppent "Property, Plant and Equipment - Total (Net), deflated"

gen r_go_ppegt=ppegt/PGO
label variable r_go_ppegt "Property, Plant and Equipment - Total (Gross), deflated"

gen r_go_sale=sale/PGO
label variable r_go_sale "Sales/Turnover (Net), deflated"

gen r_go_sale_i=sale_i/PGO
label variable r_go_sale_i "Industry Sales, deflated"

gen r_go_seq=seq/PGO
label variable r_go_seq "Stockholders Equity - Parent, deflated"

gen r_go_txdb=txdb/PGO
label variable r_go_txdb "Deferred Taxes (Balance Sheet), deflated"

gen r_go_xlr=xlr/PGO
label variable r_go_xlr "Staff Expense - Total, deflated"

gen r_go_xrd=xrd/PGO
label variable r_go_xrd "Research and Development Expense, deflated"

gen r_go_va= va/PGO
label variable r_go_va "Value Added, deflated"

gen r_go_va_a= va_a/PGO
label variable r_go_va_a "Value Added, deflated"

gen r_go_va_e=va_e/PGO
label variable r_go_va_e "Value Added, deflated"

gen r_go_tex=tex/PGO

gen r_go_materials=materials/PGO

/* Firm variables, Value Added NBER deflator */

gen r_nber_cf=cf/piship
label variable r_nber_cf "Cash Flow, deflated"

gen r_nber_cfmxrd=cfmxrd/piship
label variable r_nber_cfmxrd "Cash Flow minus R&D Spending, deflated"

gen r_nber_at=at/piship
label variable r_nber_at "Assets - Total, deflated"

gen r_nber_capx=capx/piship
label variable r_nber_capx "Capital Expenditures, deflated"

gen r_nber_ceq=ceq/piship
label variable r_nber_ceq "Common/Ordinary Equity - Total, deflated"

gen r_nber_che=che/piship
label variable r_nber_che "Cash and Short-Term Investments, deflated"

gen r_nber_dd1=dd1/piship
label variable r_nber_dd1 "Long-Term Debt Due in One Year, deflated"

gen r_nber_dlc=dlc/piship
label variable r_nber_dlc "Debt in Current Liabilities - Total, deflated"

gen r_nber_dltt=dltt/piship
label variable r_nber_dltt "Long-Term Debt - Total, deflated"

gen r_nber_dp=dp/piship
label variable r_nber_dp "Depreciation and Amortization, deflated"

gen r_nber_dvc=dvc/piship
label variable r_nber_dvc "Dividends Common/Ordinary, deflated"

gen r_nber_dvp=dvp/piship
label variable r_nber_dvp "Dividends - Preferred/Preference, deflated"

gen r_nber_ib=ib/piship
label variable r_nber_ib "Income Before Extraordinary Items, deflated"

gen r_nber_lt=lt/piship
label variable r_nber_lt "Liabilities - Total, deflated"

gen r_nber_oibdp=oibdp/piship
label variable r_nber_oibdp "Operating Income Before Depreciation, deflated"

gen r_nber_ppent=ppent/piship
label variable r_nber_ppent "Property, Plant and Equipment - Total (Net), deflated"

gen r_nber_ppegt=ppegt/piship
label variable r_nber_ppegt "Property, Plant and Equipment - Total (Gross), deflated"

gen r_nber_sale=sale/piship
label variable r_nber_sale "Sales/Turnover (Net), deflated"

gen r_nber_sale_i=sale_i/piship
label variable r_nber_sale_i "Industry Sales, deflated"

gen r_nber_seq=seq/piship
label variable r_nber_seq "Stockholders Equity - Parent, deflated"

gen r_nber_txdb=txdb/piship
label variable r_nber_txdb "Deferred Taxes (Balance Sheet), deflated"

gen r_nber_xlr=xlr/piship
label variable r_nber_xlr "Staff Expense - Total, deflated"

gen r_nber_xrd=xrd/piship
label variable r_nber_xrd "Research and Development Expense, deflated"

gen r_nber_va= va/piship
label variable r_nber_va "Value Added, deflated"

gen r_nber_va_a= va_a/piship
label variable r_nber_va_a "Value Added, deflated"

gen r_nber_va_e=va_e/piship
label variable r_nber_va_e "Value Added, deflated"

gen r_nber_tex=tex/piship

gen r_nber_materials=materials/piship

gen r_ipr_xrd=xrd/P_IPR
label variable r_ipr_xrd "Research and Development Expense, deflated"

gen r_inv_capx=capx/P_NonResidential
label variable r_inv_capx "Capital Expenditures, deflated"

gen r_inv_ppent=ppent/P_NonResidential
label variable r_inv_ppent "Property, Plant and Equipment - Total (Net), deflated"

gen r_inv_ppegt=ppegt/P_NonResidential
label variable r_inv_ppegt "Property, Plant and Equipment - Total (Gross), deflated"

gen r_nberinv_capx=capx/piinv
label variable r_nberinv_capx "Capital Expenditures, deflated"

gen r_nberinv_ppent=ppent/piinv
label variable r_nberinv_ppent "Property, Plant and Equipment - Total (Net), deflated"

gen r_nberinv_ppegt=ppegt/piinv
label variable r_nberinv_ppegt "Property, Plant and Equipment - Total (Gross), deflated"


/* 3. Generating growth rates */

gen d_gdp_xrd=ln(r_gdp_xrd)-ln(l.r_gdp_xrd)
label variable d_gdp_xrd "Growth rate of R&D"

gen d_va_xrd=ln(r_va_xrd)-ln(l.r_va_xrd)
label variable d_va_xrd "Growth rate of R&D"

gen d_go_xrd=ln(r_go_xrd)-ln(l.r_go_xrd)
label variable d_go_xrd "Growth rate of R&D"

gen d_nber_xrd=ln(r_nber_xrd)-ln(l.r_nber_xrd)
label variable d_nber_xrd "Growth rate of R&D"

gen d_ipr_xrd=ln(r_ipr_xrd)-ln(l.r_ipr_xrd)
label variable d_ipr_xrd "Growth rate of R&D"

gen d_gdp_va=ln(r_gdp_va)-ln(l.r_gdp_va)
label variable d_gdp_va "Growth rate of Value Added"

gen d_va_va=ln(r_va_va)-ln(l.r_va_va)
label variable d_va_va "Growth rate of Value Added"

gen d_go_va=ln(r_go_va)-ln(l.r_go_va)
label variable d_go_va "Growth rate of Value Added"

gen d_nber_va=ln(r_nber_va)-ln(l.r_nber_va)
label variable d_nber_va "Growth rate of Value Added"

gen d_gdp_va_a=ln(r_gdp_va_a)-ln(l.r_gdp_va_a)
label variable d_gdp_va_a "Growth rate of Value Added (Alternative)"

gen d_va_va_a=ln(r_va_va_a)-ln(l.r_va_va_a)
label variable d_va_va_a "Growth rate of Value Added (Alternative)"

gen d_go_va_a=ln(r_go_va_a)-ln(l.r_go_va_a)
label variable d_go_va_a "Growth rate of Value Added (Alternative)"

gen d_nber_va_a=ln(r_nber_va_a)-ln(l.r_nber_va_a)
label variable d_nber_va_a "Growth rate of Value Added (Alternative)"

gen d_gdp_va_e=ln(r_gdp_va_e)-ln(l.r_gdp_va_e)
label variable d_gdp_va_e "Growth rate of Value Added (Alternative)"

gen d_va_va_e=ln(r_va_va_e)-ln(l.r_va_va_e)
label variable d_va_va_e "Growth rate of Value Added (Alternative)"

gen d_go_va_e=ln(r_go_va_e)-ln(l.r_go_va_e)
label variable d_go_va_e "Growth rate of Value Added (Alternative)"

gen d_nber_va_e=ln(r_nber_va_e)-ln(l.r_nber_va_e)
label variable d_nber_va_e "Growth rate of Value Added (Alternative)"

gen d_gdp_sale=ln(r_gdp_sale)-ln(l.r_gdp_sale)
label variable d_gdp_sale "Growth rate of Sales"

gen d_va_sale=ln(r_va_sale)-ln(l.r_va_sale)
label variable d_va_sale "Growth rate of Sales"

gen d_go_sale=ln(r_go_sale)-ln(l.r_go_sale)
label variable d_go_sale "Growth rate of Sales"

gen d_nber_sale=ln(r_nber_sale)-ln(l.r_nber_sale)
label variable d_nber_sale "Growth rate of Sales"

gen d_gdp_sale_i=ln(r_gdp_sale_i)-ln(l.r_gdp_sale_i)
label variable d_gdp_sale_i "Growth rate of sale_is"

gen d_va_sale_i=ln(r_va_sale_i)-ln(l.r_va_sale_i)
label variable d_va_sale_i "Growth rate of sale_is"

gen d_go_sale_i=ln(r_go_sale_i)-ln(l.r_go_sale_i)
label variable d_go_sale_i "Growth rate of sale_is"

gen d_nber_sale_i=ln(r_nber_sale_i)-ln(l.r_nber_sale_i)
label variable d_nber_sale_i "Growth rate of sale_is"

gen d_GDP=ln(GDP/P_GDP)-ln(l.GDP/l.P_GDP)
label variable d_GDP "Growth rate of GDP"

/* Generating ratios */

gen z_xrd_sale=xrd/sale
label variable z_xrd_sale "Ratio of R&D to Sales"

gen z_xrd_va=xrd/va
label variable z_xrd_va "Ratio of R&D to Value Added"

gen z_xrd_va_a=xrd/va_a
label variable z_xrd_va_a "Ratio of R&D to Value Added (Alternative)"

gen z_xrd_capx=xrd/(xrd+capx)
label variable z_xrd_capx "Ratio of R&D to R&D and Capital Expenditure"

/* 4. Generating financial variables */

gen mkv=prcc12*cshoq12
label variable mkv "Market Value (common shares)"
gen cfratio=(ib+dp)/l.ppent
label variable cfratio "Cash-flow to physical capital ratio"
gen Q=(at+mkv-ceq-txdb)/at
label variable Q "Tobin Q estimate"
gen debt=(dltt+dlc)/(seq+dltt+dlc)
label variable debt "Debt to total capital ratio"
gen div=(dvp+dvc)/l.ppent
label variable div "Dividends to physical capital ratio"
gen cash=che/l.ppent
label variable cash "Cash and liquid assets to physical capital ratio"

gen KZ=-1.001909*cfratio+.2826389*Q+3.139193*debt-39.3678*div-1.314759*cash

gen KZ_1=1 if KZ< -4.575488
replace KZ_1=0 if KZ >= -4.575488
gen KZ_2=1 if KZ> -4.575488 & KZ<=-1.35775
replace KZ_2=0 if KZ <= -4.575488 | KZ > -1.35775
gen KZ_3=1 if KZ> -1.35775 & KZ<=.3688995
replace KZ_3=0 if KZ <= -1.35775 | KZ > .3688995
gen KZ_4=1 if KZ> .3688995
replace KZ_4=0 if KZ <= .3688995 | KZ == .

gen divpos=1 if dvc > 0 | dvp > 0
replace divpos=0 if divpos != 1

gen lnta=ln(r_gdp_at)
gen ln_va_ta=ln(r_va_at)
gen ln_go_ta=ln(r_go_at)
gen ln_nber_ta=ln(r_nber_at)

gen WW=-0.091*cfratio-0.062*divpos+0.021*debt-0.044*lnta+0.102*d_gdp_sale_i-0.035*d_gdp_sale

gen WW_1=1 if WW< -0.4075759
replace WW_1=0 if WW >= -0.4075759
gen WW_2=1 if WW> -0.4075759 & WW<=-0.3237967
replace WW_2=0 if WW <= -0.4075759 | WW > -0.3237967
gen WW_3=1 if WW> -0.3237967 & WW<=-0.2442014
replace WW_3=0 if WW <= -0.3237967 | WW > -0.2442014
gen WW_4=1 if WW> -0.2442014
replace WW_4=0 if WW <= -0.2442014 | WW == .

/* Generating interaction between growth rates and financial indicators */

gen d_sale_KZ1=d_gdp_sale*KZ_1
gen d_sale_KZ2=d_gdp_sale*KZ_2
gen d_sale_KZ3=d_gdp_sale*KZ_3
gen d_sale_KZ4=d_gdp_sale*KZ_4

gen d_va_a_KZ1=d_gdp_va_a*KZ_1
gen d_va_a_KZ2=d_gdp_va_a*KZ_2
gen d_va_a_KZ3=d_gdp_va_a*KZ_3
gen d_va_a_KZ4=d_gdp_va_a*KZ_4

gen d_va_KZ1=d_gdp_va*KZ_1
gen d_va_KZ2=d_gdp_va*KZ_2
gen d_va_KZ3=d_gdp_va*KZ_3
gen d_va_KZ4=d_gdp_va*KZ_4

gen d_go_KZ1=d_go*KZ_1
gen d_go_KZ2=d_go*KZ_2
gen d_go_KZ3=d_go*KZ_3
gen d_go_KZ4=d_go*KZ_4

gen d_va_i_KZ1=d_va_ind*KZ_1
gen d_va_i_KZ2=d_va_ind*KZ_2
gen d_va_i_KZ3=d_va_ind*KZ_3
gen d_va_i_KZ4=d_va_ind*KZ_4

gen d_vadd_KZ1=d_vadd*KZ_1
gen d_vadd_KZ2=d_vadd*KZ_2
gen d_vadd_KZ3=d_vadd*KZ_3
gen d_vadd_KZ4=d_vadd*KZ_4

gen d_vship_KZ1=d_vship*KZ_1
gen d_vship_KZ2=d_vship*KZ_2
gen d_vship_KZ3=d_vship*KZ_3
gen d_vship_KZ4=d_vship*KZ_4

gen d_sale_WW1=d_gdp_sale*WW_1
gen d_sale_WW2=d_gdp_sale*WW_2
gen d_sale_WW3=d_gdp_sale*WW_3
gen d_sale_WW4=d_gdp_sale*WW_4

gen d_va_a_WW1=d_gdp_va_a*WW_1
gen d_va_a_WW2=d_gdp_va_a*WW_2
gen d_va_a_WW3=d_gdp_va_a*WW_3
gen d_va_a_WW4=d_gdp_va_a*WW_4

gen d_va_WW1=d_gdp_va*WW_1
gen d_va_WW2=d_gdp_va*WW_2
gen d_va_WW3=d_gdp_va*WW_3
gen d_va_WW4=d_gdp_va*WW_4

gen d_go_WW1=d_go*WW_1
gen d_go_WW2=d_go*WW_2
gen d_go_WW3=d_go*WW_3
gen d_go_WW4=d_go*WW_4

gen d_va_i_WW1=d_va_ind*WW_1
gen d_va_i_WW2=d_va_ind*WW_2
gen d_va_i_WW3=d_va_ind*WW_3
gen d_va_i_WW4=d_va_ind*WW_4

gen d_vadd_WW1=d_vadd*WW_1
gen d_vadd_WW2=d_vadd*WW_2
gen d_vadd_WW3=d_vadd*WW_3
gen d_vadd_WW4=d_vadd*WW_4

gen d_vship_WW1=d_vship*WW_1
gen d_vship_WW2=d_vship*WW_2
gen d_vship_WW3=d_vship*WW_3
gen d_vship_WW4=d_vship*WW_4

gen d_h_ag=1 if ag > l.ag
replace d_h_ag=0 if ag < l.ag
gen d_l_ag=1-d_h_ag

gen d_h_ag_fc_sale=d_h_ag*d_gdp_sale
gen d_l_ag_fc_sale=d_l_ag*d_gdp_sale

gen d_h_ag_fc_va_a=d_h_ag*d_gdp_va_a
gen d_l_ag_fc_va_a=d_l_ag*d_gdp_va_a

gen d_h_ag_fc_va=d_h_ag*d_gdp_va
gen d_l_ag_fc_va=d_l_ag*d_gdp_va

gen d_h_bg=1 if bg > l.bg
replace d_h_bg=0 if bg < l.bg
gen d_l_bg=1-d_h_bg

gen d_h_bg_fc_sale=d_h_bg*d_gdp_sale
gen d_l_bg_fc_sale=d_l_bg*d_gdp_sale

gen d_h_bg_fc_va_a=d_h_bg*d_gdp_va_a
gen d_l_bg_fc_va_a=d_l_bg*d_gdp_va_a

gen d_h_bg_fc_va=d_h_bg*d_gdp_va
gen d_l_bg_fc_va=d_l_bg*d_gdp_va

gen d_h_ba=1 if ba > l.ba
replace d_h_ba=0 if ba < l.ba
gen d_l_ba=1-d_h_ba

gen d_h_ba_fc_sale=d_h_ba*d_gdp_sale
gen d_l_ba_fc_sale=d_l_ba*d_gdp_sale

gen d_h_ba_fc_va_a=d_h_ba*d_gdp_va_a
gen d_l_ba_fc_va_a=d_l_ba*d_gdp_va_a

gen d_h_ba_fc_va=d_h_ba*d_gdp_va
gen d_l_ba_fc_va=d_l_ba*d_gdp_va

/* 5. Generating asymmetric growth rates */

gen d_h_va=1 if d_gdp_va>0
replace d_h_va=0 if d_gdp_va<0
gen d_l_va=1-d_h_va
replace d_h_va=d_h_va*d_gdp_va
replace d_l_va=d_l_va*d_gdp_va

gen d_h_va_a=1 if d_gdp_va_a>0
replace d_h_va_a=0 if d_gdp_va_a<0
gen d_l_va_a=1-d_h_va_a
replace d_h_va_a=d_h_va_a*d_gdp_va_a
replace d_l_va_a=d_l_va_a*d_gdp_va_a

gen d_h_sale=1 if d_gdp_sale>0
replace d_h_sale=0 if d_gdp_sale<0
gen d_l_sale=1-d_h_sale
replace d_h_sale=d_h_sale*d_gdp_sale
replace d_l_sale=d_l_sale*d_gdp_sale

gen d_h_GDP=1 if d_GDP>0
replace d_h_GDP=0 if d_GDP<0
gen d_l_GDP=1-d_h_GDP
replace d_h_GDP=d_h_GDP*d_GDP
replace d_l_GDP=d_l_GDP*d_GDP

gen d_h_va_i=1 if d_va_ind>0
replace d_h_va_i=0 if d_va_ind<0
gen d_l_va_i=1-d_h_va_i
replace d_h_va_i=d_h_va_i*d_va_ind
replace d_l_va_i=d_l_va_i*d_va_ind

gen d_h_go=1 if d_go>0
replace d_h_go=0 if d_go<0
gen d_l_go=1-d_h_go
replace d_h_go=d_h_go*d_go
replace d_l_go=d_l_go*d_go

gen d_h_vadd=1 if d_vadd>0
replace d_h_vadd=0 if d_vadd<0
gen d_l_vadd=1-d_h_vadd
replace d_h_vadd=d_h_vadd*d_vadd
replace d_l_vadd=d_l_vadd*d_vadd

gen d_h_vship=1 if d_vship>0
replace d_h_vship=0 if d_vship<0
gen d_l_vship=1-d_h_vship
replace d_h_vship=d_h_vship*d_vship
replace d_l_vship=d_l_vship*d_vship

/* 6. Generating Deviations */

by key: egen mean_d_xrd=mean(d_xrd)
gen dev_xrd=d_xrd-mean_d_xrd

by key: egen mean_d_sale=mean(d_sale)
gen dev_sale=d_sale-mean_d_sale

by key: egen mean_d_GDP=mean(d_GDP)
gen dev_GDP=d_GDP-mean_d_GDP

by key: egen mean_d_va=mean(d_va)
gen dev_va=d_va-mean_d_va

by key: egen mean_d_va_a=mean(d_va_a)
gen dev_va_a=d_va_a-mean_d_va_a

by key: egen mean_d_va_i=mean(d_va_i)
gen dev_va_i=d_va_i-mean_d_va_i

by key: egen mean_d_go=mean(d_go)
gen dev_go=d_go-mean_d_go

by key: egen mean_d_vadd=mean(d_vadd)
gen dev_vadd=d_vadd-mean_d_vadd

by key: egen mean_d_vship=mean(d_vship)
gen dev_vship=d_vship-mean_d_vship

gen dev_h_sale=1 if dev_sale > 0
replace dev_h_sale=0 if dev_sale < 0
gen dev_l_sale=1-dev_h_sale
replace dev_h_sale=dev_sale*dev_h_sale
replace dev_l_sale=dev_sale*dev_l_sale

gen dev_h_GDP=1 if dev_GDP > 0
replace dev_h_GDP=0 if dev_GDP < 0
gen dev_l_GDP=1-dev_h_GDP
replace dev_h_GDP=dev_GDP*dev_h_GDP
replace dev_l_GDP=dev_GDP*dev_l_GDP

gen dev_h_va=1 if dev_va > 0
replace dev_h_va=0 if dev_va < 0
gen dev_l_va=1-dev_h_va
replace dev_h_va=dev_va*dev_h_va
replace dev_l_va=dev_va*dev_l_va

gen dev_h_va_a=1 if dev_va_a > 0
replace dev_h_va_a=0 if dev_va_a < 0
gen dev_l_va_a=1-dev_h_va_a
replace dev_h_va_a=dev_va_a*dev_h_va_a
replace dev_l_va_a=dev_va_a*dev_l_va_a

gen dev_h_va_i=1 if dev_va_i > 0
replace dev_h_va_i=0 if dev_va_i < 0
gen dev_l_va_i=1-dev_h_va_i
replace dev_h_va_i=dev_va_i*dev_h_va_i
replace dev_l_va_i=dev_va_i*dev_l_va_i

gen dev_h_go=1 if dev_go > 0
replace dev_h_go=0 if dev_go < 0
gen dev_l_go=1-dev_h_go
replace dev_h_go=dev_go*dev_h_go
replace dev_l_go=dev_go*dev_l_go

gen dev_h_vadd=1 if dev_vadd > 0
replace dev_h_vadd=0 if dev_vadd < 0
gen dev_l_vadd=1-dev_h_vadd
replace dev_h_vadd=dev_vadd*dev_h_vadd
replace dev_l_vadd=dev_vadd*dev_l_vadd

gen dev_h_vship=1 if dev_vship > 0
replace dev_h_vship=0 if dev_vship < 0
gen dev_l_vship=1-dev_h_vship
replace dev_h_vship=dev_vship*dev_h_vship
replace dev_l_vship=dev_vship*dev_l_vship

/* Generating exit variable */

gen t=_n
gen firmid = gvkeysort firmid yearby firmid: gen count = _Ngen survivor = count == 61gen has95 = 1 if year == 2011sort firmid has95by firmid: replace has95 = 1 if has95[_n-1] == 1replace has95 = 0 if has95 == .sort firmid yearby firmid: gen has_gaps = 1 if year[_n-1] != year-1 & _n != 1sort firmid has_gapsby firmid: replace has_gaps = 1 if has_gaps[_n-1] == 1replace has_gaps = 0 if has_gaps == .
sort firmid yearby firmid: generate exit = survivor == 0 & has95 == 0 & has_gaps != 1 & _n == _Nreplace exit = 0 if exit == 1 & year == 2011

sort key year sic naics

tabulate year, gen(yr)

/* Returns to R&D estimation */

gen q=r_sale/emp
gen l_q=ln(q)
gen d_q=d.l_q
gen z1=r_xrd/q
gen z2=r_xrd/emp
sort year key
by year: egen average_z1=mean(z1)
by year: egen average_z2=mean(z2)
sort key year
gmm (ONE:f.d_q-{B1=0.027}*z1^{B2=0.1}), instruments(d_q l.d_q l.z1) wmatrix(hac bartlett)

/* Regressions */

/* Firm measures of output */

/* First table COMPUSTAT - Table 9 in paper */

xtreg d_ipr_xrd d_gdp_sale l.d_gdp_sale emp r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_inv_ppent l.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_inv_ppent) l2.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_inv_ppent) i.year if z_xrd_sale<2 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_gdp_sale<3 & d_gdp_sale>-3, fe vce(cluster sic)
est store A
xtreg z_xrd_sale l.z_xrd_sale l2.z_xrd_sale d_gdp_sale l.d_gdp_sale emp r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_inv_ppent l.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_inv_ppent) l2.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_inv_ppent)  i.year if z_xrd_sale<2 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_gdp_sale<3 & d_gdp_sale>-3, fe vce(cluster sic)
est store B
xtreg z_xrd_capx l.z_xrd_capx l2.z_xrd_capx d_gdp_sale l.d_gdp_sale emp r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_inv_ppent l.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_inv_ppent) l2.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_inv_ppent)  i.year if z_xrd_sale<2 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_gdp_sale<3 & d_gdp_sale>-3, fe vce(cluster sic)
est store C
xtreg d_ipr_xrd d_gdp_va l.d_gdp_va emp r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_inv_ppent l.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_inv_ppent) l2.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_inv_ppent) i.year if z_xrd_va<1 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_gdp_va<1 & d_gdp_va>-1, fe vce(cluster sic)
est store D
xtreg z_xrd_va l.z_xrd_va l2.z_xrd_va d_gdp_va l.d_gdp_va emp r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_inv_ppent l.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_inv_ppent) l2.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_inv_ppent)  i.year if z_xrd_va<1 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_gdp_va<1 & d_gdp_va>-1, fe vce(cluster sic)
est store E
xtreg z_xrd_capx l.z_xrd_capx l2.z_xrd_capx d_gdp_va l.d_gdp_va emp r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_inv_ppent l.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_inv_ppent) l2.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_inv_ppent)  i.year if z_xrd_va<1 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_gdp_va<1 & d_gdp_va>-1, fe vce(cluster sic)
est store F
esttab A B C D E F, tex se
drop _est_A _est_B _est_C _est_D _est_E _est_F

/* Alternatives */

xtreg d_gdp_xrd d_gdp_sale l.d_gdp_sale emp r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent l.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent) l2.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent) i.year if z_xrd_sale<2 & d_gdp_xrd<2 & d_gdp_xrd>-2 & d_gdp_sale<3 & d_gdp_sale>-3, fe vce(cluster sic)
est store A
xtreg z_xrd_sale l.z_xrd_sale l2.z_xrd_sale d_gdp_sale l.d_gdp_sale emp r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent l.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent) l2.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent)  i.year if z_xrd_sale<2 & d_gdp_xrd<2 & d_gdp_xrd>-2 & d_gdp_sale<3 & d_gdp_sale>-3, fe vce(cluster sic)
est store B
xtreg z_xrd_capx l.z_xrd_capx l2.z_xrd_capx d_gdp_sale l.d_gdp_sale emp r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent l.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent) l2.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent)  i.year if z_xrd_sale<2 & d_gdp_xrd<2 & d_gdp_xrd>-2 & d_gdp_sale<3 & d_gdp_sale>-3, fe vce(cluster sic)
est store C
xtreg d_gdp_xrd d_gdp_va l.d_gdp_va emp r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent l.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent) l2.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent) i.year if z_xrd_va<1 & d_gdp_xrd<2 & d_gdp_xrd>-2 & d_gdp_va<1 & d_gdp_va>-1, fe vce(cluster sic)
est store D
xtreg z_xrd_va l.z_xrd_va l2.z_xrd_va d_gdp_va l.d_gdp_va emp r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent l.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent) l2.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent)  i.year if z_xrd_va<1 & d_gdp_xrd<2 & d_gdp_xrd>-2 & d_gdp_va<1 & d_gdp_va>-1, fe vce(cluster sic)
est store E
xtreg z_xrd_capx l.z_xrd_capx l2.z_xrd_capx d_gdp_va l.d_gdp_va emp r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent l.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent) l2.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent)  i.year if z_xrd_va<1 & d_gdp_xrd<2 & d_gdp_xrd>-2 & d_gdp_va<1 & d_gdp_va>-1, fe vce(cluster sic)
est store F
esttab A B C D E F, tex se
drop _est_A _est_B _est_C _est_D _est_E _est_F

xtreg d_va_xrd d_va_sale l.d_va_sale emp r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent l.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) l2.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) i.year if z_xrd_sale<2 & d_va_xrd<2 & d_va_xrd>-2 & d_va_sale<3 & d_va_sale>-3, fe vce(cluster sic)
est store A
xtreg z_xrd_sale l.z_xrd_sale l2.z_xrd_sale d_va_sale l.d_va_sale emp r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent l.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) l2.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent)  i.year if z_xrd_sale<2 & d_va_xrd<2 & d_va_xrd>-2 & d_va_sale<3 & d_va_sale>-3, fe vce(cluster sic)
est store B
xtreg z_xrd_capx l.z_xrd_capx l2.z_xrd_capx d_va_sale l.d_va_sale emp r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent l.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) l2.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent)  i.year if z_xrd_sale<2 & d_va_xrd<2 & d_va_xrd>-2 & d_va_sale<3 & d_va_sale>-3, fe vce(cluster sic)
est store C
xtreg d_va_xrd d_va_va l.d_va_va emp r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent l.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) l2.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) i.year if z_xrd_va<1 & d_va_xrd<2 & d_va_xrd>-2 & d_va_va<1 & d_va_va>-1, fe vce(cluster sic)
est store D
xtreg z_xrd_va l.z_xrd_va l2.z_xrd_va d_va_va l.d_va_va emp r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent l.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) l2.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent)  i.year if z_xrd_va<1 & d_va_xrd<2 & d_va_xrd>-2 & d_va_va<1 & d_va_va>-1, fe vce(cluster sic)
est store E
xtreg z_xrd_capx l.z_xrd_capx l2.z_xrd_capx d_va_va l.d_va_va emp r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent l.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) l2.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent)  i.year if z_xrd_va<1 & d_va_xrd<2 & d_va_xrd>-2 & d_va_va<1 & d_va_va>-1, fe vce(cluster sic)
est store F
esttab A B C D E F, tex se
drop _est_A _est_B _est_C _est_D _est_E _est_F

xtreg d_ipr_xrd d_va_sale l.d_va_sale emp r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent l.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) l2.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) i.year if z_xrd_sale<2 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_va_sale<3 & d_va_sale>-3, fe vce(cluster sic)
est store A
xtreg z_xrd_sale l.z_xrd_sale l2.z_xrd_sale d_va_sale l.d_va_sale emp r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent l.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) l2.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent)  i.year if z_xrd_sale<2 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_va_sale<3 & d_va_sale>-3, fe vce(cluster sic)
est store B
xtreg z_xrd_capx l.z_xrd_capx l2.z_xrd_capx d_va_sale l.d_va_sale emp r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent l.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) l2.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent)  i.year if z_xrd_sale<2 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_va_sale<3 & d_va_sale>-3, fe vce(cluster sic)
est store C
xtreg d_ipr_xrd d_va_va l.d_va_va emp r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent l.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) l2.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) i.year if z_xrd_va<1 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_va_va<1 & d_va_va>-1, fe vce(cluster sic)
est store D
xtreg z_xrd_va l.z_xrd_va l2.z_xrd_va d_va_va l.d_va_va emp r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent l.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) l2.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent)  i.year if z_xrd_va<1 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_va_va<1 & d_va_va>-1, fe vce(cluster sic)
est store E
xtreg z_xrd_capx l.z_xrd_capx l2.z_xrd_capx d_va_va l.d_va_va emp r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent l.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) l2.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent)  i.year if z_xrd_va<1 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_va_va<1 & d_va_va>-1, fe vce(cluster sic)
est store F
esttab A B C D E F, tex se
drop _est_A _est_B _est_C _est_D _est_E _est_F

xtreg d_go_xrd d_go_sale l.d_go_sale emp r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent l.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) l2.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) i.year if z_xrd_sale<2 & d_go_xrd<2 & d_go_xrd>-2 & d_go_sale<3 & d_go_sale>-3, fe vce(cluster sic)
est store A
xtreg z_xrd_sale l.z_xrd_sale l2.z_xrd_sale d_go_sale l.d_go_sale emp r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent l.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) l2.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent)  i.year if z_xrd_sale<2 & d_go_xrd<2 & d_go_xrd>-2 & d_go_sale<3 & d_go_sale>-3, fe vce(cluster sic)
est store B
xtreg z_xrd_capx l.z_xrd_capx l2.z_xrd_capx d_go_sale l.d_go_sale emp r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent l.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) l2.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent)  i.year if z_xrd_sale<2 & d_go_xrd<2 & d_go_xrd>-2 & d_go_sale<3 & d_go_sale>-3, fe vce(cluster sic)
est store C
xtreg d_go_xrd d_go_va l.d_go_va emp r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent l.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) l2.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) i.year if z_xrd_va<1 & d_go_xrd<2 & d_go_xrd>-2 & d_go_va<1 & d_go_va>-1, fe vce(cluster sic)
est store D
xtreg z_xrd_va l.z_xrd_va l2.z_xrd_va d_go_va l.d_go_va emp r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent l.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) l2.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent)  i.year if z_xrd_va<1 & d_go_xrd<2 & d_go_xrd>-2 & d_go_va<1 & d_go_va>-1, fe vce(cluster sic)
est store E
xtreg z_xrd_capx l.z_xrd_capx l2.z_xrd_capx d_go_va l.d_go_va emp r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent l.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) l2.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent)  i.year if z_xrd_va<1 & d_go_xrd<2 & d_go_xrd>-2 & d_go_va<1 & d_go_va>-1, fe vce(cluster sic)
est store F
esttab A B C D E F, tex se
drop _est_A _est_B _est_C _est_D _est_E _est_F

xtreg d_ipr_xrd d_go_sale l.d_go_sale emp r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent l.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) l2.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) i.year if z_xrd_sale<2 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_go_sale<3 & d_go_sale>-3, fe vce(cluster sic)
est store A
xtreg z_xrd_sale l.z_xrd_sale l2.z_xrd_sale d_go_sale l.d_go_sale emp r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent l.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) l2.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent)  i.year if z_xrd_sale<2 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_go_sale<3 & d_go_sale>-3, fe vce(cluster sic)
est store B
xtreg z_xrd_capx l.z_xrd_capx l2.z_xrd_capx d_go_sale l.d_go_sale emp r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent l.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) l2.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent)  i.year if z_xrd_sale<2 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_go_sale<3 & d_go_sale>-3, fe vce(cluster sic)
est store C
xtreg d_ipr_xrd d_go_va l.d_go_va emp r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent l.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) l2.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) i.year if z_xrd_va<1 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_go_va<1 & d_go_va>-1, fe vce(cluster sic)
est store D
xtreg z_xrd_va l.z_xrd_va l2.z_xrd_va d_go_va l.d_go_va emp r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent l.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) l2.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent)  i.year if z_xrd_va<1 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_go_va<1 & d_go_va>-1, fe vce(cluster sic)
est store E
xtreg z_xrd_capx l.z_xrd_capx l2.z_xrd_capx d_go_va l.d_go_va emp r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent l.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) l2.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent)  i.year if z_xrd_va<1 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_go_va<1 & d_go_va>-1, fe vce(cluster sic)
est store F
esttab A B C D E F, tex se
drop _est_A _est_B _est_C _est_D _est_E _est_F

xtreg d_nber_xrd d_nber_sale l.d_nber_sale emp r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent l.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) l2.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) i.year if z_xrd_sale<2 & d_nber_xrd<2 & d_nber_xrd>-2 & d_nber_sale<3 & d_nber_sale>-3, fe vce(cluster sic)
est store A
xtreg z_xrd_sale l.z_xrd_sale l2.z_xrd_sale d_nber_sale l.d_nber_sale emp r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent l.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) l2.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent)  i.year if z_xrd_sale<2 & d_nber_xrd<2 & d_nber_xrd>-2 & d_nber_sale<3 & d_nber_sale>-3, fe vce(cluster sic)
est store B
xtreg z_xrd_capx l.z_xrd_capx l2.z_xrd_capx d_nber_sale l.d_nber_sale emp r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent l.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) l2.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent)  i.year if z_xrd_sale<2 & d_nber_xrd<2 & d_nber_xrd>-2 & d_nber_sale<3 & d_nber_sale>-3, fe vce(cluster sic)
est store C
xtreg d_nber_xrd d_nber_va l.d_nber_va emp r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent l.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) l2.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) i.year if z_xrd_va<1 & d_nber_xrd<2 & d_nber_xrd>-2 & d_nber_va<1 & d_nber_va>-1, fe vce(cluster sic)
est store D
xtreg z_xrd_va l.z_xrd_va l2.z_xrd_va d_nber_va l.d_nber_va emp r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent l.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) l2.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent)  i.year if z_xrd_va<1 & d_nber_xrd<2 & d_nber_xrd>-2 & d_nber_va<1 & d_nber_va>-1, fe vce(cluster sic)
est store E
xtreg z_xrd_capx l.z_xrd_capx l2.z_xrd_capx d_nber_va l.d_nber_va emp r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent l.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) l2.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent)  i.year if z_xrd_va<1 & d_nber_xrd<2 & d_nber_xrd>-2 & d_nber_va<1 & d_nber_va>-1, fe vce(cluster sic)
est store F
esttab A B C D E F, tex se
drop _est_A _est_B _est_C _est_D _est_E _est_F

xtreg d_ipr_xrd d_nber_sale l.d_nber_sale emp r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent l.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) l2.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) i.year if z_xrd_sale<2 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_nber_sale<3 & d_nber_sale>-3, fe vce(cluster sic)
est store A
xtreg z_xrd_sale l.z_xrd_sale l2.z_xrd_sale d_nber_sale l.d_nber_sale emp r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent l.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) l2.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent)  i.year if z_xrd_sale<2 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_nber_sale<3 & d_nber_sale>-3, fe vce(cluster sic)
est store B
xtreg z_xrd_capx l.z_xrd_capx l2.z_xrd_capx d_nber_sale l.d_nber_sale emp r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent l.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) l2.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent)  i.year if z_xrd_sale<2 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_nber_sale<3 & d_nber_sale>-3, fe vce(cluster sic)
est store C
xtreg d_ipr_xrd d_nber_va l.d_nber_va emp r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent l.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) l2.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) i.year if z_xrd_va<1 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_nber_va<1 & d_nber_va>-1, fe vce(cluster sic)
est store D
xtreg z_xrd_va l.z_xrd_va l2.z_xrd_va d_nber_va l.d_nber_va emp r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent l.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) l2.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent)  i.year if z_xrd_va<1 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_nber_va<1 & d_nber_va>-1, fe vce(cluster sic)
est store E
xtreg z_xrd_capx l.z_xrd_capx l2.z_xrd_capx d_nber_va l.d_nber_va emp r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent l.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) l2.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent)  i.year if z_xrd_va<1 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_nber_va<1 & d_nber_va>-1, fe vce(cluster sic)
est store F
esttab A B C D E F, tex se
drop _est_A _est_B _est_C _est_D _est_E _est_F


/* Second table COMPUSTAT - Table 10 in paper */

xtreg d_xrd d_h_sale d_l_sale l.(d_h_sale d_l_sale) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) i.year if z_xrd_sale<2 & d_xrd<2 & d_xrd>-2 & d_sale<3 & d_sale>-3, fe vce(cluster sic)
est store A
xtreg z_xrd_sale l.z_xrd_sale l2.z_xrd_sale d_h_sale d_l_sale l.(d_h_sale d_l_sale) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  i.year if z_xrd_sale<2 & d_xrd<2 & d_xrd>-2 & d_sale<3 & d_sale>-3, fe vce(cluster sic)
est store B
xtreg z_xrd_capx l.z_xrd_capx l2.z_xrd_capx d_h_sale d_l_sale l.(d_h_sale d_l_sale) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  i.year if z_xrd_sale<2 & d_xrd<2 & d_xrd>-2 & d_sale<3 & d_sale>-3, fe vce(cluster sic)
est store C
xtreg d_xrd d_h_va d_l_va l.(d_h_va d_l_va) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) i.year if z_xrd_va<1 & d_xrd<2 & d_xrd>-2 & d_va<1 & d_va>-1, fe vce(cluster sic)
est store D
xtreg z_xrd_va l.z_xrd_va l2.z_xrd_va d_h_va d_l_va l.(d_h_va d_l_va) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  i.year if z_xrd_va<1 & d_xrd<2 & d_xrd>-2 & d_va<1 & d_va>-1, fe vce(cluster sic)
est store E
xtreg z_xrd_capx l.z_xrd_capx l2.z_xrd_capx d_h_va d_l_va l.(d_h_va d_l_va) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  i.year if z_xrd_va<1 & d_xrd<2 & d_xrd>-2 & d_va<1 & d_va>-1, fe vce(cluster sic)
est store F
esttab A B C D E F, tex se
drop _est_A _est_B _est_C _est_D _est_E _est_F

/* Endogeneity */

xtreg d_gdp_xrd d_gdp_sale l.d_gdp_sale d_va_ind emp r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent l.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent) l2.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent) i.year if z_xrd_sale<2 & d_gdp_xrd<2 & d_gdp_xrd>-2 & d_gdp_sale<3 & d_gdp_sale>-3, fe vce(cluster sic)
est store A
xtreg d_gdp_xrd d_gdp_va l.d_gdp_va d_va_ind emp r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent l.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent) l2.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent) i.year if z_xrd_va<1 & d_gdp_xrd<2 & d_gdp_xrd>-2 & d_gdp_va<1 & d_gdp_va>-1, fe vce(cluster sic)
est store B
xtreg d_gdp_xrd d_gdp_sale l.d_gdp_sale d_go emp r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent l.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent) l2.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent) i.year if z_xrd_sale<2 & d_gdp_xrd<2 & d_gdp_xrd>-2 & d_gdp_sale<3 & d_gdp_sale>-3, fe vce(cluster sic)
est store C
xtreg d_gdp_xrd d_gdp_va l.d_gdp_va d_go emp r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent l.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent) l2.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent) i.year if z_xrd_va<1 & d_gdp_xrd<2 & d_gdp_xrd>-2 & d_gdp_va<1 & d_gdp_va>-1, fe vce(cluster sic)
est store D
esttab A B C D, tex se
drop _est_A _est_B _est_C _est_D

xtreg d_va_xrd d_va_sale l.d_va_sale d_va_ind emp r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent l.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) l2.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) i.year if z_xrd_sale<2 & d_va_xrd<2 & d_va_xrd>-2 & d_va_sale<3 & d_va_sale>-3, fe vce(cluster sic)
est store A
xtreg d_va_xrd d_va_va l.d_va_va d_va_ind emp r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent l.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) l2.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) i.year if z_xrd_va<1 & d_va_xrd<2 & d_va_xrd>-2 & d_va_va<1 & d_va_va>-1, fe vce(cluster sic)
est store B
xtreg d_va_xrd d_va_sale l.d_va_sale d_go emp r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent l.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) l2.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) i.year if z_xrd_sale<2 & d_va_xrd<2 & d_va_xrd>-2 & d_va_sale<3 & d_va_sale>-3, fe vce(cluster sic)
est store C
xtreg d_va_xrd d_va_va l.d_va_va d_go emp r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent l.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) l2.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) i.year if z_xrd_va<1 & d_va_xrd<2 & d_va_xrd>-2 & d_va_va<1 & d_va_va>-1, fe vce(cluster sic)
est store D
esttab A B C D, tex se
drop _est_A _est_B _est_C _est_D

xtreg d_go_xrd d_go_sale l.d_go_sale d_va_ind emp r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent l.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) l2.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) i.year if z_xrd_sale<2 & d_go_xrd<2 & d_go_xrd>-2 & d_go_sale<3 & d_go_sale>-3, fe vce(cluster sic)
est store A
xtreg d_go_xrd d_go_va l.d_go_va d_va_ind emp r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent l.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) l2.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) i.year if z_xrd_va<1 & d_go_xrd<2 & d_go_xrd>-2 & d_go_va<1 & d_go_va>-1, fe vce(cluster sic)
est store B
xtreg d_go_xrd d_go_sale l.d_go_sale d_go emp r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent l.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) l2.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) i.year if z_xrd_sale<2 & d_go_xrd<2 & d_go_xrd>-2 & d_go_sale<3 & d_go_sale>-3, fe vce(cluster sic)
est store C
xtreg d_go_xrd d_go_va l.d_go_va d_go emp r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent l.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) l2.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) i.year if z_xrd_va<1 & d_go_xrd<2 & d_go_xrd>-2 & d_go_va<1 & d_go_va>-1, fe vce(cluster sic)
est store D
esttab A B C D, tex se
drop _est_A _est_B _est_C _est_D

xtreg d_nber_xrd d_nber_sale l.d_nber_sale d_vadd emp r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent l.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) l2.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) i.year if z_xrd_sale<2 & d_nber_xrd<2 & d_nber_xrd>-2 & d_nber_sale<3 & d_nber_sale>-3, fe vce(cluster sic)
est store A
xtreg d_nber_xrd d_nber_va l.d_nber_va d_vadd emp r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent l.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) l2.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) i.year if z_xrd_va<1 & d_nber_xrd<2 & d_nber_xrd>-2 & d_nber_va<1 & d_nber_va>-1, fe vce(cluster sic)
est store B
xtreg d_nber_xrd d_nber_sale l.d_nber_sale d_vship emp r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent l.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) l2.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) i.year if z_xrd_sale<2 & d_nber_xrd<2 & d_nber_xrd>-2 & d_nber_sale<3 & d_nber_sale>-3, fe vce(cluster sic)
est store C
xtreg d_nber_xrd d_nber_va l.d_nber_va d_vship emp r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent l.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) l2.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) i.year if z_xrd_va<1 & d_nber_xrd<2 & d_nber_xrd>-2 & d_nber_va<1 & d_nber_va>-1, fe vce(cluster sic)
est store D
esttab A B C D, tex se
drop _est_A _est_B _est_C _est_D

xtreg d_ipr_xrd d_gdp_sale l.d_gdp_sale d_va_ind emp r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent l.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent) l2.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent) i.year if z_xrd_sale<2 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_gdp_sale<3 & d_gdp_sale>-3, fe vce(cluster sic)
est store A
xtreg d_ipr_xrd d_gdp_va l.d_gdp_va d_va_ind emp r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent l.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent) l2.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent) i.year if z_xrd_va<1 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_gdp_va<1 & d_gdp_va>-1, fe vce(cluster sic)
est store B
xtreg d_ipr_xrd d_gdp_sale l.d_gdp_sale d_go emp r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent l.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent) l2.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent) i.year if z_xrd_sale<2 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_gdp_sale<3 & d_gdp_sale>-3, fe vce(cluster sic)
est store C
xtreg d_ipr_xrd d_gdp_va l.d_gdp_va d_go emp r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent l.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent) l2.(r_gdp_cf r_gdp_dd1 r_gdp_dltt r_gdp_lt r_gdp_at r_gdp_ppent) i.year if z_xrd_va<1 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_gdp_va<1 & d_gdp_va>-1, fe vce(cluster sic)
est store D
esttab A B C D, tex se
drop _est_A _est_B _est_C _est_D

xtreg d_ipr_xrd d_va_sale l.d_va_sale d_va_ind emp r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent l.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) l2.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) i.year if z_xrd_sale<2 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_va_sale<3 & d_va_sale>-3, fe vce(cluster sic)
est store A
xtreg d_ipr_xrd d_va_va l.d_va_va d_va_ind emp r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent l.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) l2.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) i.year if z_xrd_va<1 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_va_va<1 & d_va_va>-1, fe vce(cluster sic)
est store B
xtreg d_ipr_xrd d_va_sale l.d_va_sale d_go emp r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent l.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) l2.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) i.year if z_xrd_sale<2 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_va_sale<3 & d_va_sale>-3, fe vce(cluster sic)
est store C
xtreg d_ipr_xrd d_va_va l.d_va_va d_go emp r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent l.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) l2.(r_va_cf r_va_dd1 r_va_dltt r_va_lt r_va_at r_va_ppent) i.year if z_xrd_va<1 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_va_va<1 & d_va_va>-1, fe vce(cluster sic)
est store D
esttab A B C D, tex se
drop _est_A _est_B _est_C _est_D

xtreg d_ipr_xrd d_go_sale l.d_go_sale d_va_ind emp r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent l.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) l2.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) i.year if z_xrd_sale<2 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_go_sale<3 & d_go_sale>-3, fe vce(cluster sic)
est store A
xtreg d_ipr_xrd d_go_va l.d_go_va d_va_ind emp r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent l.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) l2.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) i.year if z_xrd_va<1 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_go_va<1 & d_go_va>-1, fe vce(cluster sic)
est store B
xtreg d_ipr_xrd d_go_sale l.d_go_sale d_go emp r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent l.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) l2.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) i.year if z_xrd_sale<2 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_go_sale<3 & d_go_sale>-3, fe vce(cluster sic)
est store C
xtreg d_ipr_xrd d_go_va l.d_go_va d_go emp r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent l.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) l2.(r_go_cf r_go_dd1 r_go_dltt r_go_lt r_go_at r_go_ppent) i.year if z_xrd_va<1 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_go_va<1 & d_go_va>-1, fe vce(cluster sic)
est store D
esttab A B C D, tex se
drop _est_A _est_B _est_C _est_D

xtreg d_ipr_xrd d_nber_sale l.d_nber_sale d_vadd emp r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent l.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) l2.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) i.year if z_xrd_sale<2 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_nber_sale<3 & d_nber_sale>-3, fe vce(cluster sic)
est store A
xtreg d_ipr_xrd d_nber_va l.d_nber_va d_vadd emp r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent l.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) l2.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) i.year if z_xrd_va<1 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_nber_va<1 & d_nber_va>-1, fe vce(cluster sic)
est store B
xtreg d_ipr_xrd d_nber_sale l.d_nber_sale d_vship emp r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent l.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) l2.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) i.year if z_xrd_sale<2 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_nber_sale<3 & d_nber_sale>-3, fe vce(cluster sic)
est store C
xtreg d_ipr_xrd d_nber_va l.d_nber_va d_vship emp r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent l.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) l2.(r_nber_cf r_nber_dd1 r_nber_dltt r_nber_lt r_nber_at r_nber_ppent) i.year if z_xrd_va<1 & d_ipr_xrd<2 & d_ipr_xrd>-2 & d_nber_va<1 & d_nber_va>-1, fe vce(cluster sic)
est store D
esttab A B C D, tex se
drop _est_A _est_B _est_C _est_D

/**/

xtivreg2 d_xrd (d_sale l.d_sale =  d_go f.d_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) yr* if z_xrd_sale<2 & d_xrd<2 & d_xrd>-2 & d_sale<3 & d_sale>-3, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_sale l.d_sale) 
est store A
xtivreg2 d_xrd (d_sale l.d_sale =  d_va_i f.d_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) yr* if z_xrd_sale<2 & d_xrd<2 & d_xrd>-2 & d_sale<3 & d_sale>-3, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_sale l.d_sale) 
est store B
xtivreg2 d_xrd (d_sale l.d_sale =  d_output f.d_output) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) yr* if z_xrd_sale<2 & d_xrd<2 & d_xrd>-2 & d_sale<3 & d_sale>-3, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_sale l.d_sale)
est store C
xtivreg2 d_xrd (d_sale l.d_sale =  d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) yr* if z_xrd_sale<2 & d_xrd<2 & d_xrd>-2 & d_sale<3 & d_sale>-3, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_sale l.d_sale)
est store D
xtivreg2 d_xrd (d_sale l.d_sale =  d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) yr* if z_xrd_sale<2 & d_xrd<2 & d_xrd>-2 & d_sale<3 & d_sale>-3, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_sale l.d_sale)
est store E
esttab A B C D E, tex se
drop _est_A _est_B _est_C _est_D _est_E

xtivreg2 d_xrd (d_va l.d_va =  d_go f.d_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) yr*  if z_xrd_va<1 & d_xrd<2 & d_xrd>-2 & d_va<1 & d_va>-1, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_va l.d_va)
est store A
xtivreg2 d_xrd (d_va l.d_va =  d_va_i f.d_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) yr*  if z_xrd_va<1 & d_xrd<2 & d_xrd>-2 & d_va<1 & d_va>-1, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_va l.d_va)
est store B
xtivreg2 d_xrd (d_va l.d_va =  d_output f.d_output) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) yr*  if z_xrd_va<1 & d_xrd<2 & d_xrd>-2 & d_va<1 & d_va>-1, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_va l.d_va)
est store C
xtivreg2 d_xrd (d_va l.d_va =  d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) yr*  if z_xrd_va<1 & d_xrd<2 & d_xrd>-2 & d_va<1 & d_va>-1, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_va l.d_va)
est store D
xtivreg2 d_xrd (d_va l.d_va =  d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) yr*  if z_xrd_va<1 & d_xrd<2 & d_xrd>-2 & d_va<1 & d_va>-1, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_va l.d_va)
est store E
esttab A B C D E, tex se
drop _est_A _est_B _est_C _est_D _est_E

xtivreg2 d_xrd (d_va_a l.d_va_a =  d_go f.d_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) yr* if z_xrd_va_a<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_va_a l.d_va_a)
est store A
xtivreg2 d_xrd (d_va_a l.d_va_a =  d_va_i f.d_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) yr* if z_xrd_va_a<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_va_a l.d_va_a)
est store B
xtivreg2 d_xrd (d_va_a l.d_va_a =  d_output f.d_output) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) yr* if z_xrd_va_a<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_va_a l.d_va_a) 
est store C
xtivreg2 d_xrd (d_va_a l.d_va_a =  d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) yr* if z_xrd_va_a<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_va_a l.d_va_a) 
est store D
xtivreg2 d_xrd (d_va_a l.d_va_a =  d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) yr* if z_xrd_va_a<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_va_a l.d_va_a) 
est store E
esttab A B C D E, tex se
drop _est_A _est_B _est_C _est_D _est_E

/* */
xtivreg2 dev_xrd (dev_sale = dev_go f.(dev_go)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(dev_sale) redundant(f.dev_go)
est store A
xtivreg2 dev_xrd (dev_sale = dev_va_i f.(dev_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(dev_sale) redundant(f.dev_va_i)
est store B
xtivreg2 dev_xrd (dev_sale = dev_output f.(dev_output)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(dev_sale) redundant(f.dev_output)
est store C
xtivreg2 dev_xrd (dev_sale = dev_vadd f.(dev_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(dev_sale) redundant(f.dev_vadd)
est store D
xtivreg2 dev_xrd (dev_sale = dev_vship f.(dev_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(dev_sale) redundant(f.dev_vship)
est store E
esttab A B C D E, tex se
drop _est_A _est_B _est_C _est_D _est_E

xtivreg2 d_xrd (d_h_sale d_l_sale =  d_h_go d_l_go f.(d_h_go d_l_go)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_h_sale d_l_sale) redundant( f.(d_h_go d_l_go))
est store A
xtivreg2 d_xrd (d_h_sale d_l_sale =  d_h_va_i d_l_va_i f.(d_h_va_i d_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_h_sale d_l_sale) redundant( f.(d_h_va_i d_l_va_i))
est store B
xtivreg2 d_xrd (d_h_sale d_l_sale =  d_h_output d_l_output f.(d_h_output d_l_output)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_h_sale d_l_sale) redundant( f.(d_h_output d_l_output))
est store C
xtivreg2 d_xrd (d_h_sale d_l_sale =  d_h_vadd d_l_vadd f.(d_h_vadd d_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_h_sale d_l_sale) redundant( f.(d_h_vadd d_l_vadd))
est store D
xtivreg2 d_xrd (d_h_sale d_l_sale =  d_h_vship d_l_vship f.(d_h_vship d_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_h_sale d_l_sale) redundant( f.(d_h_vship d_l_vship))
est store E
esttab A B C D E, tex se
drop _est_A _est_B _est_C _est_D _est_E

xtivreg2 d_xrd (d_h_sale d_l_sale = d_h_go d_l_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_h_sale d_l_sale)
est store A
xtivreg2 d_xrd (d_h_sale d_l_sale = d_h_va_i d_l_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_h_sale d_l_sale)
est store B
xtivreg2 d_xrd (d_h_sale d_l_sale = d_h_output d_l_output) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_h_sale d_l_sale)
est store C
xtivreg2 d_xrd (d_h_sale d_l_sale = d_h_vadd d_l_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_h_sale d_l_sale)
est store D
xtivreg2 d_xrd (d_h_sale d_l_sale = d_h_vship d_l_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_h_sale d_l_sale)
est store E
esttab A B C D E, tex se
drop _est_A _est_B _est_C _est_D _est_E

xtivreg2 dev_xrd (dev_h_sale dev_l_sale = dev_h_go dev_l_go f.(dev_h_go dev_l_go)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(dev_h_sale dev_l_sale)
est store A
xtivreg2 dev_xrd (dev_h_sale dev_l_sale = dev_h_va_i dev_l_va_i f.(dev_h_va_i dev_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(dev_h_sale dev_l_sale)
est store B
xtivreg2 dev_xrd (dev_h_sale dev_l_sale = dev_h_output dev_l_output f.(dev_h_output dev_l_output)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(dev_h_sale dev_l_sale)
est store C
xtivreg2 dev_xrd (dev_h_sale dev_l_sale = dev_h_vadd dev_l_vadd f.(dev_h_vadd dev_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(dev_h_sale dev_l_sale)
est store D
xtivreg2 dev_xrd (dev_h_sale dev_l_sale = dev_h_vship dev_l_vship f.(dev_h_vship dev_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(dev_h_sale dev_l_sale)
est store E
esttab A B C D E, tex se
drop _est_A _est_B _est_C _est_D _est_E

xtivreg2 dev_xrd (dev_h_sale dev_l_sale = dev_h_go dev_l_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(dev_h_sale dev_l_sale)
est store A
xtivreg2 dev_xrd (dev_h_sale dev_l_sale = dev_h_va_i dev_l_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(dev_h_sale dev_l_sale)
est store B
xtivreg2 dev_xrd (dev_h_sale dev_l_sale = dev_h_output dev_l_output) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(dev_h_sale dev_l_sale)
est store C
xtivreg2 dev_xrd (dev_h_sale dev_l_sale = dev_h_vadd dev_l_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  yr* if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(dev_h_sale dev_l_sale)
est store D
xtivreg2 dev_xrd (dev_h_sale dev_l_sale = dev_h_vship dev_l_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(dev_h_sale dev_l_sale)
est store E
esttab A B C D E, tex se
drop _est_A _est_B _est_C _est_D _est_E


/* Production Function Estimates */

replace logcap=ln(l.ppegt/l.P_FixedInvestment)

reg logvaa logemp logcap t, vce(cluster sic)
test (_b[logemp] + _b[logcap]=1)
est store A
gen l_tfp_1=logvaa-logemp*_b[logemp]-logcap*_b[logcap]
gen l_vaa_hat_1=logvaa-l_tfp_1
gen d_tfp_1=d.l_tfp_1
gen d_vaa_hat_1=d.l_vaa_hat_1
xtreg logvaa logemp logcap t, fe vce(cluster sic)
test (_b[logemp] + _b[logcap]=1)
est store B
gen l_tfp_2=logvaa-logemp*_b[logemp]-logcap*_b[logcap]
gen l_vaa_hat_2=logvaa-l_tfp_2
gen d_tfp_2=d.l_tfp_2
gen d_vaa_hat_2=d.l_vaa_hat_2
opreg logvaa, exit(exit) state(logcap) proxy(loginv) free(logemp) cvars(t) vce(bootstrap, seed(1) rep(100))
test (_b[logemp] + _b[logcap]=1)
est store C
predict l_tfp_3, tfp
gen l_vaa_hat_3=logvaa-l_tfp_3
gen d_tfp_3=d.l_tfp_3
gen d_vaa_hat_3=d.l_vaa_hat_3

reg logva logemp logcap t, vce(cluster sic)
test (_b[logemp] + _b[logcap]=1)
est store A
gen l_tfp_1=logva-logemp*_b[logemp]-logcap*_b[logcap]
gen l_vaa_hat_1=logva-l_tfp_1
gen d_tfp_1=d.l_tfp_1
gen d_vaa_hat_1=d.l_vaa_hat_1
xtreg logva logemp logcap t, fe vce(cluster sic)
test (_b[logemp] + _b[logcap]=1)
est store B
gen l_tfp_2=logva-logemp*_b[logemp]-logcap*_b[logcap]
gen l_vaa_hat_2=logva-l_tfp_2
gen d_tfp_2=d.l_tfp_2
gen d_vaa_hat_2=d.l_vaa_hat_2
opreg logva, exit(exit) state(logcap) proxy(loginv) free(logemp) cvars(t) vce(bootstrap, seed(1) rep(100))
test (_b[logemp] + _b[logcap]=1)
est store C
predict l_tfp_3, tfp
gen l_vaa_hat_3=logva-l_tfp_3
gen d_tfp_3=d.l_tfp_3
gen d_vaa_hat_3=d.l_vaa_hat_3


reg logvaa logemp logcap logvai t, vce(cluster sic)
nlcom _b[logemp]*(1/(1-_b[logvai]))+_b[logcap]*(1/(1-_b[logvai]))-1, level(95)
est store D
gen l_tfp_va_i_1=logvaa-logemp*_b[logemp]-logcap*_b[logcap]-_b[t]*t-_b[logvai]*logvai
gen l_vaa_hat_va_i_1=logvaa-l_tfp_va_i_1
gen d_tfp_va_i_1=d.l_tfp_va_i_1
gen d_vaa_hat_va_i_1=d.l_vaa_hat_va_i_1
xtreg logvaa logemp logcap logvai t, fe vce(cluster sic)
nlcom _b[logemp]*(1/(1-_b[logvai]))+_b[logcap]*(1/(1-_b[logvai]))-1, level(95)
est store E
gen l_tfp_va_i_2=logvaa-logemp*_b[logemp]-logcap*_b[logcap]-_b[t]*t-_b[logvai]*logvai
gen l_vaa_hat_va_i_2=logvaa-l_tfp_va_i_2
gen d_tfp_va_i_2=d.l_tfp_va_i_2
gen d_vaa_hat_va_i_2=d.l_vaa_hat_va_i_2
opreg logvaa, exit(exit) state(logcap) proxy(loginv) free(logemp) cvars(logvai t) vce(bootstrap, seed(1) rep(100))
nlcom _b[logemp]*(1/(1-_b[logvai]))+_b[logcap]*(1/(1-_b[logvai]))-1, level(95)
est store F
predict l_tfp_va_i_3, tfp
gen l_va_hat_va_i_3=logvaa-l_tfp_va_i_3
gen d_tfp_va_i_3=d.l_tfp_va_i_3
gen d_va_hat_va_i_3=d.l_va_hat_va_i_3

reg logvaa logemp logcap logvadd t, vce(cluster sic)
nlcom _b[logemp]*(1/(1-_b[logvadd]))+_b[logcap]*(1/(1-_b[logvadd]))-1, level(95)
est store G
gen l_tfp_vadd_1=logvaa-logemp*_b[logemp]-logcap*_b[logcap]-_b[t]*t-_b[logvadd]*logvadd
gen l_vaa_hat_vadd_1=logvaa-l_tfp_vadd_1
gen d_tfp_vadd_1=d.l_tfp_vadd_1
gen d_vaa_hat_vadd_1=d.l_vaa_hat_vadd_1
xtreg logvaa logemp logcap logvadd t, fe vce(cluster sic)
nlcom _b[logemp]*(1/(1-_b[logvadd]))+_b[logcap]*(1/(1-_b[logvadd]))-1, level(95)
est store H
gen l_tfp_vadd_2=logvaa-logemp*_b[logemp]-logcap*_b[logcap]-_b[t]*t-_b[logvadd]*logvadd
gen l_vaa_hat_vadd_2=logvaa-l_tfp_vadd_2
gen d_tfp_vadd_2=d.l_tfp_vadd_2
gen d_vaa_hat_vadd_2=d.l_vaa_hat_vadd_2
opreg logvaa, exit(exit) state(logcap) proxy(loginv) free(logemp) cvars(logvadd t) vce(bootstrap, seed(1) rep(100))
nlcom _b[logemp]*(1/(1-_b[logvadd]))+_b[logcap]*(1/(1-_b[logvadd]))-1, level(95)
est store I
predict l_tfp_vadd_3, tfp
gen l_va_hat_vadd_3=logvaa-l_tfp_vadd_3
gen d_tfp_vadd_3=d.l_tfp_vadd_3
gen d_va_hat_vadd_3=d.l_va_hat_vadd_3
esttab A B C D E F G H I, tex se
drop _est_A _est_B _est_C _est_D _est_E _est_F _est_G _est_H _est_I

by key: egen mean_tfp_1=mean(l_tfp_1)
by key: egen mean_d_tfp_1=mean(d_tfp_1)

by key: egen mean_tfp_2=mean(l_tfp_2)
by key: egen mean_d_tfp_2=mean(d_tfp_2)

by key: egen mean_tfp_3=mean(l_tfp_3)
by key: egen mean_d_tfp_3=mean(d_tfp_3)

/* Alternative deflator, NBER data */

reg vanber logemp capnber t, vce(cluster sic)
test (_b[logemp] + _b[capnber]=1)
est store A
predict l_tfp_nber_1, xb
gen l_va_hat_nber_1=vanber-l_tfp_nber_1
gen d_tfp_nber_1=d.l_tfp_nber_1
gen d_va_hat_nber_1=d.l_va_hat_nber_1
xtreg vanber logemp capnber t, fe vce(cluster sic)
test (_b[logemp] + _b[capnber]=1)
est store B
predict l_tfp_nber_2, xb
gen l_va_hat_nber_2=vanber-l_tfp_nber_2
gen d_tfp_nber_2=d.l_tfp_nber_2
gen d_va_hat_nber_2=d.l_va_hat_nber_2
opreg vanber, exit(exit) state(capnber) proxy(invnber) free(logemp) cvars(t) vce(bootstrap, seed(1) rep(50))
test (_b[logemp] + _b[capnber]=1)
est store C
predict l_tfp_nber_3, tfp
gen l_va_hat_nber_3=vanber-l_tfp_nber_3
gen d_tfp_nber_3=d.l_tfp_nber_3
gen d_va_hat_nber_3=d.l_va_hat_nber_3

reg vanber logemp capnber logvadd t, vce(cluster sic)
nlcom _b[logemp]/_b[logvadd]/(1/_b[logvadd]-1)+_b[capnber]/_b[logvadd]/(1/_b[logvadd]-1)-1, level(95)
est store D
predict l_tfp_nber_vadd_1, xb
gen l_va_hat_nber_vadd_1=vanber-l_tfp_nber_vadd_1
gen d_tfp_nber_vadd_1=d.l_tfp_nber_vadd_1
gen d_va_hat_nber_vadd_1=d.l_va_hat_nber_vadd_1
xtreg vanber logemp capnber logvadd t, fe vce(cluster sic)
nlcom _b[logemp]/_b[logvadd]/(1/_b[logvadd]-1)+_b[capnber]/_b[logvadd]/(1/_b[logvadd]-1)-1, level(95)
est store E
predict l_tfp_nber_vadd_2, xb
gen l_va_hat_nber_vadd_2=vanber-l_tfp_nber_vadd_2
gen d_tfp_nber_vadd_2=d.l_tfp_nber_vadd_2
gen d_va_hat_nber_vadd_2=d.l_va_hat_nber_vadd_2
opreg vanber, exit(exit) state(capnber) proxy(invnber) free(logemp) cvars(logvadd t) vce(bootstrap, seed(1) rep(50))
nlcom _b[logemp]/_b[logvadd]/(1/_b[logvadd]-1)+_b[capnber]/_b[logvadd]/(1/_b[logvadd]-1)-1, level(95)
est store F
predict l_tfp_nber_vadd_3, tfp
gen l_va_hat_nber_vadd_3=vanber-l_tfp_nber_vadd_3
gen d_tfp_nber_vadd_3=d.l_tfp_nber_vadd_3
gen d_va_hat_nber_vadd_3=d.l_va_hat_nber_vadd_3

reg vanber logemp capnber logvship t, vce(cluster sic)
nlcom _b[logemp]/_b[logvship]/(1/_b[logvship]-1)+_b[capnber]/_b[logvship]/(1/_b[logvship]-1)-1, level(95)
est store G
predict l_tfp_nber_vship_1, xb
gen l_va_hat_nber_vship_1=vanber-l_tfp_nber_vship_1
gen d_tfp_nber_vship_1=d.l_tfp_nber_vship_1
gen d_va_hat_nber_vship_1=d.l_va_hat_nber_vship_1
xtreg vanber logemp capnber logvship t, fe vce(cluster sic)
nlcom _b[logemp]/_b[logvship]/(1/_b[logvship]-1)+_b[capnber]/_b[logvship]/(1/_b[logvship]-1)-1, level(95)
est store H
predict l_tfp_nber_vship_2, xb
gen l_va_hat_nber_vship_2=vanber-l_tfp_nber_vship_2
gen d_tfp_nber_vship_2=d.l_tfp_nber_vship_2
gen d_va_hat_nber_vship_2=d.l_va_hat_nber_vship_2
opreg vanber, exit(exit) state(capnber) proxy(invnber) free(logemp) cvars(logvship t) vce(bootstrap, seed(1) rep(50))
nlcom _b[logemp]/_b[logvship]/(1/_b[logvship]-1)+_b[capnber]/_b[logvship]/(1/_b[logvship]-1)-1, level(95)
est store I
predict l_tfp_nber_vship_3, tfp
gen l_va_hat_nber_vship_3=vanber-l_tfp_nber_vship_3
gen d_tfp_nber_vship_3=d.l_tfp_nber_vship_3
gen d_va_hat_nber_vship_3=d.l_va_hat_nber_vship_3
esttab A B C D E F G H I, tex se
drop _est_A _est_B _est_C _est_D _est_E _est_F _est_G _est_H _est_I

/* Financial constraints */

xtreg d_xrd d_h_ba_fc_sale d_l_ba_fc_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  i.year if  z_xrd_sale<2, fe vce(cluster sic)
est store A
xtreg z_xrd_sale l.z_xrd_sale l2.z_xrd_sale d_h_ba_fc_sale d_l_ba_fc_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  i.year if  z_xrd_sale<2, fe vce(cluster sic)
est store B
xtreg z_xrd_capx l.z_xrd_capx l2.z_xrd_capx d_h_ba_fc_sale d_l_ba_fc_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  i.year if  z_xrd_sale<2, fe vce(cluster sic)
est store C
esttab A B C, tex se
drop _est_A _est_B _est_C

xtreg d_xrd d_h_bg_fc_sale d_l_bg_fc_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  i.year if  z_xrd_sale<2, fe vce(cluster sic)
est store A
xtreg z_xrd_sale l.z_xrd_sale l2.z_xrd_sale d_h_bg_fc_sale d_l_bg_fc_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  i.year if  z_xrd_sale<2, fe vce(cluster sic)
est store B
xtreg z_xrd_capx l.z_xrd_capx l2.z_xrd_capx d_h_bg_fc_sale d_l_bg_fc_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  i.year if  z_xrd_sale<2, fe vce(cluster sic)
est store C
esttab A B C, tex se
drop _est_A _est_B _est_C

xtreg d_xrd d_sale_KZ1 d_sale_KZ2 d_sale_KZ3 d_sale_KZ4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  i.year if  z_xrd_sale<2, fe vce(cluster sic)
est store A
test (_b[d_sale_KZ1] = _b[d_sale_KZ4])
xtreg z_xrd_sale l.z_xrd_sale l2.z_xrd_sale d_sale_KZ1 d_sale_KZ2 d_sale_KZ3 d_sale_KZ4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  i.year if  z_xrd_sale<2, fe vce(cluster sic)
est store B
test (_b[d_sale_KZ1] = _b[d_sale_KZ4])
xtreg z_xrd_capx l.z_xrd_capx l2.z_xrd_capx d_sale_KZ1 d_sale_KZ2 d_sale_KZ3 d_sale_KZ4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  i.year if  z_xrd_sale<2, fe vce(cluster sic)
est store C
test (_b[d_sale_KZ1] = _b[d_sale_KZ4])
esttab A B C, tex se
drop _est_A _est_B _est_C

xtreg d_xrd d_sale_WW1 d_sale_WW2 d_sale_WW3 d_sale_WW4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  i.year if  z_xrd_sale<2, fe vce(cluster sic)
est store A
test (_b[d_sale_WW1] = _b[d_sale_WW4])
xtreg z_xrd_sale l.z_xrd_sale l2.z_xrd_sale d_sale_WW1 d_sale_WW2 d_sale_WW3 d_sale_WW4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  i.year if  z_xrd_sale<2, fe vce(cluster sic)
est store B
test (_b[d_sale_WW1] = _b[d_sale_WW4])
xtreg z_xrd_capx l.z_xrd_capx l2.z_xrd_capx d_sale_WW1 d_sale_WW2 d_sale_WW3 d_sale_WW4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  i.year if  z_xrd_sale<2, fe vce(cluster sic)
est store C
test (_b[d_sale_WW1] = _b[d_sale_WW4])
esttab A B C, tex se
drop _est_A _est_B _est_C

xtreg d_xrd d_h_ag_fc_sale d_l_ag_fc_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  i.year if  z_xrd_sale<2, fe vce(cluster sic)
est store A
xtreg z_xrd_sale l.z_xrd_sale l2.z_xrd_sale d_h_ag_fc_sale d_l_ag_fc_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  i.year if  z_xrd_sale<2, fe vce(cluster sic)
est store B
xtreg z_xrd_capx l.z_xrd_capx l2.z_xrd_capx d_h_ag_fc_sale d_l_ag_fc_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent)  i.year if  z_xrd_sale<2, fe vce(cluster sic)
est store C
esttab A B C, tex se
drop _est_A _est_B _est_C

/* Simultaneity and TFP */

xtivreg2 d_xrd d_tfp_nber_1 (d_sale =  d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_sale) redundant( f.d_vadd)
xtivreg2 d_xrd d_tfp_nber_2 (d_sale =  d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_sale) redundant( f.d_vadd)
xtivreg2 d_xrd d_tfp_nber_3 (d_sale =  d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_sale) redundant( f.d_vadd)
xtivreg2 d_xrd d_tfp_nber_1 (d_sale =  d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_sale) redundant( f.d_vship)
xtivreg2 d_xrd d_tfp_nber_2 (d_sale =  d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_sale) redundant( f.d_vship)
xtivreg2 d_xrd d_tfp_nber_3 (d_sale =  d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_sale) redundant( f.d_vship)

xtivreg2 d_xrd d_tfp_nber_vadd_1 (d_sale =  d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_sale) redundant( f.d_vadd)
xtivreg2 d_xrd d_tfp_nber_vadd_2 (d_sale =  d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_sale) redundant( f.d_vadd)
xtivreg2 d_xrd d_tfp_nber_vadd_3 (d_sale =  d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_sale) redundant( f.d_vadd)
xtivreg2 d_xrd d_tfp_nber_vship_1 (d_sale =  d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_sale) redundant( f.d_vship)
xtivreg2 d_xrd d_tfp_nber_vship_2 (d_sale =  d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_sale) redundant( f.d_vship)
xtivreg2 d_xrd d_tfp_nber_vship_3 (d_sale =  d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) l2.(r_cf r_dd1 r_dltt r_lt r_at r_ppent) yr*  if  z_xrd_sale<2, fe ivar(key) tvar(year) robust cluster(sic) endogtest(d_sale) redundant( f.d_vship)

