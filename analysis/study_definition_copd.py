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
        """
        copd AND
        (age >=35 AND age <= 110) AND
        ever_smoked AND
        has_follow_up AND NOT
        recent_asthma AND NOT
        other_respiratory AND NOT
        nebules AND NOT
        ltra_single
        """,
        has_follow_up=patients.registered_with_one_practice_between(
            "2019-03-01", "2020-03-01"
        ),
        recent_asthma=patients.with_these_clinical_events(
            asthma_codes, between=["2017-03-01", "2020-03-01"],
        ),
        #### NEBULES
        nebules=patients.with_these_medications(
            nebulised_med_codes, between=["2019-03-01", "2020-03-01"],
        ),
    ),
    ## OUTCOMES (at least one outcome or covariate is required)
    icu_date_admitted=patients.admitted_to_icu(
        on_or_after="2020-03-01",
        include_day=True,
        returning="date_admitted",
        return_expectations={"date": {"earliest": "2020-03-01"}},
    ),
    died_date_cpns=patients.with_death_recorded_in_cpns(
        on_or_after="2020-03-01",
        returning="date_of_death",
        include_month=True,
        include_day=True,
        return_expectations={"date": {"earliest": "2020-03-01"}},
    ),
    died_ons_covid_flag_any=patients.with_these_codes_on_death_certificate(
        covid_codelist,
        on_or_after="2020-03-01",
        match_only_underlying_cause=False,
        return_expectations={"date": {"earliest": "2020-03-01"}},
    ),
    died_ons_covid_flag_underlying=patients.with_these_codes_on_death_certificate(
        covid_codelist,
        on_or_after="2020-03-01",
        match_only_underlying_cause=True,
        return_expectations={"date": {"earliest": "2020-03-01"}},
    ),
    died_date_ons=patients.died_from_any_cause(
        on_or_after="2020-03-01",
        returning="date_of_death",
        include_month=True,
        include_day=True,
        return_expectations={"date": {"earliest": "2020-03-01"}},
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
        return_expectations={
            "category": {"ratios": {"1": 0.8, "5": 0.1, "3": 0.1}},
            "incidence": 0.75,
        },
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
            "incidence": 0.95,
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
        return_expectations={"date": {"latest": "2020-03-01"}},
    ),
    #### HIGH DOSE ICS
    high_dose_ics=patients.with_these_medications(
        high_dose_ics_med_codes,
        between=["2019-11-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-11-01", "latest": "2020-03-01"},
        },
    ),
    ### LOW-MED DOSE ICS
    low_med_dose_ics=patients.with_these_medications(
        low_medium_ics_med_codes,
        between=["2019-11-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-11-01", "latest": "2020-03-01"},
        },
    ),
    #### ICS SINGLE CONSTITUENT
    ics_single=patients.with_these_medications(
        ics_single_med_codes,
        between=["2019-11-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-11-01", "latest": "2020-03-01"},
        },
    ),
    #### ORAL STEROIDS SINGLE CONSTITUENT
    oral_steroids=patients.with_these_medications(
        oral_steroid_med_codes,
        between=["2019-11-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-11-01", "latest": "2020-03-01"},
        },
    ),
    #### SABA SINGLE CONSTITUENT
    saba_single=patients.with_these_medications(
        saba_med_codes,
        between=["2019-11-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-11-01", "latest": "2020-03-01"},
        },
    ),
    #### SAMA SINGLE CONSTITUENT
    sama_single=patients.with_these_medications(
        sama_med_codes,
        between=["2019-11-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-11-01", "latest": "2020-03-01"},
        },
    ),
    #### LABA SINGLE CONSTITUENT
    laba_single=patients.with_these_medications(
        single_laba_med_codes,
        between=["2019-11-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-11-01", "latest": "2020-03-01"},
        },
    ),
    #### LAMA SINGLE CONSTITUENT
    lama_single=patients.with_these_medications(
        single_lama_med_codes,
        between=["2019-11-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-11-01", "latest": "2020-03-01"},
        },
    ),
    #### LABA + ICS
    laba_ics=patients.with_these_medications(
        laba_ics_med_codes,
        between=["2019-11-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-11-01", "latest": "2020-03-01"},
        },
    ),
    #### LABA + LAMA
    laba_lama=patients.with_these_medications(
        laba_lama_med_codes,
        between=["2019-11-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-11-01", "latest": "2020-03-01"},
        },
    ),
    #### LABA + LAMA + ICS
    laba_lama_ics=patients.with_these_medications(
        laba_lama__ics_med_codes,
        between=["2019-11-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-11-01", "latest": "2020-03-01"},
        },
    ),
    #### LTRA SINGLE CONSTITUENT
    ltra_single=patients.with_these_medications(
        leukotriene_med_codes,
        between=["2019-11-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-11-01", "latest": "2020-03-01"},
        },
    ),
    ### OXYGEN THERAPY LEFT OUT AT PRESENT DUE TO POOR RECORDS
    ### COPD
    copd=patients.with_these_clinical_events(
        copd_codes,
        on_or_before="2020-03-01",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-03-01"}},
    ),
    ### OTHER RESPIRATORY
    other_respiratory=patients.with_these_clinical_events(
        other_respiratory_codes,
        on_or_before="2020-03-01",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-03-01"}},
    ),
    ### ASTHMA EVER
    asthma_ever=patients.with_these_clinical_events(
        asthma_ever_codes,
        on_or_before="2020-03-01",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-03-01"}},
    ),
    ### OTHER HEART DISEASE
    other_heart_disease=patients.with_these_clinical_events(
        other_heart_disease_codes,
        on_or_before="2020-03-01",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-03-01"}},
    ),
    ### ILI
    ili=patients.with_these_clinical_events(
        ili_codes,
        return_first_date_in_period=True,
        include_month=True,
        between=["2016-09-01", "2020-03-01"],
        return_expectations={
            "date": {"earliest": "2019-09-01", "latest": "2020-03-01"}
        },
    ),
    ### HYPERTENSION
    hypertension=patients.with_these_clinical_events(
        hypertension_codes,
        on_or_before="2020-03-01",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-03-01"}},
    ),
    ### HEART FAILURE
    heart_failure=patients.with_these_clinical_events(
        heart_failure_codes,
        on_or_before="2020-03-01",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-03-01"}},
    ),
    #### SYSTOLIC BLOOD PRESSURE
    bp_sys=patients.mean_recorded_value(
        systolic_blood_pressure_codes,
        on_most_recent_day_of_measurement=True,
        on_or_before="2020-03-01",
        include_measurement_date=True,
        include_month=True,
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 10},
            "date": {"latest": "2020-03-01"},
            "incidence": 0.95,
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
            "float": {"distribution": "normal", "mean": 120, "stddev": 10},
            "date": {"latest": "2020-03-01"},
            "incidence": 0.95,
        },
    ),
    ### DIABETES
    diabetes=patients.with_these_clinical_events(
        diabetes_codes,
        on_or_before="2020-03-01",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-03-01"}},
    ),
    ### CANCER - 3 TYPES
    lung_cancer=patients.with_these_clinical_events(
        lung_cancer_codes,
        on_or_before="2020-03-01",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-03-01"}},
    ),
    haem_cancer=patients.with_these_clinical_events(
        haem_cancer_codes,
        on_or_before="2020-03-01",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-03-01"}},
    ),
    other_cancer=patients.with_these_clinical_events(
        other_cancer_codes,
        on_or_before="2020-03-01",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-03-01"}},
    ),
    # IMMUNOSUPPRESSION - 4 TYPES
    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/36
    aplastic_anaemia=patients.with_these_clinical_events(
        aplastic_codes,
        on_or_before="2020-03-01",
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-03-01"}},
    ),
    hiv=patients.with_these_clinical_events(
        hiv_codes,
        on_or_before="2020-03-01",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-03-01"}},
    ),
    permanent_immunodeficiency=patients.with_these_clinical_events(
        permanent_immune_codes,
        on_or_before="2020-03-01",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-03-01"}},
    ),
    temporary_immunodeficiency=patients.with_these_clinical_events(
        temp_immune_codes,
        between=["2019-03-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-03-01", "latest": "2020-03-01"}
        },
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
            "float": {"distribution": "normal", "mean": 60.0, "stddev": 15},
            "date": {"latest": "2020-03-01"},
            "incidence": 0.95,
        },
    ),
    #### end stage renal disease codes incl. dialysis / transplant
    esrf=patients.with_these_clinical_events(
        ckd_codes,
        on_or_before="2020-03-01",
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-03-01"}},
    ),
    ### VACCINATION HISTORY
    flu_vaccine_tpp_table=patients.with_tpp_vaccination_record(
        target_disease_matches="INFLUENZA",
        between=["2019-09-01", "2020-03-01"],  # current flu season
        find_first_match_in_period=True,
        returning="date",
        return_expectations={
            "date": {"earliest": "2019-09-01", "latest": "2020-03-01"}
        },
    ),
    flu_vaccine_med=patients.with_these_medications(
        flu_med_codes,
        between=["2019-09-01", "2020-03-01"],  # current flu season
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-09-01", "latest": "2020-03-01"}
        },
    ),
    flu_vaccine_clinical=patients.with_these_clinical_events(
        flu_clinical_codes,
        between=["2019-09-01", "2020-03-01"],  # current flu season
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-09-01", "latest": "2020-03-01"}
        },
    ),
    flu_vaccine=patients.satisfying(
        """
        flu_vaccine_tpp_table OR
        flu_vaccine_med
        """,
        # ADD IN flu_vaccine_clinical WHEN DECIDED
    ),
    # PNEUMOCOCCAL VACCINE
    pneumococcal_vaccine_tpp_table=patients.with_tpp_vaccination_record(
        target_disease_matches="PNEUMOCOCCAL",
        between=["2015-03-01", "2020-03-01"],
        find_first_match_in_period=True,
        returning="date",
        return_expectations={
            "date": {"earliest": "2015-03-01", "latest": "2020-03-01"}
        },
    ),
    pneumococcal_vaccine_med=patients.with_these_medications(
        pneumococcal_med_codes,
        between=["2015-03-01", "2020-03-01"],  # past five years
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2015-03-01", "latest": "2020-03-01"}
        },
    ),
    pneumococcal_vaccine_clinical=patients.with_these_clinical_events(
        pneumococcal_clinical_codes,
        between=["2015-03-01", "2020-03-01"],  # past five years
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2015-03-01", "latest": "2020-03-01"}
        },
    ),
    pneumococcal_vaccine=patients.satisfying(
        """
        pneumococcal_vaccine_tpp_table OR
        pneumococcal_vaccine_med
        """,
        # ADD IN pneumococcal_vaccine_clinical WHEN DECIDED
    ),
    ### INSULIN USE
    insulin=patients.with_these_medications(
        insulin_med_codes,
        between=["2019-11-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-11-01", "latest": "2020-03-01"}
        },
    ),
    ### STATIN USE
    statin=patients.with_these_medications(
        statin_med_codes,
        between=["2019-11-01", "2020-03-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-11-01", "latest": "2020-03-01"}
        },
    ),
    ### EXACERBATIONS
    ## count
    exacerbation_count=patients.with_these_clinical_events(
        copd_exacerbation_codes,
        between=["2019-03-01", "2020-03-01"],
        ignore_days_where_these_codes_occur=copd_review_rescue_codes,
        returning="number_of_episodes",
        episode_defined_as="series of events each <= 14 days apart",
        return_expectations={
            "int": {"distribution": "normal", "mean": 4, "stddev": 2},
            "incidence": 0.2,
        },
    ),
    # binary flag
    exacerbations=patients.satisfying(
        """
        exacerbation_count
        """,
    ),
    ### GP CONSULTATION RATE
    gp_consult_count=patients.with_gp_consultations(
        on_or_before="2019-03-01",
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 4, "stddev": 2},
            "date": {"latest": "2020-03-01"},
            "incidence": 0.7,
        },
    ),
    has_consultation_history=patients.with_complete_gp_consultation_history_between(
        "2019-03-01", "2020-03-01"
    ),
)
