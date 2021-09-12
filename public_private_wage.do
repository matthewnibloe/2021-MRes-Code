* MRes Thesis Project: Changing Job Composition in the UK since 2000
* APS Job Decompositions
* Matthew Nibloe
* 31/08/21


cd "/Users/mattnibloe/Documents/MRes UCL 2020-2021/Dissertation/Changing job composition in the UK/APS"

use "Data/Final/panel.dta", clear

gen N = 1 

drop if PUBLICR ==. | SOC_2DIGIT ==.

gen ID = "a"+string(SOC_2DIGIT)+string(PUBLICR)

collapse (mean) LRWAGE (count) N [aweight = WEIGHT], by(ID WAVE)

reshape wide LRWAGE N, i(WAVE) j(ID) string

gen YEAR = _n + 2003
tsset YEAR

foreach var of varlist *{
	gen `var'_norm = `var' - `var'[8]
	gen norm_`var' = d.`var'
}


order *, alphabetic



drop if _n <= 8 

reshape long norm_LRWAGEa, i(WAVE) j(ID)
keep  WAVE norm_LRWAGEa ID
sort ID WAVE
tostring ID, replace force
gen  PUBLIC = substr(ID,3,1) 
destring PUBLIC, replace force
destring ID, replace force 
drop if ID > 400

xtset WAVE ID

reg norm_LRWAGEa PUBLIC, nocons


preserve



*foreach i in 11 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92{
*	local a = 2
*	local b = 1
*	gen Public_`i' = 100*(Na`i'`a')/(Na`i'`a' + Na`i'`b')
*	gen LRWAGE_`i' = (LRWAGEa`i'1*Na`i'1 + LRWAGEa`i'2*Na`i'2)/(Na`i'2+ Na`i'1)
*} 
*
*
*foreach i in 11 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92{
*	local a = 2
*	local b = 1
*	drop Na`i'`a'
*	drop Na`i'`b'
*	drop Na`i'`a'_norm
*	drop Na`i'`b'_norm
*	drop LRWAGEa`i'`a'
*	drop LRWAGEa`i'`b'
*	drop LRWAGEa`i'`a'_norm
*	drop LRWAGEa`i'`b'_norm
*} 
*drop WAVE_norm

*foreach var of varlist *{
*	gen diff_`var' = d.`var'
*}

*reshape long diff_LRWAGE_ LRWAGE_ Public_ diff_Public_, i(WAVE) j(ID)
*sort ID WAVE
*rename diff_LRWAGE_ LRWAGE_DIFF
*rename LRWAGE_ LRWAGE
*rename Public_  PUBLIC
*rename diff_Public PUBLIC_DIFF
*drop if _n < 8
*reg LRWAGE_DIFF PUBLIC, nocons

restore


drop if _n < 8 


label variable LRWAGEa111_norm "Public Corporate"
label variable LRWAGEa121_norm "Public Other"

label variable LRWAGEa211_norm "Public Science"
label variable LRWAGEa221_norm "Public Healthcare"
label variable LRWAGEa231_norm "Public Teaching"
label variable LRWAGEa241_norm "Public Business"

label variable LRWAGEa311_norm "Public Science"
label variable LRWAGEa321_norm "Public Healthcare"
label variable LRWAGEa331_norm "Public Protective Services"
label variable LRWAGEa341_norm "Public Culture"
label variable LRWAGEa351_norm "Public Business"

label variable LRWAGEa112_norm "Private Corporate"
label variable LRWAGEa122_norm "Private Other"

label variable LRWAGEa212_norm "Private Science"
label variable LRWAGEa222_norm "Private Healthcare"
label variable LRWAGEa232_norm "Private Teaching"
label variable LRWAGEa242_norm "Private Business"

label variable LRWAGEa312_norm "Private Science"
label variable LRWAGEa322_norm "Private Healthcare"
label variable LRWAGEa332_norm "Private Protective Services"
label variable LRWAGEa342_norm "Private Culture"
label variable LRWAGEa352_norm "Private Business"

* Managers

graph twoway tsline LRWAGEa111_norm LRWAGEa112_norm, ytitle("Real Wage Growth") xtitle("") legend(cols(1)) title(" Real Hourly Wage Percentage Growth by Corporate Managers (indexed at 2011)") scale(0.6) tlabel(2011(2)2020)   

graph twoway tsline LRWAGEa121_norm LRWAGEa122_norm, ytitle("Real Wage Growth") xtitle("") legend(cols(1)) title(" Real Hourly Wage Percentage Growth by Other Managers (indexed at 2011)") scale(0.6) tlabel(2011(2)2020)   

* Professionals 

graph twoway tsline LRWAGEa211_norm LRWAGEa212_norm, ytitle("Real Wage Growth") xtitle("") legend(cols(1)) title(" Real Hourly Wage Percentage Growth by Science Professionals (indexed at 2011)") scale(0.6) tlabel(2011(2)2020)  

graph twoway tsline LRWAGEa221_norm LRWAGEa222_norm, ytitle("Real Wage Growth") xtitle("") legend(cols(1)) title(" Real Hourly Wage Percentage Growth by Healthcare Professionals (indexed at 2011)") scale(0.6) tlabel(2011(2)2020)  

graph twoway tsline LRWAGEa231_norm LRWAGEa232_norm, ytitle("Real Wage Growth") xtitle("") legend(cols(1)) title(" Real Hourly Wage Percentage Growth by Teaching Professionals (indexed at 2011)") scale(0.6) tlabel(2011(2)2020) 

graph twoway tsline LRWAGEa241_norm LRWAGEa242_norm, ytitle("Real Wage Growth") xtitle("") legend(cols(1)) title(" Real Hourly Wage Percentage Growth by Business Professionals (indexed at 2011)") scale(0.6) tlabel(2011(2)2020) 

* Associate Professionals


graph twoway tsline LRWAGEa311_norm LRWAGEa312_norm, ytitle("Real Wage Growth") xtitle("") legend(cols(1)) title(" Real Hourly Wage Percentage Growth by Science Associate Professionals (indexed at 2011)") scale(0.6) tlabel(2011(2)2020)  

graph twoway tsline LRWAGEa321_norm LRWAGEa322_norm, ytitle("Real Wage Growth") xtitle("") legend(cols(1)) title(" Real Hourly Wage Percentage Growth by Healthcare Associate Professionals (indexed at 2011)") scale(0.6) tlabel(2011(2)2020)  

graph twoway tsline LRWAGEa331_norm LRWAGEa332_norm, ytitle("Real Wage Growth") xtitle("") legend(cols(1)) title(" Real Hourly Wage Percentage Growth by Protective Service Professionals (indexed at 2011)") scale(0.6) tlabel(2011(2)2020) 

graph twoway tsline LRWAGEa351_norm LRWAGEa352_norm, ytitle("Real Wage Growth") xtitle("") legend(cols(1)) title(" Real Hourly Wage Percentage Growth by Business Professionals (indexed at 2011)") scale(0.6) tlabel(2011(2)2020) 







