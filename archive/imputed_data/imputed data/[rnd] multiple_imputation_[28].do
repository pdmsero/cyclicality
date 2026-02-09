use "/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/[rnd] multiple_imputation_[28].dta"

mi set mlong

mi register imputed  r_sic_28_t r_sic_28_f 

mi register regular r_sic_28_c r_all_ind_t r_all_ind_c r_all_ind_f

mi set M=100

mi impute mvn r_sic_28_t r_sic_28_f = r_sic_28_c r_all_ind_t r_all_ind_c r_all_ind_f, noconstant replace rseed(4000)

mi estimate, saving("/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/f_28_mi.ster", replace) : reg r_sic_28_f r_sic_28_t r_sic_28_c r_all_ind_t r_all_ind_c r_all_ind_f, nocons

mi predict mi_f_28 using "/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/f_28_mi.ster", xb
