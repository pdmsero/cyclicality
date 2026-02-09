/* COMPUSTAT merged with BEA, 3 digit NAICS code */

use "/Users/pedroserodio/Dropbox/Working folder/Thesis ~ Working Files/data/[3]_compustat_BEA_3digits.dta", clear

sort key year sic naics

xtset key year, yearly

/* Aggregate variables */

gen r_GDP=GDP/GDPdeflator
label variable r_GDP "GDP, deflated"

/* Industry variables */

gen r_va_i=va_i/GDPdeflator
label variable r_va_i "Total value added, deflated"

gen r_go=go/GDPdeflator
label variable r_go "Total value added in $1m, own deflator"

/* Firm variables */

gen cf=ib+dp
label variable cf "Cash Flow"

gen r_cf=cf/GDPdeflator
label variable r_cf "Cash Flow, deflated"

gen r_at=at/GDPdeflator
label variable r_at "Assets - Total, deflated"

gen r_capx=capx/GDPdeflator
label variable r_capx "Capital Expenditures, deflated"

gen r_ceq=ceq/GDPdeflator
label variable r_ceq "Common/Ordinary Equity - Total, deflated"

gen r_che=che/GDPdeflator
label variable r_che "Cash and Short-Term Investments, deflated"

gen r_dd1=dd1/GDPdeflator
label variable r_dd1 "Long-Term Debt Due in One Year, deflated"

gen r_dlc=dlc/GDPdeflator
label variable r_dlc "Debt in Current Liabilities - Total, deflated"

gen r_dltt=dltt/GDPdeflator
label variable r_dltt "Long-Term Debt - Total, deflated"

gen r_dp=dp/GDPdeflator
label variable r_dp "Depreciation and Amortization, deflated"

gen r_dvc=dvc/GDPdeflator
label variable r_dvc "Dividends Common/Ordinary, deflated"

gen r_dvp=dvp/GDPdeflator
label variable r_dvp "Dividends - Preferred/Preference, deflated"

gen r_ib=ib/GDPdeflator
label variable r_ib "Income Before Extraordinary Items, deflated"

gen r_lt=lt/GDPdeflator
label variable r_lt "Liabilities - Total, deflated"

gen r_oibdp=oibdp/GDPdeflator
label variable r_oibdp "Operating Income Before Depreciation, deflated"

gen r_ppent=ppent/GDPdeflator
label variable r_ppent "Property, Plant and Equipment - Total (Net), deflated"

gen r_sale=sale/GDPdeflator
label variable r_sale "Sales/Turnover (Net), deflated"

gen r_seq=seq/GDPdeflator
label variable r_seq "Stockholders Equity - Parent, deflated"

gen r_txdb=txdb/GDPdeflator
label variable r_txdb "Deferred Taxes (Balance Sheet), deflated"

gen r_xlr=xlr/GDPdeflator
label variable r_xlr "Staff Expense - Total, deflated"

gen r_xrd=xrd/GDPdeflator
label variable r_xrd "Research and Development Expense, deflated"

gen va= oibdp+xlr
label variable va "Value Added"

gen r_va= va/GDPdeflator
label variable r_va "Value Added, deflated"

gen wagebill=emp*averagewage/1000
label variable wagebill "Approximate wage bill using mean annual wage"

gen va_a=oibdp+wagebill
label variable va_a "Alternative measure of Value Added"

gen r_va_a= va_a/GDPdeflator
label variable r_va_a "Value Added, deflated"

/* Generating growth rates */

gen d_xrd=ln(r_xrd)-ln(l.r_xrd)
label variable d_xrd "Growth rate of R&D"

gen d_va=ln(r_va)-ln(l.r_va)
label variable d_va "Growth rate of Value Added"

gen d_va_a=ln(r_va_a)-ln(l.r_va_a)
label variable d_va_a "Growth rate of Value Added (Alternative)"

gen d_sale=ln(r_sale)-ln(l.r_sale)
label variable d_sale "Growth rate of Sales"

gen d_GDP=ln(r_GDP)-ln(l.r_GDP)
label variable d_GDP "Growth rate of GDP"

gen d_va_i=ln(r_va_i)-ln(l.r_va_i)
label variable d_va_i "Growth rate of Value Added, Industry"

gen d_go=ln(r_go)-ln(l.r_go)
label variable d_go "Growth rate of Gross Output"



/* Generating ratios */

gen z_xrd_sale=xrd/sale
label variable z_xrd_sale "Ratio of R&D to Sales"

gen z_xrd_va=xrd/va
label variable z_xrd_va "Ratio of R&D to Value Added"

gen z_xrd_va_a=xrd/va_a
label variable z_xrd_va _a"Ratio of R&D to Value Added (Alternative)"

gen z_xrd_capx=xrd/(xrd+capx)
label variable z_xrd_capx "Ratio of R&D to R&D and Capital Expenditure"


/* Generating asymmetric growth rates */

gen d_h_va=1 if d_va>0
replace d_h_va=0 if d_va<0
gen d_l_va=1-d_h_va
replace d_h_va=d_h_va*d_va
replace d_l_va=d_l_va*d_va

gen d_h_va_a=1 if d_va_a>0
replace d_h_va_a=0 if d_va_a<0
gen d_l_va_a=1-d_h_va_a
replace d_h_va_a=d_h_va_a*d_va_a
replace d_l_va_a=d_l_va_a*d_va_a

gen g_h_sale=1 if d_sale>0
replace g_h_sale=0 if d_sale<0
gen g_l_sale=1-g_h_sale
gen d_h_sale=g_h_sale*d_sale
gen d_l_sale=g_l_sale*d_sale

gen g_h_GDP=1 if d_GDP>0
replace g_h_GDP=0 if d_GDP<0
gen g_l_GDP=1-g_h_GDP
gen d_h_GDP=g_h_GDP*d_GDP
gen d_l_GDP=g_l_GDP*d_GDP

gen d_h_va_i=1 if d_va_i>0
replace d_h_va_i=0 if d_va_i<0
gen d_l_va_i=1-d_h_va_i
replace d_h_va_i=d_h_va_i*d_va_i
replace d_l_va_i=d_l_va_i*d_va_i

gen d_h_go=1 if d_go>0
replace d_h_go=0 if d_go<0
gen d_l_go=1-d_h_go
replace d_h_go=d_h_go*d_go
replace d_l_go=d_l_go*d_go

/* Deviations */

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


/* REGRESSIONS */

xtreg d_xrd d_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store A
xtreg z_rd_go l.z_rd_go l2.z_rd_go d_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store A
xtreg z_rd_va_i l.z_rd_va_i l2.z_rd_va_i d_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store A
xtreg z_rd_sale l.z_rd_sale l2.z_rd_sale d_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store A
xtreg z_rd_va_a l.z_rd_va_a l2.z_rd_va_a d_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_h_go d_l_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store A
xtreg z_rd_go l.z_rd_go l2.z_rd_go d_h_go d_l_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_h_go d_l_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_h_va_i d_l_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store A
xtreg z_rd_va_i l.z_rd_va_i l2.z_rd_va_i d_h_va_i d_l_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_h_va_i d_l_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_h_va_a d_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store A
xtreg z_rd_va_a l.z_rd_va_a l2.z_rd_va_a d_h_va_a d_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_h_va_a d_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_h_sale d_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store A
xtreg z_rd_sale l.z_rd_sale l2.z_rd_sale d_h_sale d_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_h_sale d_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

$|------------------------------------------------------------------------------------------ IV SECTION ------------------------------------------------------------------------------------------|$

xtivreg2 d_xrd (d_sale = d_go f.d_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key) endogtest(d_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (d_sale = d_go f.d_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key) endogtest(d_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_sale = d_go f.d_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key) endogtest(d_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (d_sale = d_va_i f.d_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key) endogtest(d_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (d_sale = d_va_i f.d_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key) endogtest(d_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_sale = d_va_i f.d_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key) endogtest(d_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (d_va_a = d_va_i f.d_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key) endogtest(d_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (d_va_a = d_va_i f.d_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key) endogtest(d_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_va_a = d_va_i f.d_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key) endogtest(d_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (d_va_a = d_go f.d_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key) endogtest(d_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (d_va_a = d_go f.d_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key) endogtest(d_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_va_a = d_go f.d_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key) endogtest(d_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (d_h_sale d_l_sale = d_h_go d_l_go f.(d_h_go d_l_go)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key) endogtest(d_h_sale d_l_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (d_h_sale d_l_sale = d_h_go d_l_go f.(d_h_go d_l_go)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key) endogtest(d_h_sale d_l_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_h_sale d_l_sale = d_h_go d_l_go f.(d_h_go d_l_go)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key) endogtest(d_h_sale d_l_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (d_h_sale d_l_sale = d_h_va_i d_l_va_i f.(d_h_va_i d_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key) endogtest(d_h_sale d_l_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (d_h_sale d_l_sale = d_h_va_i d_l_va_i f.(d_h_va_i d_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key) endogtest(d_h_sale d_l_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_h_sale d_l_sale = d_h_va_i d_l_va_i f.(d_h_va_i d_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key) endogtest(d_h_sale d_l_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (d_h_va_a d_l_va_a = d_h_va_i d_l_va_i f.(d_h_va_i d_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key) endogtest(d_h_va_a d_l_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (d_h_va_a d_l_va_a = d_h_va_i d_l_va_i f.(d_h_va_i d_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key) endogtest(d_h_va_a d_l_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_h_va_a d_l_va_a = d_h_va_i d_l_va_i f.(d_h_va_i d_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key) endogtest(d_h_va_a d_l_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (d_h_va_a d_l_va_a = d_h_go d_l_go f.(d_h_go d_l_go)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key) endogtest(d_h_va_a d_l_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (d_h_va_a d_l_va_a = d_h_go d_l_go f.(d_h_go d_l_go)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key) endogtest(d_h_va_a d_l_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_h_va_a d_l_va_a = d_h_go d_l_go f.(d_h_go d_l_go)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key) endogtest(d_h_va_a d_l_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

$|------------------------------------------------------------------------------------------ DEMEANED DATA ------------------------------------------------------------------------------------------|$

xtreg dev_xrd dev_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store A
xtreg z_rd_go l.z_rd_go l2.z_rd_go dev_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store A
xtreg z_rd_va_i l.z_rd_va_i l2.z_rd_va_i dev_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store A
xtreg z_rd_sale l.z_rd_sale l2.z_rd_sale dev_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store A
xtreg z_rd_va_a l.z_rd_va_a l2.z_rd_va_a dev_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_h_go dev_l_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store A
xtreg z_rd_go l.z_rd_go l2.z_rd_go dev_h_go dev_l_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_h_go dev_l_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_g_h_va_i dev_g_l_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store A
xtreg z_rd_va_i l.z_rd_va_i l2.z_rd_va_i dev_g_h_va_i dev_g_l_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_g_h_va_i dev_g_l_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_g_h_va_a dev_g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store A
xtreg z_rd_va_a l.z_rd_va_a l2.z_rd_va_a dev_g_h_va_a dev_g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_g_h_va_a dev_g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_g_h_sale dev_g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store A
xtreg z_rd_sale l.z_rd_sale l2.z_rd_sale dev_g_h_sale dev_g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_g_h_sale dev_g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

$|------------------------------------------------------------------------------------------ IV SECTION ------------------------------------------------------------------------------------------|$

xtivreg2 dev_xrd (dev_sale = dev_go f.dev_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_sale = dev_go f.dev_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_sale = dev_go f.dev_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_sale = dev_va_i f.dev_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key) endogtest(d_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_sale = dev_va_i f.dev_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_sale = dev_va_i f.dev_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_va_a = dev_va_i f.dev_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (dev_va_a = dev_va_i f.dev_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_va_a = dev_va_i f.dev_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_g_h_sale dev_g_l_sale = dev_g_h_go dev_g_l_go f.(dev_g_h_go dev_g_l_go)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_g_h_sale dev_g_l_sale = dev_g_h_go dev_g_l_go f.(dev_g_h_go dev_g_l_go)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_g_h_sale dev_g_l_sale = dev_g_h_go dev_g_l_go f.(dev_g_h_go dev_g_l_go)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_g_h_sale dev_g_l_sale = dev_g_h_va_i dev_g_l_va_i f.(dev_g_h_va_i dev_g_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_g_h_sale dev_g_l_sale = dev_g_h_va_i dev_g_l_va_i f.(dev_g_h_va_i dev_g_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_g_h_sale dev_g_l_sale = dev_g_h_va_i dev_g_l_va_i f.(dev_g_h_va_i dev_g_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_g_h_va_a dev_g_l_va_a = dev_g_h_va_i dev_g_l_va_i f.(dev_g_h_va_i dev_g_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (dev_g_h_va_a dev_g_l_va_a = dev_g_h_va_i dev_g_l_va_i f.(dev_g_h_va_i dev_g_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_g_h_va_a dev_g_l_va_a = dev_g_h_va_i dev_g_l_va_i f.(dev_g_h_va_i dev_g_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

$|------------------------------------------------------------------------------------------ GMM2 SECTION ------------------------------------------------------------------------------------------|$

xtivreg2 dev_xrd (dev_sale = dev_go f.dev_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(key)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_sale = dev_go f.dev_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(key)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_sale = dev_go f.dev_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_sale = dev_va_i f.dev_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(key)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_sale = dev_va_i f.dev_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(key)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_sale = dev_va_i f.dev_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_va_a = dev_va_i f.dev_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(key)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (dev_va_a = dev_va_i f.dev_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(key)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_va_a = dev_va_i f.dev_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_g_h_sale dev_g_l_sale = dev_go f.dev_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(key)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_g_h_sale dev_g_l_sale = dev_go f.dev_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(key)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_g_h_sale dev_g_l_sale = dev_go f.dev_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_g_h_sale dev_g_l_sale = dev_g_h_va_i dev_g_l_va_i f.(dev_g_h_va_i dev_g_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(key)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_g_h_sale dev_g_l_sale = dev_g_h_va_i dev_g_l_va_i f.(dev_g_h_va_i dev_g_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(key)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_g_h_sale dev_g_l_sale = dev_g_h_va_i dev_g_l_va_i f.(dev_g_h_va_i dev_g_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_g_h_va_a dev_g_l_va_a = dev_g_h_va_i dev_g_l_va_i f.(dev_g_h_va_i dev_g_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(key)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (dev_g_h_va_a dev_g_l_va_a = dev_g_h_va_i dev_g_l_va_i f.(dev_g_h_va_i dev_g_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(key)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_g_h_va_a dev_g_l_va_a = dev_g_h_va_i dev_g_l_va_i f.(dev_g_h_va_i dev_g_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C




$|------------------------------------------------------------------------------------------ CLUSTERING ON NAICS ------------------------------------------------------------------------------------------|$


$|------------------------------------------------------------------------------------------ REGRESSIONS------------------------------------------------------------------------------------------|$

xtreg d_xrd d_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store A
xtreg z_rd_go l.z_rd_go l2.z_rd_go d_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store A
xtreg z_rd_va_i l.z_rd_va_i l2.z_rd_va_i d_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store A
xtreg z_rd_sale l.z_rd_sale l2.z_rd_sale d_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store A
xtreg z_rd_va_a l.z_rd_va_a l2.z_rd_va_a d_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_h_go d_l_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store A
xtreg z_rd_go l.z_rd_go l2.z_rd_go d_h_go d_l_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_h_go d_l_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_h_va_i d_l_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store A
xtreg z_rd_va_i l.z_rd_va_i l2.z_rd_va_i d_h_va_i d_l_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_h_va_i d_l_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_h_va_a d_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store A
xtreg z_rd_va_a l.z_rd_va_a l2.z_rd_va_a d_h_va_a d_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_h_va_a d_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_h_sale d_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store A
xtreg z_rd_sale l.z_rd_sale l2.z_rd_sale d_h_sale d_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_h_sale d_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

$|------------------------------------------------------------------------------------------ IV SECTION ------------------------------------------------------------------------------------------|$

xtivreg2 d_xrd (d_sale = d_go f.d_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics) endogtest(d_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (d_sale = d_go f.d_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics) endogtest(d_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_sale = d_go f.d_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics) endogtest(d_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (d_sale = d_va_i f.d_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics) endogtest(d_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (d_sale = d_va_i f.d_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics) endogtest(d_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_sale = d_va_i f.d_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics) endogtest(d_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (d_va_a = d_va_i f.d_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics) endogtest(d_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (d_va_a = d_va_i f.d_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics) endogtest(d_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_va_a = d_va_i f.d_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics) endogtest(d_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (d_va_a = d_go f.d_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics) endogtest(d_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (d_va_a = d_go f.d_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics) endogtest(d_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_va_a = d_go f.d_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics) endogtest(d_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (d_h_sale d_l_sale = d_h_go d_l_go f.(d_h_go d_l_go)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics) endogtest(d_h_sale d_l_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (d_h_sale d_l_sale = d_h_go d_l_go f.(d_h_go d_l_go)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics) endogtest(d_h_sale d_l_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_h_sale d_l_sale = d_h_go d_l_go f.(d_h_go d_l_go)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics) endogtest(d_h_sale d_l_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (d_h_sale d_l_sale = d_h_va_i d_l_va_i f.(d_h_va_i d_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics) endogtest(d_h_sale d_l_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (d_h_sale d_l_sale = d_h_va_i d_l_va_i f.(d_h_va_i d_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics) endogtest(d_h_sale d_l_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_h_sale d_l_sale = d_h_va_i d_l_va_i f.(d_h_va_i d_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics) endogtest(d_h_sale d_l_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (d_h_va_a d_l_va_a = d_h_va_i d_l_va_i f.(d_h_va_i d_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics) endogtest(d_h_va_a d_l_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (d_h_va_a d_l_va_a = d_h_va_i d_l_va_i f.(d_h_va_i d_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics) endogtest(d_h_va_a d_l_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_h_va_a d_l_va_a = d_h_va_i d_l_va_i f.(d_h_va_i d_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics) endogtest(d_h_va_a d_l_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (d_h_va_a d_l_va_a = d_h_go d_l_go f.(d_h_go d_l_go)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics) endogtest(d_h_va_a d_l_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (d_h_va_a d_l_va_a = d_h_go d_l_go f.(d_h_go d_l_go)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics) endogtest(d_h_va_a d_l_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_h_va_a d_l_va_a = d_h_go d_l_go f.(d_h_go d_l_go)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics) endogtest(d_h_va_a d_l_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

$|------------------------------------------------------------------------------------------ DEMEANED DATA ------------------------------------------------------------------------------------------|$

xtreg dev_xrd dev_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store A
xtreg z_rd_go l.z_rd_go l2.z_rd_go dev_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store A
xtreg z_rd_va_i l.z_rd_va_i l2.z_rd_va_i dev_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store A
xtreg z_rd_sale l.z_rd_sale l2.z_rd_sale dev_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store A
xtreg z_rd_va_a l.z_rd_va_a l2.z_rd_va_a dev_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_h_go dev_l_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store A
xtreg z_rd_go l.z_rd_go l2.z_rd_go dev_h_go dev_l_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_h_go dev_l_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_g_h_va_i dev_g_l_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store A
xtreg z_rd_va_i l.z_rd_va_i l2.z_rd_va_i dev_g_h_va_i dev_g_l_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_g_h_va_i dev_g_l_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_g_h_va_a dev_g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store A
xtreg z_rd_va_a l.z_rd_va_a l2.z_rd_va_a dev_g_h_va_a dev_g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_g_h_va_a dev_g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_g_h_sale dev_g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store A
xtreg z_rd_sale l.z_rd_sale l2.z_rd_sale dev_g_h_sale dev_g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_g_h_sale dev_g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe vce(cluster naics)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

$|------------------------------------------------------------------------------------------ IV SECTION ------------------------------------------------------------------------------------------|$

xtivreg2 dev_xrd (dev_sale = dev_go f.dev_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_sale = dev_go f.dev_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_sale = dev_go f.dev_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_sale = dev_va_i f.dev_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics) endogtest(d_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_sale = dev_va_i f.dev_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_sale = dev_va_i f.dev_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_va_a = dev_va_i f.dev_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (dev_va_a = dev_va_i f.dev_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_va_a = dev_va_i f.dev_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_g_h_sale dev_g_l_sale = dev_go f.dev_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_g_h_sale dev_g_l_sale = dev_go f.dev_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_g_h_sale dev_g_l_sale = dev_go f.dev_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_g_h_sale dev_g_l_sale = dev_g_h_va_i dev_g_l_va_i f.(dev_g_h_va_i dev_g_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_g_h_sale dev_g_l_sale = dev_g_h_va_i dev_g_l_va_i f.(dev_g_h_va_i dev_g_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_g_h_sale dev_g_l_sale = dev_g_h_va_i dev_g_l_va_i f.(dev_g_h_va_i dev_g_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_g_h_va_a dev_g_l_va_a = dev_g_h_va_i dev_g_l_va_i f.(dev_g_h_va_i dev_g_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (dev_g_h_va_a dev_g_l_va_a = dev_g_h_va_i dev_g_l_va_i f.(dev_g_h_va_i dev_g_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_g_h_va_a dev_g_l_va_a = dev_g_h_va_i dev_g_l_va_i f.(dev_g_h_va_i dev_g_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe ivar(key) tvar(year) robust cluster(naics)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

$|------------------------------------------------------------------------------------------ GMM2 SECTION ------------------------------------------------------------------------------------------|$

xtivreg2 dev_xrd (dev_sale = dev_go f.dev_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(naics)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_sale = dev_go f.dev_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(naics)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_sale = dev_go f.dev_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(naics)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_sale = dev_va_i f.dev_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(naics)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_sale = dev_va_i f.dev_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(naics)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_sale = dev_va_i f.dev_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(naics)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_va_a = dev_va_i f.dev_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(naics)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (dev_va_a = dev_va_i f.dev_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(naics)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_va_a = dev_va_i f.dev_va_i) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(naics)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_g_h_sale dev_g_l_sale = dev_go f.dev_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(naics)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_g_h_sale dev_g_l_sale = dev_go f.dev_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(naics)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_g_h_sale dev_g_l_sale = dev_go f.dev_go) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(naics)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_g_h_sale dev_g_l_sale = dev_g_h_va_i dev_g_l_va_i f.(dev_g_h_va_i dev_g_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(naics)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_g_h_sale dev_g_l_sale = dev_g_h_va_i dev_g_l_va_i f.(dev_g_h_va_i dev_g_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(naics)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_g_h_sale dev_g_l_sale = dev_g_h_va_i dev_g_l_va_i f.(dev_g_h_va_i dev_g_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(naics)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_g_h_va_a dev_g_l_va_a = dev_g_h_va_i dev_g_l_va_i f.(dev_g_h_va_i dev_g_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(naics)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (dev_g_h_va_a dev_g_l_va_a = dev_g_h_va_i dev_g_l_va_i f.(dev_g_h_va_i dev_g_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(naics)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_g_h_va_a dev_g_l_va_a = dev_g_h_va_i dev_g_l_va_i f.(dev_g_h_va_i dev_g_l_va_i)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, fe gmm2 ivar(key) tvar(year) robust cluster(naics)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

$|------------------------------------------------------------------------------------------ SYSTEM GMM SECTION ------------------------------------------------------------------------------------------|$



xtabond z_rd_va_i d_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_va_i d_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)

xtabond z_rd_capx d_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx d_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)

xtabond z_rd_go d_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_go d_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)

xtabond z_rd_capx d_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx d_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)

xtabond z_rd_sale d_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_sale d_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)

xtabond z_rd_capx d_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx d_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)

xtabond z_rd_va_a d_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_va_a d_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)

xtabond z_rd_capx d_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx d_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)



xtabond z_rd_va_i g_h_va_i g_l_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_va_i g_h_va_i g_l_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)

xtabond z_rd_capx g_h_va_i g_l_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx g_h_va_i g_l_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)

xtabond z_rd_go g_h_go g_l_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_go g_h_go g_l_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)

xtabond z_rd_capx g_h_go g_l_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx g_h_go g_l_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)

xtabond z_rd_sale g_h_sale g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_sale g_h_sale g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)

xtabond z_rd_capx g_h_sale g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx g_h_sale g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)

xtabond z_rd_va_a g_h_va_a g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_va_a g_h_va_a g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)

xtabond z_rd_capx g_h_va_a g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx g_h_va_a g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)


$|------------------------------------------------------------------------------------------ IV SECTION ------------------------------------------------------------------------------------------|$


xtabond z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(d_sale) vce(robust) artests(2)
xtdpdsys z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(d_sale) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(d_sale) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(d_sale) vce(robust) artests(2)

xtabond z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(d_va_a) vce(robust) artests(2)
xtdpdsys z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(d_va_a) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(d_va_a) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(d_va_a) vce(robust) artests(2)

xtabond z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(d_sale) vce(robust) artests(2)
xtdpdsys z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(d_sale) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(d_sale) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(d_sale) vce(robust) artests(2)

xtabond z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(d_va_a) vce(robust) artests(2)
xtdpdsys z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(d_va_a) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(d_va_a) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(d_va_a) vce(robust) artests(2)


xtabond z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(g_h_sale g_l_sale) vce(robust) artests(2)
xtdpdsys z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(g_h_sale g_l_sale) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(g_h_sale g_l_sale) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(g_h_sale g_l_sale) vce(robust) artests(2)

xtabond z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(g_h_va_a g_l_va_a) vce(robust) artests(2)
xtdpdsys z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(g_h_va_a g_l_va_a) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(g_h_va_a g_l_va_a) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(g_h_va_a g_l_va_a) vce(robust) artests(2)

xtabond z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(g_h_sale g_l_sale) vce(robust) artests(2)
xtdpdsys z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(g_h_sale g_l_sale) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(g_h_sale g_l_sale) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(g_h_sale g_l_sale) vce(robust) artests(2)

xtabond z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(g_h_va_a g_l_va_a) vce(robust) artests(2)
xtdpdsys z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(g_h_va_a g_l_va_a) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(g_h_va_a g_l_va_a) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(g_h_va_a g_l_va_a) vce(robust) artests(2)

$|------------------------------------------------------------------------------------------ DEMEANED DATA ------------------------------------------------------------------------------------------|$


xtabond z_rd_va_i dev_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_va_i dev_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)

xtabond z_rd_capx dev_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx dev_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)

xtabond z_rd_go dev_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_go dev_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)

xtabond z_rd_capx dev_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx dev_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)

xtabond z_rd_sale dev_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_sale dev_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)

xtabond z_rd_capx dev_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx dev_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)

xtabond z_rd_va_a dev_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_va_a dev_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)

xtabond z_rd_capx dev_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx dev_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)



xtabond z_rd_va_i dev_g_h_va_i dev_g_l_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_va_i dev_g_h_va_i dev_g_l_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)

xtabond z_rd_capx dev_g_h_va_i dev_g_l_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx dev_g_h_va_i dev_g_l_va_i emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)

xtabond z_rd_go dev_g_h_go dev_g_l_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_go dev_g_h_go dev_g_l_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)

xtabond z_rd_capx dev_g_h_go dev_g_l_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx dev_g_h_go dev_g_l_go emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)

xtabond z_rd_sale dev_g_h_sale dev_g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_sale dev_g_h_sale dev_g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)

xtabond z_rd_capx dev_g_h_sale dev_g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx dev_g_h_sale dev_g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)

xtabond z_rd_va_a dev_g_h_va_a dev_g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_va_a dev_g_h_va_a dev_g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)

xtabond z_rd_capx dev_g_h_va_a dev_g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx dev_g_h_va_a dev_g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year, lags(2) vce(robust) artests(2)



$|------------------------------------------------------------------------------------------ IV SECTION ------------------------------------------------------------------------------------------|$


xtabond z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(dev_sale) vce(robust) artests(2)
xtdpdsys z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(dev_sale) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(dev_sale) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(dev_sale) vce(robust) artests(2)

xtabond z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(dev_va_a) vce(robust) artests(2)
xtdpdsys z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(dev_va_a) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(dev_va_a) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(dev_va_a) vce(robust) artests(2)

xtabond z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(dev_sale) vce(robust) artests(2)
xtdpdsys z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(dev_sale) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(dev_sale) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(dev_sale) vce(robust) artests(2)

xtabond z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(dev_va_a) vce(robust) artests(2)
xtdpdsys z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(dev_va_a) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(dev_va_a) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(dev_va_a) vce(robust) artests(2)

xtabond z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(dev_g_h_sale dev_g_l_sale) vce(robust) artests(2)
xtdpdsys z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(dev_g_h_sale dev_g_l_sale) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(dev_g_h_sale dev_g_l_sale) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(dev_g_h_sale dev_g_l_sale) vce(robust) artests(2)

xtabond z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(dev_g_h_va_a dev_g_l_va_a) vce(robust) artests(2)
xtdpdsys z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(dev_g_h_va_a dev_g_l_va_a) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(dev_g_h_va_a dev_g_l_va_a) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_va_i f.d_va_i) lags(2) endog(dev_g_h_va_a dev_g_l_va_a) vce(robust) artests(2)

xtabond z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(dev_g_h_sale dev_g_l_sale) vce(robust) artests(2)
xtdpdsys z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(dev_g_h_sale dev_g_l_sale) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(dev_g_h_sale dev_g_l_sale) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(dev_g_h_sale dev_g_l_sale) vce(robust) artests(2)

xtabond z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(dev_g_h_va_a dev_g_l_va_a) vce(robust) artests(2)
xtdpdsys z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(dev_g_h_va_a dev_g_l_va_a) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(dev_g_h_va_a dev_g_l_va_a) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) i.year,  inst(d_go f.d_go) lags(2) endog(dev_g_h_va_a dev_g_l_va_a) vce(robust) artests(2)
