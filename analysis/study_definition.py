from datalab_cohorts import StudyDefinition, patients, codelist, codelist_from_csv

chronic_cardiac_disease_codes = codelist_from_csv(
    "codelists/chronic_cardiac_disease.csv", system="ctv3", column="CTV3ID"
)
chronic_liver_disease_codes = codelist_from_csv(
    "codelists/chronic_liver_disease.csv", system="ctv3", column="CTV3ID"
)
salbutamol_codes = codelist_from_csv(
    "codelists/sabutamol_asthma.csv", system="snomed", column="id"
)
systolic_blood_pressure_codes = codelist(["2469."], system="ctv3")
diastolic_blood_pressure_codes = codelist(["246A."], system="ctv3")

study = StudyDefinition(
    # This line defines the study population
    population=patients.registered_with_one_practice_between(
        "2019-02-01", "2020-02-01"
    ),

    # Outcomes
    icu_date_admitted=patients.admitted_to_icu(
        on_or_after="2020-02-01",
        include_day=True,
        returning="date_admitted",
        find_first_match_in_period=True,
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
        returning="date_of_death",
        include_month=True,
        include_day=True,
    ),

    # Negative control outcomes
    # hospital_admission_ili - I think no suitable hospital admission data yet
    # icu_admission_ili - is this possible from the data we have?
    # ili_death - needs an ILI codelist then can define in ONS

    # The rest of the lines define the covariates with associated GitHub issues
    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/33
    age=patients.age_as_of("2020-02-01"),
    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/46
    sex=patients.sex(),

    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/27
    ethnicity=patients.with_these_clinical_events(
        ethnicity_codes,
        returning="category",
        find_last_match_in_period=True,
        include_date_of_match=True,
        ),

    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/10
    bmi=patients.most_recent_bmi(
        on_or_after="2010-02-01",
        minimum_age_at_measurement=16,
        include_measurement_date=True,
        include_month=True,
    ),

    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/6
    smoking_status=patients.categorised_as(
        {
            "S": """
                most_recent_smoking_code = 'S' OR (
                  most_recent_smoking_code = 'X' AND most_recent_smoking_numeric > 0
                )
            """,
            "E": """
                 most_recent_smoking_code = 'E' OR (
                   most_recent_smoking_code = 'N' AND ever_smoked
                 )
            """,
            "N": """
                (
                  most_recent_smoking_code = 'N' OR (
                    most_recent_smoking_code = 'X' AND most_recent_smoking_numeric = 0
                  )
                ) AND NOT ever_smoked
            """,
            "M": "DEFAULT"
        },
        most_recent_smoking_code=patients.with_these_clinical_events(
            smoking_codes,
            find_last_match_in_period=True,
            on_or_before='2020-02-01',
            returning="category",
        ),
        most_recent_smoking_numeric=patients.with_these_clinical_events(
            smoking_codes,
            find_last_match_in_period=True,
            on_or_before="2020-02-01",
            returning="numeric_value",
        ),
        ever_smoked=patients.with_these_clinical_events(
            filter_codes_by_category(smoking_codes, include=['S', 'E']),
            on_or_before='2020-02-01'
        ),
    ),

    # Hypertenstion - TBD

    # Heart failure - TBD

    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/7
    chronic_cardiac_disease=patients.with_these_clinical_events(
        chronic_cardiac_disease_codes,
        return_first_date_in_period=True,
        include_month=True,
    ),

    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/30
    diabetes=patients.with_these_clinical_events(
        diabetes_codes,
        return_first_date_in_period=True,
        include_month=True,
    ),

    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/12
    chronic_liver_disease=patients.with_these_clinical_events(
        chronic_liver_disease_codes,
        returning="date",
        find_first_match_in_period=True,
        include_month=True,
    ),
)
