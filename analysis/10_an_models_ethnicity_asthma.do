/*==============================================================================
DO FILE NAME:			10_models_ethnicity 
PROJECT:				ICS in COVID-19 
DATE: 					22nd of May 2020  
AUTHOR:					A Schultze 									
DESCRIPTION OF FILE:	program 10, restrict to known ethnicity == 1 
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						table6, printed to analysis/$outdir
							
==============================================================================*/

* Open a log file

cap log close
log using $logdir\10_an_models_ethnicity_asthma, replace t

* Open Stata dataset
use $tempdir\analysis_dataset_STSET_$outcome, clear

/* Restrict population========================================================*/ 

preserve 
drop if ethnicity != 1

/* Sense check outcomes=======================================================*/ 

tab exposure $outcome, missing row

/* Main Model=================================================================*/

/* Univariable model */ 

stcox i.exposure 
estimates save ./$tempdir/univar, replace 

/* Multivariable models */ 

* Age and Gender 
* Age fit as spline in first instance, categorical below 

stcox i.exposure i.male age1 age2 age3 
estimates save ./$tempdir/multivar1, replace 

* Age, Gender and Comorbidities 
stcox i.exposure i.male age1 age2 age3 	i.obese4cat					///
										i.smoke_nomiss				///
										i.imd 						///
										i.ckd	 					///		
										i.hypertension			 	///		
										i.heart_failure				///		
										i.other_heart_disease		///		
										i.diabetes 					///		
										i.cancer_ever 				///							
										i.statin 					///		
										i.insulin					///		
										i.flu_vaccine 				///	
										i.pneumococcal_vaccine		///	
										i.exacerbations 			///
										i.gp_consult, strata(stp)				
										
estimates save ./$tempdir/multivar2, replace 

/* MODEL CHANGES TO DO: 
- Diabetes as severity, remove insulin 
*/ 

/* Print table================================================================*/ 
*  Print the results for the main model 

cap file close tablecontent
file open tablecontent using ./$outdir/table6.txt, write text replace

* Column headings 
file write tablecontent ("Table 6: Association between current ICS use and COVID-19 death - $population Population ethnicity == 1") _n
file write tablecontent _tab ("N") _tab ("Univariable") _tab _tab ("Age/Sex Adjusted") _tab _tab ///
						("Age/Sex and Comorbidity Adjusted") _tab _tab _n
file write tablecontent _tab _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ///
						("95% CI") _tab ("HR") _tab ("95% CI") _n
file write tablecontent ("Main Analysis") _n 					

* Row headings 
local lab0: label exposure 0
local lab1: label exposure 1
local lab2: label exposure 2
 
/* Counts */
 
* First row, exposure = 0 (reference)

	cou if exposure == 0 
	local rowdenom = r(N)
	cou if exposure == 0 & cpnsdeath == 1
	local pct = 100*(r(N)/`rowdenom') 
	
	file write tablecontent ("`lab0'") _tab
	file write tablecontent (r(N)) (" (") %3.1f (`pct') (")") _tab
	file write tablecontent ("1.00 (ref)") _tab _tab ("1.00 (ref)") _tab _tab ("1.00 (ref)") _n
	
* Second row, exposure = 1 (comparator)

file write tablecontent ("`lab1'") _tab  

	cou if exposure == 1 
	local rowdenom = r(N)
	cou if exposure == 1 & cpnsdeath == 1
	local pct = 100*(r(N)/`rowdenom') 
	file write tablecontent (r(N)) (" (") %3.1f (`pct') (")") _tab

/* Main Model */ 
estimates use ./$tempdir/univar 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use ./$tempdir/multivar1 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use ./$tempdir/multivar2 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n 

* Third row, exposure = 2 (comparator)

file write tablecontent ("`lab2'") _tab  

	cou if exposure == 2
	local rowdenom = r(N)
	cou if exposure == 2 & cpnsdeath == 1
	local pct = 100*(r(N)/`rowdenom') 
	file write tablecontent (r(N)) (" (") %3.1f (`pct') (")") _tab

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

restore 

* Close log file 
log close