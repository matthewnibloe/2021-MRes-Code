* MRes Thesis Project: Changing Job Composition in the UK since 2000
* NMW Counterfactuals
* Matthew Nibloe
* 31/08/21

cd "/Users/mattnibloe/Documents/MRes UCL 2020-2021/Dissertation/Changing job composition in the UK/APS"

forvalues q = 1(1)4{
	forvalues i = 8(1)8 {
		local k = `i' + 1
		forvalues j = `k'(1)17 {
			
			local nn = 100 // number of kernel observations
			
			* loading in the panel
			use "Data/Final/panel.dta", clear 
			
			* selecting relevant variables 
			keep WAVE LRWAGE AGE SEX TASK LRNMW WEIGHT
			drop if AGE <= 25 // as living wage only affectsthose aged 25 and over
			drop if  WAVE !=`i' & WAVE !=`j' //keeping track of only relevant waves and taks for analysis
			keep if TASK == `q'
			
			* creating identifier for base and final year
			gen YEAR`j' = 1 if WAVE == `j' 
			replace YEAR`j' = 0 if WAVE == `i'
			
			* creating identifier of whether wage is below NMW or not
			summ LRNMW if WAVE ==`j'
			****
			return list
			gen NMW`i' = r(mean)
			gen NMW`i'binds =1 if LRWAGE <= NMW`i'
			recode NMW`i'binds .=0 
			
			* creaing the weights
			probit YEAR AGE SEX [pweight = WEIGHT] if NMW`i'binds ==1
			predict probNMWyear`j'
			gen probNMWyear`i' = 1 - probNMWyear`j' // generating probability that year is equal to `j' and the prob that the year is equal to `j' given that wages are at least the same as in `i'
			gen NMWweight = probNMWyear`i' / probNMWyear`j' // the first part of the weighting factor in equation 19 of DFL	
			probit YEAR AGE SEX [pweight = WEIGHT]
			predict probyear`j', p 
			gen probyear`i' = 1 - probyear`j' // generating probability that year is equal to `j' and the prob that the year is equal to `j'
			gen yearweight = probyear`i'/probyear`j' // the second part of the weighting factor in equation 19 of DFL paper*
			gen newweight = NMWweight*yearweight // generating the weighting factor as in equation 19 of DFL
			
			* distribution at j 
			summ LRWAGE [aweight = WEIGHT], detail
			gen xstep=(r(max)-r(min))/`nn' // simplify the Kernel estimate by using only nn values
			gen kwage =r(min)+(_n-1)*xstep if _n<=`nn' //generating the wage at which the density is estimated
			kdensity LRWAGE [aweight= WEIGHT] if WAVE==`j', at(kwage) gauss gen(w`j' fd`j') nograph
			label var fd`j' "Density of wages at wave `j'"
			label var  kwage "Ln(Real Wage)" 
			
			* counterfactual distribution
			gen finalweight = newweight*WEIGHT if NMW`i'binds == 1
			replace finalweight = WEIGHT if NMW`i'binds ==0
			kdensity LRWAGE [aweight= finalweight] if WAVE==`j', at(kwage) gauss gen(w`j'x`i' fd`j'x`i') nograph
			label var fd`j'x`i' "Density of wages at wave `j' given minimum wage binding as in `i'"
			

			gen kwage_`i' = kwage 
			keep kwage_`i' fd`j' fd`j'x`i' 
			
			
			*generating means of the distribution and counterfactual distribution
			egen denom = sum(fd`j')
			egen cfdenom = sum(fd`j'x`i')
			egen num = sum(fd`j'*kwage)
			egen cfnum = sum(fd`j'x`i'*kwage)
			gen mean_`j'_`q' = num/denom
			gen mean_`j'x`i'_`q' = cfnum/cfdenom
			gen diff = mean_`j'_`q' - mean_`j'x`i'_`q'
			gen WAVE = `j'
			
			if `q' == 1{
				keep WAVE mean_`j'_`q' mean_`j'x`i'_`q' diff
			}
			else if `q' != 1{
				keep mean_`j'_`q' mean_`j'x`i'_`q' diff
			}
			
			drop if _n > 1
			
			local l = `j' -  `i' + 1 // local variable for where to export matrix
			
			if `q' == 1{
				local row = "A"
			}
			else if `q' == 2{
				local row = "E"
			}
			else if `q' == 3{
				local row = "H"
			}
			else if `q' == 4{
				local row = "K"
			}
			
			export excel using "Data/Final/nmw_counterfactuals.xls", sheet(1) sheetmodify cell("`row'`l'")
			

		}
	}
}






