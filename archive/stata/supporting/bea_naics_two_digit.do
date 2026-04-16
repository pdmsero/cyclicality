use "/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/bea_naics_two_digit.dta"

. gen code=1 if naics == "11"

. replace code=2 if naics == "21"

. replace code=3 if naics == "22"

. replace code=4 if naics == "23"

. replace code=5 if naics == "33.321.327"

. replace code=6 if naics == "31.32-321.327"

. replace code=7 if naics == "42"

. replace code=8 if naics == "44.45"

. replace code=9 if naics == "48.49-491"

. replace code=10 if naics == "51"

. replace code=11 if naics == "52"

. replace code=12 if naics == "53"

. replace code=13 if naics == "54"

. replace code=14 if naics == "55"

. replace code=15 if naics == "56"

. replace code=16 if naics == "61"

. replace code=17 if naics == "62"

. replace code=18 if naics == "71"

. replace code=19 if naics == "72"

. replace code=20 if naics == "81"

rename code code_two

. save "/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/bea_naics_two_digit.dta", replace

use "/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/compustat.dta"

tostring naics, gen (naics2)
gen naics3 = substr(naics, 1, 3)
gen naics2 = substr(naics, 1, 2)

. gen code=1 if naics2 == "11"

. replace code=2 if naics2 == "21"

. replace code=3 if naics2 == "22"

. replace code=4 if naics2 == "23"

. replace code=5 if naics2 == "33"

. replace code=5 if naics3 == "321"

. replace code=5 if naics3 == "327"

. replace code=6 if naics2 == "31"

. replace code=6 if naics3 != "321" & naics3 != "327" & naics2 == "32"

. replace code=7 if naics2 == "42"

. replace code=8 if naics2 == "44"

. replace code=8 if naics2 == "45"

. replace code=9 if naics2 == "48"

. replace code=9 if naics2 == "49" & naics3 != "491"

. replace code=10 if naics2 == "51"

. replace code=11 if naics2 == "52"

. replace code=12 if naics2 == "53"

. replace code=13 if naics2 == "54"

. replace code=14 if naics2 == "55"

. replace code=15 if naics2 == "56"

. replace code=16 if naics2 == "61"

. replace code=17 if naics2 == "62"

. replace code=18 if naics2 == "71"

. replace code=19 if naics2 == "72"

. replace code=20 if naics2 == "81"

rename code code_two

merge m:m code_two year using bea_naics_two_digit.dta

save "/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/[4]_compustat_BEA_2digits.dta"
