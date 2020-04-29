from datalab_cohorts import StudyDefinition, patients, codelist, codelist_from_csv


## CODE Lists
copd_not_signed_off = codelist_from_csv(
    "codelists/copd_not_signed_off.csv", system="ctv3", column="CTV3ID")

lama_laba_codes = codelist_from_csv(
    "codelists/lama_laba_codelist.csv", system="snomed", column="id")

laba_codes = codelist_from_csv(
    "codelists/laba_single_codelist.csv", system="snomed", column="id")

lama_codes = codelist_from_csv(
    "codelists/lama_single_codelist.csv", system="snomed", column="id")

triple_codes = codelist_from_csv(
    "codelists/lama_triple_codelist.csv", system="snomed", column="id")

steroid_codes = codelist_from_csv(
    "codelists/inhaledsteroid_asthma.csv", system="snomed", column="id")


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
    # 
    copd_not_signed_off=patients.with_these_clinical_events(
        copd_not_signed_off,
        returning="date",
        find_first_match_in_period=True,
        include_month=True,
    ),
    
    recent_lama_laba=patients.with_these_medications(
        lama__laba_codes,
        between=["2019-12-01", "2020-03-01"],
        returning="number_of_matches_in_period",
    ),

     recent_lama_count=patients.with_these_medications(
        lama_codes,
        between=["2019-12-01", "2020-03-01"],
        returning="number_of_matches_in_period",
    ),

      recent_triple_therapy_count=patients.with_these_medications(
        triple_codes,
        between=["2019-12-01", "2020-03-01"],
        returning="number_of_matches_in_period",
    ),

       recent_inhaled_steroid_count=patients.with_these_medications(
        steroid_codes,
        between=["2019-12-01", "2020-03-01"],
        returning="number_of_matches_in_period",
    ),

        recent_laba_count=patients.with_these_medications(
        laba_codes,
        between=["2019-12-01", "2020-03-01"],
        returning="number_of_matches_in_period",
    ),

         recent_lama_count=patients.with_these_medications(
        salbutamol_codes,
        between=["2018-02-01", "2020-02-01"],
        returning="number_of_matches_in_period",
    ),

         # https://github.com/ebmdatalab/tpp-sql-notebook/issues/55
        laba_lama_only=patients.categorised_as(
        {
            "0": "DEFAULT",
            "1": """
                (
                  recent_lama_laba OR (
                    recent_lama_count AND recent_laba)
                  )
                ) AND NOT (
                  recent_inhaled_steroid_count OR 
                  recent_triple_therapy_count
                )
            """,
      
        }, 
)
