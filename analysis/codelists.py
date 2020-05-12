from datalab_cohorts import (
    codelist,
    codelist_from_csv,
)

placeholder_event_codes = codelist_from_csv(  #### USED AS A PLACEHOLDER
    "codelists/opensafely-diabetes.csv", system="ctv3", column="CTV3ID"
)

placeholder_med_codes = codelist_from_csv(
    "codelists/opensafely-asthma-inhaler-steroid-medication.csv",
    system="snomed",
    column="id",
)

ethnicity_codes = codelist_from_csv(
    "codelists/opensafely-ethnicity.csv",
    system="ctv3",
    column="Code",
    category_column="Grouping_6",
)

clear_smoking_codes = codelist_from_csv(
    "codelists/opensafely-smoking-clear.csv",
    system="ctv3",
    column="CTV3Code",
    category_column="Category",
)

unclear_smoking_codes = codelist_from_csv(
    "codelists/opensafely-smoking-unclear.csv",
    system="ctv3",
    column="CTV3Code",
    category_column="Category",
)

insulin_med_codes = codelist_from_csv(
    "codelists/opensafely-insulin-medication.csv", system="snomed", column="id"
)

statin_med_codes = codelist_from_csv(
    "codelists/opensafely-statin-medication.csv", system="snomed", column="id"
)

heartfailure_codes = codelist_from_csv(
    "codelists/opensafely-heart-failure.csv", system="ctv3", column="CTV3ID"
)

ics_single_med_codes = codelist_from_csv(
    "codelists/opensafely-asthma-inhaler-steroid-medication.csv",
    system="snomed",
    column="id",
)

laba_ics_med_codes = codelist_from_csv(
    "codelists/opensafely-laba-ics-combination-inhaler.csv",
    system="snomed",
    column="id",
)

laba_lama_med_codes = codelist_from_csv(
    "codelists/opensafely-laba-lama-combination-inhaler.csv",
    system="snomed",
    column="id",
)

laba_lama__ics_med_codes = codelist_from_csv(
    "codelists/opensafely-laba-lama-ics-combination-inhaler.csv",
    system="snomed",
    column="id",
)

leukotriene_med_codes = codelist_from_csv(
    "codelists/opensafely-leukotriene-receptor-antagonist-medication.csv",
    system="snomed",
    column="id",
)

low_medium__ics_med_codes = codelist_from_csv(
    "codelists/opensafely-low-and-medium-dose-ics-inhalers.csv",
    system="snomed",
    column="id",
)

nebulised_med_codes = codelist_from_csv(
    "codelists/opensafely-nebulised-asthma-and-copd-medications.csv",
    system="snomed",
    column="id",
)

single_laba_med_codes = codelist_from_csv(
    "codelists/opensafely-single-ingredient-laba-inhalers.csv",
    system="snomed",
    column="id",
)

single_lama_med_codes = codelist_from_csv(
    "codelists/opensafely-single-ingredient-lama-inhalers.csv",
    system="snomed",
    column="id",
)

oral_steroid_med_codes = codelist_from_csv(
    "codelists/opensafely-asthma-oral-prednisolone-medication.csv",
    system="snomed",
    column="vpid",
)

saba_med_codes = codelist_from_csv(
    "codelists/opensafely-saba-inhaler-medications.csv", system="snomed", column="id"
)

asthma_codes = codelist_from_csv(
    "codelists/opensafely-current-asthma.csv", system="ctv3", column="CTV3ID"
)

copd_codes = codelist_from_csv(
    "codelists/opensafely-current-copd.csv", system="ctv3", column="CTV3ID"
)

hypertension_codes = codelist_from_csv(
    "codelists/opensafely-hypertension.csv", system="ctv3", column="CTV3ID"
)

diabetes_codes = codelist_from_csv(
    "codelists/opensafely-diabetes.csv", system="ctv3", column="CTV3ID"
)

systolic_blood_pressure_codes = codelist(["2469."], system="ctv3")
diastolic_blood_pressure_codes = codelist(["246A."], system="ctv3")

lung_cancer_codes = codelist_from_csv(
    "codelists/opensafely-lung-cancer.csv", system="ctv3", column="CTV3ID"
)

haem_cancer_codes = codelist_from_csv(
    "codelists/opensafely-haematological-cancer.csv", system="ctv3", column="CTV3ID"
)

other_cancer_codes = codelist_from_csv(
    "codelists/opensafely-cancer-excluding-lung-and-haematological.csv",
    system="ctv3",
    column="CTV3ID",
)

aplastic_codes = codelist_from_csv(
    "codelists/opensafely-aplastic-anaemia.csv", system="ctv3", column="CTV3ID"
)

hiv_codes = codelist_from_csv(
    "codelists/opensafely-hiv.csv", system="ctv3", column="CTV3ID"
)

permanent_immune_codes = codelist_from_csv(
    "codelists/opensafely-permanent-immunosuppresion.csv",
    system="ctv3",
    column="CTV3ID",
)

temp_immune_codes = codelist_from_csv(
    "codelists/opensafely-temporary-immunosuppresion.csv",
    system="ctv3",
    column="CTV3ID",
)

creatinine_codes = codelist(["XE2q5"], system="ctv3")

ckd_codes = codelist_from_csv(
    "codelists/opensafely-chronic-kidney-disease.csv", system="ctv3", column="CTV3ID"
)

covid_codelist = codelist(["U071", "U072"], system="icd10")

high_dose_ics_codes = codelist_from_csv(
    "codelists/opensafely-high-dose-ics-inhalers.csv", system="snomed", column="id"
)

other_heart_disease_codes = codelist_from_csv(
    "codelists/opensafely-other-heart-disease.csv", system="ctv3", column="CTV3ID"
)

ibd_codes = codelist_from_csv(
    "codelists/opensafely-inflammatory-bowel-disease.csv", system="ctv3", column="CTV3ID"
)

ms_codes = codelist_from_csv(
    "codelists/opensafely-multiple-sclerosis.csv", system="ctv3", column="CTV3ID"
)

ra_codes = codelist_from_csv(
    "codelists/opensafely-rheumatoid-arthritis.csv", system="ctv3", column="CTV3ID"
)

flu_codes = codelist_from_csv(
    "codelists/opensafely-influenza-vaccination.csv", system="snomed", column="snomed_id"
)

pneumococcal_codes = codelist_from_csv(
    "codelists/opensafely-pneumococcal-vaccination.csv", system="snomed", column="snomed_id"
)
