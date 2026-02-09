use "/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/[rnd] multiple_imputation_[30].dta"

mi set mlong

mi register imputed  r_sic_30_t r_sic_30_c r_sic_30_f g_r_sic_30_t g_r_sic_30_c g_r_sic_30_f

mi register regular r_all_ind_t r_all_ind_c r_all_ind_f g_r_all_ind_t g_r_all_ind_c g_r_all_ind_f

mi set M=100

mi impute mvn g_r_sic_30_c g_r_sic_30_t g_r_sic_30_f = r_all_ind_t r_all_ind_c g_r_all_ind_t g_r_all_ind_c g_r_all_ind_f, noconstant force replace rseed(4000)

mi estimate, saving("/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/g_c_30_mi.ster", replace) : reg g_r_sic_30_c g_r_sic_30_t g_r_sic_30_f g_r_all_ind_t g_r_all_ind_c, nocons

mi predict mi_g_c_30 using "/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/g_c_30_mi.ster", xb

mi estimate, saving("/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/c_30_mi.ster", replace) : reg r_sic_30_c r_sic_30_f r_sic_30_t g_r_all_ind_t r_all_ind_c, nocons

mi predict mi_c_30 using "/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/c_30_mi.ster", xb
