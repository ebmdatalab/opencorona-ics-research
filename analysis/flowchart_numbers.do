
log using $logdir\flow_chart_numbers, replace t
import delimited input_copd_flow_chart.csv, clear

/*
# COPD pop
copd AND
(age >=35 AND age <= 110) AND
ever_smoked AND
has_follow_up AND NOT
recent_asthma AND NOT
other_respiratory AND NOT
nebules AND NOT
ltra_single
*/
count
drop if copd!=1
count
drop if age_cat!=1
count
drop if ever_smoked!=1
count
drop if has_follow_up!=1
count
drop if recent_asthma==1
count
drop if other_respiratory==1
count
drop if nebules==1
count
drop if ltra_single==1
count


import delimited input_asthma_flow_chart.csv, clear

/*
# Main asthma pop
has_asthma AND
(age >=18 AND age <= 110) AND
has_follow_up AND NOT
copd AND NOT
other_respiratory AND NOT
nebules AND NOT
(
  (lama_single OR laba_lama) AND NOT (
    high_dose_ics OR
    high_dose_ics_single_ing OR
    high_dose_ics_multiple_ingredient OR
    low_med_dose_ics_single_ingredient OR
    low_med_dose_ics_multiple_ingredient OR
    low_med_dose_ics OR
    ics_single OR
    laba_ics OR
    laba_lama_ics
  )
)
*/
preserve
count
drop if has_asthma!=1
count
drop if age_cat!=1
count
drop if has_follow_up!=1
count
drop if copd==1
count
drop if other_respiratory==1
count
drop if nebules==1
count
drop if lama_no_ics==1
count
restore
/*
# Sensitivity analysis population
(
  has_asthma OR
  (asthma_ever AND any_asthma_med)
) AND
(age >=18 AND age <= 110) AND
has_follow_up AND NOT
copd AND NOT
other_respiratory AND NOT
nebules AND NOT
(
  (lama_single OR laba_lama) AND NOT (
    high_dose_ics OR
    high_dose_ics_single_ing OR
    high_dose_ics_multiple_ingredient OR
    low_med_dose_ics_single_ingredient OR
    low_med_dose_ics_multiple_ingredient OR
    low_med_dose_ics OR
    ics_single OR
    laba_ics OR
    laba_lama_ics
  )
)
*/
preserve
count
drop if asthma_sensitivity!=1
count
drop if age_cat!=1
count
drop if has_follow_up!=1
count
drop if copd==1
count
drop if other_respiratory==1
count
drop if nebules==1
count
drop if lama_no_ics==1
count
restore


log close
