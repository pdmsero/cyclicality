use "/Users/pedroserodio/Dropbox/Working folder/Papers/Cyclicality of R&D at the Firm Level/Data files/AllCompustat.dta", clear

gen count=_N

merge 1:1 key year using "/Users/pedroserodio/Dropbox/Working folder/Papers/Cyclicality of R&D at the Firm Level/Data files/StockMarketData.dta"

drop if _merge==2
drop _merge

gen naics3 = substr(naics, 1, 3)

. gen code=1 if naics3 == "111"
. replace code=1 if naics3 == "112"

. replace code=2 if naics3 == "113"
. replace code=2 if naics3 == "114"
. replace code=2 if naics3 == "115"

. replace code=3 if naics3 == "211"

. replace code=4 if naics3 == "212"

. replace code=5 if naics3 == "213"

. replace code=6 if naics3 == "221"

. replace code=7 if naics3 == "233"

. replace code=8 if naics3 == "311"
. replace code=8 if naics3 == "312"

. replace code=9 if naics3 == "313"
. replace code=9 if naics3 == "314"

. replace code=10 if naics3 == "315"
. replace code=10 if naics3 == "316"

. replace code=11 if naics3 == "321"

. replace code=12 if naics3 == "322"

. replace code=13 if naics3 == "323"

. replace code=14 if naics3 == "324"

. replace code=15 if naics3 == "325"

. replace code=16 if naics3 == "326"

. replace code=17 if naics3 == "327"

. replace code=18 if naics3 == "331"

. replace code=19 if naics3 == "332"

. replace code=20 if naics3 == "333"

. replace code=21 if naics3 == "334"

. replace code=22 if naics3 == "335"

. replace code=23 if naics3 == "336"

. replace code=24 if naics3 == "337"

. replace code=25 if naics3 == "339"

. replace code=26 if naics3 == "441"

. replace code=27 if naics3 == "442"
. replace code=27 if naics3 == "443"
. replace code=27 if naics3 == "444"
. replace code=27 if naics3 == "446"
. replace code=27 if naics3 == "447"
. replace code=27 if naics3 == "448"
. replace code=27 if naics3 == "451"
. replace code=27 if naics3 == "453"
. replace code=27 if naics3 == "454"

. replace code=28 if naics3 == "445"

. replace code=29 if naics3 == "452"

. replace code=30 if naics3 == "481"

. replace code=31 if naics3 == "482"

. replace code=32 if naics3 == "483"

. replace code=33 if naics3 == "484"

. replace code=34 if naics3 == "485"

. replace code=35 if naics3 == "486"

. replace code=36 if naics3 == "487"
. replace code=36 if naics3 == "488"
. replace code=36 if naics3 == "492"

. replace code=37 if naics3 == "493"

. replace code=38 if naics3 == "511"

. replace code=39 if naics3 == "512"

. replace code=40 if naics3 == "513"

. replace code=41 if naics3 == "514"

. replace code=42 if naics3 == "521"
. replace code=42 if naics3 == "522"

. replace code=43 if naics3 == "523"

. replace code=44 if naics3 == "524"

. replace code=45 if naics3 == "525"

. replace code=46 if naics3 == "531"

. replace code=47 if naics3 == "532"
. replace code=47 if naics3 == "533"

. replace code=48 if naics3 == "541"

. replace code=49 if naics3 == "561"

. replace code=50 if naics3 == "562"

. replace code=51 if naics3 == "611"

. replace code=52 if naics3 == "621"

. replace code=53 if naics3 == "622"

. replace code=54 if naics3 == "623"

. replace code=55 if naics3 == "624"

. replace code=56 if naics3 == "711"
. replace code=56 if naics3 == "712"

. replace code=57 if naics3 == "713"

. replace code=58 if naics3 == "721"

. replace code=59 if naics3 == "722"

. replace code=60 if naics3 == "811"
. replace code=60 if naics3 == "812"
. replace code=60 if naics3 == "813"
. replace code=60 if naics3 == "814"

drop naics3

merge m:1 code year using "/Users/pedroserodio/Dropbox/Working folder/Papers/Cyclicality of R&D at the Firm Level/Data files/BEA_ValueAdded.dta"

drop NAICS code

drop if _merge==2
drop _merge

destring sic, replace
merge m:1 sic year using "/Users/pedroserodio/Dropbox/Working folder/Papers/Cyclicality of R&D at the Firm Level/Data files/NBER_EXPORTS.dta"

drop if _merge==2
drop _merge

merge m:1 year using "/Users/pedroserodio/Dropbox/Working folder/Papers/Cyclicality of R&D at the Firm Level/Data files/BondYields.dta"

drop if _merge==2
drop _merge

merge m:1 year using "/Users/pedroserodio/Dropbox/Working folder/Papers/Cyclicality of R&D at the Firm Level/Data files/SocialSecurityWageData.dta"

drop if _merge==2
drop _merge

merge m:1 year using "/Users/pedroserodio/Dropbox/Working folder/Papers/Cyclicality of R&D at the Firm Level/Data files/GDPData.dta"

drop if _merge==2
drop _merge

label variable GDP "Nominal Gross Domestic Product"
label variable P_GDP "Gross Domestic Product Deflator"
label variable awi "Average Wage Index, Social Security"

label variable gov_b "Yield on 3-month Government Bonds"
label variable aaa "Yield on AAA-rated Corporate Bonds"
label variable baa "Yield on BAA-rated Corporate Bonds"
label variable aaa_g "Spread, AAA-G"
label variable baa_g "Spread, BAA-G"
label variable baa_aaa "Spread, BAA-AAA"

drop count

save "/Users/pedroserodio/Dropbox/Working folder/Papers/Cyclicality of R&D at the Firm Level/Data files/AllData.dta", replace
