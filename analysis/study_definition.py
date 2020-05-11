from datalab_cohorts import (
    StudyDefinition,
    patients,
    filter_codes_by_category,
)

from codelists import *

study = StudyDefinition(
    # Configure the expectations framework (optional)
    default_expectations={
        "date": {"earliest": "1970-01-01", "latest": "today"},
        "rate": "exponential_increase",
        "incidence": 0.2,
    },
    ## STUDY POPULATION (required)
    population=patients.satisfying(
        "has_follow_up AND has_asthma",
        has_asthma=patients.with_these_clinical_events(
            asthma_codes, on_or_before="2017-02-01"
        ),
        has_follow_up=patients.registered_with_one_practice_between(
            "2019-03-01", "2020-03-01"
        ),
    ),
    ## OUTCOMES (at least one outcome or covariate is required)
    icu_date_admitted=patients.admitted_to_icu(
        on_or_after="2020-03-01",
        include_day=True,
        returning="date_admitted",
        return_expectations={"date": {}},
    ),
    died_date_cpns=patients.with_death_recorded_in_cpns(
        on_or_before="2020-06-01",
        returning="date_of_death",
        include_month=True,
        include_day=True,
        return_expectations={"date": {}},
    ),
    died_ons_covid_flag_any=patients.with_these_codes_on_death_certificate(
        covid_codelist,
        on_or_before="2020-06-01",
        match_only_underlying_cause=False,
        return_expectations={"date": {}},
    ),
    died_ons_covid_flag_underlying=patients.with_these_codes_on_death_certificate(
        covid_codelist,
        on_or_before="2020-06-01",
        match_only_underlying_cause=True,
        return_expectations={"date": {}},
    ),
    died_date_ons=patients.died_from_any_cause(
        on_or_before="2020-06-01",
        returning="date_of_death",
        include_month=True,
        include_day=True,
        return_expectations={"date": {}},
    ),
    ## DEMOGRAPHIC INFORMATION
    age=patients.age_as_of(
        "2020-03-01",
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
        },
    ),
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.51}},
        }
    ),
    stp=patients.registered_practice_as_of(
        "2020-03-01",
        returning="stp_code",
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"STP1": 0.5, "STP2": 0.5}},
        },
    ),
    imd=patients.address_as_of(
        "2020-03-01",
        returning="index_of_multiple_deprivation",
        round_to_nearest=100,
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"100": 0.1, "200": 0.2, "300": 0.7}},
        },
    ),
    ethnicity=patients.with_these_clinical_events(
        ethnicity_codes,
        returning="category",
        find_last_match_in_period=True,
        include_date_of_match=True,
        return_expectations={"category": {"ratios": {"1": 0.8, "5": 0.1, "3": 0.1}}},
    ),
    ## COVARIATES
    bmi=patients.most_recent_bmi(
        on_or_after="2010-03-01",
        minimum_age_at_measurement=16,
        include_measurement_date=True,
        include_month=True,
        return_expectations={
            "date": {},
            "float": {"distribution": "normal", "mean": 35, "stddev": 10},
        },
    ),
    smoking_status=patients.categorised_as(
        {
            "S": "most_recent_smoking_code = 'S'",
            "E": """
                     most_recent_smoking_code = 'E' OR (
                       most_recent_smoking_code = 'N' AND ever_smoked
                     )
                """,
            "N": "most_recent_smoking_code = 'N' AND NOT ever_smoked",
            "M": "DEFAULT",
        },
        return_expectations={
            "category": {"ratios": {"S": 0.6, "E": 0.1, "N": 0.2, "M": 0.1}}
        },
        most_recent_smoking_code=patients.with_these_clinical_events(
            clear_smoking_codes,
            find_last_match_in_period=True,
            on_or_before="2020-03-01",
            returning="category",
        ),
        ever_smoked=patients.with_these_clinical_events(
            filter_codes_by_category(clear_smoking_codes, include=["S", "E"]),
            on_or_before="2020-03-01",
        ),
    ),
    smoking_status_date=patients.with_these_clinical_events(
        clear_smoking_codes,
        on_or_before="2020-03-01",
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),

    #### HIGH DOSE ICS
    high_dose_ics=patients.with_these_medications(
        high_dose_ics_codes,
        between=["2019-11-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),

    ### LOW-MED DOSE ICS
    low_med_dose_ics=patients.with_these_medications(
        low_medium__ics_med_codes,
        between=["2019-11-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),

    #### ICS SINGLE CONSTITUENT
    ics_single=patients.with_these_medications(
        ics_single_med_codes,
        between=["2019-11-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),
    #### ORAL STEROIDS SINGLE CONSTITUENT
    oral_steroids=patients.with_these_medications(
        oral_steroid_med_codes,
        between=["2019-11-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),
    #### SABA SINGLE CONSTITUENT
    saba_single=patients.with_these_medications(
        saba_med_codes,
        between=["2019-11-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),
    #### SAMA SINGLE CONSTITUENT
    sama_single=patients.with_these_medications(
        placeholder_med_codes,  #### REPLACE WITH REAL CODE LIST WHEN AVAILABLE
        between=["2019-11-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),
    #### LABA SINGLE CONSTITUENT
    laba_single=patients.with_these_medications(
        single_laba_med_codes,
        between=["2019-11-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),
    #### LAMA SINGLE CONSTITUENT
    lama_single=patients.with_these_medications(
        single_lama_med_codes,
        between=["2019-11-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),
    #### LABA + ICS
    laba_ics=patients.with_these_medications(
        laba_ics_med_codes,
        between=["2019-11-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),
    #### LABA + LAMA
    laba_lama=patients.with_these_medications(
        laba_lama_med_codes,
        between=["2019-11-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),
    #### LABA + LAMA + ICS
    laba_lama_ics=patients.with_these_medications(
        laba_lama__ics_med_codes,
        between=["2019-11-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),
    #### LTRA SINGLE CONSTITUENT
    ltra_single=patients.with_these_medications(
        leukotriene_med_codes,
        between=["2019-11-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),
    #### NEBULES
    nebules=patients.with_these_medications(
        nebulised_med_codes,
        between=["2019-11-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),
    ### OXYGEN THERAPY LEFT OUT AT PRESENT DUE TO POOR RECORDS
    ### COPD
    copd=patients.with_these_clinical_events(
        placeholder_event_codes,  #### REPLACE WITH REAL CODE LIST WHEN AVAILABLE
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),
    ### OTHER RESPIRATORY
    other_respiratory=patients.with_these_clinical_events(
        placeholder_event_codes,  #### REPLACE WITH REAL CODE LIST WHEN AVAILABLE
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),

    ### OTHER HEART DISEASE
    other_heart_disease=patients.with_these_clinical_events(
        other_heart_disease_codes,
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),

    ### ILI
    ili=patients.with_these_clinical_events(
        placeholder_event_codes,  #### REPLACE WITH REAL CODE LIST WHEN AVAILABLE
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),
    ### HYPERTENSION
    hypertension=patients.with_these_clinical_events(
        hypertension_codes,
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),
    #### SYSTOLIC BLOOD PRESSURE
    bp_sys=patients.mean_recorded_value(
        systolic_blood_pressure_codes,
        on_most_recent_day_of_measurement=True,
        on_or_before="2020-03-01",
        include_measurement_date=True,
        include_month=True,
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 10}
        },
    ),
    ### DIASTOLIC BLOOD PRESSURE
    bp_dias=patients.mean_recorded_value(
        diastolic_blood_pressure_codes,
        on_most_recent_day_of_measurement=True,
        on_or_before="2020-03-01",
        include_measurement_date=True,
        include_month=True,
        return_expectations={
            "float": {"distribution": "normal", "mean": 120, "stddev": 10}
        },
    ),
    ### DIABETES
    diabetes=patients.with_these_clinical_events(
        diabetes_codes,
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),
    ### CANCER - 3 TYPES
    lung_cancer=patients.with_these_clinical_events(
        lung_cancer_codes,
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),
    haem_cancer=patients.with_these_clinical_events(
        haem_cancer_codes,
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),
    other_cancer=patients.with_these_clinical_events(
        other_cancer_codes,
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),
    # IMMUNOSUPPRESSION - 4 TYPES
    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/36
    aplastic_anaemia=patients.with_these_clinical_events(
        aplastic_codes,
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),
    hiv=patients.with_these_clinical_events(
        hiv_codes,
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),
    permanent_immunodeficiency=patients.with_these_clinical_events(
        permanent_immune_codes,
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),
    temporary_immunodeficiency=patients.with_these_clinical_events(
        temp_immune_codes,
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),
    ### CHRONIC KIDNEY DISEASE
    creatinine=patients.with_these_clinical_events(
        creatinine_codes,
        find_last_match_in_period=True,
        on_or_before="2020-03-01",
        returning="numeric_value",
        include_date_of_match=True,
        include_month=True,
        return_expectations={
            "float": {"distribution": "normal", "mean": 43.2, "stddev": 10}
        },
    ),

    #### end stage renal disease codes incl. dialysis / transplant
    esrf=patients.with_these_clinical_events(
        ckd_codes,
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),

    ### VACCINATION HISTORY
    vaccine=patients.with_these_clinical_events(
        placeholder_event_codes,  #### REPLACE WITH REAL CODE LIST WHEN AVAILABLE
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),
    ### INSULIN USE
    insulin=patients.with_these_medications(
        insulin_med_codes,
        between=["2019-11-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),
    ### STATIN USE
    statin=patients.with_these_medications(
        statin_med_codes,
        between=["2019-11-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {}},
    ),
)
