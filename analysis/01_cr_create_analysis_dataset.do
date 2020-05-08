/*==============================================================================
DO FILE NAME:			01_cr_create_analysis_dataset
PROJECT:				Effect of ICS on Covid-19 outcomes
DATE: 					6th of May 2020 
AUTHOR:					Anna Schultze, Angel Wong, Christopher Rentsch									
DESCRIPTION OF FILE:	Check inclusion/exclusion citeria
						Reformat variables 
						Categorise variables
						Label variables 
DATASETS USED:			Data in memory (from analysis/input.csv)

DATASETS CREATED: 		cr_create_analysis_dataset.dta, in folder 
						analysis/tempdata 
OTHER OUTPUT: 			Logfiles, printed to folder analysis/log
							
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

/* RENAME VARAIBLES===========================================================*/

rename most_recent_unclear_smoking_cat		smoking_unclear_cat
rename most_recent_unclear_smoking_nume 	smoking_unclear_num
rename most_recent_unclear_smoking_cat_		smoking_unclear_date
rename bmi_date_measured  	    			bmi_date_measured
rename bp_dias_date_measured	  			bp_dias_date
rename bp_sys_date_measured		   			bp_sys_date

/* CONVERT STRINGS TO DATE====================================================*/
/* Comorb dates are given with month only, so adding day 15 to enable
   them to be processed as dates 											  */

// 						bone_marrow_transplant 			///
// 						chemo_radio_therapy 			///
// 						chronic_liver_disease 			///
// 						organ_transplant 				///	
// 						dysplenia						///
// 						sickle_cell 					///
// 						ra_sle_psoriasis  


// 						Heart Failure					///
// 						Other Heart Disease				///
// 						Flu vaccine 					///
// 						Pneuomococcal vaccine			///
// 						GP consultation rate 			///

foreach var of varlist 	aplastic_anaemia				///
						asthma           				///
						bmi_date_measured 				///
						ckd_diagnosis    				///
						copd            				///
						creatinine_date  				///
						diabetes         				///
						exacerbation     				///
						haem_cancer      				///
						hiv             				///
						hypertension     				///
						ili              				///
						lung_cancer      				///
						other_cancer     				///
						other_respiratory 				///
						permanent_immunodeficiency   	///
						smoking_status_date				///
						smoking_unclear_date           	///
						temporary_immunodeficiency   	///
						vaccine {

							
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

* Handle death dates separately because these are released as exact dates

gen died_cpns_date	= date(died_date_cpns, "YMD") 
format died_cpns_date %td 
gen died_cpns_flag  = 1 if died_cpns_date != . 
recode died_cpns_flag (. = 0)

tab died_cpns_flag

/* RENAME VARAIBLES===========================================================*/
*  An extra 'date' added to the end of some variables, remove 

rename creatinine_date_date 		creatinine_measured_date
rename smoking_unclear_date_date  	smoking_unclear_date
rename smoking_status_date_date 	smoking_status_date
rename bmi_date_measured_date  		bmi_measured_date

tab died_cpns_date

/* CREATE BINARY VARIABLES====================================================*/

foreach var of varlist 	aplastic_anaemia_date				///
						asthma_date           				///
						bmi_measured_date 					///
						ckd_diagnosis_date 					///
						copd_date          					///
						creatinine_measured_date 			///
						diabetes_date       	    		///
						exacerbation_date      				///
						haem_cancer_date       				///
						hiv_date              				///
						hypertension_date      				///
						ili_date               				///
						lung_cancer_date       				///
						other_cancer_date      				///
						other_respiratory_date  			///
						permanent_immunodeficiency_date    	///
						temporary_immunodeficiency_date    	///
						vaccine_date  {
						
	local newvar =  substr("`var'", 1, length("`var'") - 5)
	gen `newvar' = (`var'< d("$indexdate"))
	order `newvar', after(`var')
	
}

/* RECODE IMPLAUSIBLE VALUES==================================================*/

* BMI 
summarize bmi, d
replace bmi = . if bmi == 0 
replace bmi = . if !inrange(bmi, 15, 50)

* Creatinine
summarize creatinine, d
replace creatinine = . if creatinine == 0 

/* CREATE CATEGORICAL VARIABLES===============================================*/

* Check each variable type
describe

* Asthma Treatment: Primary exposure variable

local treatlist ics_single          ///
				saba_single 		///
				laba_single 		///
				lama_single 		///
				laba_ics 			///
				laba_lama 			///
				laba_lama_ics 		///
				ltra_single
				

foreach i in `treatlist' {	 
	tab `i', m
}
			
* Any Treatment

gen any_treament = 0 

foreach i in `treatlist' {	 
	replace any_treament = 1 if `i' >= 1
}

tab any_treament 
                                   
* Set up exposed (ICS-based) and unexposed groups (non-ICS based) 

gen 	exposed = 1 if ics_single >= 1 
replace exposed = 1 if laba_ics >= 1
replace exposed = 1 if laba_lama_ics >= 1

/* PLACEHOLDER FOR ICS DOSE */ 

replace exposed = 0 if saba_single == 1   &  ///
					   ics_single 	 < 1  &  ///
					   laba_ics		 < 1  &  ///
					   laba_single   < 1  &  ///
					   lama_single   < 1  &  ///
					   laba_lama 	 < 1  &  ///
					   laba_lama_ics < 1  &  ///
					   ltra_single 	 < 1  
					   
replace exposed = 3 if exposed == . 

tab exposed 

/* PLACEHOLDER FOR CHECKING DATE RANGE FOR EXPOSURE VARIABLES */ 

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
recode age 18/39.9999 = 1 40/49.9999 = 2 50/59.9999 = 3 ///
	60/69.9999 = 4 70/79.9999 = 5 80/max = 6, gen(agegroup) 

label define agegroup 	1 "18-<40" ///
						2 "40-<50" ///
						3 "50-<60" ///
						4 "60-<70" ///
						5 "70-<80" ///
						6 "80+"
						
label values agegroup agegroup

* Create binary age
recode age min/69.999 = 0 70/max = 1, gen(age70)

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

/*  Centred age, sex, IMD, ethnicity (for adjusted KM plots)  

* Centre age (linear)
summ age
gen c_age = age-r(mean)

* "Centre" sex to be coded -1 +1 
recode male 0=-1, gen(c_male)

* "Centre" IMD
gen c_imd = imd - 3

* "Centre" ethnicity
gen c_ethnicity = ethnicity - 3


*/


/*  Spleen  */

* Spleen problems (dysplenia/splenectomy/etc and sickle cell disease)   
// egen spleen = rowmax(dysplenia sickle_cell) 
// order spleen, after(sickle_cell)


/*  Cancer  */

label define cancer 1 "Never" 2 "Last year" 3 "2-5 years ago" 4 "5+ years"

* Haematological malignancies
gen     cancer_haem_cat = 4 if inrange(haem_cancer_date, d(1/1/1900), d(1/2/2015))
replace cancer_haem_cat = 3 if inrange(haem_cancer_date, d(1/2/2015), d(1/2/2019))
replace cancer_haem_cat = 2 if inrange(haem_cancer_date, d(1/2/2019), d(1/2/2020))
recode  cancer_haem_cat . = 1

label values cancer_haem_cat cancer


* All other cancers
gen     cancer_exhaem_cat = 4 if inrange(lung_cancer_date,  d(1/1/1900), d(1/2/2015)) | ///
								 inrange(other_cancer_date, d(1/1/1900), d(1/2/2015)) 
replace cancer_exhaem_cat = 3 if inrange(lung_cancer_date,  d(1/2/2015), d(1/2/2019)) | ///
								 inrange(other_cancer_date, d(1/2/2015), d(1/2/2019)) 
replace cancer_exhaem_cat = 2 if inrange(lung_cancer_date,  d(1/2/2019), d(1/2/2020)) | ///
								 inrange(other_cancer_date, d(1/2/2019), d(1/2/2020))
recode  cancer_exhaem_cat . = 1

label values cancer_exhaem_cat cancer

* Put variables together
order cancer_exhaem_cat cancer_haem_cat, after(other_cancer_date)


/*  Immunosuppression  */

* Immunosuppressed:
* HIV, permanent immunodeficiency ever, OR 
* temporary immunodeficiency or aplastic anaemia last year
gen temp1  = max(hiv, permanent_immunodeficiency)
gen temp2  = inrange(temporary_immunodeficiency_date, d(1/11/2019), d(1/2/2020))
gen temp3  = inrange(aplastic_anaemia_date, d(1/11/2019), d(1/2/2020))

egen other_immunosuppression = rowmax(temp1 temp2 temp3)
drop temp1 temp2 temp3
order other_immunosuppression, after(temporary_immunodeficiency)


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

* Categorise into ckd stages
egen egfr_cat = cut(egfr), at(0, 15, 30, 45, 60, 5000)
recode egfr_cat 0=5 15=4 30=3 45=2 60=0, generate(ckd)
* 0 = "No CKD" 	2 "stage 3a" 3 "stage 3b" 4 "stage 4" 5 "stage 5"
label define ckd 0 "No CKD" 1 "CKD"
label values ckd ckd
label var ckd "CKD stage calc without eth"

* Convert into CKD group
recode ckd 2/5=1, gen(chronic_kidney_disease)
replace chronic_kidney_disease = 0 if creatinine==. 

tab ckd_diagnosis 

/* OUTCOME AND SURVIVAL TIME==================================================*/


/*  Cohort entry and censor dates  */

* Date of cohort entry, 1 Feb 2020
gen enter_date = date("01/02/2020", "DMY")

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
********************************************************************************CTR NOTE: ONS date numeric because value is 2020 for 11 people. the rest are missing
********************************************************************************CTR NOTE: only 4 people have CPNS and 3 ICU outcomes
foreach var of varlist 	/*died_date_ons*/ died_date_cpns		///
						icu_date_admitted  {
	confirm string variable `var'
	rename `var' `var'_dstr
	gen `var' = date(`var'_dstr, "YMD")
	drop `var'_dstr
}
rename icu_date_admitted itu_date

* Date of Covid death in ONS
gen died_date_onscovid = died_date_ons if died_ons_covid_flag_any==1

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
format stime* %td 
format	stime* 				///
		itu_date 			///
		died_date_onscovid 	///
		died_date_ons 		///
		died_date_cpns %td 

		
		
		
		
		

*********************
*  Label variables  *
*********************

describe

* Demographics
label var patient_id					"Patient ID"
label var age 							"Age (years)"
label var agegroup						"Grouped age"
label var age70 						"70 years and older"
label var male 							"Male"
label var bmi 							"Body Mass Index (BMI, kg/m2)"
label var bmicat 						"Grouped BMI"
label var bmi_date  					"Body Mass Index (BMI, kg/m2), date measured"
label var obese4cat						"Evidence of obesity (4 categories)"
label var smoke		 					"Smoking status"
label var smoke_nomiss	 				"Smoking status (missing set to non)"
label var imd 							"Index of Multiple Deprivation (IMD)"
label var ethnicity						"Ethnicity"
label var stp 							"Sustainability and Transformation Partnership"
// label var region 						"Geographical region"

// label var hba1ccat						"Categorised hba1c"

label var chronic_kidney_disease      	"Chronic kidney disease" 
label var egfr_cat						"Calculated eGFR"
	
label var bp_sys 						"Systolic blood pressure"
label var bp_sys_date 					"Systolic blood pressure, date"
label var bp_dias 						"Diastolic blood pressure"
label var bp_dias_date 					"Diastolic blood pressure, date"
label var bpcat 						"Grouped blood pressure"
label var bphigh						"Binary high (stage 1/2) blood pressure"
label var htdiag_or_highbp				"Diagnosed hypertension or high blood pressure"

label var age1 							"Age spline 1"
label var age2 							"Age spline 2"
label var age3 							"Age spline 3"
label var c_age							"Centred age"
label var c_male 						"Centred sex (code: -1/+1)"
label var c_imd							"Centred Index of Multiple Deprivation (values: -2/+2)"
label var c_ethnicity					"Centred ethnicity (values: -2/+2)"

* Comorbidities
// label var chronic_respiratory_disease	"Respiratory disease (excl. asthma)"
// label var asthmacat						"Asthma, grouped by severity (OCS use)"
label var asthma						"Asthma"
// label var chronic_cardiac_disease		"Heart disease"
label var diabetes						"Diabetes"
// label var diabcat						"Diabetes, grouped"
label var cancer_exhaem_cat				"Cancer (exc. haematological), grouped by time since diagnosis"
label var cancer_haem_cat				"Haematological malignancy, grouped by time since diagnosis"
// label var chronic_liver_disease			"Chronic liver disease"
// label var stroke_dementia				"Stroke or dementia"
// label var other_neuro					"Neuro condition other than stroke/dementia"	
label var chronic_kidney_disease 		"Kidney disease"
// label var organ_transplant 				"Organ transplant recipient"
// label var dysplenia						"Dysplenia (splenectomy, other, not sickle cell)"
// label var sickle_cell 					"Sickle cell"
// label var spleen						"Spleen problems (dysplenia, sickle cell)"
// label var ra_sle_psoriasis				"RA, SLE, Psoriasis (autoimmune disease)"
// label var chemo_radio_therapy			"Chemotherapy or radiotherapy"
label var aplastic_anaemia				"Aplastic anaemia"
label var hiv 							"HIV"
label var permanent_immunodeficiency 	"Permanent immunodeficiency"
label var temporary_immunodeficiency 	"Temporary immunosuppression"
label var other_immunosuppression		"Immunosuppressed (combination algorithm)"
// label var chronic_respiratory_disease_date	"Respiratory disease (excl. asthma), date"
// label var chronic_cardiac_disease_date	"Heart disease, date"
label var diabetes_date					"Diabetes, date"
label var lung_cancer_date				"Lung cancer, date"
label var haem_cancer_date				"Haem. cancer, date"
label var other_cancer_date				"Any cancer, date"
// label var bone_marrow_transplant_date	"Organ transplant, date"
// label var chronic_liver_disease_date	"Liver, date"
// label var stroke_date					"Stroke, date"
// label var dementia_date					"Dementia, date"
// label var other_neuro_date				"Neuro condition other than stroke/dementia, date"	
// label var organ_transplant_date			"Organ transplant recipient, date"
// label var dysplenia_date				"Splenectomy etc, date"
// label var sickle_cell_date 				"Sickle cell, date"
// label var ra_sle_psoriasis_date			"RA, SLE, Psoriasis (autoimmune disease), date"
// label var chemo_radio_therapy_date		"Chemotherapy or radiotherapy, date"
label var aplastic_anaemia_date			"Aplastic anaemia, date"
label var hiv_date 						"HIV, date"
label var permanent_immunodeficiency_date "Permanent immunodeficiency, date"
label var temporary_immunodeficiency_date "Temporary immunosuppression, date"

* Outcomes and follow-up
label var enter_date					"Date of study entry"
label var ituadmissioncensor_date 		"Date of admin censoring for itu admission (icnarc)"
label var cpnsdeathcensor_date 			"Date of admin censoring for cpns deaths"
label var onscoviddeathcensor_date 		"Date of admin censoring for ONS deaths"

label var ituadmission					"Failure/censoring indicator for outcome: ITU admission"
label var cpnsdeath						"Failure/censoring indicator for outcome: CPNS covid death"
label var onscoviddeath					"Failure/censoring indicator for outcome: ONS covid death"

* Survival times
label var  stime_ituadmission			"Survival time (date); outcome ITU admission"
label var  stime_cpnsdeath 				"Survival time (date); outcome CPNS covid death"
label var  stime_onscoviddeath 			"Survival time (date); outcome ONS covid death"




		
		

		
		
		
***************
*  Tidy data  *
***************
****************************************************************************** CTR NOTE: I pulled from risk factor analysis, but did nothing else. let's wait for real data
* REDUCE DATASET SIZE TO VARIABLES NEEDED
// keep patient_id imd stp region enter_date  									///
// 	ituadmission itu_date ituadmissioncensor_date stime_ituadmission		///
// 	cpnsdeath died_date_cpns cpnsdeathcensor_date stime_cpnsdeath			///
// 	onscoviddeath onscoviddeathcensor_date died_date_ons died_date_onscovid ///
// 	stime_onscoviddeath														///
// 	age agegroup age70 age1 age2 age3 male bmi smoke   						///
// 	smoke smoke_nomiss bmicat bpcat_nomiss obese4cat ethnicity 				///
// 	bpcat bphigh htdiag_or_highbp hypertension 								///
// 	chronic_respiratory_disease asthma asthmacat chronic_cardiac_disease 	///
// 	diabetes diabcat hba1ccat cancer_exhaem_cat cancer_haem_cat 			///
// 	chronic_liver_disease organ_transplant spleen ra_sle_psoriasis 			///
// 	chronic_kidney_disease stroke dementia stroke_dementia other_neuro		///
// 	other_immunosuppression   												///
// 	creatinine egfr egfr_cat ckd  chronic_kidney_disease



***************
*  Save data  *
***************

sort patient_id
label data "Analysis dataset ICU and Covid outcomes project, asthma population"
save "cr_create_analysis_dataset.dta", replace

* Save a version set on CPNS survival outcome
stset stime_cpnsdeath, fail(cpnsdeath) id(patient_id) enter(enter_date) origin(enter_date)
	
save "cr_create_analysis_dataset_STSET_cpnsdeath.dta", replace


log close


