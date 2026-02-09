use "/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/[rnd] multiple_imputation_[283].dta"

mi set mlong

mi register imputed  r_sic_c_283_t r_sic_c_283_c r_sic_c_283_f r_sic_28_t r_sic_28_f

mi register regular  r_all_ind_t r_all_ind_c r_all_ind_f r_sic_28_c

mi set M=100

mi impute mvn r_sic_c_283_t r_sic_c_283_c r_sic_c_283_f r_sic_28_t r_sic_28_f = r_all_ind_t r_all_ind_c r_all_ind_f r_sic_28_c, noconstant replace rseed(4000)

mi estimate, saving("/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/f_283_mi.ster", replace) : reg r_sic_c_283_c r_sic_c_283_f r_sic_c_283_t r_sic_28_t r_sic_28_c r_sic_28_f r_all_ind_t r_all_ind_c r_all_ind_f, nocons

mi predict mi_f_283 using "/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/f_283_mi.ster", xb
