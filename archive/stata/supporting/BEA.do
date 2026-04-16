use "/Users/pedroserodio/Dropbox/Working folder/Papers/Cyclicality of R&D at the Firm Level/Data files/BEA_ValueAdded_RawFile.dta", clear

xtset code year

gen r_GO=GO/PGO
gen r_VA=VA/PVA
gen r_COMP=COMP/PVA
gen r_TAX=TAX/PVA
gen r_SURPLUS=SURPLUS/PVA
gen r_INPUTS=INPUTS/PINPUTS
gen r_ENER=ENER/PENER
gen r_MAT=MAT/PMAT
gen r_SERVICE=SERVICE/PSERVICE
gen r_GO_GDP=GO_GDP/PGO_GDP
gen r_VA_GDP=VA_GDP/PVA_GDP
gen r_COMP_GDP=COMP_GDP/PVA_GDP
gen r_TAX_GDP=TAX_GDP/PVA_GDP
gen r_SURPLUS_GDP=SURPLUS_GDP/PVA_GDP
gen r_INPUTS_GDP=INPUTS_GDP/PINPUTS_GDP
gen r_ENER_GDP=ENER_GDP/PENER_GDP
gen r_MAT_GDP=MAT_GDP/PMAT_GDP
gen r_SERVICE_GDP=SERVICE_GDP/PSERVICE_GDP

gen d_go=ln(r_GO)-ln(l.r_GO)
gen d_va_ind=ln(r_VA)-ln(l.r_VA)
gen d_instrument=ln(Instrument)-ln(l.Instrument)

drop COMP TAX SURPLUS INPUTS ENER MAT SERVICE GO_GDP VA_GDP COMP_GDP TAX_GDP SURPLUS_GDP INPUTS_GDP ENER_GDP MAT_GDP SERVICE_GDP PINPUTS PENER PMAT PSERVICE PGO_GDP PVA_GDP PINPUTS_GDP PENER_GDP PMAT_GDP PSERVICE_GDP Instrument r_GO r_VA r_COMP r_TAX r_SURPLUS r_INPUTS r_ENER r_MAT r_SERVICE r_GO_GDP r_VA_GDP r_COMP_GDP r_TAX_GDP r_SURPLUS_GDP r_INPUTS_GDP r_ENER_GDP r_MAT_GDP r_SERVICE_GDP

save "/Users/pedroserodio/Dropbox/Working folder/Papers/Cyclicality of R&D at the Firm Level/Data files/BEA_ValueAdded.dta", replace
