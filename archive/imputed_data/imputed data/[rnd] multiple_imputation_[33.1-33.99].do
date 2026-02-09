use "/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/[rnd] multiple_imputation_[33.1-33.99].dta"

mi set mlong

mi register imputed  r_sic_c_331_332_3398_3399_t r_sic_c_331_332_3398_3399_c r_sic_c_331_332_3398_3399_f r_sic_33_t r_sic_33_f

mi register regular  r_all_ind_t r_all_ind_c r_all_ind_f r_sic_33_c

mi set M=100

mi impute mvn r_sic_c_331_332_3398_3399_t r_sic_c_331_332_3398_3399_c r_sic_c_331_332_3398_3399_f r_sic_33_t r_sic_33_f = r_all_ind_t r_all_ind_c r_all_ind_f r_sic_33_c, noconstant replace rseed(4000)

mi estimate, saving("/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/c_331_332_3398_3399_mi.ster", replace) : reg r_sic_c_331_332_3398_3399_c r_sic_c_331_332_3398_3399_f r_sic_c_331_332_3398_3399_t r_sic_33_t r_sic_33_c r_sic_33_f r_all_ind_t r_all_ind_c r_all_ind_f, nocons

mi predict mi_c_331_332_3398_3399 using "/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/c_331_332_3398_3399_mi.ster", xb

use "/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/[rnd] multiple_imputation_[33.1-33.99].dta"

mi set mlong

mi register imputed  r_sic_c_333Ð336_t r_sic_c_333Ð336_c r_sic_c_333Ð336_f r_sic_33_t r_sic_33_f

mi register regular  r_all_ind_t r_all_ind_c r_all_ind_f r_sic_33_c

mi set M=100

mi impute mvn r_sic_c_333Ð336_t r_sic_c_333Ð336_c r_sic_c_333Ð336_f r_sic_33_t r_sic_33_f = r_all_ind_t r_all_ind_c r_all_ind_f r_sic_33_c, noconstant replace rseed(4000)

mi estimate, saving("/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/c_333Ð336_mi.ster", replace) : reg r_sic_c_333Ð336_c r_sic_c_333Ð336_f r_sic_c_333Ð336_t r_sic_33_t r_sic_33_c r_sic_33_f r_all_ind_t r_all_ind_c, nocons

mi predict mi_c_333Ð336 using "/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/imputed data/c_333Ð336_mi.ster", xb
