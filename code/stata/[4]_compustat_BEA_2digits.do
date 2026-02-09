. use "/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/[4]_compustat_BEA_2digits.dta"

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

gen r_va=va/p

gen r_gdp=gdp/p

gen r_p_gdp=private_gdp/p

gen r_go=go/p

gen r_go_all=go_allind/p

gen r_go_p_ind=go_privateind/p

gen d_xrd=ln(r_xrd)-ln(l.r_xrd)

gen d_va=ln(r_va)-ln(l.r_va)

gen d_gdp=ln(r_gdp)-ln(l.r_gdp)

gen d_p_gdp=ln(r_p_gdp)-ln(l.r_p_gdp)

gen d_go=ln(r_go)-ln(l.r_go)

gen d_go_all=ln(r_go_all)-ln(l.r_go_all)

gen d_go_p=ln(r_go_p)-ln(l.r_go_p)

gen z_rd_go=r_xrd/r_go

gen z_rd_va=r_xrd/r_va

xtreg d_xrd d_go, fe
xtreg d_xrd d_va, fe

xtreg d_xrd d_go t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48 t49 t50 t51 t52 t53 t54 t55 t56 t57 t58 t59 t60 t61 t62, fe
xtreg d_xrd d_va t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48 t49 t50 t51 t52 t53 t54 t55 t56 t57 t58 t59 t60 t61 t62, fe

xtreg d_xrd d_go  emp r_che r_dd1 r_dltt r_lt r_at r_ppent l.(r_che r_dd1 r_dltt r_lt r_at) l2.(r_che r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48 t49 t50 t51 t52 t53 t54 t55 t56 t57 t58 t59 t60 t61 t62, fe
xtreg d_xrd d_va  emp r_che r_dd1 r_dltt r_lt r_at r_ppent l.(r_che r_dd1 r_dltt r_lt r_at) l2.(r_che r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48 t49 t50 t51 t52 t53 t54 t55 t56 t57 t58 t59 t60 t61 t62, fe


xtreg z_rd_go d_go, fe
xtreg z_rd_va d_va, fe

xtreg z_rd_go d_go t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48 t49 t50 t51 t52 t53 t54 t55 t56 t57 t58 t59 t60 t61 t62, fe
xtreg z_rd_va d_va t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48 t49 t50 t51 t52 t53 t54 t55 t56 t57 t58 t59 t60 t61 t62, fe

xtreg z_rd_go d_go emp r_che r_dd1 r_dltt r_lt r_at r_ppent l.(r_che r_dd1 r_dltt r_lt r_at) l2.(r_che r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48 t49 t50 t51 t52 t53 t54 t55 t56 t57 t58 t59 t60 t61 t62, fe
xtreg z_rd_va d_va emp r_che r_dd1 r_dltt r_lt r_at r_ppent l.(r_che r_dd1 r_dltt r_lt r_at) l2.(r_che r_dd1 r_dltt r_lt r_at) t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30 t31 t32 t33 t34 t35 t36 t37 t38 t39 t40 t41 t42 t43 t44 t45 t46 t47 t48 t49 t50 t51 t52 t53 t54 t55 t56 t57 t58 t59 t60 t61 t62, fe
