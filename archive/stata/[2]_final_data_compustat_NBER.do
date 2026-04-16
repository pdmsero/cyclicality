use "/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/[2]_final_data_compustat_NBER.dta"

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
gen r_xstfws=xstfws/p
gen r_y=y/p
gen r_vship=vship/piship
gen r_vship_p=vship/p
gen r_vadd=vadd/piship
gen r_vadd_p=vadd/p
gen wagebill=emp*averagewage/1000
label variable wagebill "Approximate wage bill using average annual wage"
gen va = oibdp+xlr
gen va_a=oibdp+wagebill
gen r_va=va/p
gen r_va_a=va_a/p

xtset key year, year
gen z_rd_vship=r_xrd/r_vship
gen z_rd_vadd=r_xrd/r_vadd
gen z_rd_vship_p=r_xrd/r_vship_p
gen z_rd_vadd_p=r_xrd/r_vadd_p
gen z_rd_sale=r_xrd/r_sale
gen d_xrd=ln(r_xrd)-ln(l.r_xrd)
gen d_vship=ln(r_vship)-ln(l.r_vship)
gen d_vship_p=ln(r_vship_p)-ln(l.r_vship_p)
gen d_vadd=ln(r_vadd)-ln(l.r_vadd)
gen d_vadd_p=ln(r_vadd_p)-ln(l.r_vadd_p)
gen d_sale=ln(r_sale)-ln(l.r_sale)
gen d_y=ln(r_y)-ln(l.r_y)
gen d_va=ln(r_va)-ln(l.r_va)
gen d_va_a=ln(r_va_a)-ln(l.r_va_a)
gen cashrnd=r_xnrd+r_che

gen d_h_vadd=1 if d_vadd > 0
replace d_h_vadd=0 if d_vadd < 0
gen d_l_vadd=1-d_h_vadd
gen g_h_vadd=d_vadd*d_h_vadd
gen g_l_vadd=d_vadd*d_l_vadd

gen d_h_vship=1 if d_vship > 0
replace d_h_vship=0 if d_vship < 0
gen d_l_vship=1-d_h_vship
gen g_h_vship=d_vship*d_h_vship
gen g_l_vship=d_vship*d_l_vship

gen d_h_sale=1 if d_sale > 0
replace d_h_sale=0 if d_sale < 0
gen d_l_sale=1-d_h_sale
gen g_h_sale=d_sale*d_h_sale
gen g_l_sale=d_sale*d_l_sale

gen d_h_va_a=1 if d_va_a > 0
replace d_h_va_a=0 if d_va_a < 0
gen d_l_va_a=1-d_h_va_a
gen g_h_va_a=d_va_a*d_h_va_a
gen g_l_va_a=d_va_a*d_l_va_a

by key: egen average_d_xrd=mean(d_xrd)
gen dev_xrd=d_xrd-average_d_xrd

by key: egen average_d_vship=mean(d_vship)
gen dev_vship=d_vship-average_d_vship

by key: egen average_d_vadd=mean(d_vadd)
gen dev_vadd=d_vadd-average_d_vadd

by key: egen average_d_sale=mean(d_sale)
gen dev_sale=d_sale-average_d_sale

by key: egen average_d_y=mean(d_y)
gen dev_y=d_y-average_d_y

by key: egen average_d_va=mean(d_va)
gen dev_va=d_va-average_d_va

by key: egen average_d_va_a=mean(d_va_a)
gen dev_va_a=d_va_a-average_d_va_a

gen dev_h_vadd=1 if dev_vadd > 0
replace dev_h_vadd=0 if dev_vadd < 0
gen dev_l_vadd=1-dev_h_vadd
gen dev_g_h_vadd=dev_vadd*dev_h_vadd
gen dev_g_l_vadd=dev_vadd*dev_l_vadd

gen dev_h_vship=1 if dev_vship > 0
replace dev_h_vship=0 if dev_vship < 0
gen dev_l_vship=1-dev_h_vship
gen dev_g_h_vship=dev_vship*dev_h_vship
gen dev_g_l_vship=dev_vship*dev_l_vship

gen dev_h_sale=1 if dev_sale > 0
replace dev_h_sale=0 if dev_sale < 0
gen dev_l_sale=1-dev_h_sale
gen dev_g_h_sale=dev_sale*dev_h_sale
gen dev_g_l_sale=dev_sale*dev_l_sale

gen dev_h_va_a=1 if dev_va_a > 0
replace dev_h_va_a=0 if dev_va_a < 0
gen dev_l_va_a=1-dev_h_va_a
gen dev_g_h_va_a=dev_va_a*dev_h_va_a
gen dev_g_l_va_a=dev_va_a*dev_l_va_aw

$|------------------------------------------------------------------------------------------ REGRESSIONS------------------------------------------------------------------------------------------|$

xtreg d_xrd d_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store A
xtreg z_rd_vadd l.z_rd_vadd l2.z_rd_vadd d_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store A
xtreg z_rd_vship l.z_rd_vship l2.z_rd_vship d_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store A
xtreg z_rd_sale l.z_rd_sale l2.z_rd_sale d_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store A
xtreg z_rd_va_a l.z_rd_va_a l2.z_rd_va_a d_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd g_h_vadd g_l_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store A
xtreg z_rd_vadd l.z_rd_vadd l2.z_rd_vadd g_h_vadd g_l_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx g_h_vadd g_l_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd g_h_vship g_l_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store A
xtreg z_rd_vship l.z_rd_vship l2.z_rd_vship g_h_vship g_l_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx g_h_vship g_l_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd g_h_sale g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store A
xtreg z_rd_sale l.z_rd_sale l2.z_rd_sale g_h_sale g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx g_h_sale g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd g_h_va_a g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store A
xtreg z_rd_va_a l.z_rd_va_a l2.z_rd_va_a g_h_va_a g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx g_h_va_a g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

$|------------------------------------------------------------------------------------------ IV SECTION ------------------------------------------------------------------------------------------|$

xtivreg2 d_xrd (d_sale = d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(d_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (d_sale = d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(d_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_sale = d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(d_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (d_sale = d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(d_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (d_sale = d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first gmm2 ivar(key) tvar(year) robust cluster(key) endogtest(d_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_sale = d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first gmm2 ivar(key) tvar(year) robust cluster(key) endogtest(d_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C


xtivreg2 d_xrd (d_va_a = d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(d_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (d_va_a = d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(d_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_va_a = d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(d_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (d_va_a = d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(d_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (d_va_a = d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(d_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_va_a = d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(d_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (d_sale = d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(d_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (d_sale = d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(d_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_sale = d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(d_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (d_sale = d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(d_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (d_sale = d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(d_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_sale = d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(d_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (d_va_a = d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(d_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (d_va_a = d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(d_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_va_a = d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(d_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (d_va_a = d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(d_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (d_va_a = d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(d_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_va_a = d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(d_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (g_h_sale g_l_sale = g_h_vadd g_l_vadd f.(g_h_vadd g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(g_h_sale g_l_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (g_h_sale g_l_sale = g_h_vadd g_l_vadd f.(g_h_vadd g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(g_h_sale g_l_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (g_h_sale g_l_sale = g_h_vadd g_l_vadd f.(g_h_vadd g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(g_h_sale g_l_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (g_h_sale g_l_sale = g_h_vadd g_l_vadd f.(g_h_vadd g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(g_h_sale g_l_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (g_h_sale g_l_sale = g_h_vadd g_l_vadd f.(g_h_vadd g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(g_h_sale g_l_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (g_h_sale g_l_sale = g_h_vadd g_l_vadd f.(g_h_vadd g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(g_h_sale g_l_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (g_h_sale g_l_sale = g_h_vship g_l_vship f.(g_h_vship g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(g_h_sale g_l_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (g_h_sale g_l_sale = g_h_vship g_l_vship f.(g_h_vship g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(g_h_sale g_l_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (g_h_sale g_l_sale = g_h_vship g_l_vship f.(g_h_vship g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(g_h_sale g_l_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (g_h_sale g_l_sale = g_h_vship g_l_vship f.(g_h_vship g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(g_h_sale g_l_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (g_h_sale g_l_sale = g_h_vship g_l_vship f.(g_h_vship g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(g_h_sale g_l_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (g_h_sale g_l_sale = g_h_vship g_l_vship f.(g_h_vship g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(g_h_sale g_l_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (g_h_va_a g_l_va_a = g_h_vadd g_l_vadd f.(g_h_vadd g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(g_h_va_a g_l_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (g_h_va_a g_l_va_a = g_h_vadd g_l_vadd f.(g_h_vadd g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(g_h_va_a g_l_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (g_h_va_a g_l_va_a = g_h_vadd g_l_vadd f.(g_h_vadd g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(g_h_va_a g_l_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (g_h_va_a g_l_va_a = g_h_vadd g_l_vadd f.(g_h_vadd g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(g_h_va_a g_l_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (g_h_va_a g_l_va_a = g_h_vadd g_l_vadd f.(g_h_vadd g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(g_h_va_a g_l_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (g_h_va_a g_l_va_a = g_h_vadd g_l_vadd f.(g_h_vadd g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(g_h_va_a g_l_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (g_h_va_a g_l_va_a = g_h_vship g_l_vship f.(g_h_vship g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(g_h_va_a g_l_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (g_h_va_a g_l_va_a = g_h_vship g_l_vship f.(g_h_vship g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(g_h_va_a g_l_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (g_h_va_a g_l_va_a = g_h_vship g_l_vship f.(g_h_vship g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(g_h_va_a g_l_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (g_h_va_a g_l_va_a = g_h_vship g_l_vship f.(g_h_vship g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(g_h_va_a g_l_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (g_h_va_a g_l_va_a = g_h_vship g_l_vship f.(g_h_vship g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(g_h_va_a g_l_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (g_h_va_a g_l_va_a = g_h_vship g_l_vship f.(g_h_vship g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(g_h_va_a g_l_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

$|------------------------------------------------------------------------------------------ DEMEANED DATA ------------------------------------------------------------------------------------------|$

xtreg dev_xrd dev_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store A
xtreg z_rd_vadd l.z_rd_vadd l2.z_rd_vadd dev_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store A
xtreg z_rd_vship l.z_rd_vship l2.z_rd_vship dev_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store A
xtreg z_rd_sale l.z_rd_sale l2.z_rd_sale dev_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store A
xtreg z_rd_va_a l.z_rd_va_a l2.z_rd_va_a dev_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_g_h_vadd dev_g_l_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store A
xtreg z_rd_vadd l.z_rd_vadd l2.z_rd_vadd dev_g_h_vadd dev_g_l_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_g_h_vadd dev_g_l_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_g_h_vship dev_g_l_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store A
xtreg z_rd_vship l.z_rd_vship l2.z_rd_vship dev_g_h_vship dev_g_l_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_g_h_vship dev_g_l_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_g_h_sale dev_g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store A
xtreg z_rd_sale l.z_rd_sale l2.z_rd_sale dev_g_h_sale dev_g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_g_h_sale dev_g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_g_h_va_a dev_g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store A
xtreg z_rd_va_a l.z_rd_va_a l2.z_rd_va_a dev_g_h_va_a dev_g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_g_h_va_a dev_g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster key)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

$|------------------------------------------------------------------------------------------ IV SECTION ------------------------------------------------------------------------------------------|$

xtivreg2 dev_xrd (dev_sale = dev_vadd f.dev_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(dev_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_sale = dev_vadd f.dev_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(dev_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_sale = dev_vadd f.dev_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(dev_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_sale = dev_vadd f.dev_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(dev_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_sale = dev_vadd f.dev_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first gmm2 ivar(key) tvar(year) robust cluster(key) endogtest(dev_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_sale = dev_vadd f.dev_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first gmm2 ivar(key) tvar(year) robust cluster(key) endogtest(dev_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C


xtivreg2 dev_xrd (dev_va_a = dev_vadd f.dev_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(dev_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (dev_va_a = dev_vadd f.dev_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(dev_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_va_a = dev_vadd f.dev_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(dev_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_va_a = dev_vadd f.dev_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(dev_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (dev_va_a = dev_vadd f.dev_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(dev_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_va_a = dev_vadd f.dev_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(dev_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_sale = dev_vship f.dev_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(dev_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_sale = dev_vship f.dev_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(dev_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_sale = dev_vship f.dev_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(dev_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_sale = dev_vship f.dev_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(dev_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_sale = dev_vship f.dev_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(dev_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_sale = dev_vship f.dev_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(dev_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_va_a = dev_vship f.dev_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(dev_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (dev_va_a = dev_vship f.dev_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(dev_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_va_a = dev_vship f.dev_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(dev_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_va_a = dev_vship f.dev_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(dev_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (dev_va_a = dev_vship f.dev_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(dev_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_va_a = dev_vship f.dev_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(dev_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_g_h_sale dev_g_l_sale = dev_g_h_vadd dev_g_l_vadd f.(dev_g_h_vadd dev_g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(dev_g_h_sale dev_g_l_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_g_h_sale dev_g_l_sale = dev_g_h_vadd dev_g_l_vadd f.(dev_g_h_vadd dev_g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(dev_g_h_sale dev_g_l_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_g_h_sale dev_g_l_sale = dev_g_h_vadd dev_g_l_vadd f.(dev_g_h_vadd dev_g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(dev_g_h_sale dev_g_l_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_g_h_sale dev_g_l_sale = dev_g_h_vadd dev_g_l_vadd f.(dev_g_h_vadd dev_g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(dev_g_h_sale dev_g_l_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_g_h_sale dev_g_l_sale = dev_g_h_vadd dev_g_l_vadd f.(dev_g_h_vadd dev_g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(dev_g_h_sale dev_g_l_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_g_h_sale dev_g_l_sale = dev_g_h_vadd dev_g_l_vadd f.(dev_g_h_vadd dev_g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(dev_g_h_sale dev_g_l_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_g_h_sale dev_g_l_sale = dev_g_h_vship dev_g_l_vship f.(dev_g_h_vship dev_g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(dev_g_h_sale dev_g_l_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_g_h_sale dev_g_l_sale = dev_g_h_vship dev_g_l_vship f.(dev_g_h_vship dev_g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(dev_g_h_sale dev_g_l_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_g_h_sale dev_g_l_sale = dev_g_h_vship dev_g_l_vship f.(dev_g_h_vship dev_g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(dev_g_h_sale dev_g_l_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_g_h_sale dev_g_l_sale = dev_g_h_vship dev_g_l_vship f.(dev_g_h_vship dev_g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(dev_g_h_sale dev_g_l_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_g_h_sale dev_g_l_sale = dev_g_h_vship dev_g_l_vship f.(dev_g_h_vship dev_g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(dev_g_h_sale dev_g_l_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_g_h_sale dev_g_l_sale = dev_g_h_vship dev_g_l_vship f.(dev_g_h_vship dev_g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(dev_g_h_sale dev_g_l_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_g_h_va_a dev_g_l_va_a = dev_g_h_vadd dev_g_l_vadd f.(dev_g_h_vadd dev_g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(dev_g_h_va_a dev_g_l_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (dev_g_h_va_a dev_g_l_va_a = dev_g_h_vadd dev_g_l_vadd f.(dev_g_h_vadd dev_g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(dev_g_h_va_a dev_g_l_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_g_h_va_a dev_g_l_va_a = dev_g_h_vadd dev_g_l_vadd f.(dev_g_h_vadd dev_g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(dev_g_h_va_a dev_g_l_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_g_h_va_a dev_g_l_va_a = dev_g_h_vadd dev_g_l_vadd f.(dev_g_h_vadd dev_g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(dev_g_h_va_a dev_g_l_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (dev_g_h_va_a dev_g_l_va_a = dev_g_h_vadd dev_g_l_vadd f.(dev_g_h_vadd dev_g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(dev_g_h_va_a dev_g_l_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_g_h_va_a dev_g_l_va_a = dev_g_h_vadd dev_g_l_vadd f.(dev_g_h_vadd dev_g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(dev_g_h_va_a dev_g_l_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_g_h_va_a dev_g_l_va_a = dev_g_h_vship dev_g_l_vship f.(dev_g_h_vship dev_g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(dev_g_h_va_a dev_g_l_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (dev_g_h_va_a dev_g_l_va_a = dev_g_h_vship dev_g_l_vship f.(dev_g_h_vship dev_g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(dev_g_h_va_a dev_g_l_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_g_h_va_a dev_g_l_va_a = dev_g_h_vship dev_g_l_vship f.(dev_g_h_vship dev_g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(key) endogtest(dev_g_h_va_a dev_g_l_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_g_h_va_a dev_g_l_va_a = dev_g_h_vship dev_g_l_vship f.(dev_g_h_vship dev_g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(dev_g_h_va_a dev_g_l_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (dev_g_h_va_a dev_g_l_va_a = dev_g_h_vship dev_g_l_vship f.(dev_g_h_vship dev_g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(dev_g_h_va_a dev_g_l_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_g_h_va_a dev_g_l_va_a = dev_g_h_vship dev_g_l_vship f.(dev_g_h_vship dev_g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(key) endogtest(dev_g_h_va_a dev_g_l_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C


$|------------------------------------------------------------------------------------------ SYSTEM GMM SECTION ------------------------------------------------------------------------------------------|$



xtabond z_rd_vadd d_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_vadd d_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)

xtabond z_rd_capx d_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx d_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)

xtabond z_rd_vship d_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_vship d_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)

xtabond z_rd_capx d_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx d_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)

xtabond z_rd_sale d_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_sale d_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)

xtabond z_rd_capx d_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx d_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)

xtabond z_rd_va_a d_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_va_a d_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)

xtabond z_rd_capx d_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx d_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)



xtabond z_rd_vadd g_h_vadd g_l_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_vadd g_h_vadd g_l_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)

xtabond z_rd_capx g_h_vadd g_l_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx g_h_vadd g_l_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)

xtabond z_rd_vship g_h_vship g_l_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_vship g_h_vship g_l_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)

xtabond z_rd_capx g_h_vship g_l_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx g_h_vship g_l_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)

xtabond z_rd_sale g_h_sale g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_sale g_h_sale g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)

xtabond z_rd_capx g_h_sale g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx g_h_sale g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)

xtabond z_rd_va_a g_h_va_a g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_va_a g_h_va_a g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)

xtabond z_rd_capx g_h_va_a g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx g_h_va_a g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)


$|------------------------------------------------------------------------------------------ IV SECTION ------------------------------------------------------------------------------------------|$


xtabond z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(d_sale) vce(robust) artests(2)
xtdpdsys z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(d_sale) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(d_sale) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(d_sale) vce(robust) artests(2)

xtabond z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(d_va_a) vce(robust) artests(2)
xtdpdsys z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(d_va_a) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(d_va_a) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(d_va_a) vce(robust) artests(2)

xtabond z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(d_sale) vce(robust) artests(2)
xtdpdsys z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(d_sale) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(d_sale) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(d_sale) vce(robust) artests(2)

xtabond z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(d_va_a) vce(robust) artests(2)
xtdpdsys z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(d_va_a) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(d_va_a) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(d_va_a) vce(robust) artests(2)


xtabond z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(g_h_sale g_l_sale) vce(robust) artests(2)
xtdpdsys z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(g_h_sale g_l_sale) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(g_h_sale g_l_sale) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(g_h_sale g_l_sale) vce(robust) artests(2)

xtabond z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(g_h_va_a g_l_va_a) vce(robust) artests(2)
xtdpdsys z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(g_h_va_a g_l_va_a) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(g_h_va_a g_l_va_a) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(g_h_va_a g_l_va_a) vce(robust) artests(2)

xtabond z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(g_h_sale g_l_sale) vce(robust) artests(2)
xtdpdsys z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(g_h_sale g_l_sale) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(g_h_sale g_l_sale) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(g_h_sale g_l_sale) vce(robust) artests(2)

xtabond z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(g_h_va_a g_l_va_a) vce(robust) artests(2)
xtdpdsys z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(g_h_va_a g_l_va_a) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(g_h_va_a g_l_va_a) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(g_h_va_a g_l_va_a) vce(robust) artests(2)

$|------------------------------------------------------------------------------------------ DEMEANED DATA ------------------------------------------------------------------------------------------|$


xtabond z_rd_vadd dev_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_vadd dev_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)

xtabond z_rd_capx dev_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx dev_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)

xtabond z_rd_vship dev_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_vship dev_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)

xtabond z_rd_capx dev_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx dev_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)

xtabond z_rd_sale dev_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_sale dev_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)

xtabond z_rd_capx dev_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx dev_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)

xtabond z_rd_va_a dev_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_va_a dev_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)

xtabond z_rd_capx dev_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx dev_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)



xtabond z_rd_vadd dev_g_h_vadd dev_g_l_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_vadd dev_g_h_vadd dev_g_l_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)

xtabond z_rd_capx dev_g_h_vadd dev_g_l_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx dev_g_h_vadd dev_g_l_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)

xtabond z_rd_vship dev_g_h_vship dev_g_l_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_vship dev_g_h_vship dev_g_l_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)

xtabond z_rd_capx dev_g_h_vship dev_g_l_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx dev_g_h_vship dev_g_l_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)

xtabond z_rd_sale dev_g_h_sale dev_g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_sale dev_g_h_sale dev_g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)

xtabond z_rd_capx dev_g_h_sale dev_g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx dev_g_h_sale dev_g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)

xtabond z_rd_va_a dev_g_h_va_a dev_g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_va_a dev_g_h_va_a dev_g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)

xtabond z_rd_capx dev_g_h_va_a dev_g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)
xtdpdsys z_rd_capx dev_g_h_va_a dev_g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, lags(2) vce(robust) artests(2)



$|------------------------------------------------------------------------------------------ IV SECTION ------------------------------------------------------------------------------------------|$


xtabond z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(dev_sale) vce(robust) artests(2)
xtdpdsys z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(dev_sale) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(dev_sale) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(dev_sale) vce(robust) artests(2)

xtabond z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(dev_va_a) vce(robust) artests(2)
xtdpdsys z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(dev_va_a) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(dev_va_a) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(dev_va_a) vce(robust) artests(2)

xtabond z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(dev_sale) vce(robust) artests(2)
xtdpdsys z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(dev_sale) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(dev_sale) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(dev_sale) vce(robust) artests(2)

xtabond z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(dev_va_a) vce(robust) artests(2)
xtdpdsys z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(dev_va_a) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(dev_va_a) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(dev_va_a) vce(robust) artests(2)

xtabond z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(dev_g_h_sale dev_g_l_sale) vce(robust) artests(2)
xtdpdsys z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(dev_g_h_sale dev_g_l_sale) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(dev_g_h_sale dev_g_l_sale) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(dev_g_h_sale dev_g_l_sale) vce(robust) artests(2)

xtabond z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(dev_g_h_va_a dev_g_l_va_a) vce(robust) artests(2)
xtdpdsys z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(dev_g_h_va_a dev_g_l_va_a) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(dev_g_h_va_a dev_g_l_va_a) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vadd f.d_vadd) lags(2) endog(dev_g_h_va_a dev_g_l_va_a) vce(robust) artests(2)

xtabond z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(dev_g_h_sale dev_g_l_sale) vce(robust) artests(2)
xtdpdsys z_rd_sale  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(dev_g_h_sale dev_g_l_sale) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(dev_g_h_sale dev_g_l_sale) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(dev_g_h_sale dev_g_l_sale) vce(robust) artests(2)

xtabond z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(dev_g_h_va_a dev_g_l_va_a) vce(robust) artests(2)
xtdpdsys z_rd_va_a  emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(dev_g_h_va_a dev_g_l_va_a) vce(robust) artests(2)

xtabond z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(dev_g_h_va_a dev_g_l_va_a) vce(robust) artests(2)
xtdpdsys z_rd_capx emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48,  inst(d_vship f.d_vship) lags(2) endog(dev_g_h_va_a dev_g_l_va_a) vce(robust) artests(2)


$|------------------------------------------------------------------------------------------ CLUSTER ON SIC ------------------------------------------------------------------------------------------|$



xtreg d_xrd d_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store A
xtreg z_rd_vadd l.z_rd_vadd l2.z_rd_vadd d_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store A
xtreg z_rd_vship l.z_rd_vship l2.z_rd_vship d_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store A
xtreg z_rd_sale l.z_rd_sale l2.z_rd_sale d_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd d_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store A
xtreg z_rd_va_a l.z_rd_va_a l2.z_rd_va_a d_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx d_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd g_h_vadd g_l_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store A
xtreg z_rd_vadd l.z_rd_vadd l2.z_rd_vadd g_h_vadd g_l_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx g_h_vadd g_l_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd g_h_vship g_l_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store A
xtreg z_rd_vship l.z_rd_vship l2.z_rd_vship g_h_vship g_l_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx g_h_vship g_l_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd g_h_sale g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store A
xtreg z_rd_sale l.z_rd_sale l2.z_rd_sale g_h_sale g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx g_h_sale g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg d_xrd g_h_va_a g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store A
xtreg z_rd_va_a l.z_rd_va_a l2.z_rd_va_a g_h_va_a g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx g_h_va_a g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

$|------------------------------------------------------------------------------------------ IV SECTION ------------------------------------------------------------------------------------------|$

xtivreg2 d_xrd (d_sale = d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(d_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (d_sale = d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(d_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_sale = d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(d_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (d_sale = d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(d_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (d_sale = d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first gmm2 ivar(key) tvar(year) robust cluster(sic) endogtest(d_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_sale = d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first gmm2 ivar(key) tvar(year) robust cluster(sic) endogtest(d_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C


xtivreg2 d_xrd (d_va_a = d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(d_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (d_va_a = d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(d_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_va_a = d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(d_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (d_va_a = d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(d_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (d_va_a = d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(d_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_va_a = d_vadd f.d_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(d_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (d_sale = d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(d_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (d_sale = d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(d_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_sale = d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(d_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (d_sale = d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(d_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (d_sale = d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(d_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_sale = d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(d_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (d_va_a = d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(d_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (d_va_a = d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(d_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_va_a = d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(d_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (d_va_a = d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(d_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (d_va_a = d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(d_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (d_va_a = d_vship f.d_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(d_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (g_h_sale g_l_sale = g_h_vadd g_l_vadd f.(g_h_vadd g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(g_h_sale g_l_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (g_h_sale g_l_sale = g_h_vadd g_l_vadd f.(g_h_vadd g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(g_h_sale g_l_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (g_h_sale g_l_sale = g_h_vadd g_l_vadd f.(g_h_vadd g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(g_h_sale g_l_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (g_h_sale g_l_sale = g_h_vadd g_l_vadd f.(g_h_vadd g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(g_h_sale g_l_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (g_h_sale g_l_sale = g_h_vadd g_l_vadd f.(g_h_vadd g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(g_h_sale g_l_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (g_h_sale g_l_sale = g_h_vadd g_l_vadd f.(g_h_vadd g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(g_h_sale g_l_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (g_h_sale g_l_sale = g_h_vship g_l_vship f.(g_h_vship g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(g_h_sale g_l_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (g_h_sale g_l_sale = g_h_vship g_l_vship f.(g_h_vship g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(g_h_sale g_l_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (g_h_sale g_l_sale = g_h_vship g_l_vship f.(g_h_vship g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(g_h_sale g_l_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (g_h_sale g_l_sale = g_h_vship g_l_vship f.(g_h_vship g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(g_h_sale g_l_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (g_h_sale g_l_sale = g_h_vship g_l_vship f.(g_h_vship g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(g_h_sale g_l_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (g_h_sale g_l_sale = g_h_vship g_l_vship f.(g_h_vship g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(g_h_sale g_l_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (g_h_va_a g_l_va_a = g_h_vadd g_l_vadd f.(g_h_vadd g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(g_h_va_a g_l_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (g_h_va_a g_l_va_a = g_h_vadd g_l_vadd f.(g_h_vadd g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(g_h_va_a g_l_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (g_h_va_a g_l_va_a = g_h_vadd g_l_vadd f.(g_h_vadd g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(g_h_va_a g_l_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (g_h_va_a g_l_va_a = g_h_vadd g_l_vadd f.(g_h_vadd g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(g_h_va_a g_l_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (g_h_va_a g_l_va_a = g_h_vadd g_l_vadd f.(g_h_vadd g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(g_h_va_a g_l_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (g_h_va_a g_l_va_a = g_h_vadd g_l_vadd f.(g_h_vadd g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(g_h_va_a g_l_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (g_h_va_a g_l_va_a = g_h_vship g_l_vship f.(g_h_vship g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(g_h_va_a g_l_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (g_h_va_a g_l_va_a = g_h_vship g_l_vship f.(g_h_vship g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(g_h_va_a g_l_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (g_h_va_a g_l_va_a = g_h_vship g_l_vship f.(g_h_vship g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(g_h_va_a g_l_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 d_xrd (g_h_va_a g_l_va_a = g_h_vship g_l_vship f.(g_h_vship g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(g_h_va_a g_l_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (g_h_va_a g_l_va_a = g_h_vship g_l_vship f.(g_h_vship g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(g_h_va_a g_l_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (g_h_va_a g_l_va_a = g_h_vship g_l_vship f.(g_h_vship g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(g_h_va_a g_l_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

$|------------------------------------------------------------------------------------------ DEMEANED DATA ------------------------------------------------------------------------------------------|$

xtreg dev_xrd dev_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store A
xtreg z_rd_vadd l.z_rd_vadd l2.z_rd_vadd dev_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store A
xtreg z_rd_vship l.z_rd_vship l2.z_rd_vship dev_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store A
xtreg z_rd_sale l.z_rd_sale l2.z_rd_sale dev_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store A
xtreg z_rd_va_a l.z_rd_va_a l2.z_rd_va_a dev_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_g_h_vadd dev_g_l_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store A
xtreg z_rd_vadd l.z_rd_vadd l2.z_rd_vadd dev_g_h_vadd dev_g_l_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_g_h_vadd dev_g_l_vadd emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_g_h_vship dev_g_l_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store A
xtreg z_rd_vship l.z_rd_vship l2.z_rd_vship dev_g_h_vship dev_g_l_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_g_h_vship dev_g_l_vship emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_g_h_sale dev_g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store A
xtreg z_rd_sale l.z_rd_sale l2.z_rd_sale dev_g_h_sale dev_g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_g_h_sale dev_g_l_sale emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtreg dev_xrd dev_g_h_va_a dev_g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store A
xtreg z_rd_va_a l.z_rd_va_a l2.z_rd_va_a dev_g_h_va_a dev_g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store B
xtreg z_rd_capx l.z_rd_capx l2.z_rd_capx dev_g_h_va_a dev_g_l_va_a emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe vce(cluster sic)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

$|------------------------------------------------------------------------------------------ IV SECTION ------------------------------------------------------------------------------------------|$

xtivreg2 dev_xrd (dev_sale = dev_vadd f.dev_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_sale = dev_vadd f.dev_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_sale = dev_vadd f.dev_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_sale = dev_vadd f.dev_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_sale = dev_vadd f.dev_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first gmm2 ivar(key) tvar(year) robust cluster(sic) endogtest(dev_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_sale = dev_vadd f.dev_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first gmm2 ivar(key) tvar(year) robust cluster(sic) endogtest(dev_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C


xtivreg2 dev_xrd (dev_va_a = dev_vadd f.dev_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (dev_va_a = dev_vadd f.dev_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_va_a = dev_vadd f.dev_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_va_a = dev_vadd f.dev_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (dev_va_a = dev_vadd f.dev_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_va_a = dev_vadd f.dev_vadd) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_sale = dev_vship f.dev_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_sale = dev_vship f.dev_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_sale = dev_vship f.dev_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_sale = dev_vship f.dev_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_sale = dev_vship f.dev_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_sale = dev_vship f.dev_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_va_a = dev_vship f.dev_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (dev_va_a = dev_vship f.dev_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_va_a = dev_vship f.dev_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_va_a = dev_vship f.dev_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (dev_va_a = dev_vship f.dev_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_va_a = dev_vship f.dev_vship) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_g_h_sale dev_g_l_sale = dev_g_h_vadd dev_g_l_vadd f.(dev_g_h_vadd dev_g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_g_h_sale dev_g_l_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_g_h_sale dev_g_l_sale = dev_g_h_vadd dev_g_l_vadd f.(dev_g_h_vadd dev_g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_g_h_sale dev_g_l_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_g_h_sale dev_g_l_sale = dev_g_h_vadd dev_g_l_vadd f.(dev_g_h_vadd dev_g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_g_h_sale dev_g_l_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_g_h_sale dev_g_l_sale = dev_g_h_vadd dev_g_l_vadd f.(dev_g_h_vadd dev_g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_g_h_sale dev_g_l_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_g_h_sale dev_g_l_sale = dev_g_h_vadd dev_g_l_vadd f.(dev_g_h_vadd dev_g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_g_h_sale dev_g_l_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_g_h_sale dev_g_l_sale = dev_g_h_vadd dev_g_l_vadd f.(dev_g_h_vadd dev_g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_g_h_sale dev_g_l_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_g_h_sale dev_g_l_sale = dev_g_h_vship dev_g_l_vship f.(dev_g_h_vship dev_g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_g_h_sale dev_g_l_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_g_h_sale dev_g_l_sale = dev_g_h_vship dev_g_l_vship f.(dev_g_h_vship dev_g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_g_h_sale dev_g_l_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_g_h_sale dev_g_l_sale = dev_g_h_vship dev_g_l_vship f.(dev_g_h_vship dev_g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_g_h_sale dev_g_l_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_g_h_sale dev_g_l_sale = dev_g_h_vship dev_g_l_vship f.(dev_g_h_vship dev_g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_g_h_sale dev_g_l_sale)
est store A
xtivreg2 z_rd_sale l.z_rd_sale l2.z_rd_sale (dev_g_h_sale dev_g_l_sale = dev_g_h_vship dev_g_l_vship f.(dev_g_h_vship dev_g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_g_h_sale dev_g_l_sale)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_g_h_sale dev_g_l_sale = dev_g_h_vship dev_g_l_vship f.(dev_g_h_vship dev_g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_g_h_sale dev_g_l_sale)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_g_h_va_a dev_g_l_va_a = dev_g_h_vadd dev_g_l_vadd f.(dev_g_h_vadd dev_g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_g_h_va_a dev_g_l_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (dev_g_h_va_a dev_g_l_va_a = dev_g_h_vadd dev_g_l_vadd f.(dev_g_h_vadd dev_g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_g_h_va_a dev_g_l_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_g_h_va_a dev_g_l_va_a = dev_g_h_vadd dev_g_l_vadd f.(dev_g_h_vadd dev_g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_g_h_va_a dev_g_l_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_g_h_va_a dev_g_l_va_a = dev_g_h_vadd dev_g_l_vadd f.(dev_g_h_vadd dev_g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_g_h_va_a dev_g_l_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (dev_g_h_va_a dev_g_l_va_a = dev_g_h_vadd dev_g_l_vadd f.(dev_g_h_vadd dev_g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_g_h_va_a dev_g_l_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_g_h_va_a dev_g_l_va_a = dev_g_h_vadd dev_g_l_vadd f.(dev_g_h_vadd dev_g_l_vadd)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_g_h_va_a dev_g_l_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_g_h_va_a dev_g_l_va_a = dev_g_h_vship dev_g_l_vship f.(dev_g_h_vship dev_g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_g_h_va_a dev_g_l_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (dev_g_h_va_a dev_g_l_va_a = dev_g_h_vship dev_g_l_vship f.(dev_g_h_vship dev_g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_g_h_va_a dev_g_l_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_g_h_va_a dev_g_l_va_a = dev_g_h_vship dev_g_l_vship f.(dev_g_h_vship dev_g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_g_h_va_a dev_g_l_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C

xtivreg2 dev_xrd (dev_g_h_va_a dev_g_l_va_a = dev_g_h_vship dev_g_l_vship f.(dev_g_h_vship dev_g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_g_h_va_a dev_g_l_va_a)
est store A
xtivreg2 z_rd_va_a l.z_rd_va_a l2.z_rd_va_a (dev_g_h_va_a dev_g_l_va_a = dev_g_h_vship dev_g_l_vship f.(dev_g_h_vship dev_g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_g_h_va_a dev_g_l_va_a)
est store B
xtivreg2 z_rd_capx l.z_rd_capx l2.z_rd_capx (dev_g_h_va_a dev_g_l_va_a = dev_g_h_vship dev_g_l_vship f.(dev_g_h_vship dev_g_l_vship)) emp r_cf r_dd1 r_dltt r_lt r_at r_ppent l.(r_cf r_dd1 r_dltt r_lt r_at) l2.(r_cf r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48, fe gmm2 first ivar(key) tvar(year) robust cluster(sic) endogtest(dev_g_h_va_a dev_g_l_va_a)
est store C

esttab A B C, tex p

drop _est_A _est_B _est_C
