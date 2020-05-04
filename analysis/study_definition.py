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

    # Outcomes
    icu_date_admitted=patients.admitted_to_icu(
        on_or_after="2020-02-01",
        include_day=True,
        returning="date_admitted",
      
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

    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/12
    vaccination_status=patients.with_these_clinical_events(
        vaccination_codes,
        returning="date",
        between=["2019-09-01", "2020-02-01"], ### note this is from 1st September 2019
        find_first_match_in_period=True,
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
      
    recent_salbutamol_count=patients.with_these_medications(
        salbutamol_codes,
        between=["2018-02-01", "2020-02-01"],
        returning="number_of_matches_in_period",
    ),
)
