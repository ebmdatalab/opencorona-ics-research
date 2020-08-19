/*==============================================================================
DO FILE NAME:			11_an_stand_surv_copd
PROJECT:				ICS in COVID-19 
AUTHORS:				A Schultze
						adapted from K Baskharan A Wong
DATE: 					12th of May 2020
VERSION: 				Stata 16.1 
DESCRIPTION OF FILE:	fit parametric model
						use postestimation command to plot standardised surv 
						estimate difference in % at 2 months
						derive marginal HR
						
DATASETS USED:			$tempdir\analysis_dataset_STSET_$outcome.dta
DATASETS CREATED: 		None
OTHER OUTPUT: 			Results in svg: $outdir\standsurvplot1
						Log file: $logdir\11_an_stand_surv_copd 
						
==============================================================================*/

* Open a log file
capture log close
log using $logdir\11_an_stand_surv_copd, replace t

* Open Stata dataset
use $tempdir\analysis_dataset_STSET_$outcome, clear

/* Sense check outcomes=======================================================*/ 
tab exposure $outcome

/* Fit the parametric model===================================================*/

xi i.exposure i.male $varlist
stpm2 _I* age1 age2 age3, scale(hazard) df(3) eform nolog 

/* Predict survival===========================================================*/

* set timevar for time points to be plotted
summ _t
local tmax=r(max)
local tmaxplus1=r(max)+1

display `tmax'

range timevar 0 `tmax' `tmaxplus1'

* Generate the standardised predictions 
stpm2_standsurv, at1(_Iexposure 0) at2(_Iexposure 1) timevar(timevar) ci contrast(difference) fail

* list the standardized curves for longest follow-up, followed by their difference.
list _at1* if timevar == `tmax', noobs
list _at2* if timevar == `tmax', noobs
list _contrast* if timevar == `tmax', noobs ab(16)

* Convert them to be expressed in %
for var _at1 _at2 _at1_lci _at1_uci _at2_lci _at2_uci ///
_contrast2_1 _contrast2_1_lci _contrast2_1_uci: replace X=100*X

* Plot the survival curves
twoway  (rarea _at1_lci _at1_uci timevar, color(blue%25)) ///
                (rarea _at2_lci _at2_uci timevar, color(red%25)) ///
                 (line _at1 timevar, sort lcolor(blue)) ///
                 (line _at2  timevar, sort lcolor(red)) ///
                 , legend(order(1 "LABA/LAMA" 2 "ICS Combination") ///
				 ring(0) cols(1) pos(1) size(small) region(lwidth(none))) ///
                 ylabel(0 (0.1) 0.5 ,angle(h) format(%4.2f)) ///
                 ytitle("Standardised cumulative mortality (%)") ///
                 xtitle("Days from 1 March 2020") ///
				 graphregion(fcolor(white)) ///
				 saving(adj_survival_curves_copd, replace)
				 
graph export "$outdir/adj_survival_curves_copd.svg", as(svg) replace

* Close window 
graph close

* Delete unneeded graphs
erase adj_survival_curves_copd.gph
