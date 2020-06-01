/*==============================================================================
DO FILE NAME:			03_an_checks
PROJECT:				ICS in COVID-19 
AUTHOR:					A Wong, A Schultze, C Rentsch
						Adapted from K Baskharan, E Williamson
DATE: 					10th of May 2020 
DESCRIPTION OF FILE:	Run sanity checks on all variables
							- Check variables take expected ranges 
							- Cross-check logical relationships 
							- Explore expected relationships 
							- Check stsettings 
DATASETS USED:			$tempdir\analysis_dataset.dta
DATASETS CREATED: 		None
OTHER OUTPUT: 			Log file: $logdir\03_an_checks
							
==============================================================================*/

* Open a log file

capture log close
log using $logdir\03_an_checks, replace t

* Open Stata dataset
use $tempdir\analysis_dataset, clear

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
datacheck inlist(obese4cat, 1, 2, 3, 4), nol
datacheck inlist(bmicat, 1, 2, 3, 4, 5, 6, .u), nol

* IMD
datacheck inlist(imd, 1, 2, 3, 4, 5), nol

* Ethnicity
datacheck inlist(ethnicity, 1, 2, 3, 4, 5, .u), nol

* Smoking
datacheck inlist(smoke, 1, 2, 3, .u), nol
datacheck inlist(smoke_nomiss, 1, 2, 3), nol 

* Check date ranges for all treatment variables  
foreach var of varlist 	high_dose_ics		///
						low_med_dose_ics 	///
						ics_single        	///
						saba_single 		///
						sama_single 	    ///
						laba_single 		///
						lama_single 		///
						laba_ics 			///
						laba_lama 			///
						laba_lama_ics 		///
						ltra_single	 {
						
	summ `var'_date, format

}

* Check date ranges for all comorbidities 

foreach var of varlist  asthma_ever					///
						ckd     					///			
						hypertension				///
						other_respiratory 			///
						other_heart_disease 		///
						heart_failure				///
						copd 						///
						diabetes					///
						cancer_ever 				///
						insulin						///
						oral_steroids				///	
						statin { 
						
	summ `var'_date, format

}

* Outcome dates

summ  stime_cpnsdeath stime_onscoviddeath,   format
summ  died_date_ons died_date_cpns died_date_onscovid, format


/* LOGICAL RELATIONSHIPS======================================================*/ 

* BMI
bysort bmicat: summ bmi
tab bmicat obese4cat, m

* Age
bysort agegroup: summ age
tab agegroup age70, m

* Smoking
tab smoke smoke_nomiss, m

* Diabetes
tab diabcat diabetes, m

* CKD
tab ckd egfr_cat, m

/* Treatment variables */ 

foreach var of varlist 	high_dose_ics		///
						low_med_dose_ics 	///
						ics_single        	///
						saba_single 		///
						sama_single 	    ///
						laba_single 		///
						lama_single 		///
						laba_ics 			///
						laba_lama 			///
						laba_lama_ics 		///
						ltra_single	 {
						
	tab exposure `var', row missing

}

tab high_dose_ics ics_single
tab low_med_dose_ics ics_single

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


/*  Relationships with demographic/lifestyle variables  */ 
						*exacerbation				///
						*exacerbation_count			///

* Relationships with age
foreach var of varlist  ckd     					///	
						asthma_ever					///
						hypertension				///
						other_respiratory 			///
						other_heart_disease 		///
						heart_failure				///
						copd 						///
						diabetes					///
						cancer_ever 				///
						statin 						///
						insulin						///
						flu_vaccine					///
						pneumococcal_vaccine		///								
						insulin 					///
						statin 						///
						immunodef_any				///
						exacerbations				///
						gp_consult 					{

		
 	tab agegroup `var', row 
 }


 * Relationships with sex
foreach var of varlist  ckd     					///	
						asthma_ever					///
						hypertension				///
						other_respiratory 			///
						other_heart_disease 		///
						heart_failure				///
						copd 						///
						diabetes					///
						cancer_ever 				///
						statin 						///
						insulin						///
						flu_vaccine					///
						pneumococcal_vaccine		///								
						insulin 					///
						statin 						///
						immunodef_any				///
						exacerbations				///
						gp_consult 					{
						
 	tab male `var', row 
}

 * Relationships with smoking
foreach var of varlist  ckd     					///	
						asthma_ever					///
						hypertension				///
						other_respiratory 			///
						other_heart_disease 		///
						heart_failure				///
						copd 						///
						diabetes					///
						cancer_ever 				///
						statin 						///
						insulin						///
						flu_vaccine					///
						pneumococcal_vaccine		///								
						insulin 					///
						statin 						///
						immunodef_any				///
						exacerbations				///
						gp_consult 					{
	
 	tab smoke `var', row 
}


/* SENSE CHECK OUTCOMES=======================================================*/

tab onscoviddeath cpnsdeath, row col


* Close log file 
log close
