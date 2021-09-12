* MRes Thesis Project: Changing Job Composition in the UK since 2000
* NMW motivation
* Matthew Nibloe
* 31/08/21

cd "/Users/mattnibloe/Documents/MRes UCL 2020-2021/Dissertation/Changing job composition in the UK/APS"

use "Data/Final/panel.dta", clear

bysort  WAVE TASK :  egen MEAN = mean(LRWAGE) // mean wage
bysort WAVE: egen P90 = pctile(LRWAGE), p(90) // 90 percentile wage
bysort WAVE: egen P50 = pctile(LRWAGE), p(50) // 50 percentile wage
bysort WAVE: egen P10 = pctile(LRWAGE), p(10) // 10 percentile wage

collapse P10 P50 P90 LRNMW MEAN, by(WAVE TASK)
drop if TASK ==.

xtset WAVE TASK

reshape wide P10 P50 P90 LRNMW MEAN, i(WAVE) j(TASK)

foreach x in P101 P501 P901 LRNMW1 MEAN1 MEAN2 MEAN3 MEAN4{
	gen `x'_norm = `x' - `x'[1]
}

gen YEAR = _n +2003

tsset YEAR

label variable P101_norm "10th percentile wages"
label variable P501_norm "50th percentile wages"
label variable P901_norm "90th percentile wages"
label variable MEAN2_norm "Non-routine manual wages"
label variable MEAN3_norm "Routine manual wages"
label variable MEAN4_norm "Routine cognitive wages"
label variable LRNMW1_norm "NMW"

estpost corr LRNMW1_norm P101_norm P501_norm P901_norm MEAN1_norm MEAN2_norm MEAN3_norm MEAN4_norm, matrix listwise
eststo correlation
esttab correlation using Data/Final/nmw_correlations.dta, replace




*** MOTIVATION FIGURE

graph twoway tsline P101_norm MEAN2_norm MEAN3_norm MEAN4_norm LRNMW1_norm, ytitle("Percentage Growth") xtitle("") legend(cols(1)) title("Percentage Wage Growth Normalised at 2004") tlabel(2004(2)2020) scale(0.6)


*** COUNTERFACTUAL FIGURE

import excel "/Users/mattnibloe/Documents/MRes UCL 2020-2021/Dissertation/Changing job composition in the UK/APS/Data/Final/nmw_counterfactuals.xls", sheet("1") firstrow clear

label variable DIFF_1 "Non-routine Cognitive"
label variable DIFF_2 "Non-routine Manual"
label variable DIFF_3 "Routine Manual"
label variable DIFF_4 "Routine Cognitive"

gen YEAR = _n +2010

tsset YEAR

graph twoway tsline DIFF_1 DIFF_2 DIFF_3 DIFF_4, ytitle("Percentage Difference") xtitle("") legend(cols(1)) title("Percentage Wage Difference Between Observed and Counterfactual Wages") tlabel(2011(1)2020) scale(0.6)










