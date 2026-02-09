*use "/Users/pedroserodio/Dropbox/Working folder/Papers/Cyclicality of R&D at the Firm Level/Data files/NBER_EXPORTS_RawFile.dta", clear
use "C:\Users\Economics\Dropbox\Working folder\Ongoing Projects\Papers\Cyclicality of R&D at the Firm Level\Data files\NBER_EXPORTS_RawFile.dta", clear

xtset sic year

gen r_vadd=vadd/piship
gen r_vship=vship/piship
gen r_exports=exports/piship

gen d_vadd=ln(r_vadd)-ln(l.r_vadd)
gen d_vship=ln(r_vship)-ln(l.r_vship)
gen d_exports=ln(r_exports)-ln(l.r_exports)

drop emp_ind pay prode prodh prodw matcost invest invent energy cap equip plant pimat pien r_vadd r_vship r_exports

save "C:\Users\Economics\Dropbox\Working folder\Ongoing Projects\Papers\Cyclicality of R&D at the Firm Level\Data files\NBER_EXPORTS.dta", replace
*save "/Users/pedroserodio/Dropbox/Working folder/Papers/Cyclicality of R&D at the Firm Level/Data files/NBER_EXPORTS.dta", replace
