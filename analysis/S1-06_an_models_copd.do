/*==============================================================================
DO FILE NAME:			S1-06_models_copd
PROJECT:				ICS in COVID-19 
DATE: 					21 of May 2020  
AUTHOR:					A Schultze 		
VERSION: 				Stata 16.1							
DESCRIPTION OF FILE:	program 06 
						univariable regression
						multivariable regression 
						SENSITIVITY 1 - New COPD exposure definition
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						S1table2, printed to analysis/$outdir
							
==============================================================================*/

* Open a log file

cap log close
log using $logdir\S1-06_an_models_copd, replace t

* Open Stata dataset
use $tempdir\analysis_dataset_STSET_onscoviddeath, clear

/* Sense check outcomes=======================================================*/ 

tab exposure onscoviddeath, missing row

/* Main Model=================================================================*/

*Post to a stata dataset for appending with other results later
capture postfile temp str30 outcome str30 population str30 level str30 title estimate min95 max95 using "$tempdir/temp_copd.dta",replace

/* Univariable model */ 

stcox i.exposure 
estimates save ./$tempdir/univar, replace 

/* Multivariable models */ 

* Age and Gender 
* Age fit as spline 

stcox i.exposure i.male age1 age2 age3 
estimates save ./$tempdir/multivar1, replace 

* Age, Gender and Comorbidities 
stcox i.exposure i.male age1 age2 age3 $varlist, strata(stp)														
estimates save ./$tempdir/multivar2, replace 

/* Print table================================================================*/ 
*  Print the results for the main model 

cap file close tablecontent
file open tablecontent using ./$outdir/S1table2.txt, write text replace

* Column headings 
file write tablecontent ("S1 Table 2: Association between current ICS use and $tableoutcome - $population Population") _n
file write tablecontent _tab _tab _tab _tab ("Univariable") _tab _tab ("Age/Sex Adjusted") _tab _tab ///
						("Age/Sex and Comorbidity Adjusted") _tab _tab _n
file write tablecontent _tab ("Events") _tab ("Person-weeks") _tab ("Rate per 1,000") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ///
						("95% CI") _tab ("HR") _tab ("95% CI") _n				

* Row headings 
local lab0: label exposure 0
local lab1: label exposure 1
local lab2: label exposure 2
 
/* Counts and Rates */
 
* First row, exposure = 0 (reference)

	count if exposure == 0 & $outcome == 1
	local event = r(N)
    bysort exposure: egen total_follow_up = total(_t)
	summarize total_follow_up if exposure == 0
	local person_week = r(mean)/7
	* note, mean is fine as total_follow_up the same for each person 
	local rate = 1000*(`event'/`person_week')
	
	file write tablecontent ("`lab0'") _tab
	file write tablecontent (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab
	file write tablecontent ("1.00 (ref)") _tab _tab ("1.00 (ref)") _tab _tab ("1.00 (ref)") _n
	
* Second row, exposure = 1 (comparator)

file write tablecontent ("`lab1'") _tab  

	count if exposure == 1 & $outcome == 1
	local event = r(N)
	summarize total_follow_up if exposure == 1
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	file write tablecontent (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab

/* Main Model */ 
estimates use ./$tempdir/univar 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 
post temp ("$tableoutcome") ("$population") ("Univariable") ("`lab1'") (round(r(estimate)),0.01) (round(r(lb)),0.01) (round(r(ub)),0.01) 
lincom 2.exposure, eform
post temp ("$tableoutcome") ("$population") ("Univariable") ("`lab2'") (round(r(estimate)),0.01) (round(r(lb)),0.01) (round(r(ub)),0.01)    
estimates use ./$tempdir/multivar1 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 
post temp ("$tableoutcome") ("$population") ("Age/Sex adjusted") ("`lab1'") (round(r(estimate)),0.01) (round(r(lb)),0.01) (round(r(ub)),0.01)   
lincom 2.exposure, eform
post temp ("$tableoutcome") ("$population") ("Age/Sex adjusted") ("`lab2'") (round(r(estimate)),0.01) (round(r(lb)),0.01) (round(r(ub)),0.01)    

estimates use ./$tempdir/multivar2 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n 
post temp ("$tableoutcome") ("$population") ("Fully adjusted") ("`lab1'") (round(r(estimate)),0.01) (round(r(lb)),0.01) (round(r(ub)),0.01)
lincom 2.exposure, eform
post temp ("$tableoutcome") ("$population") ("Fully adjusted") ("`lab2'") (round(r(estimate)),0.01) (round(r(lb)),0.01) (round(r(ub)),0.01)    

* Third row, exposure = 2 (comparator)

file write tablecontent ("`lab2'") _tab  

	count if exposure == 2 & $outcome == 1
	local event = r(N)
	summarize total_follow_up if exposure == 2
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	file write tablecontent (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab

/* Main Model */ 
estimates use ./$tempdir/univar 
lincom 2.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use ./$tempdir/multivar1 
lincom 2.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use ./$tempdir/multivar2 
lincom 2.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n 

file write tablecontent _n
file close tablecontent
postclose temp  

* At editorial request, need to add number of people in each category for forest plots 

capture postfile temp str20 exp1 using "$tempdir/temp2.dta", replace

count if exposure == 1 & $outcome == 1
local event = r(N)
count if exposure == 1 
local denom = r(N)

gen exp1string = string(`event', "%6.0f") + "/" + string(`denom', "%6.0f")

count if exposure == 2 & $outcome == 1
local event = r(N)
count if exposure == 2 
local denom = r(N)

gen exp2string = string(`event', "%6.0f") + "/" + string(`denom', "%6.0f") 

post temp (exp1string) 
post temp (exp2string)
post temp ("")
post temp ("") 
post temp ("")
post temp ("")

postclose temp

capture postfile temp str20 exp0 using "$tempdir/temp3.dta", replace

count if exposure == 0 & $outcome == 1
local event = r(N)
count if exposure == 0 
local denom = r(N)

gen exp0string = string(`event', "%6.0f") + "/" + string(`denom', "%6.0f")

post temp (exp0string) 
post temp (exp0string)
post temp ("")
post temp ("") 
post temp ("")
post temp ("")

postclose temp

use $tempdir/temp_copd.dta, clear
gen ID = _n 
save $tempdir/temp_copd.dta, replace

use $tempdir/temp2.dta, clear
gen ID = _n
save $tempdir/temp2.dta, replace

use $tempdir/temp3.dta, clear
gen ID = _n
save $tempdir/temp3.dta, replace

use $tempdir/temp_copd.dta, clear

merge 1:1 ID using $tempdir/temp2 
drop _merge
merge 1:1 ID using $tempdir/temp3
drop _merge
drop ID
 
save $tempdir/temp_copd.dta, replace

* Close log file 
log close
