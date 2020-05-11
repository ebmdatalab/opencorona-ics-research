/*==============================================================================
DO FILE NAME:			01_cr_create_analysis_dataset
PROJECT:				ICS in COVID-19 
DATE: 					6th of May 2020 
AUTHOR:					A Wong, A Schultze, C Rentsch
						adapted from K Baskharan, E Williamson 										
DESCRIPTION OF FILE:	check inclusion/exclusion citeria
						reformat variables 
						categorise variables
						label variables 
DATASETS USED:			data in memory (from analysis/input.csv)

DATASETS CREATED: 		analysis_dataset.dta
						lives in folder analysis/tempdata 
OTHER OUTPUT: 			logfiles, printed to folder analysis/log
							
==============================================================================*/

* Open a log file

cap log close
log using output\01_cr_create_analysis_dataset, replace t

/* SET FU DATES===============================================================*/ 
* Censoring dates for each outcome (largely, last date outcome data available)

global ituadmissioncensor 	= "20/04/2020"
global cpnsdeathcensor 		= "25/04/2020"
global onscoviddeathcensor 	= "06/04/2020"
global indexdate 			= "01/03/2020"

/* TEMP: INCLUSION/EXCLUIONS==================================================*/ 
* These should not make difference, should be in Python 

noi di "DROP MISSING GENDER:"
drop if inlist(sex,"I", "U")

noi di "DROP AGE <18:"
drop if age < 18 

noi di "DROP AGE >110:"
drop if age > 110 & age != .

noi di "DROP AGE MISSING:"
drop if age == . 

/* CHECK INCLUSION AND EXCLUSION CRITERIA=====================================*/ 

* DATA STRUCTURE: Confirm one row per patient 
duplicates tag patient_id, generate(dup_check)
assert dup_check == 0 
drop dup_check

* INCLUSION 1: Asthma in 3 years of 1 March 2020 

* INCLUSION 2: >=18 and <=110 at 1 March 2020 
assert age < .
assert age > 17 
assert age < 111 
 
* INCLUSION 3: Non-missing gender at 1 March 2020 
assert inlist(sex, "M", "F")

* EXCLUSION 1: 12 months or baseline time 
* EXCLUSION 2: No diagnosis of conflicting respiratory conditions 
* EXCLUSION 3: COPD 
* EXCLUSION 4: Nebulising treament 


* After checks, create variable for number of people in population 
gen total_pop = _N

/* RENAME VARAIBLES===========================================================*/

rename bmi_date_measured  	    			bmi_date_measured
rename bp_dias_date_measured	  			bp_dias_date
rename bp_sys_date_measured		   			bp_sys_date

/* CONVERT STRINGS TO DATE====================================================*/
/* Comorb dates are given with month only, so adding day 15 to enable
   them to be processed as dates 											  */


// 						Heart Failure					///
// 						Other Heart Disease				///
// 						Flu vaccine 					///
// 						Pneuomococcal vaccine			///
// 						GP consultation rate 			///
//						asthma           				///
//						ckd_diagnosis    				///

foreach var of varlist 	aplastic_anaemia				///
						bmi_date_measured 				///
						copd            				///
						creatinine_date  				///
						diabetes         				///
						haem_cancer      				///
						hiv             				///
						hypertension     				///
						ili              				///
						lung_cancer      				///
						other_cancer     				///
						other_respiratory 				///
						permanent_immunodeficiency   	///
						smoking_status_date				///
						temporary_immunodeficiency   	///
						vaccine							///
						ics_single                      ///
						saba_single                     ///
						sama_single                     ///
						laba_single                     ///
						lama_single                     ///
						laba_ics 	                    ///
						laba_lama 	                    ///
						laba_lama_ics					///
						nebules 						///
						oral_steroids					///
                        ltra_single {
							
		capture confirm string variable `var'
		if _rc!=0 {
			assert `var'==.
			rename `var' `var'_date
		}
	
		else {
				replace `var' = `var' + "-15"
				rename `var' `var'_dstr
				replace `var'_dstr = " " if `var'_dstr == "-15"
				gen `var'_date = date(`var'_dstr, "YMD") 
				order `var'_date, after(`var'_dstr)
				drop `var'_dstr
		}
	
	format `var'_date %td
}

* Note - outcome dates are handled separtely below 

/* RENAME VARAIBLES===========================================================*/
*  An extra 'date' added to the end of some variable names, remove 

rename creatinine_date_date 		creatinine_measured_date
rename smoking_status_date_date 	smoking_status_date
rename bmi_date_measured_date  		bmi_measured_date

* Some names too long for loops below, shorten

rename permanent_immunodeficiency_date perm_immunodef_date
rename temporary_immunodeficiency_date temp_immunodef_date

/* CREATE BINARY VARIABLES====================================================*/
*  Remove dates occuring after the index date
*  Create a variable 'time from measured until index' 
*  Create assertions to make sure variables are defined prior to index 

// 						Heart Failure					///
// 						Other Heart Disease				///
// 						Flu vaccine 					///
// 						Pneuomococcal vaccine			///
// 						GP consultation rate 			///
//						asthma           				///
//						ckd_diagnosis    				///
// 						exacerbation 					///

foreach var of varlist 	aplastic_anaemia_date			///
						bmi_measured_date 				///
						copd_date          				///
						creatinine_measured_date 		///
						diabetes_date       	    	///
						haem_cancer_date       			///
						hiv_date              			///
						hypertension_date      			///
						ili_date               			///
						lung_cancer_date       			///
						other_cancer_date      			///
						other_respiratory_date  		///
						perm_immunodef_date    			///
						temp_immunodef_date    			///
						vaccine_date  					///
						ics_single                      ///
						saba_single                     ///
						sama_single                     ///
						laba_single                     ///
						lama_single                     ///
						laba_ics 	                    ///
						laba_lama 	                    ///
						laba_lama_ics					///
						nebules 						///
						oral_steroids					///
                        ltra_single {
						
	local newvar =  substr("`var'", 1, length("`var'") - 5)
	gen `newvar' = (`var'< d("$indexdate"))
	order `newvar', after(`var')
	
	replace `var' = . if `var' > d("$indexdate")
	gen t_diff_`newvar' = d("$indexdate") - `var'
	order t_diff_`newvar', after(`newvar')
	
}

/* Confirm each covariate is defined before the index date
   Confirm each coviariate is defined using date occurring in the past 50 years 
*/ 

foreach var of varlist  t_diff_aplastic_anaemia			///
						t_diff_bmi_measured				///
						t_diff_copd						///
						t_diff_creatinine				///
						t_diff_diabetes					///
						t_diff_haem_cancer				///
						t_diff_hiv						///
						t_diff_hypertension				///
						t_diff_ili						///
						t_diff_lung_cancer				///
						t_diff_other_cancer				///
						t_diff_other_respiratory		///
						t_diff_perm_immunodef			///
						t_diff_temp_immunodef			///
						t_diff_vaccine {
						
	assert `var' > 0 
					
}

/* RECODE IMPLAUSIBLE VALUES==================================================*/

* BMI 
* SET BMI TO MISSING IF VERY FAR FROM INDEX? WHAT TIMEFRAME? 
summarize bmi, d
replace bmi = . if bmi == 0 
replace bmi = . if !inrange(bmi, 15, 50)

* Creatinine
summarize creatinine, d
replace creatinine = . if creatinine == 0 

/* CREATE VARIABLES===========================================================*/

describe

/* TREATMENTS */ 
                                   
* Set up exposure of interest 
* Need high and low dose, putting in combination vs. single for now

gen exposure = .  

replace exposure = 0 if saba_single    == 1 & ///
                        ics_single     != 1 & ///
						laba_single    != 1 & /// 
						lama_single    != 1 & ///
						laba_ics       != 1 & ///
						laba_lama      != 1 & ///
						laba_lama_ics  != 1 & ///
						ltra_single    != 1    
				
//* UPDATE WHEN YOU GET THE DOSES !!!!!!! //				
replace exposure = 1 if ics_single    == 1 

replace exposure = 2 if laba_ics      == 1 & ///				 
						laba_lama_ics == 1 
						
tab exposure 

foreach var of varlist  ics_single          ///
						saba_single 		///
						sama_single 	    ///
						laba_single 		///
						lama_single 		///
						laba_ics 			///
						laba_lama 			///
						laba_lama_ics 		///
						ltra_single {
						
tab `var' exposure, m
						
}

label define exposure 0 "SABA only" 1 "ICS low dose" 2 "ICS high dose" 
label values exposure exposure 

/* PLACEHOLDER FOR CHECKING DATE RANGE FOR EXPOSURE VARIABLES */ 

/* DEMOGRAPHICS */ 

* Sex
assert inlist(sex, "M", "F")
gen male = (sex == "M")
drop sex

* Smoking 
label define smoke 1 "Never" 2 "Former" 3 "Current" .u "Unknown (.u)"

gen     smoke = 1  if smoking_status == "N"
replace smoke = 2  if smoking_status == "E"
replace smoke = 3  if smoking_status == "S"
replace smoke = .u if smoking_status == "M"

label values smoke smoke
drop smoking_status

* Ethnicity 
replace ethnicity = .u if ethnicity == .

label define ethnicity 	1 "White"  					///
						2 "Mixed" 					///
						3 "Asian or Asian British"	///
						4 "Black"  					///
						5 "Other"					///
						.u "Unknown"

label values ethnicity ethnicity

* STP 
rename stp stp_old
bysort stp_old: gen stp = 1 if _n==1
replace stp = sum(stp)
drop stp_old

/*  Age variables  */ 

* Create categorised age
recode age 18/39.9999 = 1 /// 
           40/49.9999 = 2 ///
		   50/59.9999 = 3 ///
	       60/69.9999 = 4 ///
		   70/79.9999 = 5 ///
		   80/max = 6, gen(agegroup) 

label define agegroup 	1 "18-<40" ///
						2 "40-<50" ///
						3 "50-<60" ///
						4 "60-<70" ///
						5 "70-<80" ///
						6 "80+"
						
label values agegroup agegroup

* Create binary age
recode age min/69.999 = 0 ///
           70/max = 1, gen(age70)

* Check there are no missing ages
assert age < .
assert agegroup < .
assert age70 < .

* Create restricted cubic splines fir age
mkspline age = age, cubic nknots(4)

/*  Body Mass Index  */

* BMI (NB: watch for missingness)

gen 	bmicat = .
recode  bmicat . = 1 if bmi < 18.5
recode  bmicat . = 2 if bmi < 25
recode  bmicat . = 3 if bmi < 30
recode  bmicat . = 4 if bmi < 35
recode  bmicat . = 5 if bmi < 40
recode  bmicat . = 6 if bmi < .
replace bmicat = .u if bmi >= .

label define bmicat 1 "Underweight (<18.5)" 	///
					2 "Normal (18.5-24.9)"		///
					3 "Overweight (25-29.9)"	///
					4 "Obese I (30-34.9)"		///
					5 "Obese II (35-39.9)"		///
					6 "Obese III (40+)"			///
					.u "Unknown (.u)"
					
label values bmicat bmicat

* Create less  granular categorisation
recode bmicat 1/3 .u = 1 4 = 2 5 = 3 6 = 4, gen(obese4cat)

label define obese4cat 	1 "No record of obesity" 	///
						2 "Obese I (30-34.9)"		///
						3 "Obese II (35-39.9)"		///
						4 "Obese III (40+)"		

label values obese4cat obese4cat
order obese4cat, after(bmicat)

/*  Smoking  */
* Create non-missing 3-category variable for current smoking
* Assumes missing smoking is never smoking 
recode smoke .u = 1, gen(smoke_nomiss)
order smoke_nomiss, after(smoke)
label values smoke_nomiss smoke

describe 

/*  IMD  */
* Group into 5 groups
* There's imd that's -1 --> what does this mean? Should this be missing? 

rename imd imd_o
egen imd = cut(imd_o), group(5) icodes
replace imd = imd + 1
replace imd = .u if imd_o==-1
drop imd_o

* Reverse the order (so high is more deprived)
recode imd 5 = 1 4 = 2 3 = 3 2 = 4 1 = 5 .u = .u

label define imd 1 "1 least deprived" 2 "2" 3 "3" 4 "4" 5 "5 most deprived" .u "Unknown"
label values imd imd 


/* CLINICAL COMORBIDITIES */ 

/* Exacerbation	*/ 
*Need to make categories


/* GP consultation rate */ 
* Need to make categories 

/*  Cancer  */

gen cancer_ever =   (haem_cancer == 1 | /// 
                     lung_cancer == 1 | /// 
					 other_cancer ==1)			   

/*  Immunosuppression  */

* Immunosuppressed:
* HIV, permanent immunodeficiency ever, OR 
* temporary immunodeficiency or aplastic anaemia last year
gen temp1  = max(hiv, perm_immunodef)
gen temp2  = inrange(temp_immunodef_date, (date("$indexdate", "DMY") - 365), d("$indexdate"))
gen temp3  = inrange(aplastic_anaemia_date, (date("$indexdate", "DMY") - 365), d("$indexdate"))

egen immunodef_any = rowmax(temp1 temp2 temp3)
drop temp1 temp2 temp3
order immunodef_any, after(temp_immunodef_date)

/* eGFR=======================================================================*/

* Set implausible creatinine values to missing (Note: zero changed to missing)
replace creatinine = . if !inrange(creatinine, 20, 3000) 
	
* Divide by 88.4 (to convert umol/l to mg/dl)
gen SCr_adj = creatinine/88.4

gen min = .
replace min = SCr_adj/0.7 if male==0
replace min = SCr_adj/0.9 if male==1
replace min = min^-0.329  if male==0
replace min = min^-0.411  if male==1
replace min = 1 if min<1

gen max=.
replace max=SCr_adj/0.7 if male==0
replace max=SCr_adj/0.9 if male==1
replace max=max^-1.209
replace max=1 if max>1

gen egfr=min*max*141
replace egfr=egfr*(0.993^age)
replace egfr=egfr*1.018 if male==0
label var egfr "egfr calculated using CKD-EPI formula with no eth"

summarize egfr 

* Categorise into ckd stages
egen egfr_cat = cut(egfr), at(0, 15, 30, 45, 60, 5000)
recode egfr_cat 0 = 5 15 = 4 30 = 3 45 = 2 60 = 0, generate(ckd)

* 0 = "No CKD" 	2 "stage 3a" 3 "stage 3b" 4 "stage 4" 5 "stage 5"
label define ckd 0 "No CKD" 1 "CKD"
label values ckd ckd
label var ckd "CKD stage calc without eth"

* Convert into CKD group
recode ckd 2/5=1, gen(chronic_kidney_disease)
replace chronic_kidney_disease = 0 if creatinine==. 

/* PLACEHOLDER FOR CKD DIAGNOSIS AND DIALYSIS CODES TO BE ADDED IN */ 

/* OUTCOME AND SURVIVAL TIME==================================================*/

/*  Cohort entry and censor dates  */

* Date of cohort entry, 1 Mar 2020
gen enter_date = date("$indexdate", "DMY")

* Date of study end (typically: last date of outcome data available)
gen ituadmissioncensor_date 	= date("$ituadmissioncensor", 	"DMY") 
gen cpnsdeathcensor_date		= date("$cpnsdeathcensor", 		"DMY")
gen onscoviddeathcensor_date 	= date("$onscoviddeathcensor", 	"DMY")

* Format the dates
format 	enter_date					///
		cpnsdeathcensor_date 		///
		onscoviddeathcensor_date 	///
		ituadmissioncensor_date  %td

/*   Outcomes   */

/* !! COMMENTING OUT BECAUSE ALL DATES ARE MISSING 

* Dates of: ITU admission, CPNS death, ONS-covid death

tab died_date_cpns
tab died_date_ons
tab icu_date_admitted 

		

foreach var of varlist 	died_date_ons 		///
						died_date_cpns		///
						icu_date_admitted  {
						
	confirm string variable `var'
	rename `var' `var'_dstr
	gen `var' = date(`var'_dstr, "YMD")
	drop `var'_dstr
	format `var' %td 
	
}

rename icu_date_admitted itu_date

* Date of Covid death in ONS
gen died_date_onscovid = died_date_ons if died_ons_covid_flag_any == 1

* Binary indicators for outcomes
gen cpnsdeath 		= (died_date_cpns		< .)
gen onscoviddeath 	= (died_date_onscovid 	< .)
gen ituadmission 	= (itu_date 			< .)

/*  Create survival times  */

* For looping later, name must be stime_binary_outcome_name

* Survival time = last followup date (first: end study, death, or that outcome)
gen stime_ituadmission 	= min(ituadmissioncensor_date, 	itu_date, 		died_date_ons)
gen stime_cpnsdeath  	= min(cpnsdeathcensor_date, 	died_date_cpns, died_date_ons)
gen stime_onscoviddeath = min(onscoviddeathcensor_date, 				died_date_ons)

* If outcome was after censoring occurred, set to zero
replace ituadmission 	= 0 if (itu_date			> ituadmissioncensor_date) 
replace cpnsdeath 		= 0 if (died_date_cpns		> cpnsdeathcensor_date) 
replace onscoviddeath 	= 0 if (died_date_onscovid	> onscoviddeathcensor_date) 

* Format date variables
format  stime* %td 
	
*/ 

/* LABEL VARIABLES============================================================*/
*  Label variables you are intending to keep, drop the rest 

describe, fullname 

* Demographics
label var patient_id					"Patient ID"
label var total_pop						"Total Number in Study"
label var age 							"Age (years)"
label var agegroup						"Grouped age"
label var age70 						"70 years and older"
label var male 							"Male"
label var bmi 							"Body Mass Index (BMI, kg/m2)"
label var bmicat 						"Grouped BMI"
label var bmi_measured_date  		    "Body Mass Index (BMI, kg/m2), date measured"
label var obese4cat						"Evidence of obesity (4 categories)"
label var smoke		 					"Smoking status"
label var smoke_nomiss	 				"Smoking status (missing set to non)"
label var imd 							"Index of Multiple Deprivation (IMD)"
label var ethnicity						"Ethnicity"
label var stp 							"Sustainability and Transformation Partnership"

label var age1 							"Age spline 1"
label var age2 							"Age spline 2"
label var age3 							"Age spline 3"

* Exposure variables 

label var exposure 						"Treatment Exposure of Interest "
label var ics_single        		"Single ICS"
label var saba_single 				"Single SABA"
label var sama_single 	    		"Single SAMA"
label var laba_single 				"Single LABA"
label var lama_single 				"Single LAMA"
label var laba_ics 					"LABA ICS"		
label var laba_lama 				"LABA LAMA"
label var laba_lama_ics 			"LABA LAMA ICS"
label var ltra_single				"Single LTRA"

label var nebules 						"Nebules"
label var oral_steroids 				"Oral Steroids"

* Comorbidities of interest 

*label var chronic_kidney_disease      	"Chronic kidney disease" 
label var egfr_cat						"Calculated eGFR"
label var hypertension				    "Diagnosed hypertension"
*label var asthma						"Asthma"
label var ili 							"Infleunza Like Illness"
label var other_respiratory 			"Other Respiratory Diseases"
label var copd 							"COPD"
label var diabetes						"Diabetes"
label var cancer_ever 					"Cancer"
label var immunodef_any					"Immunosuppressed (combination algorithm)"

* Outcomes and follow-up
label var enter_date					"Date of study entry"
label var ituadmissioncensor_date 		"Date of admin censoring for itu admission (icnarc)"
label var cpnsdeathcensor_date 			"Date of admin censoring for cpns deaths"
label var onscoviddeathcensor_date 		"Date of admin censoring for ONS deaths"

label var ituadmission					"Failure/censoring indicator for outcome: ITU admission"
label var cpnsdeath						"Failure/censoring indicator for outcome: CPNS covid death"
label var onscoviddeath					"Failure/censoring indicator for outcome: ONS covid death"

* Survival times
*label var  stime_ituadmission			"Survival time (date); outcome ITU admission"
*label var  stime_cpnsdeath 				"Survival time (date); outcome CPNS covid death"
*label var  stime_onscoviddeath 			"Survival time (date); outcome ONS covid death"


/* TIDY DATA==================================================================*/
*  Drop variables that are needed (those labelled)
ds, not(varlabel)
drop `r(varlist)'
	
/* SAVE DATA==================================================================*/	

sort patient_id
label data "Analysis dataset ICU and Covid outcomes project, asthma population"
save tempdata\analysis_dataset, replace

/*
* Save a version set on CPNS survival outcome
* NEED OUTCOMES FOR THIS
stset stime_cpnsdeath, fail(cpnsdeath) id(patient_id) enter(enter_date) origin(enter_date)
	
save "analysis_dataset_STSET_cpnsdeath.dta", replace
*/ 

log close


