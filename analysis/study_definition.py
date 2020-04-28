from datalab_cohorts import StudyDefinition, patients, codelist, codelist_from_csv

copd_exacerbation_codes = codelist_from_csv( ## CHANGE TO REAL COPD EXACERBATION CODES WHEN AVAILABLE
    "codelists/chronic_cardiac_disease.csv", system="ctv3", column="CTV3ID"
    )

salbutamol_codes = codelist_from_csv(
    "codelists/sabutamol_asthma.csv", system="snomed", column="id"
    )

insulin_codes = codelist_from_csv( ### CHANGE TO REAL INSULIN CODES WHEN AVAILABLE
    "codelists/sabutamol_asthma.csv", system="snomed", column="id"
    )

statin_codes = codelist_from_csv( ### CHANGE TO REAL STATIN CODES WHEN AVAILABLE
    "codelists/sabutamol_asthma.csv", system="snomed", column="id"
    )

vaccination_codes = codelist_from_csv( ## CHANGE TO REAL VACCINATION CODES WHEN AVAILABLE
    "codelists/chronic_cardiac_disease.csv", system="ctv3", column="CTV3ID"
    )

creatinine_codes = codelist(["XE2q5"], system="ctv3")

end_stage_ckd_codes = codelist_from_csv( ### please note this ESRF AND Dialysis codes
    "codelists/dialysis_codes.csv", system="ctv3", column="CTV3ID"
    )

organ_transplant_codes = codelist_from_csv(
    "codelists/organ_transplant.csv", system="ctv3", column="CTV3ID"
    )

spleen_codes = codelist_from_csv(
    "codelists/spleen_2020-04-16.csv", system="ctv3", column="CTV3ID"
    )

sickle_cell_codes = codelist_from_csv(
    "codelists/sickle_cell_2020-04-16.csv", system="ctv3", column="CTV3ID"
    )

aplastic_codes = codelist_from_csv(
    "codelists/aplastic.csv", system="ctv3", column="CTV3ID")

hiv_codes = codelist_from_csv(
    "codelists/hiv.csv", system="ctv3", column="CTV3ID")

permanent_immune_codes = codelist_from_csv(
    "codelists/permanent-immune.csv", system="ctv3", column="CTV3ID")

temp_immune_codes = codelist_from_csv(
    "codelists/temporary-immune.csv", system="ctv3", column="CTV3ID")

lung_cancer_codes = codelist_from_csv(
    "codelists/lung_cancer_2020-04-16.csv", system="ctv3", column="CTV3ID"
)

haem_cancer_codes = codelist_from_csv(
    "codelists/haematological_cancer_2020-04-16.csv", system="ctv3", column="CTV3ID"
)

other_cancer_codes = codelist_from_csv(
    "codelists/other_cancer_2020-04-16.csv", system="ctv3", column="CTV3ID"
)

study = StudyDefinition(
    # This line defines the study population
    population=patients.registered_with_one_practice_between(
        "2019-02-01", "2020-02-01"
    ),
    # The rest of the lines define the covariates with associated GitHub issues
    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/33
    age=patients.age_as_of("2020-02-01"),

    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/46
    sex=patients.sex(),

    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/54
    stp=patients.registered_practice_as_of("2020-02-01", returning="stp_code"),

    # region 
    region=patients.registered_practice_as_of("2020-02-01", returning="nhse_region_name"),

    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/52
    imd=patients.address_as_of(
        "2020-02-01", returning="index_of_multiple_deprivation", round_to_nearest=100
    ),

    # rural or urban areas
    rural_urban=patients.address_as_of(
        "2020-02-01", returning="rural_urban_classification"
    ),

   # https://github.com/ebmdatalab/tpp-sql-notebook/issues/31
    organ_transplant=patients.with_these_clinical_events(
        organ_transplant_codes,
        return_first_date_in_period=True,
        include_month=True,
    ),

    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/13
    dysplenia=patients.with_these_clinical_events(
        spleen_codes,
        return_first_date_in_period=True,
        include_month=True,
    ),
    sickle_cell=patients.with_these_clinical_events(
        sickle_cell_codes,
        return_first_date_in_period=True,
        include_month=True,
    ),

    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/32
    lung_cancer=patients.with_these_clinical_events(
        lung_cancer_codes,
        return_first_date_in_period=True,
        include_month=True,
    ),
    haem_cancer=patients.with_these_clinical_events(
        haem_cancer_codes,
        return_first_date_in_period=True,
        include_month=True,
    ),
    other_cancer=patients.with_these_clinical_events(
        other_cancer_codes,
        return_first_date_in_period=True,
        include_month=True,
    ),

    # immunosupression condition codes 
    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/36
    aplastic_anaemia=patients.with_these_clinical_events(
        aplastic_codes, 
        return_last_date_in_period=True,
        include_month=True,
    ),
    hiv=patients.with_these_clinical_events(
        hiv_codes, 
        return_first_date_in_period=True,
        include_month=True,
    ),
    permanent_immunodeficiency=patients.with_these_clinical_events(
        permanent_immune_codes, 
        return_first_date_in_period=True,
        include_month=True,
    ),
    temporary_immunodeficiency=patients.with_these_clinical_events(
        temp_immune_codes,
        return_last_date_in_period=True,
        include_month=True,
    ),

   # # Chronic kidney disease
    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/17
    creatinine=patients.with_these_clinical_events(
        creatinine_codes,
        find_last_match_in_period=True,
        on_or_before="2020-02-01",
        returning="numeric_value",
        include_date_of_match=True,
        include_month=True,
    ),
    esrf=patients.with_these_clinical_events(
        end_stage_ckd_codes,
        return_first_date_in_period=True,
        include_month=True,
    ),
    insulin=patients.with_these_medications(
        insulin_codes,
        between=["2019-12-01", "2020-02-01"], ## note this is in the last 2 months 
        returning="number_of_matches_in_period",
    ),

    statins=patients.with_these_medications(
        statin_codes,
        between=["2019-12-01", "2020-02-01"], ## note this is in the last 2 months 
        returning="number_of_matches_in_period",
    ),

    copd_exacerbations=patients.with_these_clinical_events(
        copd_exacerbation_codes,
        returning="date",
        between=["2019-02-01", "2020-02-01"], ### note this is from 1st February 2019
        find_first_match_in_period=True,
        include_month=True,
    ),

    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/12
    vaccination_status=patients.with_these_clinical_events(
        vaccination_codes,
        returning="date",
        between=["2019-09-01", "2020-02-01"], ### note this is from 1st September 2019
        find_first_match_in_period=True,
        include_month=True,
    ),
    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/10
    bmi=patients.most_recent_bmi(
        on_or_after="2010-02-01",
        minimum_age_at_measurement=16,
        include_measurement_date=True,
        include_month=True,
    ),
    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/35
    bp_sys=patients.mean_recorded_value(
        systolic_blood_pressure_codes,
        on_most_recent_day_of_measurement=True,
        on_or_before="2020-02-01",
        include_measurement_date=True,
        include_month=True,
    ),
    bp_dias=patients.mean_recorded_value(
        diastolic_blood_pressure_codes,
        on_most_recent_day_of_measurement=True,
        on_or_before="2020-02-01",
        include_measurement_date=True,
        include_month=True,
    ),

    recent_salbutamol_count=patients.with_these_medications(
        salbutamol_codes,
        between=["2018-02-01", "2020-02-01"],
        returning="number_of_matches_in_period",
    ),
)
