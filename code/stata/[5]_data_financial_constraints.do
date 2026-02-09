use "/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/[5]_data_financial_constraints.dta"

gen r_at=at/p
gen r_capx=capx/p
gen r_ceq=ceq/p
gen r_che=che/p
gen r_dd1=dd1/p
gen r_dlc=dlc/p
gen r_dltt=dltt/p
gen r_dp=dp/p
gen r_dvc=dvc/p
gen r_dvp=dvp/p
gen r_ib=ib/p
gen r_lt=lt/p
gen r_oibdp=oibdp/p
gen r_ppent=ppent/p
gen r_sale=sale/p
gen r_seq=seq/p
gen r_txdb=txdb/p
gen r_xlr=xlr/p
gen r_xrd=xrd/p
gen r_cf=r_xrd+r_che
gen r_sale_i=sale_i/p

gen mkv=prcc12*cshoq12
label variable mkv "Market Value (common shares)"
gen wagebill=emp*averagewage/1000
label variable wagebill "Approximate wage bill using average annual wage"
gen va=oibdp+xlr
label variable va "Value added"
gen va_a=oibdp+wagebill
label variable va_a "Value added, approximated using average wage"
gen r_va=va/p
gen r_va_a=va_a/p

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

gen lnta=ln(r_at)

gen WW=-0.091*cfratio-0.062*divpos+0.021*debt-0.044*lnta+0.102*d_sale_i-0.035*d_sale

gen WW_1=1 if WW< -0.4075759
replace WW_1=0 if WW >= -0.4075759
gen WW_2=1 if WW> -0.4075759 & WW<=-0.3237967
replace WW_2=0 if WW <= -0.4075759 | WW > -0.3237967
gen WW_3=1 if WW> -0.3237967 & WW<=-0.2442014
replace WW_3=0 if WW <= -0.3237967 | WW > -0.2442014
gen WW_4=1 if WW> -0.2442014
replace WW_4=0 if WW <= -0.2442014 | WW == .

gen d_xrd=ln(r_xrd)-ln(l.r_xrd)
gen d_sale=ln(r_sale)-ln(l.sale)
gen d_va=ln(r_va)-ln(l.va)
gen d_va_a=ln(r_va_a)-ln(l.va_a)
gen d_sale_i=ln(r_sale_i)-ln(l.r_sale_i)

gen z_rd_va=r_xrd/r_va
gen z_rd_va_a=r_xrd/r_va_a
gen z_rd_sale=r_xrd/r_sale
gen z_rd_capx=r_xrd/(r_capx+r_xrd)

gen g_h_va=1 if d_va>0
replace g_h_va=0 if d_va<0
gen g_l_va=1-g_h_va
gen d_h_va=g_h_va*d_va
gen d_l_va=g_l_va*d_va

gen g_h_sale=1 if d_sale>0
replace g_h_sale=0 if d_sale<0
gen g_l_sale=1-g_h_sale
gen d_h_sale=g_h_sale*d_sale
gen d_l_sale=g_l_sale*d_sale

gen g_h_va_a=1 if d_va_a>0
replace g_h_va_a=0 if d_va_a<0
gen g_l_va_a=1-g_h_va_a
gen d_h_va_a=g_h_va_a*d_va_a
gen d_l_va_a=g_l_va_a*d_va_a

gen d_sale_KZ1=d_sale*KZ_1
gen d_sale_KZ2=d_sale*KZ_2
gen d_sale_KZ3=d_sale*KZ_3
gen d_sale_KZ4=d_sale*KZ_4

gen d_va_a_KZ1=d_va_a*KZ_1
gen d_va_a_KZ2=d_va_a*KZ_2
gen d_va_a_KZ3=d_va_a*KZ_3
gen d_va_a_KZ4=d_va_a*KZ_4

gen d_va_KZ1=d_va*KZ_1
gen d_va_KZ2=d_va*KZ_2
gen d_va_KZ3=d_va*KZ_3
gen d_va_KZ4=d_va*KZ_4

gen d_sale_WW1=d_sale*WW_1
gen d_sale_WW2=d_sale*WW_2
gen d_sale_WW3=d_sale*WW_3
gen d_sale_WW4=d_sale*WW_4

gen d_va_a_WW1=d_va_a*WW_1
gen d_va_a_WW2=d_va_a*WW_2
gen d_va_a_WW3=d_va_a*WW_3
gen d_va_a_WW4=d_va_a*WW_4

gen d_va_WW1=d_va*WW_1
gen d_va_WW2=d_va*WW_2
gen d_va_WW3=d_va*WW_3
gen d_va_WW4=d_va*WW_4

gen d_h_ag=1 if ag > l.ag
replace d_h_ag=0 if ag < l.ag
gen d_l_ag=1-d_h_ag
gen d_h_ag_fc_sale=d_h_ag*d_sale
gen d_l_ag_fc_sale=d_l_ag*d_sale
gen d_h_ag_fc_va_a=d_h_ag*d_va_a
gen d_l_ag_fc_va_a=d_l_ag*d_va_a
gen d_h_ag_fc_va=d_h_ag*d_va
gen d_l_ag_fc_va=d_l_ag*d_va

gen d_h_bg=1 if bg > l.bg
replace d_h_bg=0 if bg < l.bg
gen d_l_bg=1-d_h_bg
gen d_h_bg_fc_sale=d_h_bg*d_sale
gen d_l_bg_fc_sale=d_l_bg*d_sale
gen d_h_bg_fc_va_a=d_h_bg*d_va_a
gen d_l_bg_fc_va_a=d_l_bg*d_va_a
gen d_h_bg_fc_va=d_h_bg*d_va
gen d_l_bg_fc_va=d_l_bg*d_va

gen d_h_ba=1 if ba > l.ba
replace d_h_ba=0 if ba < l.ba
gen d_l_ba=1-d_h_ba
gen d_h_ba_fc_sale=d_h_ba*d_sale
gen d_l_ba_fc_sale=d_l_ba*d_sale
gen d_h_ba_fc_va_a=d_h_ba*d_va_a
gen d_l_ba_fc_va_a=d_l_ba*d_va_a
gen d_h_ba_fc_va=d_h_ba*d_va
gen d_l_ba_fc_va=d_l_ba*d_va

by key: egen average_d_xrd=mean(d_xrd)
gen dev_xrd=d_xrd-average_d_xrd

by key: egen average_d_sale=mean(d_sale)
gen dev_sale=d_sale-average_d_sale

by key: egen average_d_y=mean(d_y)
gen dev_y=d_y-average_d_y

by key: egen average_d_va=mean(d_va)
gen dev_va=d_va-average_d_va

by key: egen average_d_va_a=mean(d_va_a)
gen dev_va_a=d_va_a-average_d_va_a

by key: egen average_aaa_g=mean(aaa_g)
gen dev_aaa_g=aaa_g-average_aaa_g

by key: egen average_baa_g=mean(baa_g)
gen dev_baa_g=baa_g-average_baa_g

by key: egen average_baa_aaa=mean(baa_aaa)
gen dev_baa_aaa=baa_aaa-average_baa_aaa

gen dev_h_sale=1 if dev_sale > 0
replace dev_h_sale=0 if dev_sale < 0
gen dev_l_sale=1-dev_h_sale
gen dev_g_h_sale=dev_sale*dev_h_sale
gen dev_g_l_sale=dev_sale*dev_l_sale

gen dev_h_va_a=1 if dev_va_a > 0
replace dev_h_va_a=0 if dev_va_a < 0
gen dev_l_va_a=1-dev_h_va_a
gen dev_g_h_va_a=dev_va_a*dev_h_va_a
gen dev_g_l_va_a=dev_va_a*dev_l_va_a

gen dev_h_va=1 if dev_va > 0
replace dev_h_va=0 if dev_va < 0
gen dev_l_va=1-dev_h_va
gen dev_g_h_va=dev_va*dev_h_va
gen dev_g_l_va=dev_va*dev_l_va

gen dev_h_baa_g=1 if dev_baa_g > 0
replace dev_h_baa_g=0 if dev_baa_g < 0
gen dev_l_baa_g=1-dev_h_baa_g
gen dev_g_h_baa_g=dev_baa_g*dev_h_baa_g
gen dev_g_l_baa_g=dev_baa_g*dev_l_baa_g

gen dev_h_aaa_g=1 if dev_aaa_g > 0
replace dev_h_aaa_g=0 if dev_aaa_g < 0
gen dev_l_aaa_g=1-dev_h_aaa_g
gen dev_g_h_aaa_g=dev_aaa_g*dev_h_aaa_g
gen dev_g_l_aaa_g=dev_aaa_g*dev_l_aaa_g

gen dev_h_baa_aaa=1 if dev_baa_aaa > 0
replace dev_h_baa_aaa=0 if dev_baa_aaa < 0
gen dev_l_baa_aaa=1-dev_h_baa_aaa
gen dev_g_h_baa_aaa=dev_baa_aaa*dev_h_baa_aaa
gen dev_g_l_baa_aaa=dev_baa_aaa*dev_l_baa_aaa

$|------------------------------------------------------------------------------------------ REGRESSIONS------------------------------------------------------------------------------------------|$

xtreg d_xrd d_va emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
xtreg z_rd_va l.z_rd_va l2.z_rd_va d_va emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_va emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
xtreg z_rd_sale l.z_rd_sale l2.z_rd_sale d_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
xtreg z_rd_va_a l.z_rd_va_a l2.z_rd_va_a d_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_h_va d_l_va emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
xtreg z_rd_va l.z_rd_va l2.z_rd_va d_h_va d_l_va emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_h_va d_l_va emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_h_sale d_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
xtreg z_rd_sale l.z_rd_sale l2.z_rd_sale  d_h_sale d_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_h_sale d_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_h_va d_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
xtreg z_rd_va_a l.z_rd_va_a l2.z_rd_va_a d_h_va d_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_h_va d_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_h_va_a d_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
xtreg z_rd_va_a l.z_rd_va_a l2.z_rd_va_a  d_h_va_a d_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_h_va_a d_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

$|------------------------------------------------------------------------------------------ FINANCIAL CONSTRAINTS KZ ------------------------------------------------------------------------------------------|$

xtreg d_xrd d_sale_KZ1 d_sale_KZ2 d_sale_KZ3 d_sale_KZ4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
test (_b[d_sale_KZ1] = _b[d_sale_KZ4])
xtreg z_rd_sale l.z_rd_sale l2.z_rd_sale d_sale_KZ1 d_sale_KZ2 d_sale_KZ3 d_sale_KZ4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
test (_b[d_sale_KZ1] = _b[d_sale_KZ4])
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_sale_KZ1 d_sale_KZ2 d_sale_KZ3 d_sale_KZ4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C
test (_b[d_sale_KZ1] = _b[d_sale_KZ4])

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_va_a_KZ1 d_va_a_KZ2 d_va_a_KZ3 d_va_a_KZ4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
test (_b[d_va_a_KZ1] = _b[d_va_a_KZ4])
xtreg z_rd_va_a l.z_rd_va_a l2.z_rd_va_a d_va_a_KZ1 d_va_a_KZ2 d_va_a_KZ3 d_va_a_KZ4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
test (_b[d_va_a_KZ1] = _b[d_va_a_KZ4])
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_va_a_KZ1 d_va_a_KZ2 d_va_a_KZ3 d_va_a_KZ4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C
test (_b[d_va_a_KZ1] = _b[d_va_a_KZ4])

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_va_KZ1 d_va_KZ2 d_va_KZ3 d_va_KZ4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
test (_b[d_va_KZ1] = _b[d_va_KZ4])
xtreg z_rd_va l.z_rd_va l2.z_rd_va d_va_KZ1 d_va_KZ2 d_va_KZ3 d_va_KZ4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
test (_b[d_va_KZ1] = _b[d_va_KZ4])
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_va_KZ1 d_va_KZ2 d_va_KZ3 d_va_KZ4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C
test (_b[d_va_KZ1] = _b[d_va_KZ4])

esttab A B C, tex p

drop _est_A _est_B _est_C

$|------------------------------------------------------------------------------------------ FINANCIAL CONSTRAINTS WW ------------------------------------------------------------------------------------------|$

xtreg d_xrd d_sale_WW1 d_sale_WW2 d_sale_WW3 d_sale_WW4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
xtreg z_rd_sale l.z_rd_sale l2.z_rd_sale d_sale_WW1 d_sale_WW2 d_sale_WW3 d_sale_WW4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_sale_WW1 d_sale_WW2 d_sale_WW3 d_sale_WW4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_va_a_WW1 d_va_a_WW2 d_va_a_WW3 d_va_a_WW4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
xtreg z_rd_va_a l.z_rd_va_a l2.z_rd_va_a d_va_a_WW1 d_va_a_WW2 d_va_a_WW3 d_va_a_WW4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_va_a_WW1 d_va_a_WW2 d_va_a_WW3 d_va_a_WW4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_va_WW1 d_va_WW2 d_va_WW3 d_va_WW4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
xtreg z_rd_va l.z_rd_va l2.z_rd_va d_va_WW1 d_va_WW2 d_va_WW3 d_va_WW4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_va_WW1 d_va_WW2 d_va_WW3 d_va_WW4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

$|------------------------------------------------------------------------------------------ CORPORATE SPREADS ------------------------------------------------------------------------------------------|$

xtreg d_xrd d_h_ag_fc_sale d_l_ag_fc_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
xtreg z_rd_sale l.z_rd_sale l2.z_rd_sale d_h_ag_fc_sale d_l_ag_fc_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_h_ag_fc_sale d_l_ag_fc_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_h_ag_fc_va_a d_l_ag_fc_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
xtreg z_rd_va_a l.z_rd_va_a l2.z_rd_va_a d_h_ag_fc_va_a d_l_ag_fc_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_h_ag_fc_va_a d_l_ag_fc_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_h_ag_fc_va d_l_ag_fc_va emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
xtreg z_rd_va l.z_rd_va l2.z_rd_va d_h_ag_fc_va d_l_ag_fc_va emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_h_ag_fc_va d_l_ag_fc_va emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_h_bg_fc_sale d_l_bg_fc_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
xtreg z_rd_sale l.z_rd_sale l2.z_rd_sale d_h_bg_fc_sale d_l_bg_fc_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_h_bg_fc_sale d_l_bg_fc_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_h_bg_fc_va_a d_l_bg_fc_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
xtreg z_rd_va_a l.z_rd_va_a l2.z_rd_va_a d_h_bg_fc_va_a d_l_bg_fc_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_h_bg_fc_va_a d_l_bg_fc_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_h_bg_fc_va d_l_bg_fc_va emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
xtreg z_rd_va l.z_rd_va l2.z_rd_va d_h_bg_fc_va d_l_bg_fc_va emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_h_bg_fc_va d_l_bg_fc_va emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_h_ba_fc_sale d_l_ba_fc_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
xtreg z_rd_sale l.z_rd_sale l2.z_rd_sale d_h_ba_fc_sale d_l_ba_fc_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_h_ba_fc_sale d_l_ba_fc_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_h_ba_fc_va_a d_l_ba_fc_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
xtreg z_rd_va_a l.z_rd_va_a l2.z_rd_va_a d_h_ba_fc_va_a d_l_ba_fc_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_h_ba_fc_va_a d_l_ba_fc_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_h_ba_fc_va d_l_ba_fc_va emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
xtreg z_rd_va l.z_rd_va l2.z_rd_va d_h_ba_fc_va d_l_ba_fc_va emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_h_ba_fc_va d_l_ba_fc_va emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C


$|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|$
$|------------------------------------------------------------------------------------------ DEMEANED DATA ----------------------------------------------------------------------------------------------|$
$|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|$

xtreg dev_xrd dev_va emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
xtreg z_rd_va l.z_rd_va l2.z_rd_va dev_va emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_va emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
xtreg z_rd_sale l.z_rd_sale l2.z_rd_sale dev_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
xtreg z_rd_va_a l.z_rd_va_a l2.z_rd_va_a dev_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_g_h_va dev_g_l_va emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
xtreg z_rd_va l.z_rd_va l2.z_rd_va dev_g_h_va dev_g_l_va emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_g_h_va dev_g_l_va emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_g_h_sale dev_g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
xtreg z_rd_sale l.z_rd_sale l2.z_rd_sale  dev_g_h_sale dev_g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_g_h_sale dev_g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_g_h_va dev_g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
xtreg z_rd_va_a l.z_rd_va_a l2.z_rd_va_a dev_g_h_va dev_g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_g_h_va dev_g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_g_h_va_a dev_g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
xtreg z_rd_va_a l.z_rd_va_a l2.z_rd_va_a  dev_g_h_va_a dev_g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_g_h_va_a dev_g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

$|------------------------------------------------------------------------------------------ FINANCIAL CONSTRAINTS KZ ------------------------------------------------------------------------------------------|$

xtreg dev_xrd d_sale_KZ1 d_sale_KZ2 d_sale_KZ3 d_sale_KZ4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
test (_b[d_sale_KZ1] = _b[d_sale_KZ4])
xtreg z_rd_sale l.z_rd_sale l2.z_rd_sale d_sale_KZ1 d_sale_KZ2 d_sale_KZ3 d_sale_KZ4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
test (_b[d_sale_KZ1] = _b[d_sale_KZ4])
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_sale_KZ1 d_sale_KZ2 d_sale_KZ3 d_sale_KZ4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C
test (_b[d_sale_KZ1] = _b[d_sale_KZ4])

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd d_va_a_KZ1 d_va_a_KZ2 d_va_a_KZ3 d_va_a_KZ4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
test (_b[d_va_a_KZ1] = _b[d_va_a_KZ4])
xtreg z_rd_va_a l.z_rd_va_a l2.z_rd_va_a d_va_a_KZ1 d_va_a_KZ2 d_va_a_KZ3 d_va_a_KZ4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
test (_b[d_va_a_KZ1] = _b[d_va_a_KZ4])
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_va_a_KZ1 d_va_a_KZ2 d_va_a_KZ3 d_va_a_KZ4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C
test (_b[d_va_a_KZ1] = _b[d_va_a_KZ4])

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd d_va_KZ1 d_va_KZ2 d_va_KZ3 d_va_KZ4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store A
test (_b[d_va_KZ1] = _b[d_va_KZ4])
xtreg z_rd_va l.z_rd_va l2.z_rd_va d_va_KZ1 d_va_KZ2 d_va_KZ3 d_va_KZ4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store B
test (_b[d_va_KZ1] = _b[d_va_KZ4])
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_va_KZ1 d_va_KZ2 d_va_KZ3 d_va_KZ4 emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46, fe vce(cluster key)
est store C
test (_b[d_va_KZ1] = _b[d_va_KZ4])

esttab A B C, tex p

drop _est_A _est_B _est_C
