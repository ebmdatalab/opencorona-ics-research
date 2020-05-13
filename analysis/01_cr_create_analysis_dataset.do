/*==============================================================================
DO FILE NAME:			A_01_cr_create_analysis_dataset
PROJECT:				ICS in COVID-19 
DATE: 					6th of May 2020 
AUTHOR:					A Wong, A Schultze, C Rentsch
						adapted from K Baskharan, E Williamson 										
DESCRIPTION OF FILE:	program 01, COPD population for ICS project  
						check inclusion/exclusion citeria
						reformat variables 
						categorise variables
						label variables 
DATASETS USED:			data in memory (from analysis/input.csv)

DATASETS CREATED: 		analysis_dataset.dta
						lives in folder analysis/tempdata 
OTHER OUTPUT: 			logfiles, printed to folder analysis/log
							
==============================================================================*/

* Create directories required 

capture mkdir copd_output
capture mkdir copd_log
capture mkdir copd_tempdata

* Open a log file

cap log close
log using copd_log\01_cr_create_analysis_dataset, replace t

/* SET FU DATES===============================================================*/ 
* Censoring dates for each outcome (largely, last date outcome data available)

global ituadmissioncensor 	= "20/04/2020"
global cpnsdeathcensor 		= "25/04/2020"
global onscoviddeathcensor 	= "06/04/2020"
global indexdate 			= "01/03/2020"

/* TEMP: INCLUSION/EXCLUIONS==================================================*/ 

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

* INCLUSION 1: COPD ever before 1 March 2020 

* INCLUSION 2: >=18 and <=110 at 1 March 2020 
assert age < .
assert age > 17 
assert age < 111 
 
* INCLUSION 3: M or F gender at 1 March 2020 
assert inlist(sex, "M", "F")

* INCLUSION 4: Smoking record ever (current or past)
* EXCLUSION 1: 12 months or baseline time 
* EXCLUSION 2: No diagnosis of conflicting respiratory conditions 
* EXCLUSION 3: COPD 
* EXCLUSION 4: Nebulising treament 
* EXCLUDE 5: DIED BEFORE THE 1ST OF MARCH 

* After checks, create variable for number of people in population 

/* RENAME VARAIBLES===========================================================*/

rename bmi_date_measured  	    			bmi_date_measured
rename bp_dias_date_measured	  			bp_dias_date
rename bp_sys_date_measured		   			bp_sys_date

/* CONVERT STRINGS TO DATE====================================================*/
/* Comorb dates are given with month only, so adding day 15 to enable
   them to be processed as dates 											  */

// 						heart failure					///
// 						exacerbation		 			///
//						asthma           				///

foreach var of varlist 	aplastic_anaemia				///
						bmi_date_measured 				///
						copd            				///
						creatinine_date  				///
						diabetes         				///
						flu_vaccine						///
						haem_cancer      				///
						hiv             				///
						hypertension     				///
						esrf 							///
						ili              				///
						lung_cancer      				///
						other_cancer     				///
						other_heart_disease				///
						other_respiratory 				///
						permanent_immunodeficiency   	///
						pneumococcal_vaccine			///
						smoking_status_date				///
						temporary_immunodeficiency   	///
						insulin 						///
						statin 							///
						ics_single                      ///
						low_med_dose_ics				///
						high_dose_ics					///
						saba_single                     ///
						sama_single                     ///
						laba_single                     ///
						lama_single                     ///
						laba_ics 	                    ///
						laba_lama 	                    ///
						laba_lama_ics					///
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
rename smoking_status_date_date 	smoking_status_measured_date
rename bmi_date_measured_date  		bmi_measured_date

* Some names too long for loops below, shorten

rename permanent_immunodeficiency_date perm_immunodef_date
rename temporary_immunodeficiency_date temp_immunodef_date

/* CREATE BINARY VARIABLES====================================================*/
*  Remove dates occuring after the index date
*  Create a variable 'time from measured until index' 
*  Create assertions to make sure variables are defined prior to index 

// 						Heart Failure					///
//						asthma           				///
// 						exacerbation 					///

foreach var of varlist 	aplastic_anaemia_date				///
						bmi_measured_date 					///
						copd_date            				///
						creatinine_measured_date  			///
						diabetes_date         				///
						haem_cancer_date      				///
						hiv_date             				///
						hypertension_date     				///
						esrf_date 							///
						flu_vaccine_date					///
						ili_date              				///
						lung_cancer_date     				///
						other_cancer_date    				///
						other_heart_disease_date			///
						other_respiratory_date 				///
						perm_immunodef_date   				///
						pneumococcal_vaccine_date			///
						smoking_status_measured_date		///
						temp_immunodef_date   				///
						insulin_date 						///
						statin_date 						///
						ics_single_date                     ///
						low_med_dose_ics_date				///
						high_dose_ics_date					///
						saba_single_date                    ///
						sama_single_date                    ///
						laba_single_date                    ///
						lama_single_date                    ///
						laba_ics_date 	                    ///
						laba_lama_date 	                    ///
						laba_lama_ics_date					///
						oral_steroids_date					///
                        ltra_single_date {
	
	replace `var' = . if (`var'> d("$indexdate"))
	local newvar =  substr("`var'", 1, length("`var'") - 5)
	gen `newvar' = (`var'< d("$indexdate"))
	order `newvar', after(`var')
	
}

/* 
	Potential checks: 
	Confirm each covariate is defined before the index date
    Confirm each coviariate is defined using date occurring in the past 50 years 

*/ 

/* CREATE VARIABLES===========================================================*/

/* TREATMENTS */ 
                                   
* Set up exposure of interest 

gen exptemp1 = 1 if laba_lama == 1 
gen exptemp2 = 1 if laba_single == 1 & lama_single == 1 

gen exptemp3 = 1 if laba_ics == 1 
gen exptemp4 = 1 if ics_single == 1 & laba_single == 1 
gen exptemp5 = 1 if ics_single == 1 & (laba_lama == 1 | lama_single == 1)
gen exptemp6 = 1 if laba_lama_ics == 1

gen exposure = 0 if		exptemp1 == 1 | ///
						exptemp2 == 1
						
replace exposure = 1 if exptemp3 == 1 | /// 
						exptemp4 == 1 | /// 
						exptemp5 == 1 | ///
						exptemp6 == 1 
						
recode exposure(0 = .) if ics_single == 1 
						
label define exposure 0 "LABA/LAMA Combination" 1 "ICS Combination" 
label values exposure exposure 

/* DEMOGRAPHICS */ 

* Sex
assert inlist(sex, "M", "F")
gen male = (sex == "M")
drop sex

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

/*  IMD  */
* Group into 5 groups
rename imd imd_o
egen imd = cut(imd_o), group(5) icodes

* add one to create groups 1 - 5 
replace imd = imd + 1

* - 1 is missing, should be excluded from population 
replace imd = .u if imd_o == -1
drop imd_o

* Reverse the order (so high is more deprived)
recode imd 5 = 1 4 = 2 3 = 3 2 = 4 1 = 5 .u = .u

label define imd 1 "1 least deprived" 2 "2" 3 "3" 4 "4" 5 "5 most deprived" .u "Unknown"
label values imd imd 

* Exclude unknowns 

drop if imd == .u 

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
* NB: watch for missingness

* Recode strange values 
summarize bmi, d
replace bmi = . if bmi == 0 
replace bmi = . if !inrange(bmi, 15, 50)

* Restrict to within 10 years of index and aged > 16 
gen bmi_time = (date("$indexdate", "DMY") - bmi_measured_date)/365.25
gen bmi_age = round(age - bmi_time, 0)

replace bmi = . if bmi_age < 16 
replace bmi = . if bmi_time > 10 

* Set to missing if no date, and vice versa 
replace bmi = . if bmi_measured_date == . 
replace bmi_measured_date = . if bmi == . 
replace bmi_measured_date = . if bmi == . 

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

* Smoking 
label define smoke 1 "Never" 2 "Former" 3 "Current" .u "Unknown (.u)"

gen     smoke = 1  if smoking_status == "N"
replace smoke = 2  if smoking_status == "E"
replace smoke = 3  if smoking_status == "S"
replace smoke = .u if smoking_status == "M"
replace smoke = .u if smoking_status == "" 

label values smoke smoke
drop smoking_status

* Create non-missing 3-category variable for current smoking
* Assumes missing smoking is never smoking 
recode smoke .u = 1, gen(smoke_nomiss)
order smoke_nomiss, after(smoke)
label values smoke_nomiss smoke

/* CLINICAL COMORBIDITIES */ 

/* Exacerbation	*/ 
*Need to make categories


/* GP consultation rate */ 
replace gp_consult_count = 0 if gp_consult_count <1 

* those with no count assumed to have no visits 
replace gp_consult_count = 0 if gp_consult_count == . 
gen gp_consult = (gp_consult_count >=1)


/*  Cancer  */

gen cancer_ever =   (haem_cancer == 1 | /// 
                     lung_cancer == 1 | /// 
					 other_cancer ==1)		
					 
gen cancer_ever_date = max(haem_cancer_date, lung_cancer_date, other_cancer_date)


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

* Remove creatinine dates if no measurements, and vice versa 

replace creatinine = . if creatinine_measured_date == . 
replace creatinine_measured_date = . if creatinine == . 
replace creatinine_measured = . if creatinine == . 

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

* Categorise into ckd stages
egen egfr_cat = cut(egfr), at(0, 15, 30, 45, 60, 5000)
recode egfr_cat 0 = 5 15 = 4 30 = 3 45 = 2 60 = 0, generate(ckd_egfr)

* 0 = "No CKD" 	2 "stage 3a" 3 "stage 3b" 4 "stage 4" 5 "stage 5"

* Add in end stage renal failure and create a single CKD variable 
gen ckd = 1 if esrf == 1 
replace ckd = 1 if ckd_egfr != . & ckd_egfr >= 1
replace ckd = 0 if ckd_egfr == . & esrf == 0 

label define ckd 0 "No CKD" 1 "CKD"
label values ckd ckd
label var ckd "CKD stage calc without eth"

* Create date 
gen temp1_ckd_date = creatinine_measured_date if ckd_egfr >=1
gen temp2_ckd_date = esrf_date if esrf == 1

*SOMETHING WRONG HERE 
gen ckd_date = max(temp1_ckd_date,temp2_ckd_date) 
format ckd_date %td 


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

* Dates of: ITU admission, CPNS death, ONS-covid death
* Recode to dates from the strings 
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

format died_date_ons %td
format died_date_onscovid %td 

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

/* LABEL VARIABLES============================================================*/
*  Label variables you are intending to keep, drop the rest 

describe, fullname 

* Demographics
label var patient_id				"Patient ID"
label var age 						"Age (years)"
label var agegroup					"Grouped age"
label var age70 					"70 years and older"
label var male 						"Male"
label var bmi 						"Body Mass Index (BMI, kg/m2)"
label var bmicat 					"Grouped BMI"
label var bmi_measured_date  		"Body Mass Index (BMI, kg/m2), date measured"
label var obese4cat					"Evidence of obesity (4 categories)"
label var smoke		 				"Smoking status"
label var smoke_nomiss	 			"Smoking status (missing set to non)"
label var imd 						"Index of Multiple Deprivation (IMD)"
label var ethnicity					"Ethnicity"
label var stp 						"Sustainability and Transformation Partnership"

label var age1 						"Age spline 1"
label var age2 						"Age spline 2"
label var age3 						"Age spline 3"

* Exposure variables 

label var exposure 					"Treatment Exposure of Interest "
label var high_dose_ics				"High Dose ICS"
label var low_med_dose_ics 			"Low/Medium Dose ICS"
label var ics_single        		"Single ICS"
label var saba_single 				"Single SABA"
label var sama_single 	    		"Single SAMA"
label var laba_single 				"Single LABA"
label var lama_single 				"Single LAMA"
label var laba_ics 					"LABA ICS"		
label var laba_lama 				"LABA LAMA"
label var laba_lama_ics 			"LABA LAMA ICS"
label var ltra_single				"Single LTRA"

label var oral_steroids 			"Oral Steroids"

label var high_dose_ics_date		"High Dose ICS Date"
label var low_med_dose_ics_date 	"Low/Medium Dose ICS Date"
label var ics_single_date        	"Single ICS Date"
label var saba_single_date 			"Single SABA Date"
label var sama_single_date 	    	"Single SAMA Date"
label var laba_single_date 			"Single LABA Date"
label var lama_single_date 			"Single LAMA Date"
label var laba_ics_date 			"LABA ICS Date"		
label var laba_lama_date 			"LABA LAMA Date"
label var laba_lama_ics_date		"LABA LAMA ICS Date"
label var ltra_single_date			"Single LTRA Date"

label var oral_steroids_date 			"Oral Steroids Date"

* Comorbidities of interest 

label var ckd     					 	"Chronic kidney disease" 
label var egfr_cat						"Calculated eGFR"
label var hypertension				    "Diagnosed hypertension"
*label var asthma						"Asthma"
label var ili 							"Infleunza Like Illness"
label var other_respiratory 			"Other Respiratory Diseases"
label var other_heart_disease 			"Other Heart Diseases"
label var copd 							"COPD"
label var diabetes						"Diabetes"
label var cancer_ever 					"Cancer"
label var immunodef_any					"Immunosuppressed (combination algorithm)"

label var statin 						"Recent Statin"
label var insulin						"Recent Insulin"
label var flu_vaccine					"Flu vaccine"
label var pneumococcal_vaccine			"Pneumococcal Vaccine"
label var gp_consult					"At least one GP consultation"

label var ckd_date     					"Chronic kidney disease Date" 
label var hypertension_date			    "Diagnosed hypertension Date"
*label var asthma						"Asthma  Date"
label var ili_date 						"Infleunza Like Illness Date"
label var other_respiratory_date 		"Other Respiratory Diseases Date"
label var other_heart_disease_date		"Other Heart Diseases Date"
label var copd_date 					"COPD Date"
label var diabetes_date					"Diabetes Date"
label var cancer_ever_date 				"Cancer Date"

label var statin_date 					"Recent Statin Date"
label var insulin_date					"Recent Insulin Date"
label var flu_vaccine_date				"Flu vaccine Date"
label var pneumococcal_vaccine_date 	"Pneumococcal Vaccine Date"

* Outcomes and follow-up
label var enter_date					"Date of study entry"
label var ituadmissioncensor_date 		"Date of admin censoring for itu admission (icnarc)"
label var cpnsdeathcensor_date 			"Date of admin censoring for cpns deaths"
label var onscoviddeathcensor_date 		"Date of admin censoring for ONS deaths"

label var ituadmission					"Failure/censoring indicator for outcome: ITU admission"
label var cpnsdeath						"Failure/censoring indicator for outcome: CPNS covid death"
label var onscoviddeath					"Failure/censoring indicator for outcome: ONS covid death"

label var died_date_cpns				"Date of CPNS Death"
label var died_date_onscovid 			"Date of ONS Death"
label var itu_date 						"Date of ITU Admission"

* Survival times
label var  stime_ituadmission			"Survival time (date); outcome ITU admission"
label var  stime_cpnsdeath 				"Survival time (date); outcome CPNS covid death"
label var  stime_onscoviddeath 			"Survival time (date); outcome ONS covid death"

/* TIDY DATA==================================================================*/
*  Drop variables that are needed (those labelled)
ds, not(varlabel)
drop `r(varlist)'
	
/* SAVE DATA==================================================================*/	

sort patient_id
save copd_tempdata\analysis_dataset, replace

* Save a version set on CPNS survival outcome
stset stime_cpnsdeath, fail(cpnsdeath) id(patient_id) enter(enter_date) origin(enter_date)	
save copd_tempdata\analysis_dataset_STSET_cpnsdeath, replace

log close


