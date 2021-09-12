* MRes Thesis Project: Changing Job Composition in the UK since 2000
* Creating panel
* Matthew Nibloe
* 31/08/21

** Part 1: Creating the Panel



cd "/Users/mattnibloe/Documents/MRes UCL 2020-2021/Dissertation/Changing job composition in the UK/APS"

include "variable_names_APS.do" 

foreach n of numlist 4/20 {
* looping over each quarter 
	use HOURPAY PAIDHRA SOC PUBLICR AGE SEX WEIGHT SELF1 using  "Data/Raw/`n'_intermediate.dta",clear
* extracting relevant variables
	local yearno = `n'
* generating a local variable to index each wave by year		
	local INDEX = `n' - 3 
* creating a local variable inside the loop to label each data set 
	gen WAVE = `n' - 3
* creating a new variable WAVE to index which wave number this panel represents  (will be used with merge later to introduce the deflator) 
	save "Data/Cleaned/`INDEX'.dta", replace
}

* appending the  observations to create a single long panel
clear
use "Data/Cleaned/1.dta"
foreach n of numlist 2/17 {
	append using "Data/Cleaned/`n'.dta"
}
save "Data/Final/panel.dta", replace

* appending the deflator
import delimited "Data/External/deflator.csv", varnames(1) case(upper) clear
save "Data/External/deflator.dta", replace 
* converting delflator file from csv to dt
use "Data/Final/panel.dta", clear 
merge m:1 WAVE using "Data/External/deflator.dta"
* dropping merge indicator variable 
drop _merge
save "Data/Final/panel.dta", replace

* recoding deflator to 2020 base
gen DEFLATOR2 = DEFLATOR/DEFLATOR[17]
drop DEFLATOR
rename DEFLATOR2 DEFLATOR 


* appending CPI index
import delimited "Data/External/CPI.csv", varnames(1) case(upper) clear
save "Data/External/cpi.dta", replace 
* converting cpi file from csv to dt
use "Data/Final/panel.dta", clear 
merge m:1 WAVE using "Data/External/cpi.dta"
* dropping merge indicator variable 
drop if _merge == 1 | _merge == 2 
drop _merge
save "Data/Final/panel.dta", replace

* appending NMW 
import delimited "Data/External/nmw.csv", varnames(1) case(upper) clear
save "Data/External/nmw.dta", replace 
* converting cpi file from csv to dt
use "Data/Final/panel.dta", clear 
merge m:1 WAVE using "Data/External/nmw.dta"
* dropping merge indicator variable 
drop if _merge == 1 | _merge == 2 
drop _merge
save "Data/Final/panel.dta", replace


* change all 'Don't Know' values to '.'
mvdecode _all, mv(-9/-1)

* log real wage
gen LRWAGE = ln(HOURPAY*100/DEFLATOR)
*  log real NMW
gen LRNMW = ln(NMW*100/DEFLATOR)

* index variable for cases 
gen INDEX = _n // NOT SUITABLE FOR LONGITUDINAL ANALYSIS

* setting panel (n dimension as person ID and t dimensoion as index)
xtset INDEX WAVE


* SOC one digit
gen SOC_1DIGIT = floor( SOC/100 )
recode SOC_1DIGIT 0=. // recoding oto allow for missing observations

* SOC two digit
gen SOC_2DIGIT = floor( SOC/10 )
tostring SOC_2DIGIT, replace  
gen  SOC_2DIGIT_SECOND_DIGIT = substr(SOC_2DIGIT,2,1) // extracting the second digit (use in combination with SOC_1DIGIT to identify profession)
destring SOC_2DIGIT, replace // two digit occupation classification
destring SOC_2DIGIT_SECOND_DIGIT, replace // second digit of 2 digit classifciation
recode SOC_2DIGIT 0=.

* SOC three digit
gen SOC_3DIGIT = SOC
tostring SOC_3DIGIT, replace  
gen  SOC_3DIGIT_LAST_DIGIT = substr(SOC_3DIGIT,3,1) // extracting the second digit (use in combination with SOC_1DIGIT to identify profession)
destring SOC_3DIGIT, replace // two digit occupation classification
destring SOC_3DIGIT_LAST_DIGIT, replace // second digit of 2 digit classifciation
recode SOC_3DIGIT 0=.

* task classifications
gen TASK = SOC_1DIGIT 
recode TASK 1/3=1 4=2 7=2 6=2 8=3 5=4 9=4

* routine indicator
gen ROUTINE = 1 if TASK == 3 | TASK == 4
recode ROUTINE .=0
 

* Age classifications 
gen AGE_BOUND = AGE 
recode AGE_BOUND 16/21=1 22/29=2 30/39=3 40/49=4 50/59=5 50/100=6

* Dropping those below retirement age
keep if AGE < 65 & SEX == 1 | AGE < 60 & SEX == 2

* Removing outliers 
by WAVE, sort: egen p3 = pctile(LRWAGE), p(3)
by WAVE, sort: egen p97 = pctile(LRWAGE), p(97)
keep if inrange(LRWAGE, p3, p97)

drop if SELF1 != .


save "Data/Final/panel.dta", replace

