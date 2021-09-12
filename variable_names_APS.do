* MRes Thesis Project: Changing Job Composition in the UK since 2000
* Variable Names
* Matthew Nibloe
* 31/08/21

cd "/Users/mattnibloe/Documents/MRes UCL 2020-2021/Dissertation/Changing job composition in the UK/APS"

*4 5 9 10 
*HOURPAY = hourpay
*PAIDHRA = paidhra
*SOC = sc2kmmn
*PUBLICR = publicr
*AGE = age
*GOVTOF = govtof (government office region)
*SEX = sex

foreach n of numlist 4/5 {
	use "Data/Raw/`n'.dta", clear 
	rename hourpay HOURPAY
	rename paidhra PAIDHRA
	rename publicr PUBLICR
	rename sc2kmmn SOC
	rename age AGE
	rename govtof GOVTOF
	rename sex SEX
	rename PWAPSA14 WEIGHT 
	rename self1 SELF1
	save "Data/Raw/`n'_intermediate.dta", replace
}

*6 7 8 
*HOURPAY = Y
*PAIDHRA = Y 
*SOC = SC2KMMN
*PUBLICR = Y
*AGE = Y
*GOVTOF = Y 
*SEX = Y 

foreach n of numlist 6/8{
	use "Data/Raw/`n'.dta", clear 
	rename SC2KMMN SOC
	rename PWTA14 WEIGHT 
	save "Data/Raw/`n'_intermediate.dta", replace
}

foreach n of numlist 9/10 {
	use "Data/Raw/`n'.dta", clear 
	rename hourpay HOURPAY
	rename paidhra PAIDHRA
	rename publicr PUBLICR
	rename sc2kmmn SOC
	rename age AGE
	rename govtof GOVTOF
	rename sex SEX
	rename PWTA14 WEIGHT 
	rename self1 SELF1
	save "Data/Raw/`n'_intermediate.dta", replace
}



*11
*HOURPAY = hourpay
*PAIDHRA = paidhra
*SOC = sc2kmmn
*PUBLICR = publicr
*AGE = age
*GOVTOF = govtof (government office region)
*SEX = sex
*GOVTOF = govtof
*SEX = sex 

foreach n of numlist 11{
	use "Data/Raw/`n'.dta", clear 
	rename hourpay HOURPAY
	rename paidhra PAIDHRA 
	rename publicr PUBLICR
	rename sc10mmn SOC 
	rename age AGE 
	rename govtof GOVTOF
	rename sex SEX
	rename PWTA14 WEIGHT 
	rename self1 SELF1
	save "Data/Raw/`n'_intermediate.dta", replace
}


*12 13 14 15 16 17 18 19 20 
*HOURPAY = Y
*PAIDHRA = Y 
*SOC = SC10MMN
*PUBLICR = Y
*AGE = Y
*GOVTOF = Y 
*SEX = Y 

foreach n of numlist 12/20{
	use "Data/Raw/`n'.dta", clear 
	rename SC10MMN SOC
	rename PWTA18 WEIGHT
	save "Data/Raw/`n'_intermediate.dta", replace
}
