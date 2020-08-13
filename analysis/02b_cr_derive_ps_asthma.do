/*==============================================================================
DO FILE NAME:			02b_cr_derive_ps_asthma
PROJECT:				ICS in COVID-19 
DATE: 					11th of August 2020
AUTHOR:					A Schultze 
VERSION: 				Stata 16.1									
DESCRIPTION OF FILE:	program 02b 
						derive PS - extend to asthma 3 way comparison
						check overlap and distribution 
						create weights for the population 
DATASETS USED:			data in memory 
DATASETS CREATED: 		analysis_dataset_STSET_IPW_$outcome.dta
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
							
==============================================================================*/

* Open a log file

cap log close
log using $logdir\02b_cr_derive_ps_asthma, replace t

/* PS Model===================================================================*/

mlogit exposure i.male age1 age2 age3 $varlist, base(0)
predict p0 p1 p2, pr 

bysort exposure: summarize p0 
bysort exposure: summarize p1 
bysort exposure: summarize p2 

* Plot and export graphs of the PS distribution 
* Question to Fizz - what is the best way of illustrating this given 3 groups..
* Left for now 

* Estimate and tabulate standardised differences 
* Note, this relies on the stddiff ado, provided in the repo. 
* Because 3 level treatment, compare both against baseline, so need to create indicators for this

gen exposure1v0 = 0 if exposure == 0 
replace exposure1v0 = 1 if exposure == 1 

gen exposure2v0 = 0 if exposure == 0 
replace exposure2v0 = 1 if exposure == 2 

local lab0: label exposure 0
local lab1: label exposure 1
local lab2: label exposure 2

cap file close tablecontent
file open tablecontent using ./$outdir/table_stddiff.txt, write text replace

file write tablecontent ("Table S1: Standardised differences before weighting") _n
file write tablecontent ("Variable") _tab ("SD - `lab1' vs `lab0'") _tab ("SD - `lab2' vs `lab0'") _n 

*Gender

    local lab: variable label male 
    file write tablecontent ("`lab'") _tab
	
	stddiff i.male, by(exposure1v0)
	file write tablecontent (r(stddiff)[1,1]) _tab
	
	stddiff i.male, by(exposure2v0)
	file write tablecontent (r(stddiff)[1,1]) _n 

*Age

    local lab: variable label age
    file write tablecontent ("`lab'") _tab
	
	stddiff age, by(exposure1v0)
	file write tablecontent (r(stddiff)[1,1]) _tab
	
	stddiff age, by(exposure2v0)
	file write tablecontent (r(stddiff)[1,1]) _n 
	
* All other things 

foreach comorb in $varlist {

    local comorb: subinstr local comorb "i." ""
    local lab: variable label `comorb'
    file write tablecontent ("`lab'") _tab
	
	stddiff `comorb', by(exposure1v0)
	file write tablecontent (r(stddiff)[1,1]) _tab 
	
	stddiff `comorb', by(exposure2v0)
	file write tablecontent (r(stddiff)[1,1]) _n 				
}

file close tablecontent

/* Create weights=============================================================*/

* ATE weights 
gen ipw = 1/p0 if exposure == 0 
replace ipw = 1/p1 if exposure == 1 
replace ipw = 1/p2 if exposure == 2 

summarize ipw, d

* ATT weights
* Multiplied by the comparator pscore (=p0). Unsure whether this is right. 
gen ipw_att = 1 if exposure == 0 
replace ipw_att = p0/p1 if exposure == 1
replace ipw_att = p0/p2 if exposure == 2 

summarize ipw_att, d

/* Check overlap and standardised differences in the weighted sample==========*/

* Plot and export graphs of the PS distribution 
* Left graph export for now for same reason as above 
* Adapt probability weights to frequency weights to use in graphs
* These need to be rounded up for sufficient granularity 

gen ipw_f = round(ipw*100) 

* repeat for ATT

gen ipw_fatt = round(ipw_att*100) 

* Estimate and tabulate standardised differences 
* Note, this required amending the stddiff ado file 
* The amended file is saved as Weighted STDs and called before calculating these 
* The weights are frequency weights used above and in a variable called 'wts'

gen wts = ipw_f

run "Weighted STDs.do" 

cap file close tablecontent
file open tablecontent using ./$outdir/table_stddiff2.txt, write text replace

file write tablecontent ("Table S2: Standardised differences after weighting - ATE") _n
file write tablecontent ("Variable") _tab ("SD - `lab1' vs `lab0'") _tab ("SD - `lab2` vs `lab0'") _n 

*Gender

    local lab: variable label male 
    file write tablecontent ("`lab'") _tab
	
	stddiff2 i.male, by(exposure1v0)
	file write tablecontent (r(stddiff)[1,1]) _tab
	
	stddiff2 i.male, by(exposure2v0)
	file write tablecontent (r(stddiff)[1,1]) _n 

*Age

    local lab: variable label age
    file write tablecontent ("`lab'") _tab
	
	stddiff2 age, by(exposure1v0)
	file write tablecontent (r(stddiff)[1,1]) _tab
	
	stddiff2 age, by(exposure2v0)
	file write tablecontent (r(stddiff)[1,1]) _n 
	
* All other things 

foreach comorb in $varlist {

    local comorb: subinstr local comorb "i." ""
    local lab: variable label `comorb'
    file write tablecontent ("`lab'") _tab
	
	stddiff2 `comorb', by(exposure1v0)
	file write tablecontent (r(stddiff)[1,1]) _tab 
	
	stddiff2 `comorb', by(exposure2v0)
	file write tablecontent (r(stddiff)[1,1]) _n 				
}

file close tablecontent

* Repeat for ATT

drop wts
gen wts = ipw_fatt

run "Weighted STDs.do" 

cap file close tablecontent
file open tablecontent using ./$outdir/table_stddiff2.txt, write text replace

file write tablecontent ("Table S3: Standardised differences after weighting - ATT") _n
file write tablecontent ("Variable") _tab ("SD - `lab1' vs `lab0'") _tab ("SD - `lab2` vs `lab0'") _n 

*Gender

    local lab: variable label male 
    file write tablecontent ("`lab'") _tab
	
	stddiff2 i.male, by(exposure1v0)
	file write tablecontent (r(stddiff)[1,1]) _tab
	
	stddiff2 i.male, by(exposure2v0)
	file write tablecontent (r(stddiff)[1,1]) _n 

*Age

    local lab: variable label age
    file write tablecontent ("`lab'") _tab
	
	stddiff2 age, by(exposure1v0)
	file write tablecontent (r(stddiff)[1,1]) _tab
	
	stddiff2 age, by(exposure2v0)
	file write tablecontent (r(stddiff)[1,1]) _n 
	
* All other things 

foreach comorb in $varlist {

    local comorb: subinstr local comorb "i." ""
    local lab: variable label `comorb'
    file write tablecontent ("`lab'") _tab
	
	stddiff2 `comorb', by(exposure1v0)
	file write tablecontent (r(stddiff)[1,1]) _tab 
	
	stddiff2 `comorb', by(exposure2v0)
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

* Save a version weighted on ATT weights
stset stime_$outcome [pweight = ipw_att], fail($outcome) id(patient_id) enter(enter_date) origin(enter_date)	
save $tempdir\analysis_dataset_STSET_IPWATT_$outcome, replace


* Close log file 
log close