from datalab_cohorts import (
    StudyDefinition,
    patients,
    filter_codes_by_category,
    combine_codelists,
)

from codelists import *

"""
copd AND -
(age >=35 AND age <= 110) AND
ever_smoked AND
has_follow_up AND NOT
recent_asthma AND NOT
other_respiratory AND NOT
nebules AND NOT
ltra_single
"""

study = StudyDefinition(
    # Configure the expectations framework (optional)
    default_expectations={
        "date": {"earliest": "1970-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.2,
    },
    ## STUDY POPULATION (required)
    population=patients.all(),
    copd=patients.with_these_clinical_events(
        copd_codes, on_or_before="2020-02-29", return_expectations={"incidence": 0.2},
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
    ever_smoked=patients.with_these_clinical_events(
        filter_codes_by_category(clear_smoking_codes, include=["S", "E"]),
        on_or_before="2020-02-29",
        return_expectations={"incidence": 0.2},
    ),
    has_follow_up=patients.registered_with_one_practice_between(
        "2019-02-28", "2020-02-29", return_expectations={"incidence": 0.2},
    ),
    recent_asthma=patients.with_these_clinical_events(
        asthma_codes,
        between=["2017-02-28", "2020-02-29"],
        return_expectations={"incidence": 0.2},
    ),
    other_respiratory=patients.with_these_clinical_events(
        other_respiratory_codes,
        on_or_before="2020-02-29",
        return_expectations={"incidence": 0.2},
    ),
    #### NEBULES
    nebules=patients.with_these_medications(
        nebulised_med_codes,
        between=["2019-02-28", "2020-02-29"],
        return_expectations={"incidence": 0.2},
    ),
    ltra_single=patients.with_these_medications(
        leukotriene_med_codes,
        between=["2019-11-01", "2020-02-29"],
        return_expectations={"incidence": 0.2},
    ),
)
