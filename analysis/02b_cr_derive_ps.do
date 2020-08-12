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

* ATT weights 
gen ipw_att = 1 if exposure == 1 
replace ipw_att = pscore/(1-pscore) if exposure == 0 

summarize ipw_att, d

/* Check overlap and standardised differences in the weighted sample==========*/

* Plot and export graphs of the PS distribution 
* Adapt probability weights to frequency weights to use in graphs
* These need to be rounded up for sufficient granularity 

gen ipw_f = round(ipw*100) 

hist pscore [fw = ipw_f], by(exposure, graphregion(fcolor(white))) color(emidblue)
graph export "$outdir/psplot3.svg", as(svg) replace
graph close 

graph twoway kdensity pscore if exposure == 0 [fw = ipw_f] || ///
			 kdensity pscore if exposure == 1 [fw = ipw_f], ///
			 graphregion(fcolor(white)) ///
			 legend(size(small) label(1 "Pscore - LABA/LAMA Combination") label (2 "Pscore - ICS Combination") region(lwidth(none)) order(2 1))
			 
graph export "$outdir/psplot4.svg", as(svg) replace
graph close


* Estimate and tabulate standardised differences 
* Note, this required amending the stddiff ado file 
* The amended file is saved as Weighted STDs and called before calculating these 
* The weights are frequency weights used above and in a variable called 'wts'

gen wts = ipw_f

run "Weighted STDs.do" 

cap file close tablecontent
file open tablecontent using ./$outdir/table_stddiff2.txt, write text replace

file write tablecontent ("Table S2: Standardised differences after weighting") _n
file write tablecontent ("Variable") _tab ("SD") _n

*Gender

    local lab: variable label male 
    file write tablecontent ("`lab'") _tab
	
	tab male exposure
	stddiff i.male, by(exposure)
	stddiff2 i.male, by(exposure)
	file write tablecontent (r(stddiff)[1,1]) _n 

*Age

    local lab: variable label age
    file write tablecontent ("`lab'") _tab
	
	stddiff2 age, by(exposure)
	file write tablecontent (r(stddiff)[1,1]) _n 
	
* All other things 

foreach comorb in $varlist {

    local comorb: subinstr local comorb "i." ""
    local lab: variable label `comorb'
    file write tablecontent ("`lab'") _tab
	
	stddiff2 `comorb', by(exposure)
	file write tablecontent (r(stddiff)[1,1]) _n 
				
}

file close tablecontent

/* Output weighted dataset for analyses=======================================*/

* Save a version set on survival outcome with IP weights (ATE)
* Note that this will throw a probable error for invalid weights 
* This is because we have people with missing exposure in the dataset which we allow to drop at this stage
* Those with missing exposure have missing weights and that's why there's an error 
stset stime_$outcome [pweight = ipw], fail($outcome) id(patient_id) enter(enter_date) origin(enter_date)	
save $tempdir\analysis_dataset_STSET_IPW_$outcome, replace

* Save a version that does not censor on non-COVID death 



* Close log file 
log close