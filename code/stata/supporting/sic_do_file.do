
cd "/Users/pedroserodio/Downloads/"

save sic5805_original.dta



tostring sic, gen (sic2)
gen sic3 = substr(sic2, 1, 3)
drop sic2
move sic3 year
sort year sic3

tostring sic, gen (sic2)
gen sic4 = substr(sic2, 1, 2)
drop sic2
move sic4 year
sort year sic4

collapse (sum) r_vship r_vadd, by(year sic3)

collapse (sum) emp pay prode prodh prodw vship matcost vadd invest invent energy cap equip plant, by(year sic3)

collapse (sum) emp pay prode prodh prodw vship matcost vadd invest invent energy cap equip plant r_vship, by(year alt_sig)

collapse (sum) emp pay r_vship r_vship_p r_vadd r_vadd_p r_invest r_invest_p r_cap r_cap_p r_equip r_equip_p r_plant r_plant_p, by(year sic4)
