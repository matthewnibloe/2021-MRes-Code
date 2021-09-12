* MRes Thesis Project: Changing Job Composition in the UK since 2000
* TBTC
* Matthew Nibloe
* 31/08/21

cd "/Users/mattnibloe/Documents/MRes UCL 2020-2021/Dissertation/Changing job composition in the UK/APS"

* importing the panel
use "Data/Final/panel.dta", replace

* calculating mean wage by task and wage
bysort WAVE ROUTINE: egen MEANWAGE = mean(LRWAGE) 

* calculating relative number of routine workers in each period
bysort WAVE: egen NUMROUTINE = mean(ROUTINE)

* collapsing data by wave and routine
collapse MEANWAGE NUMROUTINE [aweight = WEIGHT], by(ROUTINE WAVE)

* changing data from long to wide (time dimension is the wave and i dimension is the routine indicator)
reshape wide MEANWAGE NUMROUTINE, i(WAVE) j(ROUTINE)

drop NUMROUTINE0 // this is a duplicate column (I will use NUMSKILLED1)
gen ROUTINE = ln(NUMROUTINE1) // log ratio of skilled workers

gen PREMIUM = MEANWAGE1 - MEANWAGE0 // log college wage premium

rename WAVE TIME // the wave number takes the place of the time trend

* Katz and Murphy specification
reg PREMIUM TIME ROUTINE, nocons

regsave
texsave using "Data/Final/TBTC.tex", title(TBTC) varlabels replace
