/*==============================================================================
DO FILE NAME:			02_an_checks
PROJECT:				ICS in COVID-19 
AUTHOR:					A Wong, A Schultze, C Rentsch
						Adapted from K Baskharan, E Williamson
DATE: 					10th of May 2020 
DESCRIPTION OF FILE:	Run sanity checks on all variables
							- Check variables take expected ranges 
							- Cross-check logical relationships 
							- Explore expected relationships 
							- Check stsettings 
DATASETS USED:			!! UPDATE NAME 
DATASETS CREATED: 		None
OTHER OUTPUT: 			Log file: output/an_checks
							
==============================================================================*/

* Open a log file

capture log close
log using output\02_an_checks, replace t

* Open Stata dataset
use tempdata\an_data, clear

describe

*run ssc install if not already installed on your computer
*ssc install datacheck 

*Duplicate patient check
datacheck _n==1, by(patient_id) nol

/* EXPECTED VALUES============================================================*/ 

* Age
datacheck age<., nol
datacheck inlist(agegroup, 1, 2, 3, 4, 5, 6), nol
datacheck inlist(age70, 0, 1), nol

* Sex
datacheck inlist(male, 0, 1), nol

* BMI 
datacheck inlist(obese4cat, 0, 1), nol
datacheck inlist(bmicat, 1, 2, 3, 4, 5, 6, .u), nol

* IMD
datacheck inlist(imd, 1, 2, 3, 4, 5, .u), nol

* Ethnicity
datacheck inlist(ethnicity, 1, 2, 3, 4, 5, .u), nol

* Smoking
datacheck inlist(smoke, 1, 2, 3, .u), nol
datacheck inlist(smoke_nomiss, 1, 2, 3), nol 

/* Check date ranges for all comorbidities */
/* Dates of comorbidities  
foreach var of varlist 	chronic_respiratory_disease 	///
						chronic_cardiac_disease 		///
						diabetes 						///
						chronic_liver_disease 			///
						organ_transplant 				///	
						ra_sle_psoriasis  {
	summ `var'_date, format
	bysort `var': summ `var'_date
}

* Outcome dates

summ stime_ituadmission stime_cpnsdeath stime_onscoviddeath,   format
summ itu_date died_date_ons died_date_cpns died_date_onscovid, format

*/

/* LOGICAL RELATIONSHIPS======================================================*/ 

* BMI
bysort bmicat: summ bmi
tab bmicat obese4cat, m

* Age
bysort agegroup: summ age
tab agegroup age70, m

* Smoking
tab smoke smoke_nomiss, m

/* ADD 

ALL TREATMENT VARIABLES TO CHECK THESE ARE AS EXPECTED
LIFT THIS CHECK FROM THE 01 FILE 

*/

/* EXPECTED RELATIONSHIPS=====================================================*/ 

/*  Relationships between demographic/lifestyle variables  */

tab agegroup bmicat, 	row 
tab agegroup smoke, 	row 
tab agegroup ethnicity, row  
tab agegroup imd, 		row 

tab bmicat smoke, 		 row  
tab bmicat ethnicity, 	 row 
tab bmicat imd, 	 	 row 
tab bmicat hypertension, row

tab smoke ethnicity, 	row  
tab smoke imd, 			row  
tab smoke hypertension, row 

tab ethnicity imd, 		row

/* ADD 

Asthma and smoking
Asthma and medication 
COPD and smoking
COPD and medications 

*/ 

/*  Relationships with demographic/lifestyle variables  
COMPLETE WITH THE COMPLETE COVARIATE LIST 

* Relationships with age
 foreach var of  foreach var of varlist [PLACEHOLDER] {
 	tab agegroup `var', row col
 }


 * Relationships with sex
 foreach var of varlist [PLACEHOLDER] {
 	tab male `var', row col
 }

 * Relationships with smoking
 foreach var of varlist [PLACEHOLDER] {
 	tab smoke `var', row col
 }


/* SENSE CHECK OUTCOMES=======================================================*/

tab onscoviddeath cpnsdeath, row col

*/

* Close log file 
log close