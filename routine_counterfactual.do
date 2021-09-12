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
		keep WAVE LRWAGE AGE SEX TASK  ROUTINE WEIGHT
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
		probit YEAR AGE SEX TASK [pweight = WEIGHT] if ROUTINE ==1
		predict probR_year`j'
		gen probR_year`i' = 1 - probR_year`j' // generating probability that year is equal to `j' and the prob that the year is equal to `j' given that wages are at least the same as in `i'
		gen Rweight = probR_year`i' / probR_year`j' // the first part of the weighting factor in equation 19 of DFL	
		probit YEAR AGE SEX TASK [pweight = WEIGHT]
		predict probyear`j', p 
		gen probyear`i' = 1 - probyear`j' // generating probability that year is equal to `j' and the prob that the year is equal to `j'
		gen yearweight = probyear`i'/probyear`j' // the second part of the weighting factor in equation 19 of DFL paper*
		gen newweight = Rweight*yearweight // generating the weighting factor as in equation 19 of DFL
		
		* distribution at j 
		summ LRWAGE [aweight = WEIGHT], detail
		gen xstep=(r(max)-r(min))/`nn' // simplify the Kernel estimate by using only 200 values
		gen kwage =r(min)+(_n-1)*xstep if _n<=`nn' //generating the wage at which the density is estimated
		kdensity LRWAGE [aweight= WEIGHT] if WAVE==`j', at(kwage) gauss gen(w`j' fd`j') nograph
		label var fd`j' "Density of wages at wave `j'"
		label var  kwage "Ln(Real Wage)" 
		
		* counterfactual distribution
		gen finalweight = newweight*WEIGHT if ROUTINE == 1
		replace finalweight = WEIGHT if ROUTINE ==0
		kdensity LRWAGE [aweight= finalweight] if WAVE==`j', at(kwage) gauss gen(w`j'x`i' fd`j'x`i') nograph
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
			
			local l = `j' -  `i' + 1 // local variable for where to export matrix
			
			export excel using "Data/Final/routine_counterfactuals.xls", sheet(`i') sheetmodify cell("A`l'")
		

	}
}
