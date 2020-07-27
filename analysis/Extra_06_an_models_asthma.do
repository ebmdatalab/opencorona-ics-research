/*==============================================================================
DO FILE NAME:			Extra_06_models_asthma
PROJECT:				ICS in COVID-19 
DATE: 					21 of May 2020  
AUTHOR:					A Schultze 		
VERSION: 				Stata 16.1							
DESCRIPTION OF FILE:	program Extra_06 
						sensitivity regression models 
						different adjustment sets 
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						table2, printed to analysis/$outdir
							
==============================================================================*/

* Open a log file

cap log close
log using $logdir\Extra_06_an_models_asthma, replace t

* Open Stata dataset
use $tempdir\analysis_dataset_STSET_$outcome, clear

/* Sense check outcomes=======================================================*/ 

tab exposure $outcome, missing row

* Original model
stcox i.exposure i.male age1 age2 age3 	i.obese4cat					///
										i.smoke_nomiss				///
										i.imd 						///
										i.ckd	 					///
										i.hypertension			 	///
										i.heart_failure				///
										i.other_heart_disease		///
										i.diabcat 					///
										i.cancer_ever 				///
										i.statin 					///
										i.flu_vaccine 				///
										i.pneumococcal_vaccine		///
										i.exacerbations 			///
										i.immunodef_any, strata(stp)
										
estimates save ./$tempdir/multivar2, replace 

* Without exacerbations 									
stcox i.exposure i.male age1 age2 age3 	i.obese4cat					///
										i.smoke_nomiss				///
										i.imd 						///
										i.ckd	 					///
										i.hypertension			 	///
										i.heart_failure				///
										i.other_heart_disease		///
										i.diabcat 					///
										i.cancer_ever 				///
										i.statin 					///
										i.flu_vaccine 				///
										i.pneumococcal_vaccine		///
										i.immunodef_any	, strata(stp)		

estimates save ./$tempdir/multivar3, replace 

* Add oral steroids instead of exacerbations
stcox i.exposure i.male age1 age2 age3 	i.obese4cat					///
										i.smoke_nomiss				///
										i.imd 						///
										i.ckd	 					///
										i.hypertension			 	///
										i.heart_failure				///
										i.other_heart_disease		///
										i.diabcat 					///
										i.cancer_ever 				///
										i.statin 					///
										i.flu_vaccine 				///
										i.pneumococcal_vaccine		///
										i.immunodef_any				///
										i.oral_steroids, strata(stp)
										
estimates save ./$tempdir/multivar4, replace 
	
/* Print table================================================================*/ 
*  Print the results for the main model 

cap file close tablecontent
file open tablecontent using ./$outdir/Extratable2.txt, write text replace

* Column headings 
file write tablecontent ("Extra Table 2: Different Adjustment Sets") _n
file write tablecontent ("Adjustment Set") _tab _tab ("HR") _tab ("95% CI") _n			

* Row headings 
local lab0: label exposure 0
local lab1: label exposure 1
local lab2: label exposure 2

/* Main Model */ 

file write tablecontent ("Main Model") _tab

file write tablecontent ("`lab0'") _tab
file write tablecontent ("1.00 (ref)") _tab _tab  _n
file write tablecontent _tab ("`lab1'") _tab  

estimates use ./$tempdir/multivar2 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n 

file write tablecontent _tab ("`lab2'") _tab  
lincom 2.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n 

/* No exacerbation history */ 

file write tablecontent ("Wo. Exposure History") _tab

file write tablecontent ("`lab0'") _tab
file write tablecontent ("1.00 (ref)") _tab _tab  _n
file write tablecontent _tab ("`lab1'") _tab  

estimates use ./$tempdir/multivar3 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n 

file write tablecontent _tab ("`lab2'") _tab  
lincom 2.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n 

/* Oral Steroids */ 

file write tablecontent ("W oral steroids") _tab

file write tablecontent ("`lab0'") _tab
file write tablecontent ("1.00 (ref)") _tab _tab  _n
file write tablecontent _tab ("`lab1'") _tab  

estimates use ./$tempdir/multivar4 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n 

file write tablecontent _tab ("`lab2'") _tab  
lincom 2.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n 

file write tablecontent _n
file close tablecontent

* Close log file 
log close