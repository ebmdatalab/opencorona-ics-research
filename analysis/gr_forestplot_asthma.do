/*==============================================================================
DO FILE NAME:			gr_forestplot_asthma
PROJECT:				ICS in COVID-19 
DATE: 					18th of May 2020  
AUTHOR:					C Rentsch, adapted by A Schultze
VERSION: 				Stata 16.1									
DESCRIPTION OF FILE:	append results datasets
						plot in forest plots 
DATASETS USED:			dta saved as 'temp' in each tempdata directory created
DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						forest plot, printed to analysis/$outdir
							
==============================================================================*/

* Open a log file

cap log close
log using $logdir\gr_forestplot_asthma, replace t

* All dta outputted from 06, append into one dataset 
clear
use asthma_tempdata/temp_asthma.dta
append using asthma_tempdata/temp_asthma_eth.dta
append using asthma_tempdata_sens2/temp_asthma.dta
append using asthma_tempdata_sens3/temp_asthma.dta

*rename to match the code below 
rename level analysis 
gen primsec = outcome + " - " + population 
drop outcome population
gen outcome = _n

*need to add in analysis column, in between primsec and title

gen result_label =string(estimate,"%6.2f") + " (" + string(min95,"%6.2f") + "-" + string(max95,"%6.2f") + ")"

egen first_primsec = tag(primsec)
egen first_analysis = tag(outcome)
gen order = _n

** Now for the figure

*only keep variable/estimates you need for now
*keep if parm == "1.t2dm"
graph set window fontface "Calibri"
**sort primsec outcome     

cap drop label
gen label = outcome
local obs1 = _N + 1
set obs `obs1'
replace outcome=0 if outcome == .
replace order=0 if order == .
sort  outcome  order 

* set some label values to missing so that we don't replicate information on the graph
replace primsec="" if first_primsec != 1
replace analysis="" if first_analysis != 1


* create label for outcome column
cap drop obs
gen obs = _n
replace title="Exposure" if obs==1
replace analysis="Analysis" if obs==1
replace result_label = "HR (95% CI)" if obs==1


*bold face some labels
gen bftitle = "{bf:" + title + "}" if title == "Exposure"
replace bftitle = title if bftitle == ""
gen bfanalysis = "{bf:" + analysis + "}" if analysis == "Analysis"
replace bfanalysis = analysis if bfanalysis == ""
gen bf_result = "{bf:" + result_label + "}" if result_label == "HR (95% CI)"
replace bf_result = result_label if bf_result == ""
gen bf_primsec = "{bf:" + primsec + "}" 

cap drop x0_*
gen x0_7 = -19
gen x0_3=-9.5
gen x0_1=-5.5
gen x0_14=8.2



cap drop obs
gen obs = _n 
cap drop no_obs 
cap drop obs2
cap drop obs3

egen no_obs = max(obs) 
gen obs2 = no_obs - obs + 1
rename obs obs3 
rename obs2 obs
*add space between column titles and data
replace obs=obs+0.5 if obs==no_obs
*add space between primary and secondary outcomes
// replace obs=obs+.5 if outcome <=9
// replace obs=obs+.5 if outcome <=6
// replace obs=obs+.5 if outcome <=3
// *add to no_obs the extra space I added
// replace no_obs = no_obs+2
local height=obs


graph twoway ///
|| scatter obs estimate if obs<no_obs, msymbol(circle) msize(vsmall) mcolor(black)		/// data points 
		xline(1, lp(solid) lw(vthin) lcolor(black))					/// add ref line
	|| rcap min95 max95 obs if obs<no_obs, horizontal lw(vthin) lcolor(black)					/// add the CIs
|| scatter obs estimate if obs<no_obs, msymbol(circle) msize(vsmall) mcolor(black)		/// data points 
		xline(1, lp(solid) lw(vthin) lcolor(black))					/// add ref line
	|| rcap min95 max95 obs if obs<no_obs, horizontal lw(vthin) lcolor(black)					/// add the CIs
		/// Primary/Secondary outcomes
|| scatter obs x0_7 if obs<no_obs, m(i) mlab(bf_primsec) mlabcol(black) mlabsize(vsmall) ///
|| scatter obs x0_7 if obs>no_obs, m(i) mlab(bf_primsec) mlabcol(black) mlabsize(small) ///		
		/// Analysis
|| scatter obs x0_3 if obs<no_obs, m(i) mlab(bfanalysis) mlabcol(black) mlabsize(vsmall) ///
|| scatter obs x0_3 if obs>no_obs, m(i) mlab(bfanalysis) mlabcol(black) mlabsize(small) ///	
		/// Exposure
|| scatter obs x0_1 if obs<no_obs, m(i)  mlab(bftitle) mlabcol(black) mlabsize(vsmall)  ///
|| scatter obs x0_1 if obs>no_obs, m(i)  mlab(bftitle) mlabcol(black) mlabsize(small)  ///
		/// add results labels
|| scatter obs x0_14 if obs<no_obs, m(i)  mlab(bf_result) mlabcol(black) mlabsize(vsmall) mlabposition(0) mlabgap(tiny)   ///
|| scatter obs x0_14 if obs>no_obs, m(i)  mlab(bf_result) mlabcol(black) mlabsize(small) mlabposition(0) mlabgap(tiny)   ///
		, legend(off)						/// turn legend off
		xtitle("Hazard ratio (HR)", size(vsmall) margin(40 0 0 2)) 		/// x-axis title (left right bottom top) - legend off
		xlab(0(1)6, labsize(vsmall)) /// x-axis tick marks
		xscale(range(0.01 9.5))					///	resize x-axis
		, ylab(none) ytitle("") 	/// y-axis no labels or title
		yscale(range(1 `height') lcolor(white))					/// resize y-axis
		graphregion(color(white)) ysize(15) xsize(20) saving(forestplot1_asthma, replace)	/// get rid of rubbish grey/blue around graph

graph export "$outdir/forestplot1_asthma.svg", as(svg) replace

log close 
