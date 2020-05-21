/*==============================================================================
DO FILE NAME:			01_cr_create_copd_population
PROJECT:				ICS in COVID-19 
DATE: 					14th of May 2020 
AUTHOR:					A Wong, A Schultze, C Rentsch
						adapted from K Baskharan, E Williamson 										
DESCRIPTION OF FILE:	program 01, COPD population for ICS project  
						check inclusion/exclusion citeria
						drop patients if not relevant 
DEPENDENCIES: 
DATASETS USED:			data in memory (from analysis/input_copd.csv)

DATASETS CREATED: 		analysis_dataset.dta
						lives in folder analysis/$tempdir 
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
							
==============================================================================*/

* Open a log file

cap log close
log using $logdir\01_cr_create_copd_population, replace t

/* APPLY INCLUSION/EXCLUIONS==================================================*/ 

noi di "DROP MISSING GENDER:"
drop if inlist(sex,"I", "U")

noi di "DROP AGE <35:"
drop if age < 35 

noi di "DROP AGE >110:"
drop if age > 110 & age != .

noi di "DROP AGE MISSING:"
drop if age == . 

noi di "DROP IMD MISSING"
drop if imd == .u

noi di "DROP IF DEAD BEFORE INDEX"
drop if stime_cpnsdeath < d("$indexdate")

/* CHECK INCLUSION AND EXCLUSION CRITERIA=====================================*/ 

* DATA STRUCTURE: Confirm one row per patient 
duplicates tag patient_id, generate(dup_check)
assert dup_check == 0 
drop dup_check

* INCLUSION 1: COPD ever before 1 March 2020 
assert copd == 1 

* INCLUSION 2: >=18 and <=110 at 1 March 2020 
assert age < .
assert age >= 35 
assert age <= 110
 
* INCLUSION 3: M or F gender at 1 March 2020 
assert inlist(sex, "M", "F")

* INCLUSION 4: Smoking record ever (current or past)
assert inlist(smoke, 2, 3)

* EXCLUSION 1: 12 months or baseline time 
* [VARIABLE NOT EXPORTED, CANNOT QUANTIFY]

* EXCLUSION 2: No diagnosis of conflicting respiratory conditions 
assert other_respiratory != 1
assert asthma_ever_date == . | (date($indexdate, DMY) - asthma_ever_date) >= (365.25*3-15)

* EXCLUSION 4: Nebulising treament 
* [VARIABLE NOT EXPORTED, CANNOT QUANTIFY]

* EXCLUDE 5:  MISSING IMD
assert inlist(imd, 1, 2, 3, 4, 5)

* EXCLUSION 6: NO LTRA, as asthma treatment 
assert ltra_single != 1 

* Close log file 
log close






