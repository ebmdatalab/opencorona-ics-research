/*==============================================================================
DO FILE NAME:			S1-09_model_exploration_copd
PROJECT:				ICS in COVID-19 
DATE: 					22nd of May 2020  
AUTHOR:					A Schultze 									
DESCRIPTION OF FILE:	program 09 
						explore different models 
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						S1table5, printed to analysis/$outdir
							
==============================================================================*/

* Open a log file

cap log close
log using $logdir\S1-09_an_model_explore_copd, replace t

* Open Stata dataset
use $tempdir\analysis_dataset_STSET_$outcome, clear

/* Print table================================================================*/ 
*  Print the results for the main model 

cap file close tablecontent
file open tablecontent using ./$outdir/S1table5.txt, write text replace

* Column headings 
file write tablecontent ("S1 Table 5: 1 by 1 comorbidity adjustments (after age/sex and strata adjustments) - $population population") _n
file write tablecontent _tab ("HR") _tab ("95% CI") _n

/* Adjust one covariate at a time=============================================*/

foreach var of varlist 	obese4cat				///
						smoke_nomiss			///
						imd 					///
						ckd	 					///		
						hypertension			///	
						heart_failure			///	
						other_heart_disease		///	
						diabetes 				///	
						cancer_ever 			///	
						statin 					///	
						insulin					///	
						oral_steroids 			///	
						flu_vaccine 			///	
						pneumococcal_vaccine	///	
						exacerbations 			///
						gp_consult { 
	
	local lab: variable label `var'
	file write tablecontent ("`lab'") _n 
	
	capture stcox i.exposure i.male age1 age2 age3 i.`var', strata(stp)	
	if !_rc {
		local lab0: label exposure 0
		local lab1: label exposure 1
		local lab2: label exposure 2

		file write tablecontent ("`lab0'") _tab
		file write tablecontent ("1.00 (ref)") _tab _n
		file write tablecontent ("`lab1'") _tab  
		
		qui lincom 1.exposure, eform
		file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n
		
		file write tablecontent ("`lab2'") _tab  
		
		qui lincom 2.exposure, eform
		file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab _n _n							
									
	}
	else di "*WARNING `var' MODEL DID NOT SUCCESSFULLY FIT*"
}

file write tablecontent _n
file close tablecontent

* Close log file 
log close


