* MRes Thesis Project: Changing Job Composition in the UK since 2000
* APS Impact of public sector on real wage
* Matthew Nibloe
* 31/08/21


cd "/Users/mattnibloe/Documents/MRes UCL 2020-2021/Dissertation/Changing job composition in the UK/APS"

use "Data/Final/panel.dta", clear

gen ID_2 = string(SOC_2DIGIT)+"_"+string(WAVE)

merge m:1 ID_2 using "Data/Cleaned/public_share.dta"

drop if _merge == 1 | _merge == 2

sort WAVE 

gen LRWAGE_DIFF = d.LRWAGE

reg LRWAGE PUBLIC PUBLIC_DIFF, nocons
