use "/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/[rnd] multiple_imputation_[37.1-9].dta"

mi set mlong

mi register imputed r_sum_371_379_t r_sum_371_379_c r_sum_371_379_f r_sic_37_t r_sic_37_c r_sic_37_f

mi register regular r_all_ind_t r_all_ind_c r_all_ind_f r_sic_c_372_376_t r_sic_c_372_376_c r_sic_c_372_376_f

mi set M=100

mi impute mvn r_sum_371_379_t r_sum_371_379_c r_sum_371_379_f r_sic_37_t r_sic_37_c = r_all_ind_t r_all_ind_c r_all_ind_f r_sic_c_372_376_t r_sic_c_372_376_c r_sic_c_372_376_f, noconstant replace rseed(4000)

mi estimate, saving("/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/c_371_379_mi.ster", replace) : reg r_sum_371_379_c r_sum_371_379_t r_sic_37_t r_sic_37_c r_all_ind_t r_all_ind_c r_all_ind_f r_sic_c_372_376_t r_sic_c_372_376_c r_sic_c_372_376_f, nocons

mi predict mi_c_371_379 using "/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/c_371_379_mi.ster", xb
