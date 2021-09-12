** ASHE Data


* Setting working directory 
cd "/Users/mattnibloe/Documents/MRes UCL 2020-2021/Dissertation/Changing job composition in the UK"

* Creating aggregate data set for each year
foreach n of numlist 2003/2020{
	
	* Importing the data 
	import excel "Data/ASHE/agg_inequality.xlsx", sheet(`n') firstrow clear

	* Dropping regional variables
	drop if _n >= 36  

	* year identifier
	gen YEAR = `n'
	
	* turning all data to strings for merge
	tostring *, replace 

	* Saving the data set 
save "Data/ASHE/intermediate_data/agg_inequality_`n'", replace


}

* creating aggregate panel
clear
use "Data/ASHE/intermediate_data/agg_inequality_2003"
foreach n of numlist 2004/2020 {
	append using "Data/ASHE/intermediate_data/agg_inequality_`n'"
}
save "Data/ASHE/agg_panel", replace

* creating coherent code for overall levels
replace CODE = "0" if AREA == "United Kingdom"

* dropping area (rely on code instead)
drop AREA 

* destringing all variables
destring *, force replace 

save "Data/ASHE/agg_panel", replace

* appending deflator
import excel "Data/ASHE/deflator.xls", sheet("FRED Graph") firstrow clear
drop if _n > 18 
save "Data/ASHE/deflator", replace
use "Data/ASHE/agg_panel", clear 
merge m:1 YEAR using "/Users/mattnibloe/Documents/MRes UCL 2020-2021/Dissertation/Changing job composition in the UK/Data/ASHE/deflator.dta"
drop _merge
replace DEFLATOR = 100/DEFLATOR // standardising the deflator

* converting to real values 
foreach i in P50 P90 P10 MEAN{
	replace `i' = ln(`i'*DEFLATOR)
}

* setting panel dimensions
xtset YEAR CODE

* reshaping wide 
reshape wide OBS P50 P10 P90 MEAN, i(YEAR) j(CODE)


* non routine cognitive stats
gen NRC_WEIGHT = OBS1 + OBS2 + OBS3 // total obs for NRC jobs
foreach i in P50 P90 P10 MEAN{
	gen NRC_`i' = (`i'1*OBS1 + `i'2*OBS2 + `i'3*OBS3)/NRC_WEIGHT
	gen NRC_`i'_NORM =  NRC_`i' - NRC_`i'[1]
}

* non routine manual stats
gen RC_WEIGHT = OBS4 + OBS6 + OBS7 // total obs for NRM jobs
foreach i in P50 P90 P10 MEAN{
	gen RC_`i' = (`i'4*OBS4 + `i'6*OBS6 + `i'7*OBS7)/RC_WEIGHT
	gen RC_`i'_NORM =  RC_`i' - RC_`i'[1]
}

* routine manual stats
foreach i in P50 P90 P10 MEAN{
	gen RM_`i' = `i'8
	gen RM_`i'_NORM =  RM_`i' - RM_`i'[1]
}

* non-routine manual stats
gen NRM_WEIGHT = OBS5 + OBS9 // total obs for RC jobs
foreach i in P50 P90 P10 MEAN{
	gen NRM_`i' = (`i'5*OBS5 + `i'9*OBS9)/NRM_WEIGHT
	gen NRM_`i'_NORM =  NRM_`i' - NRM_`i'[1]
}

tsset YEAR // setting time series variable for yearly data
format %ty YEAR







* mean wage figure 


gen MEAN0_NORM = MEAN0 - MEAN0[1] // defining normalised mean real wage 
gen P900_NORM = P900 - P900[1] 
gen P500_NORM = P500 - P500[1] 
gen P100_NORM = P100 - P100[1] 

label variable MEAN0_NORM "Mean"
label variable P900_NORM "P90"
label variable P500_NORM "P50"
label variable P100_NORM "P10"

gen P90P100 = P900 - P100
gen P90P500 = P900 - P500
gen P50P100 = P500 - P100

gen P90P100_NORM = P90P100 - P90P100[1]
gen P90P500_NORM = P90P500 - P90P500[1]
gen P50P100_NORM = P50P100 - P50P100[1]

label variable P90P100_NORM "P90 P10 diff"
label variable P90P500_NORM "P90 P50 diff"
label variable P50P100_NORM "P50 P10 diff"


graph twoway tsline MEAN0_NORM, ytitle("Log Real Wage Growth") xtitle("") legend(cols(1)) title("Log Real Mean Hourly Wage Percentage Growth (indexed at 2002)") scale(0.6) tlabel(2002(2)2021)   saving("Data/ASHE/figure_outputs/fig_1_a_wage_growth_indexed", replace)

graph twoway tsline MEAN0_NORM P900_NORM P500_NORM P100_NORM, ytitle("Percentage Growth") xtitle("") legend(cols(1)) title("Log Real Mean Hourly Wage Percentage Growth (indexed at 2002)") scale(0.6) tlabel(2002(2)2021)   saving("Data/ASHE/figure_outputs/fig_1_a2_wage_growth_indexed_percentiles", replace)

graph twoway tsline P90P100_NORM P90P500_NORM P50P100_NORM, ytitle("Percentage Growth") xtitle("") legend(cols(1)) title("Aggregate inequality measures (indexed at 2002)") scale(0.6) tlabel(2002(2)2021)   saving("Data/ASHE/figure_outputs/fig_1_a3_percentile_inequality", replace)





* mean wage by task figure 

label variable NRC_MEAN_NORM "Non-routine cognitive"
label variable NRM_MEAN_NORM "Non-routine manual"
label variable RC_MEAN_NORM "Routine cognitive"
label variable RM_MEAN_NORM "Routine manual"

graph twoway tsline NRC_MEAN_NORM NRM_MEAN_NORM RC_MEAN_NORM RM_MEAN_NORM, ytitle("Log Real Wage Growth") xtitle("") legend(cols(1)) title("Log Real Hourly Wage Percentage Growth by task (indexed at 2002)") scale(0.6) tlabel(2002(2)2021)   saving("Data/ASHE/figure_outputs/fig_1_b_wage_growth_across_tasks_indexed", replace)





*non-routine cognitive figure (with isolated health)


gen MEAN_2_NO_HEALTH = (MEAN21*OBS21 + MEAN23*OBS23 + MEAN24*OBS24)/(OBS21 + OBS23 + OBS24) // professional wage w/ no health
gen MEAN_3_NO_HEALTH = (MEAN31*OBS31 + MEAN33*OBS33 + MEAN34*OBS34 + MEAN35*OBS35)/(OBS31 + OBS33 + OBS34 + OBS35) // associate professional wage w/ no health
gen MEAN22_32_HEALTH_COMPOSITE = (MEAN22*OBS22 +MEAN32*OBS32)/(OBS22+OBS32) // healthcare workers wages

gen MEAN1_NORM = MEAN1 - MEAN1[9] // managers wage normalised
gen MEAN2_NORM = MEAN2 - MEAN2[9] // profssional wage normalised
gen MEAN3_NORM = MEAN3 - MEAN3[9] // associate normalised wage
gen MEAN_2_NO_HEALTH_NORM = MEAN_2_NO_HEALTH - MEAN_2_NO_HEALTH[9] // professional wage no healthcare normalised
gen MEAN_3_NO_HEALTH_NORM = MEAN_3_NO_HEALTH - MEAN_3_NO_HEALTH[9]
gen MEAN22_32_HEALTH_COMPOSITE_NORM = MEAN22_32_HEALTH_COMPOSITE - MEAN22_32_HEALTH_COMPOSITE[9] // associate professional wage no healthcare normalised


label variable MEAN1_NORM "Managers"
label variable MEAN2_NORM "Professionals (excluding healthcare workers)"
label variable MEAN3_NORM "Associate Professionals (excluding healthcare workers)"
label variable MEAN22_32_HEALTH_COMPOSITE_NORM "Healthcare workers"

preserve 

drop if _n < 9 

graph twoway tsline MEAN1_NORM MEAN2_NORM MEAN3_NORM MEAN22_32_HEALTH_COMPOSITE_NORM, ytitle("Percentage Growth") xtitle("") legend(cols(1)) title("Real Hourly Wage Percentage Growth by NRC Decomp (indexed at 2011)") scale(0.6) tlabel(2011(2)2020)   saving("Data/ASHE/figure_outputs/fig_1_c_wage_growth_across_NRC_tasks_indexed", replace)

restore





*professional & healthcare figure 


gen MEAN21_NORM = MEAN21 - MEAN21[9] // science wage normalised 
* gen MEAN22_NORM = MEAN22 - MEAN22[9] // commented out as healthcare considered separately
gen MEAN23_NORM = MEAN23 - MEAN23[9] // teaching wage normalised
gen MEAN24_NORM = MEAN24 - MEAN24[9] // business wage normalised

label variable MEAN21_NORM "Science"
*label variable MEAN22_NORM "Health" // commented out for reasons above 
label variable MEAN23_NORM "Teaching"
label variable MEAN24_NORM "Business"

preserve 

drop if _n < 9

graph twoway tsline MEAN21_NORM  MEAN23_NORM MEAN24_NORM, ytitle("Log Real Wage Growth") xtitle("") legend(cols(1)) title(" Real Hourly Wage Percentage Growth by Professional Decomp (indexed at 2002)") scale(0.6) tlabel(2011(2)2020)   saving("Data/ASHE/figure_outputs/fig_1_d_wage_growth_across_professional_tasks_indexed", replace)

save "Data/ASHE/agg_panel", replace

restore


* associate professional figure


gen MEAN31_NORM = MEAN31 - MEAN31[9] 
*gen MEAN32_NORM = MEAN32 - MEAN32[9] 
gen MEAN33_NORM = MEAN33 - MEAN33[9]
gen MEAN34_NORM = MEAN34 - MEAN34[9] 
gen MEAN35_NORM = MEAN35 - MEAN35[9] 

label variable MEAN31_NORM "Science"
*label variable MEAN32_NORM "Health"
label variable MEAN33_NORM "Protective Services"
label variable MEAN34_NORM "Culture"
label variable MEAN35_NORM "Business"

preserve 

drop if _n < 9

graph twoway tsline MEAN31_NORM  MEAN33_NORM MEAN35_NORM, ytitle("Real Wage Growth") xtitle("") legend(cols(1)) title(" Real Hourly Wage Percentage Growth by Associate Professional Decomp (indexed at 2011)") scale(0.6) tlabel(2011(2)2020)   saving("Data/ASHE/figure_outputs/fig_1_d2_wage_growth_across_associate_professional_tasks_indexed", replace)

restore

* managerial figure

gen MEAN11_NORM = MEAN11 - MEAN11[9] 
gen MEAN12_NORM = MEAN12 - MEAN12[9] 

label variable MEAN11_NORM "Corporate"
label variable MEAN12_NORM "Other Managers"

preserve 

drop if _n < 9

graph twoway tsline MEAN11_NORM  MEAN12_NORM, ytitle("Real Wage Growth") xtitle("") legend(cols(1)) title(" Real Hourly Wage Percentage Growth by Managerial Decomp (indexed at 2011)") scale(0.6) tlabel(2011(2)2020)   saving("Data/ASHE/figure_outputs/fig_1_d3_wage_growth_across_manager_tasks_indexed", replace)

restore

* healthcare figure

gen MEAN22_32_HEALTH_COMPOSITE_NORM2 = MEAN22_32_HEALTH_COMPOSITE - MEAN22_32_HEALTH_COMPOSITE[9]

label variable MEAN22_32_HEALTH_COMPOSITE_NORM2 "Healthcare composite"

preserve 

drop if _n < 9

graph twoway tsline MEAN22_32_HEALTH_COMPOSITE_NORM2  , ytitle("Real Wage Growth") xtitle("") legend(cols(1)) title(" Real Hourly Wage Percentage Growth by Healthcare Decomp (indexed at 2011)") scale(0.6) tlabel(2011(2)2020)   saving("Data/ASHE/figure_outputs/fig_1_d4_wage_growth_across_manager_tasks_indexed", replace)

restore









* Percentage of workers routine / non-routine


gen NRC_SHARE = (OBS1 + OBS2 + OBS3)/OBS0 // non-routine cog employment share
gen RC_SHARE = (OBS4 + OBS6 + OBS7)/OBS0 // non-routine man employment share
gen RM_SHARE = OBS8/OBS0 // routine manual share
gen NRM_SHARE = (OBS5 + OBS9)/OBS0 // routine cog share
gen NR_SHARE = NRC_SHARE + NRM_SHARE // non-routine share
gen R_SHARE = RC_SHARE + RM_SHARE // routine share

gen NRC_SHARE_NORM = NRC_SHARE - NRC_SHARE[1] // non-routine cog employment share norm
gen NRM_SHARE_NORM = NRM_SHARE - NRM_SHARE[1] // non-routine man employment share norm
gen RM_SHARE_NORM = RM_SHARE - RM_SHARE[1] // routine manual share norm 
gen RC_SHARE_NORM = RC_SHARE - RC_SHARE[1] // routine cog share norm 
gen NR_SHARE_NORM = NR_SHARE - NR_SHARE[1] // non-routine share normalised
gen R_SHARE_NORM = R_SHARE - R_SHARE[1] // routine share norm 

label variable NRC_SHARE_NORM "Non-routine cognitive"
label variable NRM_SHARE_NORM "Non-routine manual"
label variable RM_SHARE_NORM "Routine manual"
label variable RC_SHARE_NORM "Routine cognitive"
label variable NR_SHARE_NORM "Non-routine"
label variable R_SHARE_NORM "Routine"

graph twoway tsline R_SHARE_NORM NR_SHARE_NORM, ytitle("Percentage change") xtitle("") legend(cols(1)) title("Change in employment share by task (indexed at 2002)") scale(0.6) tlabel(2002(2)2021)   saving("Data/ASHE/figure_outputs/fig_1_e_employment_change_by_task", replace)



* Percentage of workers by task

graph twoway tsline NRC_SHARE_NORM NRM_SHARE_NORM RM_SHARE_NORM RC_SHARE_NORM, ytitle("Percentage change") xtitle("") legend(cols(1)) title("Change in employment share by task #2 (indexed at 2002)") scale(0.6) tlabel(2002(2)2021)   saving("Data/ASHE/figure_outputs/fig_1_f_employment_change_by_task_2", replace)


* Percentage of workers by NRC task 

gen OBS1_SHARE = OBS1/OBS0 // managerial employment share
gen OBS2_SHARE = (OBS21 + OBS23 + OBS24 )/OBS0 // professional employment share (no health)
gen OBS3_SHARE = (OBS31 + OBS33 + OBS34 + OBS35)/OBS0 // associate professional employment share (no health)
gen OBS_HEALTH_SHARE = (OBS22 + OBS32)/OBS0 // healthcare share

gen OBS1_SHARE_NORM = (OBS1_SHARE - OBS1_SHARE[9])/OBS1_SHARE[9] // managerial employment share norm 
gen OBS2_SHARE_NORM = (OBS2_SHARE - OBS2_SHARE[9])/OBS2_SHARE[9] // professional employment share norm 
gen OBS3_SHARE_NORM = (OBS3_SHARE - OBS3_SHARE[9])/OBS3_SHARE[9] // associate professional employment share norm 
gen OBS_HEALTH_SHARE_NORM = (OBS_HEALTH_SHARE - OBS_HEALTH_SHARE[9])/OBS_HEALTH_SHARE[9] // healthcare employment share norm 

label variable OBS1_SHARE_NORM "Managers"
label variable OBS2_SHARE_NORM "Professionals"
label variable OBS3_SHARE_NORM "Associate Professionals"
label variable OBS_HEALTH_SHARE_NORM "Health professionals"

preserve 

drop if _n <= 8 

graph twoway tsline OBS1_SHARE_NORM OBS2_SHARE_NORM OBS3_SHARE_NORM OBS_HEALTH_SHARE_NORM, ytitle("Percentage change") xtitle("") legend(cols(1)) title("Change in employment share by NRC task (indexed at 2002)") scale(0.6) tlabel(2011(2)2020)   saving("Data/ASHE/figure_outputs/fig_1_g_employment_change_by_NRC_task", replace)

restore

graph twoway tsline NRC_MEAN RC_MEAN RM_MEAN NRM_MEAN




* TBTC

* NR_SHARE is the relative supply variable 

gen NR_WAGE = (OBS1*MEAN1 + OBS2*MEAN2 + OBS3*MEAN3 + OBS5*MEAN5 + OBS9*MEAN9)/(OBS1 + OBS2 + OBS3 + OBS5 + OBS9)
gen R_WAGE = (OBS4*MEAN4 + OBS6*MEAN6 + OBS7*MEAN7 + OBS8*MEAN8)/(OBS4 + OBS6 + OBS7 + OBS8)

preserve 

drop if YEAR == 2011 | YEAR == 2019

gen log_PREMIUM = NR_WAGE - R_WAGE
gen log_NR_SHARE = ln(NR_SHARE)
gen log_PREMIUM2 = R_WAGE - NR_WAGE
gen log_R_SHARE = ln(R_SHARE)

gen t = _n 

reg log_PREMIUM t log_NR_SHARE, nocons

*regsave using results, tstat pval ci format(%5.3f) asterisk(10 5 1) 

regsave, table(Robust, order(regvars r2) format(%5.3f) parentheses(stderr) asterisk())
texsave using "/Users/mattnibloe/Documents/MRes UCL 2020-2021/Dissertation/Changing job composition in the UK/Data/ASHE/figure_outputs/TBTC", title(Katz and Murphy Regressions) varlabels replace

*reg log_PREMIUM2 t log_R_SHARE, nocons

restore



keep if _n == 9 | _n == 18

foreach i in 11 12 21 22 23 24 31 32 33 34 35 41 42 51 52 53 54 61 62 71 72 81 82 91 92{
	gen CHANGE_`i' = (MEAN`i'[2] - MEAN`i'[1])*100
}













