use "/Users/pedroserodio/Dropbox/Working folder/Thesis ~ Working Files/data/[1]_RND_Industry_data_final.dta", clear

gen g_ship=ln(r_vship)-ln(l.r_vship)
gen g_vadd=ln(r_vadd)-ln(l.r_vadd)
gen g_ship_p=ln(r_vship_p)-ln(l.r_vship_p)
gen g_vadd_p=ln(r_vadd_p)-ln(l.r_vadd_p)

gen z_raw=raw_level/(r_invest+raw_level)
gen z_mi=mi_level/(r_invest+mi_level)
gen z_raw_p=raw_level/(r_invest_p+raw_level)
gen z_mi_p=mi_level/(r_invest_p+mi_level)

gen d_h_ship=1 if g_ship > 0
replace d_h_ship=0 if g_ship < 0
gen d_l_ship=1-d_h_ship
gen d_h_g_ship= g_ship* d_h_ship
gen d_l_g_ship= g_ship* d_l_ship

gen d_h_vadd=1 if g_vadd > 0
replace d_h_vadd=0 if g_vadd < 0
gen d_l_vadd=1-d_h_vadd
gen d_h_g_vadd= g_vadd* d_h_vadd
gen d_l_g_vadd= g_vadd* d_l_vadd

gen D80=1 if year >= 1980
replace D80=0 if year < 1980
gen t_a_D80=t*D80
gen t2_a_D80=t2*D80
gen t_b_D80=t*(1-D80)
gen t2_b_D80=t2*(1-D80)

label variable p_01 "GDP deflator at 2005 prices"

label variable g_ship "Growth rate of shipment value"
label variable d_h_ship "Dummy for positive growth rate of shipment value"
label variable d_l_ship "Dummy for negative growth rate of shipment value"
label variable g_h_ship "Growth rate of shipment value if positive"
label variable g_l_ship "Growth rate of shipment value if negative"

label variable g_vadd "Growth rate of value added"
label variable d_h_vadd "Dummy for positive growth rate of value added"
label variable d_l_vadd "Dummy for negative growth rate of value added"
label variable g_h_vadd "Growth rate of value added if positive"
label variable g_l_vadd "Growth rate of value added if negative"

label variable g_ship_p "Growth rate of shipment value (deflated using GDP deflator)"
label variable g_vadd_p "Growth rate of value added (deflated using GDP deflator)"

label variable d_h_y "Dummy for positive growth rate of GDP"
label variable d_l_y "Dummy for negative growth rate of GDP"
label variable g_h_y "Growth rate of GDP if positive"
label variable g_l_y "Growth rate of GDP if negative"

label variable sh_raw_ship "Ratio of R&D spending to shipment value"
label variable sh_raw_ship_p "Ratio of R&D spending to shipment value (deflated using GDP deflator)"

label variable sh_mi_ship "Ratio of R&D spending to shipment value"
label variable sh_mi_ship_p "Ratio of R&D spending to shipment value (deflated using GDP deflator)"

label variable sh_raw_vadd "Ratio of R&D spending to value added"
label variable sh_raw_vadd_p "Ratio of R&D spending to value added (deflated using GDP deflator)"

label variable sh_mi_vadd "Ratio of R&D spending to value added"
label variable sh_mi_vadd_p "Ratio of R&D spending to value added (deflated using GDP deflator)"

label variable z_raw_invest "Ratio of R&D spending to R&D+Capital expenditure"
label variable z_mi_invest "Ratio of R&D spending to R&D+Capital expenditure"
label variable z_raw_invest_p "Ratio of R&D spending to R&D+Capital expenditure (deflated using GDP deflator)"
label variable z_mi_invest_p "Ratio of R&D spending to R&D+Capital expenditure (deflated using GDP deflator)"

label variable raw_level "Real R&D spending"
label variable r_pay "Real payroll expenditure"

gen ln_mi=ln(mi_level)
tsfilter hp dev_mi=ln_mi, trend(t_mi) smooth(6.25)

gen ln_vadd=ln(r_vadd)
tsfilter hp dev_vadd=ln_vadd, trend(t_vadd) smooth(6.25)

gen ln_vship=ln(r_vship)
tsfilter hp dev_vship=ln_vship, trend(t_vship) smooth(6.25)



gen dev_h_ship=1 if dev_vship > 0
replace dev_h_ship=0 if dev_vship < 0
gen dev_l_ship=1-dev_h_ship
gen dev_h_g_ship= dev_vship* dev_h_ship
gen dev_l_g_ship= dev_vship* dev_l_ship

gen dev_h_vadd=1 if dev_vadd > 0
replace dev_h_vadd=0 if dev_vadd < 0
gen dev_l_vadd=1-dev_h_vadd
gen dev_h_g_vadd= dev_vadd* dev_h_vadd
gen dev_l_g_vadd= dev_vadd* dev_l_vadd

$|------------------------------------------------------------------------------------------ REGRESSIONS------------------------------------------------------------------------------------------|$

reg raw g_vadd emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store A
xtreg raw g_vadd emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store B

reg sh_raw_vadd l.sh_raw_vadd l2.sh_raw_vadd g_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store C
xtreg sh_raw_vadd l.sh_raw_vadd l2.sh_raw_vadd g_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store D


reg z_raw_invest l.z_raw_invest l2.z_raw_invest g_vadd emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store E
xtreg z_raw_invest l.z_raw_invest l2.z_raw_invest g_vadd emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

reg raw g_ship emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store A
xtreg raw g_ship emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store B

reg sh_raw_ship l.sh_raw_ship l2.sh_raw_ship g_ship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store C
xtreg sh_raw_ship l.sh_raw_ship l2.sh_raw_ship g_ship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store D

reg z_raw_invest l.z_raw_invest l2.z_raw_invest g_ship emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store E
xtreg z_raw_invest l.z_raw_invest l2.z_raw_invest g_ship emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

reg raw g_h_vadd g_l_vadd emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store A
xtreg raw g_h_vadd g_l_vadd emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store B

reg sh_raw_vadd l.sh_raw_vadd l2.sh_raw_vadd g_h_vadd g_l_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store C
xtreg sh_raw_vadd l.sh_raw_vadd l2.sh_raw_vadd g_h_vadd g_l_vadd  emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store D

reg z_raw_invest l.z_raw_invest l2.z_raw_invest g_h_vadd g_l_vadd  emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store E
xtreg z_raw_invest l.z_raw_invest l2.z_raw_invest g_h_vadd g_l_vadd  emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F


reg raw g_h_ship g_l_ship emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store A
xtreg raw g_h_ship g_l_ship emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store B

reg sh_raw_ship l.sh_raw_ship l2.sh_raw_ship g_h_ship g_l_ship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store C
xtreg sh_raw_ship l.sh_raw_ship l2.sh_raw_ship g_h_ship g_l_ship  emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store D

reg z_raw_invest l.z_raw_invest l2.z_raw_invest g_h_ship g_l_ship  emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store E
xtreg z_raw_invest l.z_raw_invest l2.z_raw_invest g_h_ship g_l_ship  emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F



$|------------------------------------------------------------------------------------------ MI SECTION------------------------------------------------------------------------------------------|$


reg mi g_vadd emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store A
xtreg mi g_vadd emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store B

reg sh_mi_vadd l.sh_mi_vadd l2.sh_mi_vadd g_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store C
xtreg sh_mi_vadd l.sh_mi_vadd l2.sh_mi_vadd g_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store D

reg z_mi_invest l.z_mi_invest l2.z_mi_invest g_vadd emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43
est store E
xtreg z_mi_invest l.z_mi_invest l2.z_mi_invest g_vadd emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

reg mi g_ship emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43
est store A
xtreg mi g_ship emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe
est store B

reg sh_mi_ship l.sh_mi_ship l2.sh_mi_ship g_ship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43
est store C
xtreg sh_mi_ship l.sh_mi_ship l2.sh_mi_ship g_ship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe
est store D

reg z_mi_invest l.z_mi_invest l2.z_mi_invest g_ship emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store E
xtreg z_mi_invest l.z_mi_invest l2.z_mi_invest g_ship emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

reg mi g_h_vadd g_l_vadd emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store A
xtreg mi g_h_vadd g_l_vadd emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store B

reg sh_mi_vadd l.sh_mi_vadd l2.sh_mi_vadd g_h_vadd g_l_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store C
xtreg sh_mi_vadd l.sh_mi_vadd l2.sh_mi_vadd g_h_vadd g_l_vadd  emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store D

reg z_mi_invest l.z_mi_invest l2.z_mi_invest g_h_vadd g_l_vadd  emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store E
xtreg z_mi_invest l.z_mi_invest l2.z_mi_invest g_h_vadd g_l_vadd  emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

reg mi g_h_ship g_l_ship emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store A
xtreg mi g_h_ship g_l_ship emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store B

reg sh_mi_ship l.sh_mi_ship l2.sh_mi_ship g_h_ship g_l_ship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store C
xtreg sh_mi_ship l.sh_mi_ship l2.sh_mi_ship g_h_ship g_l_ship  emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store D

reg z_mi_invest l.z_mi_invest l2.z_mi_invest g_h_ship g_l_ship  emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store E
xtreg z_mi_invest l.z_mi_invest l2.z_mi_invest g_h_ship g_l_ship  emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

$|------------------------------------------------------------------------------------------ IV SECTION ------------------------------------------------------------------------------------------|$

ivreg2 raw (g_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store A
xtivreg2 raw (g_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store B

ivreg2 sh_raw_vadd l.sh_raw_vadd l2.sh_raw_vadd (g_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store C
xtivreg2 sh_raw_vadd l.sh_raw_vadd l2.sh_raw_vadd (g_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store D

ivreg2 z_raw_invest l.z_raw_invest l2.z_raw_invest (g_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store E
xtivreg2 z_raw_invest l.z_raw_invest l2.z_raw_invest (g_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

ivreg2 raw (g_ship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store A
xtivreg2 raw (g_ship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store B

ivreg2 sh_raw_ship l.sh_raw_ship l2.sh_raw_ship (g_ship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store C
xtivreg2 sh_raw_ship l.sh_raw_ship l2.sh_raw_ship (g_ship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store D

ivreg2 z_raw_invest l.z_raw_invest l2.z_raw_invest (g_ship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store E
xtivreg2 z_raw_invest l.z_raw_invest l2.z_raw_invest (g_ship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

ivreg2 raw (g_h_vadd g_l_vadd = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store A
xtivreg2 raw (g_h_vadd g_l_vadd = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store B

ivreg2 sh_raw_vadd l.sh_raw_vadd l2.sh_raw_vadd (g_h_vadd g_l_vadd = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store C
xtivreg2 sh_raw_vadd l.sh_raw_vadd l2.sh_raw_vadd (g_h_vadd g_l_vadd = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store D

ivreg2 z_raw_invest l.z_raw_invest l2.z_raw_invest (g_h_vadd g_l_vadd = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store E
xtivreg2 z_raw_invest l.z_raw_invest l2.z_raw_invest (g_h_vadd g_l_vadd = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

ivreg2 raw (g_h_ship g_l_ship = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store A
xtivreg2 raw (g_h_ship g_l_ship = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store B

ivreg2 sh_raw_ship l.sh_raw_ship l2.sh_raw_ship (g_h_ship g_l_ship = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store C
xtivreg2 sh_raw_ship l.sh_raw_ship l2.sh_raw_ship (g_h_ship g_l_ship = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store D

ivreg2 z_raw_invest l.z_raw_invest l2.z_raw_invest (g_h_ship g_l_ship = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store E
xtivreg2 z_raw_invest l.z_raw_invest l2.z_raw_invest (g_h_ship g_l_ship = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

ivreg2 raw (g_h_vadd g_l_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store A
xtivreg2 raw (g_h_vadd g_l_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store B

ivreg2 sh_raw_vadd l.sh_raw_vadd l2.sh_raw_vadd (g_h_vadd g_l_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store C
xtivreg2 sh_raw_vadd l.sh_raw_vadd l2.sh_raw_vadd (g_h_vadd g_l_vadd = g_y f.g_y)  emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store D

ivreg2 z_raw_invest l.z_raw_invest l2.z_raw_invest (g_h_vadd g_l_vadd = g_y f.g_y)  emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store E
xtivreg2 z_raw_invest l.z_raw_invest l2.z_raw_invest (g_h_vadd g_l_vadd = g_y f.g_y)  emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

ivreg2 raw (g_h_ship g_l_ship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store A
xtivreg2 raw (g_h_ship g_l_ship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store B

ivreg2 sh_raw_ship l.sh_raw_ship l2.sh_raw_ship (g_h_ship g_l_ship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store C
xtivreg2 sh_raw_ship l.sh_raw_ship l2.sh_raw_ship (g_h_ship g_l_ship = g_y f.g_y)  emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store D

ivreg2 z_raw_invest l.z_raw_invest l2.z_raw_invest (g_h_ship g_l_ship = g_y f.g_y)  emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store E
xtivreg2 z_raw_invest l.z_raw_invest l2.z_raw_invest (g_h_ship g_l_ship = g_y f.g_y)  emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F


$|------------------------------------------------------------------------------------------ MI SECTION------------------------------------------------------------------------------------------|$

ivreg2 mi (g_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store A
xtivreg2 mi (g_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store B

ivreg2 sh_mi_vadd l.sh_mi_vadd l2.sh_mi_vadd (g_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store C
xtivreg2 sh_mi_vadd l.sh_mi_vadd l2.sh_mi_vadd (g_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store D

ivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (g_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store E
xtivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (g_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

ivreg2 mi (g_ship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store A
xtivreg2 mi (g_ship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store B

ivreg2 sh_mi_ship l.sh_mi_ship l2.sh_mi_ship (g_ship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store C
xtivreg2 sh_mi_ship l.sh_mi_ship l2.sh_mi_ship (g_ship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store D

ivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (g_ship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store E
xtivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (g_ship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

ivreg2 mi (g_h_vadd g_l_vadd = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store A
xtivreg2 mi (g_h_vadd g_l_vadd = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store B

ivreg2 sh_mi_vadd l.sh_mi_vadd l2.sh_mi_vadd (g_h_vadd g_l_vadd = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store C
xtivreg2 sh_mi_vadd l.sh_mi_vadd l2.sh_mi_vadd (g_h_vadd g_l_vadd = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store D

ivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (g_h_vadd g_l_vadd = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store E
xtivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (g_h_vadd g_l_vadd = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

ivreg2 mi (g_h_ship g_l_ship = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store A
xtivreg2 mi (g_h_ship g_l_ship = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store B

ivreg2 sh_mi_ship l.sh_mi_ship l2.sh_mi_ship (g_h_ship g_l_ship = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store C
xtivreg2 sh_mi_ship l.sh_mi_ship l2.sh_mi_ship (g_h_ship g_l_ship = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store D

ivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (g_h_ship g_l_ship = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store E
xtivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (g_h_ship g_l_ship = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

$|------------------------------------------------------------------------------------------ GMM2 SECTION------------------------------------------------------------------------------------------|$

ivreg2 raw (g_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store A
xtivreg2 raw (g_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store B

ivreg2 sh_raw_vadd l.sh_raw_vadd l2.sh_raw_vadd (g_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store C
xtivreg2 sh_raw_vadd l.sh_raw_vadd l2.sh_raw_vadd (g_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store D

ivreg2 z_raw_invest l.z_raw_invest l2.z_raw_invest (g_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store E
xtivreg2 z_raw_invest l.z_raw_invest l2.z_raw_invest (g_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

ivreg2 raw (g_ship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store A
xtivreg2 raw (g_ship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store B

ivreg2 sh_raw_ship l.sh_raw_ship l2.sh_raw_ship (g_ship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store C
xtivreg2 sh_raw_ship l.sh_raw_ship l2.sh_raw_ship (g_ship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store D

ivreg2 z_raw_invest l.z_raw_invest l2.z_raw_invest (g_ship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store E
xtivreg2 z_raw_invest l.z_raw_invest l2.z_raw_invest (g_ship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

ivreg2 raw (g_h_vadd g_l_vadd = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store A
xtivreg2 raw (g_h_vadd g_l_vadd = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store B

ivreg2 sh_raw_vadd l.sh_raw_vadd l2.sh_raw_vadd (g_h_vadd g_l_vadd = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store C
xtivreg2 sh_raw_vadd l.sh_raw_vadd l2.sh_raw_vadd (g_h_vadd g_l_vadd = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store D

ivreg2 z_raw_invest l.z_raw_invest l2.z_raw_invest (g_h_vadd g_l_vadd = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store E
xtivreg2 z_raw_invest l.z_raw_invest l2.z_raw_invest (g_h_vadd g_l_vadd = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

ivreg2 raw (g_h_ship g_l_ship = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store A
xtivreg2 raw (g_h_ship g_l_ship = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store B

ivreg2 sh_raw_ship l.sh_raw_ship l2.sh_raw_ship (g_h_ship g_l_ship = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store C
xtivreg2 sh_raw_ship l.sh_raw_ship l2.sh_raw_ship (g_h_ship g_l_ship = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store D

ivreg2 z_raw_invest l.z_raw_invest l2.z_raw_invest (g_h_ship g_l_ship = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store E
xtivreg2 z_raw_invest l.z_raw_invest l2.z_raw_invest (g_h_ship g_l_ship = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

$|------------------------------------------------------------------------------------------ MI SECTION------------------------------------------------------------------------------------------|$

ivreg2 mi (g_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store A
xtivreg2 mi (g_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store B

ivreg2 sh_mi_vadd l.sh_mi_vadd l2.sh_mi_vadd (g_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store C
xtivreg2 sh_mi_vadd l.sh_mi_vadd l2.sh_mi_vadd (g_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store D

ivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (g_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store E
xtivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (g_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

ivreg2 mi (g_ship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store A
xtivreg2 mi (g_ship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store B

ivreg2 sh_mi_ship l.sh_mi_ship l2.sh_mi_ship (g_ship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store C
xtivreg2 sh_mi_ship l.sh_mi_ship l2.sh_mi_ship (g_ship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store D

ivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (g_ship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store E
xtivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (g_ship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

ivreg2 mi (g_h_vadd g_l_vadd = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store A
xtivreg2 mi (g_h_vadd g_l_vadd = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store B

ivreg2 sh_mi_vadd l.sh_mi_vadd l2.sh_mi_vadd (g_h_vadd g_l_vadd = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store C
xtivreg2 sh_mi_vadd l.sh_mi_vadd l2.sh_mi_vadd (g_h_vadd g_l_vadd = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store D

ivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (g_h_vadd g_l_vadd = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store E
xtivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (g_h_vadd g_l_vadd = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

ivreg2 mi (g_h_ship g_l_ship = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store A
xtivreg2 mi (g_h_ship g_l_ship = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store B

ivreg2 sh_mi_ship l.sh_mi_ship l2.sh_mi_ship (g_h_ship g_l_ship = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store C
xtivreg2 sh_mi_ship l.sh_mi_ship l2.sh_mi_ship (g_h_ship g_l_ship = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store D

ivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (g_h_ship g_l_ship = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store E
xtivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (g_h_ship g_l_ship = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

$|------------------------------------------------------------------------------------------ DEVIATIONS SECTION------------------------------------------------------------------------------------------|$

$|------------------------------------------------------------------------------------------ MI SECTION------------------------------------------------------------------------------------------|$


reg dev_mi dev_vadd emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store A
xtreg dev_mi dev_vadd emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store B

reg sh_mi_vadd l.sh_mi_vadd l2.sh_mi_vadd dev_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store C
xtreg sh_mi_vadd l.sh_mi_vadd l2.sh_mi_vadd dev_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store D

reg z_mi_invest l.z_mi_invest l2.z_mi_invest dev_vadd emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43
est store E
xtreg z_mi_invest l.z_mi_invest l2.z_mi_invest dev_vadd emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

reg dev_mi dev_vship emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43
est store A
xtreg dev_mi dev_vship emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe
est store B

reg sh_mi_ship l.sh_mi_ship l2.sh_mi_ship dev_vship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43
est store C
xtreg sh_mi_ship l.sh_mi_ship l2.sh_mi_ship dev_vship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe
est store D

reg z_mi_invest l.z_mi_invest l2.z_mi_invest dev_vship emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store E
xtreg z_mi_invest l.z_mi_invest l2.z_mi_invest dev_vship emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

reg dev_mi dev_h_g_vadd dev_l_g_vadd emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store A
xtreg dev_mi dev_h_g_vadd dev_l_g_vadd emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store B

reg sh_mi_vadd l.sh_mi_vadd l2.sh_mi_vadd dev_h_g_vadd dev_l_g_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store C
xtreg sh_mi_vadd l.sh_mi_vadd l2.sh_mi_vadd dev_h_g_vadd dev_l_g_vadd  emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store D

reg z_mi_invest l.z_mi_invest l2.z_mi_invest dev_h_g_vadd dev_l_g_vadd  emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store E
xtreg z_mi_invest l.z_mi_invest l2.z_mi_invest dev_h_g_vadd dev_l_g_vadd  emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

reg dev_mi dev_h_g_ship dev_l_g_ship emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store A
xtreg dev_mi dev_h_g_ship dev_l_g_ship emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store B

reg sh_mi_ship l.sh_mi_ship l2.sh_mi_ship dev_h_g_ship dev_l_g_ship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store C
xtreg sh_mi_ship l.sh_mi_ship l2.sh_mi_ship dev_h_g_ship dev_l_g_ship  emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store D

reg z_mi_invest l.z_mi_invest l2.z_mi_invest dev_h_g_ship dev_l_g_ship  emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, robust
est store E
xtreg z_mi_invest l.z_mi_invest l2.z_mi_invest dev_h_g_ship dev_l_g_ship  emp r_equip l.r_equip r_plant l.r_plant y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, fe robust
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

$|------------------------------------------------------------------------------------------ IV MI SECTION------------------------------------------------------------------------------------------|$

ivreg2 dev_mi (dev_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store A
xtivreg2 dev_mi (dev_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store B

ivreg2 sh_mi_vadd l.sh_mi_vadd l2.sh_mi_vadd (dev_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store C
xtivreg2 sh_mi_vadd l.sh_mi_vadd l2.sh_mi_vadd (dev_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store D

ivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (dev_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store E
xtivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (dev_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

ivreg2 dev_mi (dev_vship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store A
xtivreg2 dev_mi (dev_vship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store B

ivreg2 sh_mi_ship l.sh_mi_ship l2.sh_mi_ship (dev_vship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store C
xtivreg2 sh_mi_ship l.sh_mi_ship l2.sh_mi_ship (dev_vship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store D

ivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (dev_vship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store E
xtivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (dev_vship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

ivreg2 dev_mi (dev_h_g_vadd dev_l_g_vadd = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store A
xtivreg2 dev_mi (dev_h_g_vadd dev_l_g_vadd = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store B

ivreg2 sh_mi_vadd l.sh_mi_vadd l2.sh_mi_vadd (dev_h_g_vadd dev_l_g_vadd = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store C
xtivreg2 sh_mi_vadd l.sh_mi_vadd l2.sh_mi_vadd (dev_h_g_vadd dev_l_g_vadd = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store D

ivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (dev_h_g_vadd dev_l_g_vadd = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store E
xtivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (dev_h_g_vadd dev_l_g_vadd = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

ivreg2 dev_mi (dev_h_g_ship dev_l_g_ship = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store A
xtivreg2 dev_mi (dev_h_g_ship dev_l_g_ship = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store B

ivreg2 sh_mi_ship l.sh_mi_ship l2.sh_mi_ship (dev_h_g_ship dev_l_g_ship = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store C
xtivreg2 sh_mi_ship l.sh_mi_ship l2.sh_mi_ship (dev_h_g_ship dev_l_g_ship = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store D

ivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (dev_h_g_ship dev_l_g_ship = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust
est store E
xtivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (dev_h_g_ship dev_l_g_ship = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

$|------------------------------------------------------------------------------------------ GMM2 MI SECTION------------------------------------------------------------------------------------------|$

ivreg2 dev_mi (dev_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store A
xtivreg2 dev_mi (dev_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store B

ivreg2 sh_mi_vadd l.sh_mi_vadd l2.sh_mi_vadd (dev_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store C
xtivreg2 sh_mi_vadd l.sh_mi_vadd l2.sh_mi_vadd (dev_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store D

ivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (dev_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store E
xtivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (dev_vadd = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

ivreg2 dev_mi (dev_vship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store A
xtivreg2 dev_mi (dev_vship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store B

ivreg2 sh_mi_ship l.sh_mi_ship l2.sh_mi_ship (dev_vship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store C
xtivreg2 sh_mi_ship l.sh_mi_ship l2.sh_mi_ship (dev_vship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store D

ivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (dev_vship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store E
xtivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (dev_vship = g_y f.g_y) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

ivreg2 dev_mi (dev_h_g_vadd dev_l_g_vadd = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store A
xtivreg2 dev_mi (dev_h_g_vadd dev_l_g_vadd = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store B

ivreg2 sh_mi_vadd l.sh_mi_vadd l2.sh_mi_vadd (dev_h_g_vadd dev_l_g_vadd = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store C
xtivreg2 sh_mi_vadd l.sh_mi_vadd l2.sh_mi_vadd (dev_h_g_vadd dev_l_g_vadd = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store D

ivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (dev_h_g_vadd dev_l_g_vadd = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store E
xtivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (dev_h_g_vadd dev_l_g_vadd = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

ivreg2 dev_mi (dev_h_g_ship dev_l_g_ship = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store A
xtivreg2 dev_mi (dev_h_g_ship dev_l_g_ship = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store B

ivreg2 sh_mi_ship l.sh_mi_ship l2.sh_mi_ship (dev_h_g_ship dev_l_g_ship = g_h_y g_l_y f.(g_h_y g_l_y)) emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store C
xtivreg2 sh_mi_ship l.sh_mi_ship l2.sh_mi_ship (dev_h_g_ship dev_l_g_ship = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store D

ivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (dev_h_g_ship dev_l_g_ship = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, ivar(code) tvar(year) robust gmm2
est store E
xtivreg2 z_mi_invest l.z_mi_invest l2.z_mi_invest (dev_h_g_ship dev_l_g_ship = g_h_y g_l_y f.(g_h_y g_l_y))  emp r_equip l.r_equip r_plant l.r_plant t t2, fe ivar(code) tvar(year) cluster(code) robust gmm2
est store F

esttab A B C D E F, tex p

drop _est_A _est_B _est_C _est_D _est_E _est_F

$|------------------------------------------------------------------------------------------ SYSTEM GMM SECTION------------------------------------------------------------------------------------------|$

xtabond sh_raw_vadd g_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)
xtdpdsys sh_raw_vadd g_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)

xtabond z_raw_invest g_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)
xtdpdsys z_raw_invest g_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)

xtabond sh_raw_ship g_ship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)
xtdpdsys sh_raw_ship g_ship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)

xtabond z_raw_invest g_ship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)
xtdpdsys z_raw_invest g_ship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)


xtabond sh_raw_vadd emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(g_vadd) vce(robust) artests(2)
xtdpdsys sh_raw_vadd emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(g_vadd) vce(robust) artests(2)

xtabond z_raw_invest emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(g_vadd) vce(robust) artests(2)
xtdpdsys z_raw_invest emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(g_vadd) vce(robust) artests(2)

xtabond sh_raw_ship emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(g_ship) vce(robust) artests(2)
xtdpdsys sh_raw_ship emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(g_ship) vce(robust) artests(2)

xtabond z_raw_invest emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(g_ship) vce(robust) artests(2)
xtdpdsys z_raw_invest emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(g_ship) vce(robust) artests(2)



xtabond sh_mi_vadd g_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)
xtdpdsys sh_mi_vadd g_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)

xtabond sh_mi_ship g_ship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)
xtdpdsys sh_mi_ship g_ship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)

xtabond sh_mi_vadd emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(g_vadd) vce(robust) artests(2)
xtdpdsys sh_mi_vadd emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(g_vadd) vce(robust) artests(2)

xtabond sh_mi_ship emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(g_ship) vce(robust) artests(2)
xtdpdsys sh_mi_ship emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(g_ship) vce(robust) artests(2)

-- Asymmetric --

xtabond sh_raw_vadd g_h_vadd g_l_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)
xtdpdsys sh_raw_vadd g_h_vadd g_l_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)

xtabond z_raw_invest g_h_vadd g_l_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)
xtdpdsys z_raw_invest g_h_vadd g_l_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)

xtabond sh_raw_ship g_h_ship g_l_ship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)
xtdpdsys sh_raw_ship g_h_ship g_l_ship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)

xtabond z_raw_invest g_h_ship g_l_ship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)
xtdpdsys z_raw_invest g_h_ship g_l_ship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)


xtabond sh_raw_vadd emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(g_h_vadd g_l_vadd) vce(robust) artests(2)
xtdpdsys sh_raw_vadd emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(g_h_vadd g_l_vadd) vce(robust) artests(2)

xtabond z_raw_invest emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(g_h_vadd g_l_vadd) vce(robust) artests(2)
xtdpdsys z_raw_invest emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(g_h_vadd g_l_vadd) vce(robust) artests(2)

xtabond sh_raw_ship emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(g_h_ship g_l_ship) vce(robust) artests(2)
xtdpdsys sh_raw_ship emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(g_h_ship g_l_ship) vce(robust) artests(2)

xtabond z_raw_invest emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(g_h_ship g_l_ship) vce(robust) artests(2)
xtdpdsys z_raw_invest emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(g_h_ship g_l_ship) vce(robust) artests(2)



xtabond sh_mi_vadd g_h_vadd g_l_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)
xtdpdsys sh_mi_vadd g_h_vadd g_l_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)

xtabond sh_mi_ship g_h_ship g_l_ship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)
xtdpdsys sh_mi_ship g_h_ship g_l_ship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)

xtabond sh_mi_vadd emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(g_h_vadd g_l_vadd) vce(robust) artests(2)
xtdpdsys sh_mi_vadd emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(g_h_vadd g_l_vadd) vce(robust) artests(2)

xtabond sh_mi_ship emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(g_h_ship g_l_ship) vce(robust) artests(2)
xtdpdsys sh_mi_ship emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(g_h_ship g_l_ship) vce(robust) artests(2)


-- Deviations --

xtabond sh_raw_vadd dev_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)
xtdpdsys sh_raw_vadd dev_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)

xtabond z_raw_invest dev_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)
xtdpdsys z_raw_invest dev_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)

xtabond sh_raw_ship dev_vship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)
xtdpdsys sh_raw_ship dev_vship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)

xtabond z_raw_invest dev_vship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)
xtdpdsys z_raw_invest dev_vship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)


xtabond sh_raw_vadd emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(dev_vadd) vce(robust) artests(2)
xtdpdsys sh_raw_vadd emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(dev_vadd) vce(robust) artests(2)

xtabond z_raw_invest emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(dev_vadd) vce(robust) artests(2)
xtdpdsys z_raw_invest emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(dev_vadd) vce(robust) artests(2)

xtabond sh_raw_ship emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(dev_vship) vce(robust) artests(2)
xtdpdsys sh_raw_ship emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(dev_vship) vce(robust) artests(2)

xtabond z_raw_invest emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(dev_vship) vce(robust) artests(2)
xtdpdsys z_raw_invest emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(dev_vship) vce(robust) artests(2)


xtabond sh_mi_vadd dev_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)
xtdpdsys sh_mi_vadd dev_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)

xtabond sh_mi_ship dev_vship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)
xtdpdsys sh_mi_ship dev_vship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)

xtabond sh_mi_vadd emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(dev_vadd) vce(robust) artests(2)
xtdpdsys sh_mi_vadd emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(dev_vadd) vce(robust) artests(2)

xtabond sh_mi_ship emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(dev_vship) vce(robust) artests(2)
xtdpdsys sh_mi_ship emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(dev_vship) vce(robust) artests(2)

-- Asymmetric -- 

xtabond sh_raw_vadd dev_h_g_vadd dev_l_g_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)
xtdpdsys sh_raw_vadd dev_h_g_vadd dev_l_g_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)

xtabond z_raw_invest dev_h_g_vadd dev_l_g_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)
xtdpdsys z_raw_invest dev_h_g_vadd dev_l_g_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)

xtabond sh_raw_ship dev_h_g_ship dev_l_g_ship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)
xtdpdsys sh_raw_ship dev_h_g_ship dev_l_g_ship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)

xtabond z_raw_invest dev_h_g_ship dev_l_g_ship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)
xtdpdsys z_raw_invest dev_h_g_ship dev_l_g_ship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)


xtabond sh_raw_vadd emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(dev_h_g_vadd dev_l_g_vadd) vce(robust) artests(2)
xtdpdsys sh_raw_vadd emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(dev_h_g_vadd dev_l_g_vadd) vce(robust) artests(2)

xtabond z_raw_invest emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(dev_h_g_vadd dev_l_g_vadd) vce(robust) artests(2)
xtdpdsys z_raw_invest emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(dev_h_g_vadd dev_l_g_vadd) vce(robust) artests(2)

xtabond sh_raw_ship emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(dev_h_g_ship dev_l_g_ship) vce(robust) artests(2)
xtdpdsys sh_raw_ship emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(dev_h_g_ship dev_l_g_ship) vce(robust) artests(2)

xtabond z_raw_invest emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(dev_h_g_ship dev_l_g_ship) vce(robust) artests(2)
xtdpdsys z_raw_invest emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(dev_h_g_ship dev_l_g_ship) vce(robust) artests(2)


xtabond sh_mi_vadd dev_h_g_vadd dev_l_g_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)
xtdpdsys sh_mi_vadd dev_h_g_vadd dev_l_g_vadd emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)

xtabond sh_mi_ship dev_h_g_ship dev_l_g_ship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)
xtdpdsys sh_mi_ship dev_h_g_ship dev_l_g_ship emp r_equip l.r_equip r_plant l.r_plant y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22 y23 y24 y25 y26 y27 y28 y29 y30 y31 y32 y33 y34 y35 y36 y37 y38 y39 y40 y41 y42 y43, lags(2) vce(robust) artests(2)

xtabond sh_mi_vadd emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(dev_h_g_vadd dev_l_g_vadd) vce(robust) artests(2)
xtdpdsys sh_mi_vadd emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(dev_h_g_vadd dev_l_g_vadd) vce(robust) artests(2)

xtabond sh_mi_ship emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(dev_h_g_ship dev_l_g_ship) vce(robust) artests(2)
xtdpdsys sh_mi_ship emp r_equip l.r_equip r_plant l.r_plant t t2, inst(g_y f.g_y) lags(2) endog(dev_h_g_ship dev_l_g_ship) vce(robust) artests(2)
