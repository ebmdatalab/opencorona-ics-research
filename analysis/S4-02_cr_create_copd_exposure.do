/*==============================================================================
DO FILE NAME:			S4-02_cr_create_copd_exposure
PROJECT:				ICS in COVID-19 
DATE: 					21 July 2020 
AUTHOR:					A Schultze
						adapted from K Baskharan, E Williamson 
VERSION: 				Stata 16.1
DESCRIPTION OF FILE:	create exposure of interest for sensitivity analyses
						include lama monotherapy in sensitivty analyses 
DATASETS USED:			data in memory (from analysis/input.csv)

DATASETS CREATED: 		analysis_dataset.dta
						lives in folder analysis/$tempdir 
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
							
==============================================================================*/

* Open a log file

cap log close
log using $logdir\S4-02_cr_create_copd_exposure, replace t

/* TREATMENT EXPOSURE=========================================================*/	

/* LABA LAMA */ 
gen exposure = .u

* At least one prescription in LABA-LAMA combination list 
replace exposure = 0 if laba_lama == 1 
* OR at least one prescription of LABA AND at least one prescription of LAMA
replace exposure = 0 if laba_single == 1 & lama_single == 1 
* OR at least one prescription of LAMA monotherapy 
replace exposure = 0 if lama_single == 1
						
* AND no prescription for an ICS 
recode exposure(0 = .u) if ics_single == 1 
recode exposure(0 = .u) if laba_ics == 1 
recode exposure(0 = .u) if laba_lama_ics == 1 

*ICS 

* Any prescription for a LABA LAMA ICS combination 
gen exptemp3 = 1 if laba_lama_ics == 1
* OR Any prescription for a LABA ICS combination product 
gen exptemp4 = 1 if laba_ics == 1 
* OR Any prescription for single ICS + Single LABA
gen exptemp5 = 1 if ics_single == 1 & laba_single == 1 
* OR Any prescription for single ICS + LABA/LAMA
gen exptemp6 = 1 if ics_single == 1 & laba_lama == 1
					
replace exposure = 1 if exptemp3 == 1 | /// 
						exptemp4 == 1 | /// 
						exptemp5 == 1 | ///
						exptemp6 == 1 
						
replace exposure = .u if exposure >= .

* Note: ICS and LAMA only considered "Other", as per protocol					

* Define missing for tables 
replace exposure = .u if exposure >= .
						
label define exposure 0 "LABA/LAMA Combination" 1 "ICS Dual Combination" .u "Other"
label values exposure exposure 

label var exposure "COPD Treatment Exposure"

/* SAVE DATA==================================================================*/	

sort patient_id
save $tempdir\analysis_dataset, replace

* Save a version set on outcome
* Save a version set on survival outcome
stset stime_$outcome, fail($outcome) id(patient_id) enter(enter_date) origin(enter_date)	
save $tempdir\analysis_dataset_STSET_$outcome, replace

* Close log file 
log close