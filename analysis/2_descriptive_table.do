/*=========================================================================
DO FILE NAME:			2_descriptive_table

AUTHOR:					Angel Wong
												
VERSION:				v1

DATE VERSION CREATED: 	2020-05-05
	
DESCRIPTION OF FILE:	Aim: describe the baseline characteristics of the exposed
and unexposed groups & produce output table in text format

DATASETS CREATED: 		
							
=========================================================================*/
/*******************************************************************************
>> HOUSEKEEPING
*******************************************************************************/
clear all
set more off
capture log close

* create a filename global that can be used throughout the file
global filename "2_descriptive_table"

* open log file - no need as fast tool will create log files
log using "${pathLogs}/${filename}", text replace

*********************************************************************
use "cr_create_analysis_dataset", clear

*ignore the inclusion and exclusion criteria for now

*Set up output file
cap file close table1 
file open table1 using "H:\My Documents\GitHub\opencorona-ics-research\analysis/output/baseline_table_Px.txt", write replace
file write table1 "Baseline characteristics"_tab "Non-ICS based therapy"_tab "ICS based therapy"_tab _n

*Show the total number of patients who exposed and unexposed respectively
tab exposed, matcell(exp)
matrix rowtot = exp/r(N)*100
matrix list rowtot

file write table1 "Total" _tab %9.0fc (exp[1,1]) " (" %3.2f (rowtot[1,1]) ")" _tab %9.0fc (exp[2,1]) " (" %3.2f (rowtot[2,1]) ")" _n 

*Show covariate distributions
*Age (median + IQR)
preserve
keep if exposed==1
su age, detail
scalar exp_age_25=r(p25)
scalar exp_age_50=r(p50)
scalar exp_age_75=r(p75)
restore
preserve
keep if exposed==0
su age, detail
scalar unexp_age_25=r(p25)
scalar unexp_age_50=r(p50)
scalar unexp_age_75=r(p75)
restore
file write table1 "Age, median (IQR)" _tab %3.2fc (unexp_age_50) " (" %3.2f (unexp_age_25) "-" %3.2f (unexp_age_75) ")" _tab %3.2fc (exp_age_50) " (" %3.2f (exp_age_25) "-" %3.2f (exp_age_75) ")" _n 

foreach i in gender  {
tab `i' exposed, m col matcell(`i')
mata : st_matrix("`i'_col_tot", colsum(st_matrix("`i'")))
scalar unexp_`i' = `i'_col_tot[1,1]
scalar exp_`i' = `i'_col_tot[1,2] 
matrix exp_`i'_percent = `i'/exp_`i' *100
matrix unexp_`i'_percent = `i'/unexp_`i' *100

file write table1 "Female" _tab %9.0fc (`i'[2,1]) " (" %3.2f (unexp_`i'_percent[2,1]) ")" _tab %9.0fc (`i'[2,2]) " (" %3.2f (exp_`i'_percent[2,2]) ")" _n 
}

file write table1 "Ethnicity" _n

*Ethnicity categories
tab ethnicity exposed, m col matcell(ethn)
mata : st_matrix("ethn_col_tot", colsum(st_matrix("ethn")))
scalar unexp_ethn = ethn_col_tot[1,1]
scalar exp_ethn = ethn_col_tot[1,2] 
matrix exp_ethn_percent = ethn/exp_ethn *100
matrix unexp_ethn_percent = ethn/unexp_ethn *100

*write to text file
file write table1 "White" _tab %9.0fc (ethn[1,1]) " (" %3.2f (unexp_ethn_percent[1,1]) ")" _tab %9.0fc (ethn[1,2]) " (" %3.2f (exp_ethn_percent[1,2]) ")" _n 
file write table1 "Mixed" _tab %9.0fc (ethn[2,1]) " (" %3.2f (unexp_ethn_percent[2,1]) ")" _tab %9.0fc (ethn[2,2]) " (" %3.2f (exp_ethn_percent[2,2]) ")" _n 
file write table1 "Asian or Asian British" _tab %9.0fc (ethn[3,1]) " (" %3.2f (unexp_ethn_percent[3,1]) ")" _tab %9.0fc (ethn[3,2]) " (" %3.2f (exp_ethn_percent[3,2]) ")" _n 
file write table1 "Black" _tab %9.0fc (ethn[4,1]) " (" %3.2f (unexp_ethn_percent[4,1]) ")" _tab %9.0fc (ethn[4,2]) " (" %3.2f (exp_ethn_percent[4,2]) ")" _n 
file write table1 "Other ethnic groups" _tab %9.0fc (ethn[5,1]) " (" %3.2f (unexp_ethn_percent[5,1]) ")" _tab %9.0fc (ethn[5,2]) " (" %3.2f (exp_ethn_percent[5,2]) ")" _n 
file write table1 "Missing" _tab %9.0fc (ethn[6,1]) " (" %3.2f (unexp_ethn_percent[6,1]) ")" _tab %9.0fc (ethn[6,2]) " (" %3.2f (exp_ethn_percent[6,2]) ")" _n 

file write table1 "Smoking status" _n

*Smoking categories
tab smoke exposed, m col matcell(smoking)
mata : st_matrix("smoking_col_tot", colsum(st_matrix("smoking")))
scalar unexp_smoking = smoking_col_tot[1,1]
scalar exp_smoking = smoking_col_tot[1,2] 
matrix exp_smoking_percent = smoking/exp_smoking *100
matrix unexp_smoking_percent = smoking/unexp_smoking *100

*write to text file [check the label for different categories to choose which matrix position]
file write table1 "Non-smoker" _tab %9.0fc (smoking[1,1]) " (" %3.2f (unexp_smoking_percent[1,1]) ")" _tab %9.0fc (smoking[1,2]) " (" %3.2f (exp_smoking_percent[1,2]) ")" _n 
file write table1 "Ex-smoker" _tab %9.0fc (smoking[3,1]) " (" %3.2f (unexp_smoking_percent[3,1]) ")" _tab %9.0fc (smoking[3,2]) " (" %3.2f (exp_smoking_percent[3,2]) ")" _n 
file write table1 "Current smoker" _tab %9.0fc (smoking[2,1]) " (" %3.2f (unexp_smoking_percent[2,1]) ")" _tab %9.0fc (smoking[2,2]) " (" %3.2f (exp_smoking_percent[2,2]) ")" _n 
file write table1 "Missing" _tab %9.0fc (smoking[4,1]) " (" %3.2f (unexp_smoking_percent[4,1]) ")" _tab %9.0fc (smoking[4,2]) " (" %3.2f (exp_smoking_percent[4,2]) ")" _n 

file write table1 "Body mass index" _n

*BMI categories
tab bmi_cat exposed, m col matcell(bmi)
mata : st_matrix("bmi_col_tot", colsum(st_matrix("bmi")))
scalar unexp_bmi = bmi_col_tot[1,1]
scalar exp_bmi = bmi_col_tot[1,2] 
matrix exp_bmi_percent = bmi/exp_bmi *100
matrix unexp_bmi_percent = bmi/unexp_bmi *100

*write to text file
file write table1 "Underweight" _tab %9.0fc (bmi[1,1]) " (" %3.2f (unexp_bmi_percent[1,1]) ")" _tab %9.0fc (bmi[1,2]) " (" %3.2f (exp_bmi_percent[1,2]) ")" _n 
file write table1 "Normal Weight" _tab %9.0fc (bmi[2,1]) " (" %3.2f (unexp_bmi_percent[2,1]) ")" _tab %9.0fc (bmi[2,2]) " (" %3.2f (exp_bmi_percent[2,2]) ")" _n 
file write table1 "Overweight" _tab %9.0fc (bmi[3,1]) " (" %3.2f (unexp_bmi_percent[3,1]) ")" _tab %9.0fc (bmi[3,2]) " (" %3.2f (exp_bmi_percent[3,2]) ")" _n 
file write table1 "Obese" _tab %9.0fc (bmi[4,1]) " (" %3.2f (unexp_bmi_percent[4,1]) ")" _tab %9.0fc (bmi[4,2]) " (" %3.2f (exp_bmi_percent[4,2]) ")" _n 
file write table1 "Missing" _tab %9.0fc (bmi[5,1]) " (" %3.2f (unexp_bmi_percent[5,1]) ")" _tab %9.0fc (bmi[5,2]) " (" %3.2f (exp_bmi_percent[5,2]) ")" _n 

file write table1 "Comorbidities" _n

*Other comorbidities (when female=2/label after male)
foreach i in hypertension diabetes other_respiratory ckd_egfr  ///
  all_cancer immuno_final  {
tab `i' exposed, m col matcell(`i')
mata : st_matrix("`i'_col_tot", colsum(st_matrix("`i'")))
scalar unexp_`i' = `i'_col_tot[1,1]
scalar exp_`i' = `i'_col_tot[1,2] 
matrix exp_`i'_percent = `i'/exp_`i' *100
matrix unexp_`i'_percent = `i'/unexp_`i' *100

file write table1 "`i'" _tab %9.0fc (`i'[2,1]) " (" %3.2f (unexp_`i'_percent[2,1]) ")" _tab %9.0fc (`i'[2,2]) " (" %3.2f (exp_`i'_percent[2,2]) ")" _n 
}

file write table1 "Prescription use in the past 60 days" _n

*Co-medication
foreach i in vaccine statin insulin  {
tab `i' exposed, m col matcell(`i')
mata : st_matrix("`i'_col_tot", colsum(st_matrix("`i'")))
scalar unexp_`i' = `i'_col_tot[1,1]
scalar exp_`i' = `i'_col_tot[1,2] 
matrix exp_`i'_percent = `i'/exp_`i' *100
matrix unexp_`i'_percent = `i'/unexp_`i' *100

file write table1 "`i'" _tab %9.0fc (`i'[2,1]) " (" %3.2f (unexp_`i'_percent[2,1]) ")" _tab %9.0fc (`i'[2,2]) " (" %3.2f (exp_`i'_percent[2,2]) ")" _n 
}


file close table1 

/*keep those below as no such variables yet in the dummy data
Hospitalisation + GP consultation (categories: 0, 1,>1)
foreach i in hosp_cat gp_cat {
tab `i' exposed, m col matcell(`i')
mata : st_matrix("`i'_col_tot", colsum(st_matrix("`i'")))
scalar unexp_`i' = `i'_col_tot[1,1]
scalar exp_`i' = `i'_col_tot[1,2] 
matrix exp_`i'_percent = `i'/exp_`i' *100
matrix unexp_`i'_percent = `i'/unexp_`i' *100

file write table1 "`i'= 0" _tab %9.0fc (`i'[1,1]) " (" %3.2f (unexp_`i'_percent[1,1]) ")" _tab %9.0fc (`i'[1,2]) " (" %3.2f (exp_`i'_percent[1,2]) ")" _n 
file write table1 "`i'= 1" _tab %9.0fc (`i'[2,1]) " (" %3.2f (unexp_`i'_percent[2,1]) ")" _tab %9.0fc (`i'[2,2]) " (" %3.2f (exp_`i'_percent[2,2]) ")" _n 
file write table1 "`i'> 0" _tab %9.0fc (`i'[3,1]) " (" %3.2f (unexp_`i'_percent[3,1]) ")" _tab %9.0fc (`i'[3,2]) " (" %3.2f (exp_`i'_percent[3,2]) ")" _n 
}
	
*Hospitalisation + GP consultation (categories: median and IQR)
foreach i in hosp_count gp_count {
preserve
keep if exposed==1
su `i', detail
scalar exp_`i'_25=r(p25)
scalar exp_`i'_50=r(p50)
scalar exp_`i'_75=r(p75)
restore
preserve
keep if exposed==0
su `i', detail
scalar unexp_`i'_25=r(p25)
scalar unexp_`i'_50=r(p50)
scalar unexp_`i'_75=r(p75)
restore
file write table1 "`i'" _tab (unexp_`i'_50) " (" (unexp_`i'_25) "-" (unexp_`i'_75) ")" _tab  (exp_`i'_50) " (" (exp_`i'_25) "-" (exp_`i'_75) ")" _n 
}

file close table1 

/*List of covariates shown in the protocol
Age
Gender
Ethnicity
BMI
Smoking 
Hypertension 
Heart failure
Chronic Heart Disease 
Diabetes 
Chronic Respiratory Disease (excluding Asthma and COPD) 
Cancer
Immunosuppression
Chronic kidney
Disease
Exacerbation  history (COPD) in the previous year 
GP consultation rate in the previous year 
Flu/pneumococcal vaccination status
Current Statin use
Current insulin use
*/