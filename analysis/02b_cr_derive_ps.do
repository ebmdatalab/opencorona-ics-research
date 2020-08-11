/*==============================================================================
DO FILE NAME:			02b_cr_derive_ps
PROJECT:				ICS in COVID-19 
DATE: 					11th of August 2020
AUTHOR:					A Schultze 
VERSION: 				Stata 16.1									
DESCRIPTION OF FILE:	program 02b 
						derive PS 
						check overlap and distribution 
						create weights for the population 
DATASETS USED:			data in memory 
DATASETS CREATED: 		analysis_dataset_STSET_IPW_$outcome.dta
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
							
==============================================================================*/

* Open a log file

cap log close
log using $logdir\02b_cr_derive_ps, replace t

/* PS Model===================================================================*/

logit exposure i.male age1 age2 age3 $varlist
predict pscore, pr 

* Check PS distribution 
summarize pscore if exposure == 0, detail
summarize pscore if exposure == 1, detail

* Plot and export graphs of the PS distribution 
hist pscore, by(exposure, graphregion(fcolor(white))) color(emidblue)
graph export "$outdir/psplot1.svg", as(svg) replace
graph close 

graph twoway kdensity pscore if exposure == 0 || ///
			 kdensity pscore if exposure == 1, ///
			 graphregion(fcolor(white)) ///
			 legend(size(small) label(1 "Pscore - LABA/LAMA Combination") label (2 "Pscore - ICS Combination") region(lwidth(none)) order(2 1))

graph export "$outdir/psplot2.svg", as(svg) replace
graph close

* Estimate and tabulate standardised differences 
* Note, this relies on the stddiff ado, provided in the repo. 

cap file close tablecontent
file open tablecontent using ./$outdir/table_stddiff.txt, write text replace

file write tablecontent ("Table S1: Standardised differences before weighting") _n
file write tablecontent ("Variable") _tab ("SD") _n

*Gender

    local lab: variable label male 
    file write tablecontent ("`lab'") _tab
	
	stddiff i.male, by(exposure)
	file write tablecontent (r(stddiff)[1,1]) _n 

*Age

    local lab: variable label age
    file write tablecontent ("`lab'") _tab
	
	stddiff age, by(exposure)
	file write tablecontent (r(stddiff)[1,1]) _n 
	
* All other things 

foreach comorb in $varlist {

    local comorb: subinstr local comorb "i." ""
    local lab: variable label `comorb'
    file write tablecontent ("`lab'") _tab
	
	stddiff `comorb', by(exposure)
	file write tablecontent (r(stddiff)[1,1]) _n 
				
}


file close tablecontent

/* Create weights=============================================================*/

* ATE weights 
gen ipw = 1/pscore if exposure == 1 
replace ipw = 1/(1-pscore) if exposure == 0 

summarize ipw, d

gen check=1 if ipw == . 
tab check

* ATT weights 
gen ipw_att = 1 if exposure == 1 
replace ipw_att = pscore/(1-pscore) if exposure == 0 

summarize ipw_att, d

/* Check overlap and standardised differences in the weighted sample==========*/


* Plot and export graphs of the PS distribution 
/* NOTE Don't think I can use pweights for these commands. I've seen on statalist
a suggestion to multiply up (with the smallest unit) to make the pweights integers and use in fweights. 
Does anyone have experience of whether this is a reasonable thing? 

hist pscore, by(exposure, graphregion(fcolor(white))) color(emidblue)
graph export "$outdir/psplot1.svg", as(svg) replace
graph close 

graph twoway kdensity pscore [weight = ipw] if exposure == 0 || ///
			 kdensity pscore [weight = ipw] if exposure == 1, ///
			 graphregion(fcolor(white)) ///
			 legend(size(small) label(1 "Pscore - LABA/LAMA Combination") label (2 "Pscore - ICS Combination") region(lwidth(none)) order(2 1))

graph export "$outdir/psplot2.svg", as(svg) replace
graph close

* Delete unneeded graphs
erase psplot1.gph
erase psplot2.gph

* Estimate and tabulate standardised differences 
* Note, this relies on the stddiff ado, provided in the repo. 

[PLACEHOLDER - need to amend the ado to allow weights]
[Fizz can help on Monday]
[If there is an old adaption anyone has, please let me know]

*/

/* Output weighted dataset for analyses=======================================*/

* Save a version set on survival outcome with IP weights (ATE)
* Note that this will throw a probable error for invalid weights 
* This is because we have people with missing exposure in the dataset which we allow to drop at this stage
* Those with missing exposure have missing weights and that's why there's an error 
stset stime_$outcome [pweight = ipw], fail($outcome) id(patient_id) enter(enter_date) origin(enter_date)	
save $tempdir\analysis_dataset_STSET_IPW_$outcome, replace


* Close log file 
log close