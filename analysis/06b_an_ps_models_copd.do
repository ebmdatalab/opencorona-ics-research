/*==============================================================================
DO FILE NAME:			06b_an_ps_models_copd
PROJECT:				ICS in COVID-19 
DATE: 					11th August 2020 
AUTHOR:					A Schultze 
VERSION: 				Stata 16.1									
DESCRIPTION OF FILE:	adapted program 06 
DATASETS USED:			weighted stset data
						($tempdir/analysis_dataset_STSET_IPW_$outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						table2-ps, printed to analysis/$outdir
							
==============================================================================*/

* Open a log file

cap log close
log using $logdir\06b_an_ps_models_copd, replace t

* Open Stata dataset
use $tempdir\analysis_dataset_STSET_IPW_$outcome, clear

/* Sense check outcomes=======================================================*/ 

tab exposure $outcome, missing row

/* Main Model=================================================================*/

*Post to a stata dataset for appending with other results later
capture postfile temp str30 outcome str30 population str30 level str30 title estimate min95 max95 using "$tempdir/temp_copd.dta",replace

/* Univariable model */ 

stcox i.exposure, vce(robust)
estimates save ./$tempdir/univar, replace 

/* Print table================================================================*/ 
*  Print the results for the main model 

cap file close tablecontent
file open tablecontent using ./$outdir/table2.txt, write text replace

* Column headings 
file write tablecontent ("Table 2 - PS: Association between current ICS use and $tableoutcome - $population Population") _n
file write tablecontent _tab ("HR") _tab ("95% CI") _n				

* Row headings 
local lab0: label exposure 0
local lab1: label exposure 1
	
	file write tablecontent ("`lab0'") _tab
	file write tablecontent ("1.00 (ref)") _tab _n
	file write tablecontent ("`lab1'") _tab  

/* Main Model */ 
estimates use ./$tempdir/univar 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 
post temp ("$tableoutcome") ("$population") ("PS - IPW") ("`lab1'") (round(r(estimate)),0.01) (round(r(lb)),0.01) (round(r(ub)),0.01)           

file write tablecontent _n
file close tablecontent
postclose temp  

* Close log file 
log close
