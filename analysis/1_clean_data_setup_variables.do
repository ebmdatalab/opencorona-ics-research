/*=========================================================================
DO FILE NAME:			1_clean_data_setup_variables

AUTHOR:					Angel Wong
												
VERSION:				v1

DATE VERSION CREATED: 	2020-05-05
	
DESCRIPTION OF FILE:	Aim: set up variables and format data variables

DATASETS CREATED: 		"cr_create_analysis_dataset"
							
=========================================================================*/
clear all
set more off
capture log close

* create a filename global that can be used throughout the file
global filename "1_clean_data_setup_variables"

* open log file - no need as fast tool will create log files
log using "${pathLogs}/${filename}", text replace

*********************************************************************
*import data
import delimited using "$pathIn/input.csv", clear

*Unique patid
unique patient_id

*check each variable type
des

*Check the meds_categories
foreach i in ics_single oral_steroids saba_single ///
laba_single lama_single laba_ics laba_lama laba_lama_ics ltra_single {
	tab `i', m
}                
                             
*Set up exposed (ICS-based) and unexposed groups (non-ICS based) no Rx date
gen exposed=1 if ics_single==1 | ics_single==2
replace exposed=1 if laba_ics==1 | laba_ics==2
replace exposed=1 if laba_lama_ics==1 | laba_ics==2
replace exposed=0 if exposed==.

*************
*Age limited to >=18 and <=110
************
su age, detail
keep if age>=18 & age<=110
su age, detail

*************
*Sex (only limit to M/F)
************ 
codebook sex
keep if sex=="F" | sex=="M"
tab sex,m
gen gender=1 if sex=="M"
replace gender=2 if sex=="F" 
label var gender "Sex"
label def sex_lbl 1 "Male" 2 "Female"
label val gender sex_lbl

*************
*Ethnicity
************
tab ethnicity,m
label def eth_lbl 1 "White" 2 "Mixed" 3 "Asian or Asian British" ///
 4 "Black" 5 "Other ethnic groups"
label val ethnicity eth_lbl

*************
*IMD
************
* Group into 5 groups
rename imd imd_o
egen imd = cut(imd_o), group(5) icodes
replace imd = imd + 1
replace imd = .u if imd_o==-1
drop imd_o

* Reverse the order (so high is more deprived)
recode imd 5=1 4=2 3=3 2=4 1=5 .u=.u

label define imd 1 "1 least deprived" 2 "2" 3 "3" 4 "4" 5 "5 most deprived" .u "Unknown"
label values imd imd 

*************
*Geographic region: STP
************
egen stp_cat=group(stp)
replace stp_cat=.u if stp_cat==.

*************
*BMI
************
* Set implausible BMIs to missing:
replace bmi = . if !inrange(bmi, 15, 50) 

egen bmi_cat=cut(bmi), at(0,18.5,25,30,1000) 
recode bmi_cat 18.5=1
recode bmi_cat 25=2
recode bmi_cat 30=3

label define bmi_cat 0 "Underweight" 1 "Normal Weight" 2 "Overweight" 3 "Obese"
lab val bmi_cat bmi_cat
tab bmi_cat,m

*************
*Smoking status
************
tab most_recent_unclear_smoking_cat,m 
tab smoking_status,m 

label define smoke 1 "Never" 2 "Former" 3 "Current" .u "Unknown (.u)"
gen     smoke = 1  if smoking_status=="N"
replace smoke = 2  if smoking_status=="E"
replace smoke = 3  if smoking_status=="S"
replace smoke = .u if smoking_status=="M"
label values smoke smoke
drop smoking_status

rename most_recent_unclear_smoking_cat_ most_recent_unclear_smok

*************
*Other comorbidities
************
*convert all date for formatting
foreach i in smoking_status_date most_recent_unclear_smok ///
copd asthma other_respiratory ili hypertension bp_sys_date_measured ///
 bp_dias_date_measured diabetes haem_cancer lung_cancer other_cancer ///               
aplastic_anaemia permanent_immunodeficiency temporary_immunodeficiency hiv ///                 
creatinine_date ckd_diagnosis exacerbation vaccine {
gen `i'_year=substr(`i',1,4)
tab `i'_year,m
gen `i'_month=substr(`i',6,7)
tab `i'_month,m
destring `i'_year, replace
destring `i'_month, replace
gen `i'_day=1
gen `i'_date =mdy(`i'_month, `i'_day, `i'_year)
format `i'_date %td
drop `i'_day `i'_year `i'_month `i'
}

************
*CKD
************
*calculate eGFR using creatinine measurements  *
* Set implausible creatinine values to missing (Note: zero changed to missing)
replace creatinine = . if !inrange(creatinine, 20, 3000) 
	
* Divide by 88.4 (to convert umol/l to mg/dl)
gen SCr_adj = creatinine/88.4

gen male=0 if gender==2
replace male=1 if gender==1

gen min=.
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
recode ckd 2/5=1, gen(ckd_egfr)
replace ckd_egfr = 0 if creatinine ==. 


**check dates later!!!!

************
*Cancer
************
gen all_cancer_date = min(haem_cancer_date, lung_cancer_date, other_cancer_date) //subject to change
format all_cancer_date %td


************
*Generate variables: study population (copd & asthma) & other cormobidities
*not including the date of cohort entry
************
gen start_date = date("01/03/2020", "DMY")
format start_date %td

foreach i in hypertension diabetes copd asthma ///
 other_respiratory all_cancer hiv permanent_immunodeficiency {
	gen `i' = 1 if `i'_date < start_date
	replace `i' = 0 if `i' ==.
}

************
*Generate Immunosuppression variable
************
* Immunosuppressed:
* HIV, permanent immunodeficiency ever, OR 
* temporary immunodeficiency or aplastic anaemia last year (1/11/2019 same as Risk factor study)
//end date: 1 day before i.e. 29/2/2020 (otherwise 01/3/2020 is inclusive)

gen temp1  = max(hiv, permanent_immunodeficiency)
gen temp2  = inrange(temporary_immunodeficiency_date, d(1/11/2019), d(29/2/2020))
gen temp3  = inrange(aplastic_anaemia_date, d(1/11/2019), d(29/2/2020)) 

egen immuno_final = rowmax(temp1 temp2 temp3)
drop temp1 temp2 temp3

************
*Generate Vaccine variable (From 1st Sep 2019 to day prior to index date TBC)
************
gen vaccine_min_date = date("01/09/2019", "DMY")
format vaccine_min_date %td
gen vaccine = 1 if vaccine_date >= vaccine_min_date & vaccine_date < start_date
replace vaccine = 0 if vaccine ==.
drop vaccine_min_date

************
*Covariate distributions
************
foreach i in gender smoke bmi_cat ethnicity ///
hypertension diabetes other_respiratory ckd_egfr  ///
  all_cancer immuno_final vaccine {
	tab `i' exposed, col m
}

save "cr_create_analysis_dataset", replace

log close
