/*==============================================================================
DO FILE NAME:			06_models_copd
PROJECT:				ICS in COVID-19 
DATE: 					18th of May 2020  
AUTHOR:					A Schultze 
						adapted from K Baskharan, E Williamson 										
DESCRIPTION OF FILE:	program 06 
						univariable regression
						multivariable regression 
						sensitivity analyses and model checks are in: 
							07_model_assumptions
							08_sensitivity 
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
							
==============================================================================*/

* Open a log file

cap log close
log using $logdir\06_models_copd, replace t

* Open Stata dataset
use $tempdir\analysis_dataset_STSET_cpnsdeath, clear

/* Sense check outcomes=======================================================*/ 

tab exposure cpnsdeath, missing row

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
stcox i.exposure i.male age1 age2 age3 								///
										i. ckd	 					///		
										i. hypertension			 	///		
										i. heart_failure			///		
										i. other_heart_disease		///		
										i. diabetes 				///		
										i. cancer_ever 				///	
										i. immunodef_any		 	///							
										i. statin 					///		
										i. insulin					///		
										i. oral_steroids 			///		
										i. flu_vaccine 				///	
										i. pneumococcal_vaccine		///	
										i. gp_consult				
										
estimates save ./$tempdir/multivar2, replace 

/* Print table================================================================*/ 

cap file close tablecontent
file open tablecontent using ./$outdir/table2.txt, write text replace

* Column headings 
file write tablecontent ("Table 2: Association between current ICS use and CPNS death - COPD Population") _n
file write tablecontent _tab ("N") _tab ("Univariable") _tab _tab ("Age/Sex Adjusted") _tab _tab ///
						("Age/Sex and Comorbidity Adjusted") _tab _tab _n
file write tablecontent _tab _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ///
						("95% CI") _tab ("HR") _tab ("95% CI") _n
file write tablecontent ("Main Analysis") _n 					

* Row headings 
local lab0: label exposure 0
local lab1: label exposure 1
 
/* Counts */
 
* First row, exposure = 0 (reference)

	cou if exposure == 0 
	local rowdenom = r(N)
	cou if exposure == 0 & cpnsdeath == 1
	local pct = 100*(r(N)/`rowdenom') 
	
	file write tablecontent ("`lab0'") _tab
	file write tablecontent (r(N)) (" (") %3.1f (`pct') (")") _tab
	file write tablecontent ("1.00 (ref)") _tab _tab ("1.00 (ref)") _n
	
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

file close tablecontent

* Close log file 
log close













