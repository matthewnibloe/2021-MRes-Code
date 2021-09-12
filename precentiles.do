* MRes Thesis Project: Changing Job Composition in the UK since 2000
* Percentiles
* Matthew Nibloe
* 23/06/21

* setting project working directory
cd "/Users/mattnibloe/Documents/MRes UCL 2020-2021/Dissertation/Changing job composition in the UK/APS"

* loading the LONG panel
use "Data/Final/panel.dta", clear
keep LRWAGE WEIGHT WAVE // keeping relevant variables

* selecting number of quantiles
local quantiles = 100 

* percentiles at each wave
forvalues i = 1(1)17{
	pctile pct`i' = LRWAGE [aweight=WEIGHT] if WAVE == `i', nq(`quantiles') // generating percentiles by wave
}

* perentiles wage change between waves i and j 
forvalues i = 1(1)16{
	local k = `i' + 1
	local x = `i'+ 2003
	local y = `j'+ 2003
	forvalues j = `k'(1)17{
			gen pct_diff_`i'_`j' = pct`j'- pct`i'
			label variable pct_diff_`i'_`j' "Percentage change in wages accross the distribution between years `x' and `y'"
	}
}

* formatting results
drop LRWAGE WEIGHT WAVE // dropping redundant variables
gen QUANTILE = _n/`quantiles' // creating a variable indicating quantiles
drop if _n >= `quantiles' // dropping null observations

* saving formatted results
save "Data/final/percentiles.dta", replace

twoway (connected pct_diff_8_17 QUANTILE) (connected pct_diff_1_8 QUANTILE), ytitle("Log Real Wage Growth") xtitle("Quantile") legend(cols(1)) title("Log Real Hourly Wage Growth between 2003-2010 and 2011-2020") scale(0.6)






