from datalab_cohorts import StudyDefinition, patients, codelist, codelist_from_csv, filter_codes_by_category

placeholder_event_codes = codelist_from_csv( #### USED AS A PLACEHOLDER
    "codelists/opensafely-diabetes.csv", system="ctv3", column="CTV3ID"
    )

placeholder_med_codes = codelist_from_csv(
    "codelists/opensafely-asthma-inhaler-steroid-medication.csv", system="snomed", column="id"
    )

ethnicity_codes  = codelist_from_csv(
    "codelists/opensafely-ethnicity.csv", system="ctv3", column="Code", category_column="Grouping_6"
)

clear_smoking_codes  = codelist_from_csv(
    "codelists/opensafely-smoking-clear.csv", system="ctv3", column="CTV3Code", category_column="Category"
)

unclear_smoking_codes  = codelist_from_csv(
    "codelists/opensafely-smoking-unclear.csv", system="ctv3", column="CTV3Code", category_column="Category"
)

insulin_med_codes  = codelist_from_csv(
    "codelists/opensafely-insulin-medication.csv", system="snomed", column="id"
)

statin_med_codes  = codelist_from_csv(
    "codelists/opensafely-statin-medication.csv", system="snomed", column="id"
)

heartfailure_codes  = codelist_from_csv(
    "codelists/opensafely-heart-failure.csv", system="ctv3", column="CTV3ID"
    )

ics_single_med_codes = codelist_from_csv(
    "codelists/opensafely-asthma-inhaler-steroid-medication.csv", system="snomed", column="id"
    )

laba_ics_med_codes = codelist_from_csv(
    "codelists/opensafely-laba-ics-combination-inhaler.csv", system="snomed", column="id"
    )

laba_lama_med_codes = codelist_from_csv(
    "codelists/laba-lama-combination-inhaler.csv", system="snomed", column="id"
    )

laba_lama__ics_med_codes = codelist_from_csv(
    "codelists/laba-lama-ics-combination-inhaler.csv", system="snomed", column="id"
    )

leukotriene_med_codes = codelist_from_csv(
    "codelists/leukotriene-receptor-antagonist-medication.csv", system="snomed", column="id"
    )

low_medium__ics_med_codes = codelist_from_csv(
    "codelists/low-and-medium-dose-ics-inhalers.csv", system="snomed", column="id"
    )

nebulised_med_codes = codelist_from_csv(
    "codelists/nebulised-asthma-and-copd-medications.csv", system="snomed", column="id"
    )

single_laba_med_codes = codelist_from_csv(
    "codelists/single-ingredient-laba-inhalers.csv", system="snomed", column="id"
    )

oral_steroid_med_codes = codelist_from_csv(
    "codelists/opensafely-asthma-oral-prednisolone-medication.csv", system="snomed", column="vpid"
    )

saba_med_codes = codelist_from_csv(
    "codelists/opensafely-asthma-inhaler-salbutamol-medication.csv", system="snomed", column="id"
    )

asthma_codes = codelist_from_csv(
    "codelists/opensafely-asthma-diagnosis.csv", system="ctv3", column="CTV3ID"
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
    "codelists/opensafely-cancer-excluding-lung-and-haematological.csv", system="ctv3", column="CTV3ID"
)

aplastic_codes = codelist_from_csv(
    "codelists/opensafely-aplastic-anaemia.csv", system="ctv3", column="CTV3ID")

hiv_codes = codelist_from_csv(
    "codelists/opensafely-hiv.csv", system="ctv3", column="CTV3ID")

permanent_immune_codes = codelist_from_csv(
    "codelists/opensafely-permanent-immunosuppresion.csv", system="ctv3", column="CTV3ID")

temp_immune_codes = codelist_from_csv(
    "codelists/opensafely-temporary-immunosuppresion.csv", system="ctv3", column="CTV3ID")

creatinine_codes = codelist(["XE2q5"], system="ctv3")

covid_codelist = codelist(["U071", "U072"], system="icd10")


study = StudyDefinition(
    ## STUDY POPULATION

    population=patients.satisfying(
    'has_follow_up AND has_asthma',
    has_asthma=patients.with_these_clinical_events(
        asthma_codes,
        on_or_before='2017-02-01',
    ),
    has_follow_up=patients.registered_with_one_practice_between("2019-02-01", "2020-02-01")
),
    ## OUTCOMES
    icu_date_admitted=patients.admitted_to_icu(
        on_or_after="2020-02-01",
        include_day=True,
        returning="date_admitted"
    ),

    died_date_cpns=patients.with_death_recorded_in_cpns(
        on_or_before="2020-06-01",
        returning="date_of_death",
        include_month=True,
        include_day=True,
    ),

    died_ons_covid_flag_any=patients.with_these_codes_on_death_certificate(
        covid_codelist, on_or_before="2020-06-01", match_only_underlying_cause=False
    ),

    died_ons_covid_flag_underlying=patients.with_these_codes_on_death_certificate(
        covid_codelist, on_or_before="2020-06-01", match_only_underlying_cause=True
    ),

    died_date_ons=patients.died_from_any_cause(
        on_or_before="2020-06-01",
        returning="date_of_death"),

    ## DEMOGRAPHIC INFORMATION

    age=patients.age_as_of("2020-02-01"),

    sex=patients.sex(),

    stp=patients.registered_practice_as_of("2020-02-01", returning="stp_code"),

    imd=patients.address_as_of("2020-02-01", returning="index_of_multiple_deprivation", round_to_nearest=100),

    ethnicity = patients.with_these_clinical_events(
        ethnicity_codes,
        returning="category",
        find_last_match_in_period=True,
        include_date_of_match=True,
    ),

    ## COVARIATES
    bmi=patients.most_recent_bmi(
        on_or_after="2010-02-01",
        minimum_age_at_measurement=16,
        include_measurement_date=True,
        include_month=True,
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
            "M": "DEFAULT"
        },
        most_recent_smoking_code=patients.with_these_clinical_events(
            clear_smoking_codes,
            find_last_match_in_period=True,
            on_or_before='2020-02-01',
            returning="category",
        ),
        ever_smoked=patients.with_these_clinical_events(
            filter_codes_by_category(clear_smoking_codes, include=['S', 'E']),
            on_or_before='2020-02-01'
        ),
    ),
    smoking_status_date=patients.with_these_clinical_events(
        clear_smoking_codes,
        on_or_before='2020-02-01',
        return_last_date_in_period=True,
        include_month=True,
    ),
    most_recent_unclear_smoking_cat=patients.with_these_clinical_events(
        unclear_smoking_codes,
        find_last_match_in_period=True,
        on_or_before='2020-02-01',
        returning="category",
    ),
    most_recent_unclear_smoking_numeric=patients.with_these_clinical_events(
        unclear_smoking_codes,
        find_last_match_in_period=True,
        on_or_before="2020-02-01",
        returning="numeric_value",
    ),
    most_recent_unclear_smoking_cat_date=patients.with_these_clinical_events(
        unclear_smoking_codes,
        on_or_before='2020-02-01',
        return_last_date_in_period=True,
        include_month=True,
    ),

    #### ICS SINGLE CONSTITUENT
    ics_single = patients.with_these_medications(
        ics_single_med_codes,
        between=["2018-02-01", "2020-02-01"],
        returning="number_of_matches_in_period",
    ),

    #### ORAL STEROIDS SINGLE CONSTITUENT
    oral_steroids = patients.with_these_medications(
        oral_steroid_med_codes,
        between=["2018-02-01", "2020-02-01"],
        returning="number_of_matches_in_period",
    ),

    #### SABA SINGLE CONSTITUENT
    saba_single=patients.with_these_medications(
        saba_med_codes,
        between=["2018-02-01", "2020-02-01"],
        returning="number_of_matches_in_period",
    ),

    #### LABA SINGLE CONSTITUENT
    laba_single=patients.with_these_medications(
        single_laba_med_codes,
        between=["2018-02-01", "2020-02-01"],
        returning="number_of_matches_in_period",
    ),

    #### LAMA SINGLE CONSTITUENT
    lama_single=patients.with_these_medications(
        placeholder_med_codes, #### REPLACE WITH REAL CODE LIST WHEN AVAILABLE
        between=["2018-02-01", "2020-02-01"],
        returning="number_of_matches_in_period",
    ),

    #### LABA + ICS
    laba_ics=patients.with_these_medications(
        laba_ics_med_codes,  
        between=["2018-02-01", "2020-02-01"],
        returning="number_of_matches_in_period",
    ),

    #### LABA + LAMA
    laba_lama=patients.with_these_medications(
        laba_lama_med_codes,  
        between=["2018-02-01", "2020-02-01"],
        returning="number_of_matches_in_period",
    ),

    #### LABA + LAMA + ICS
    laba_lama_ics=patients.with_these_medications(
        laba_lama__ics_med_codes, 
        between=["2018-02-01", "2020-02-01"],
        returning="number_of_matches_in_period",
    ),

    #### LTRA SINGLE CONSTITUENT
    ltra_single=patients.with_these_medications(
        leukotriene_med_codes,   
        between=["2018-02-01", "2020-02-01"],
        returning="number_of_matches_in_period",
    ),

    #### NEBULES
    nebules=patients.with_these_medications(
        nebulised_med_codes, 
        between=["2018-02-01", "2020-02-01"],
        returning="number_of_matches_in_period",
    ),

    ### OXYGEN THERAPY LEFT OUT AT PRESENT DUE TO POOR RECORDS

    ### COPD
    copd=patients.with_these_clinical_events(
        placeholder_event_codes, #### REPLACE WITH REAL CODE LIST WHEN AVAILABLE
        return_first_date_in_period=True,
        include_month=True,
    ),

    ### OTHER RESPIRATORY
    other_respiratory=patients.with_these_clinical_events(
        placeholder_event_codes,  #### REPLACE WITH REAL CODE LIST WHEN AVAILABLE
        return_first_date_in_period=True,
        include_month=True,
    ),

    ### ILI
    ili=patients.with_these_clinical_events(
        placeholder_event_codes,  #### REPLACE WITH REAL CODE LIST WHEN AVAILABLE
        return_first_date_in_period=True,
        include_month=True,
    ),

    ### HYPERTENSION
    hypertension=patients.with_these_clinical_events(
        placeholder_event_codes,
        return_first_date_in_period=True,
        include_month=True,
    ),

    #### SYSTOLIC BLOOD PRESSURE
    bp_sys=patients.mean_recorded_value(
        systolic_blood_pressure_codes,
        on_most_recent_day_of_measurement=True,
        on_or_before="2020-02-01",
        include_measurement_date=True,
        include_month=True,
    ),

    ### DIASTOLIC BLOOD PRESSURE
    bp_dias=patients.mean_recorded_value(
        diastolic_blood_pressure_codes,
        on_most_recent_day_of_measurement=True,
        on_or_before="2020-02-01",
        include_measurement_date=True,
        include_month=True,
    ),

    ### DIABETES
    diabetes=patients.with_these_clinical_events(
        diabetes_codes,
        return_first_date_in_period=True,
        include_month=True,
    ),

    ### CANCER - 3 TYPES
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

    # IMMUNOSUPPRESSION - 4 TYPES
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

    ### CHRONIC KIDNEY DISEASE
    creatinine=patients.with_these_clinical_events(
        creatinine_codes,
        find_last_match_in_period=True,
        on_or_before="2020-02-01",
        returning="numeric_value",
        include_date_of_match=True,
        include_month=True,
    ),

    ### EXACERBATION HISTORY
    exacerbation=patients.with_these_clinical_events(
        placeholder_event_codes,  #### REPLACE WITH REAL CODE LIST WHEN AVAILABLE
        return_number_of_matches_in_period=True,
        include_month=True,
    ),

    ### VACCINATION HISTORY
    vaccine=patients.with_these_clinical_events(
        placeholder_event_codes,  #### REPLACE WITH REAL CODE LIST WHEN AVAILABLE
        return_first_date_in_period=True,
        include_month=True,
    ),

    ### INSULIN USE
    insulin=patients.with_these_medications(
        insulin_med_codes,
        between=["2018-02-01", "2020-02-01"],
        returning="number_of_matches_in_period",
    ),

    ### STATIN USE
    statin=patients.with_these_medications(
        statin_med_codes,
        between=["2018-02-01", "2020-02-01"],
        returning="number_of_matches_in_period",
    ),

)