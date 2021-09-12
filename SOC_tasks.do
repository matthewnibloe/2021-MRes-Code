* MRes Thesis Project: Changing Job Composition in the UK since 2000
* Task Changes
* Matthew Nibloe
* 31/08/21

cd "/Users/mattnibloe/Documents/MRes UCL 2020-2021/Dissertation/Changing job composition in the UK/APS"

* importing the 2010 data set 
import excel "Data/External/SOC2010_tasks.xls", sheet("SOC2010 Full Index V7") firstrow clear

* relevant variables
keep UNIQUEID SOC2010 VERSNO

* recoding NEW 
gen NEW_TASK =  strpos(VERSNO, "new") > 0 
drop if VERSNO == "V5 new"
drop if VERSNO == "V6 new"
drop if VERSNO == "V7 new"
// creates a binary variable = 1 if VERSNO contains phrase new (the measure of new tasks) up to ammendment 4 to be consistent with the number of versions of the 2020 SOC released

* one digit SOC classification
destring SOC2010, replace force
gen SOC_1DIGIT = floor( SOC2010/1000 )

* categoriseing new tasks for 2010 
preserve
drop if NEW_TASK == 0 // dropping non-new tasks
drop if SOC_1DIGIT ==. // dropping missing obs
sort SOC_1DIGIT // ordering data
forvalues i = 1/9{
	count if SOC_1DIGIT == `i'
	gen NEW_`i' = r(N)
}
drop if _n > 1 
keep NEW_1 NEW_2 NEW_3 NEW_4 NEW_5 NEW_6 NEW_7 NEW_8 NEW_9
save "Data/Final/new_tasks", replace
restore

* identifying new tasks in 2020 dataset 
keep UNIQUEID SOC2010
save "Data/Raw/2010_tasks", replace
clear
import excel "Data/External/SOC2020_tasks.xls", sheet("SOC2020 coding index V4") firstrow
keep SOC2020 UNIQUEID VERSNO
destring SOC2020, replace force 
gen SOC_1DIGIT = floor( SOC2020/1000 )
gen NEW_TASK =  strpos(VERSNO, "new") > 0 
drop if NEW_TASK == 0 // dropping non-new tasks
drop if SOC_1DIGIT ==. // dropping missing obs
forvalues i = 1/9{
	count if SOC_1DIGIT == `i'
	gen NEW_`i' = r(N)
}
drop if _n > 1 
keep NEW_1 NEW_2 NEW_3 NEW_4 NEW_5 NEW_6 NEW_7 NEW_8 NEW_9

append using "Data/Final/new_tasks"
save "Data/Final/new_tasks", replace







