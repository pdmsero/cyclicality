use "/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/[rnd] multiple_imputation_[13+29].dta"

mi set mlong

mi register imputed  r_sic_13_29_t r_sic_13_29_c r_sic_13_29_f g_r_sic_13_29_t g_r_sic_13_29_c g_r_sic_13_29_f

mi register regular r_all_ind_t r_all_ind_c r_all_ind_f g_r_all_ind_t g_r_all_ind_c g_r_all_ind_f

mi set M=100

mi impute mvn r_sic_13_29_t r_sic_13_29_c r_sic_13_29_f g_r_sic_13_29_t g_r_sic_13_29_c g_r_sic_13_29_f = r_all_ind_t r_all_ind_c r_all_ind_f g_r_all_ind_t g_r_all_ind_c g_r_all_ind_f, noconstant force replace rseed(4000)

mi estimate, saving("/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/c_13_29_mi.ster", replace) : reg r_sic_13_29_c r_sic_13_29_t r_sic_13_29_f r_all_ind_c r_all_ind_t, nocons

mi predict mi_13_29 using "/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/c_13_29_mi.ster", xb

mi estimate, saving("/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/c_g_13_29_mi.ster", replace) : reg g_r_sic_13_29_c g_r_sic_13_29_t g_r_sic_13_29_f g_r_all_ind_c g_r_all_ind_t, nocons

mi predict mi_g_13_29 using "/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/c_g_13_29_mi.ster", xb
