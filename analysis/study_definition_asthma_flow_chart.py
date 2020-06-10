from datalab_cohorts import (
    StudyDefinition,
    patients,
    filter_codes_by_category,
    combine_codelists,
)

from codelists import *

# Main asthma pop
"""
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
"""
# Sensitivity analysis population
"""
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
"""
study = StudyDefinition(
    # Configure the expectations framework (optional)
    default_expectations={
        "date": {"earliest": "1970-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.05,
    },
    ## STUDY POPULATION (required)
    population=patients.all(),
    has_asthma=patients.with_these_clinical_events(
        asthma_codes,
        between=["2017-02-28", "2020-02-29"],
        return_expectations={"incidence": 0.5},
    ),
    asthma_ever=patients.with_these_clinical_events(
        asthma_ever_codes,
        on_or_before="2020-02-29",
        return_expectations={"incidence": 0.8},
    ),
    asthma_sensitivity=patients.satisfying(
        """
        has_asthma OR
        (asthma_ever AND any_asthma_med)
        """,
        return_expectations={"incidence": 0.9},
    ),
    any_asthma_med=patients.satisfying(
        """
            ltra_single OR
            laba_lama_ics OR
            laba_lama OR
            laba_ics OR
            lama_single OR
            laba_single OR
            sama_single OR
            saba_single OR
            ics_single OR
            low_med_dose_ics OR
            low_med_dose_ics_multiple_ingredient OR
            low_med_dose_ics_single_ingredient OR
            high_dose_ics_multiple_ingredient OR
            high_dose_ics_single_ing OR
            high_dose_ics

            """
    ),
    age_cat=patients.satisfying(
        "age >=35 AND age <= 110",
        return_expectations={"incidence": 0.9},
        age=patients.age_as_of(
            "2020-02-29",
            return_expectations={
                "rate": "universal",
                "int": {"distribution": "population_ages"},
            },
        ),
    ),
    has_follow_up=patients.registered_with_one_practice_between(
        "2019-02-28", "2020-02-29", return_expectations={"incidence": 0.9}
    ),
    copd=patients.with_these_clinical_events(
        copd_codes, on_or_before="2020-02-29", return_expectations={"incidence": 0.05},
    ),
    ### OTHER RESPIRATORY
    other_respiratory=patients.with_these_clinical_events(
        other_respiratory_codes,
        on_or_before="2020-02-29",
        return_expectations={"incidence": 0.05},
    ),
    nebules=patients.with_these_medications(
        nebulised_med_codes,
        between=["2019-02-28", "2020-02-29"],
        return_expectations={"incidence": 0.05},
    ),
    lama_no_ics=patients.satisfying(
        """(lama_single OR laba_lama) AND NOT (
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
        """,
    ),
    #### HIGH DOSE ICS - all preparation
    high_dose_ics=patients.with_these_medications(
        high_dose_ics_med_codes,
        between=["2019-11-01", "2020-02-29"],
        return_expectations={"incidence": 0.05},
    ),
    #### HIGH DOSE ICS - single ingredient preparations
    high_dose_ics_single_ing=patients.with_these_medications(
        high_dose_ics_single_ingredient_med_codes,
        between=["2019-11-01", "2020-02-29"],
        return_expectations={"incidence": 0.05},
    ),
    #### HIGH DOSE ICS - multiple ingredient preparation
    high_dose_ics_multiple_ingredient=patients.with_these_medications(
        high_dose_ics_multiple_ingredient_med_codes,
        between=["2019-11-01", "2020-02-29"],
        return_expectations={"incidence": 0.05},
    ),
    ### LOW-MED DOSE ICS - single ingredient preparations
    low_med_dose_ics_single_ingredient=patients.with_these_medications(
        low_medium_ics_single_ingredient_med_codes,
        between=["2019-11-01", "2020-02-29"],
        return_expectations={"incidence": 0.05},
    ),
    ### LOW-MED DOSE ICS - multiple ingredient preparations
    low_med_dose_ics_multiple_ingredient=patients.with_these_medications(
        low_medium_ics_multiple_ingredient_med_codes,
        between=["2019-11-01", "2020-02-29"],
        return_expectations={"incidence": 0.05},
    ),
    ### LOW-MED DOSE ICS - all preparation
    low_med_dose_ics=patients.with_these_medications(
        low_medium_ics_med_codes,
        between=["2019-11-01", "2020-02-29"],
        return_expectations={"incidence": 0.05},
    ),
    #### ICS SINGLE CONSTITUENT
    ics_single=patients.with_these_medications(
        ics_single_med_codes,
        between=["2019-11-01", "2020-02-29"],
        return_expectations={"incidence": 0.05},
    ),
    #### ORAL STEROIDS SINGLE CONSTITUENT
    oral_steroids=patients.with_these_medications(
        oral_steroid_med_codes,
        between=["2019-11-01", "2020-02-29"],
        return_expectations={"incidence": 0.05},
    ),
    #### SABA SINGLE CONSTITUENT
    saba_single=patients.with_these_medications(
        saba_med_codes,
        between=["2019-11-01", "2020-02-29"],
        return_expectations={"incidence": 0.05},
    ),
    #### SAMA SINGLE CONSTITUENT
    sama_single=patients.with_these_medications(
        sama_med_codes,
        between=["2019-11-01", "2020-02-29"],
        return_expectations={"incidence": 0.05},
    ),
    #### LABA SINGLE CONSTITUENT
    laba_single=patients.with_these_medications(
        single_laba_med_codes,
        between=["2019-11-01", "2020-02-29"],
        return_expectations={"incidence": 0.05},
    ),
    #### LAMA SINGLE CONSTITUENT
    lama_single=patients.with_these_medications(
        single_lama_med_codes,
        between=["2019-11-01", "2020-02-29"],
        return_expectations={"incidence": 0.05},
    ),
    #### LABA + ICS
    laba_ics=patients.with_these_medications(
        laba_ics_med_codes,
        between=["2019-11-01", "2020-02-29"],
        return_expectations={"incidence": 0.05},
    ),
    #### LABA + LAMA
    laba_lama=patients.with_these_medications(
        laba_lama_med_codes,
        between=["2019-11-01", "2020-02-29"],
        return_expectations={"incidence": 0.05},
    ),
    #### LABA + LAMA + ICS
    laba_lama_ics=patients.with_these_medications(
        laba_lama__ics_med_codes,
        between=["2019-11-01", "2020-02-29"],
        return_expectations={"incidence": 0.05},
    ),
    #### LTRA SINGLE CONSTITUENT
    ltra_single=patients.with_these_medications(
        leukotriene_med_codes,
        between=["2019-11-01", "2020-02-29"],
        return_expectations={"incidence": 0.05},
    ),
)
