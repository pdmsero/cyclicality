use "/Users/pedroserodio/Dropbox/Working folder/Papers/Cyclicality of R&D at the Firm Level/Data files/GDPData_RawFile.dta", clear

tsset year

gen r_GDP=GDP/P_GDP
gen d_gdp=ln(r_GDP)-ln(l.r_GDP)

drop Consumption Goods Durables NonDurables Services TotalInvestment FixedInvestment NonResidential Structures Equipment IPR Residential ChangeInventories NetExports Exports XGoods XServices Imports MGoods MServices Government Federal Defense NonDefense StateNLocal P_Consumption P_Goods P_Durables P_NonDurables P_Services P_TotalInvestment P_FixedInvestment P_Structures P_Equipment P_Residential P_ChangeInventories P_NetExports P_Exports P_XGoods P_XServices P_Imports P_MGoods P_MServices P_Government P_Federal P_Defense P_NonDefense P_StateNLocal r_GDP

save "/Users/pedroserodio/Dropbox/Working folder/Papers/Cyclicality of R&D at the Firm Level/Data files/GDPData.dta", replace
