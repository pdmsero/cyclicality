use "/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/[rnd] multiple_imputation_[22+23].dta"

mi set mlong

mi register imputed  r_sic_22_23_t r_sic_22_23_c r_sic_22_23_f g_r_sic_22_23_t g_r_sic_22_23_c g_r_sic_22_23_f

mi register regular r_all_ind_t r_all_ind_c r_all_ind_f g_r_all_ind_t g_r_all_ind_c g_r_all_ind_f

mi set M=100

mi impute mvn r_sic_22_23_t r_sic_22_23_c g_r_sic_22_23_t g_r_sic_22_23_c = g_r_all_ind_t g_r_all_ind_c, noconstant force replace rseed(4000)

mi estimate, saving("/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/g_c_2223_mi.ster", replace) : reg g_r_sic_22_23_c g_r_sic_22_23_t g_r_all_ind_t g_r_all_ind_c r_sic_22_23_t r_sic_22_23_c, nocons

mi predict mi_g_c_2223 using "/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/g_c_2223_mi.ster", xb

mi impute mvn r_sic_22_23_t r_sic_22_23_c r_sic_22_23_f = r_all_ind_t r_all_ind_c, noconstant force replace rseed(4000)

mi estimate, saving("/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/c_2223_mi.ster", replace) : reg r_sic_22_23_c r_sic_22_23_t r_sic_22_23_f r_all_ind_t r_all_ind_c, nocons

mi predict mi_c_2223_1 using "/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/c_2223_mi.ster", xb
