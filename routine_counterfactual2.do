* MRes Thesis Project: Changing Job Composition in the UK since 2000
* Routine Counterfactual
* Matthew Nibloe
* 31/08/21

cd "/Users/mattnibloe/Documents/MRes UCL 2020-2021/Dissertation/Changing job composition in the UK/APS"


forvalues i = 1(1)1{
	local k = `i' + 1
	forvalues j = `k'(1)17{
		
		local nn = 100 // number of kernel observations
		
		* loading in the panel
		use "Data/Final/panel.dta", clear 
		
		* selecting relevant variables 
		keep WAVE LRWAGE AGE SEX TASK  ROUTINE WEIGHT PUBLICR
		drop if AGE <= 25 // as living wage only affects those aged 25 and over
		drop if  WAVE !=`i' & WAVE !=`j' //keeping track of only relevant waves for analysis
		
		* creating identifier for base and final year
		gen YEAR`j' = 1 if WAVE == `j' 
		replace YEAR`j' = 0 if WAVE == `i'
		
	
		summ ROUTINE if WAVE ==`j'
		****
		return list
		gen ROUTINE`i' = r(mean)
		
		* creaing the weights
		probit ROUTINE SEX AGE [pweight = WEIGHT] if WAVE ==`i'
		predict proutine`i', p 
		sum proutine`i', detail
		*generating prob routine=1 in wave `i'*
		
		probit ROUTINE SEX AGE   [pweight = WEIGHT] if WAVE ==`j'
		predict proutine`j', p 
		sum proutine`j', detail
		*generating prob routine=1 in wave `j'*
		
		generate weightroutineCF = [ROUTINE]*[(proutine`i')/(proutine`j')] + [1 - ROUTINE]*[(1-proutine`i')/(1 - proutine`j')]
		sum weightroutineCF, detail
		
		* distribution at j 
		summ LRWAGE [aweight = WEIGHT], detail
		gen xstep=(r(max)-r(min))/`nn' // simplify the Kernel estimate by using only 200 values
		gen kwage =r(min)+(_n-1)*xstep if _n<=`nn' //generating the wage at which the density is estimated
		kdensity LRWAGE [aweight= WEIGHT] if WAVE==`j', at(kwage) gauss gen(w`j' fd`j') nograph
		label var fd`j' "Density of wages at wave `j'"
		label var  kwage "Ln(Real Wage)" 
		
		* counterfactual distribution
		gen CFweight = weight*weightroutineCF
		
		
		kdensity LRWAGE [aweight= CFweight] if WAVE==`j', at(kwage) gauss gen(w`j'x`i' fd`j'x`i') nograph
		label var fd`j'x`i' "Density of wages at wave `j' given minimum wage binding as in `i'"
		
		
			gen kwage_`i' = kwage 
			keep kwage_`i' fd`j' fd`j'x`i' w`j'x`i'
			
			
			*generating means of the distribution and counterfactual distribution
			egen denom = sum(fd`j')
			egen cfdenom = sum(fd`j'x`i')
			egen num = sum(fd`j'*kwage)
			egen cfnum = sum(fd`j'x`i'*kwage)
			gen mean_`j'_`q' = num/denom
			gen mean_`j'x`i'_`q' = cfnum/cfdenom
			gen diff = mean_`j'_`q' - mean_`j'x`i'_`q'
			gen WAVE = `j'
			summ kwage 

			
			integ fd`j'x`i' w`j'x`i', generate(cintcf)
			gen cent10cf=w`j'x`i' if cintcf>.1 & cintcf[_n-1]<.1 & cintcf~=.
			sum cent10cf
			gen d10cf=r(mean)
			gen centcf90=w`j'x`i' if cintcf>.9 & cintcf[_n-1]<.9 & cintcf~=.
			sum centcf90
			gen d90cf=r(mean)
			gen centcf50=w`j'x`i' if cintcf>.5 & cintcf[_n-1]<.5 & cintcf~=.
			sum centcf50
			gen d50cf=r(mean)
			gen d9010cf=d90cf-d10cf 
			di d9010cf
			gen d9050cf=d90cf-d50cf
			di d9050cf
			gen d5010cf=d50cf-d10cf 
			di d5010cf
			di d90cf
			di d50cf
			di d10cf


			integ fd`j' w`j', generate(cint)
			gen cent10=w`j' if cint>.1 & cint[_n-1]<.1 & cint~=.
			sum cent10
			gen d10=r(mean)
			gen cent90=w`j' if cint>.9 & cint[_n-1]<.9 & cint~=.
			sum cent90
			gen d90=r(mean)
			gen cent50=w`j' if cint>.5 & cint[_n-1]<.5 & cint~=.
			sum cent50
			gen d50=r(mean)
			gen d9010=d90-d10 
			di d9010
			gen d9050=d90-d50 
			di d9050
			gen d5010=d50-d10 
			di d5010
			di d90
			di d50
			di d10
			
			
			

			keep WAVE mean_`j'_`q' mean_`j'x`i'_`q' diff  d50 d90 d10 d50cf d90cf d10cf 

			drop if _n > 1
			
			local l = `j' -  `i' + 2 // local variable for where to export matrix
			
			export excel using "Data/Final/routine_counterfactuals2.xls", sheet(`i') sheetmodify cell("A`l'")
		

	}
}


import excel "/Users/mattnibloe/Documents/MRes UCL 2020-2021/Dissertation/Changing job composition in the UK/APS/Data/Final/routine_counterfactuals2.xls", sheet("1") firstrow clear

gen YEAR = _n + 2003 

tsset YEAR

gen P9010_diff = (P90 - P10) - (P90_CF - P10_CF)
gen P9010_diff_norm = P9010_diff - P9010_diff[1]

label variable DIFF "Mean Wage"

graph twoway tsline DIFF , ytitle("") ytitle("Percentage Growth") legend(cols(1)) title("Counterfactual Log Real Wage Growth Given Constant Routine Task Employment Share") scale(0.6) tlabel(2005(2)2021) // nodraw






