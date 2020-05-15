import delimited `c(pwd)'/analysis/input_copd.csv, clear
set more off 
cd  `c(pwd)'/analysis

/* COPD ======================================================================*/

* Create directories required 

capture mkdir copd_output
capture mkdir copd_log
capture mkdir copd_tempdata

* Set globals that will print in programs and direct output

global Population "COPD"
global Outdir  	  "copd_output" 
global Logdir     "copd_log"
global Tempdir    "copd_tempdata"

/*  Pre-analysis data manipulation  */

do "00_cr_create_analysis_dataset.do"

* COPD specific data manipulation   
do "01_cr_create_copd_population.do"
do "02_cr_create_copd_exposure.do"

/*  Checks  */

do "03_an_checks.do"

/* Run analysis */ 

* COPD specific analyses 
do "04_an_descriptive_table_copd.do"
do "05_an_descriptive_plots_copd.do"
*do "06_an_models_copd.do"
*do "07_an_sensitivity_models_copd.do"

/* 	ASTHMA ====================================================================*/

clear
import delimited `c(pwd)'/analysis/input_asthma.csv, clear
set more off 
cd  `c(pwd)'/analysis

* Create directories required 

capture mkdir asthma_output
capture mkdir asthma_log
capture mkdir asthma_tempdata

global Outdir  "asthma_output" 
global Logdir  "asthma_log"
global Tempdir "asthma_tempdata"

/*  Pre-analysis data manipulation  */

do "00_cr_create_analysis_dataset.do"

* COPD specific data manipulation   
do "01_cr_create_asthma_population.do"
do "02_cr_create_asthma_exposure.do"

/*  Checks  */

do "03_an_checks.do"

/* Run analysis */ 

* COPD specific analyses 
do "04_an_descriptive_table_asthma.do"
do "05_an_descriptive_plots_asthma.do"
*do "06_an_models_asthma.do"
*do "07_an_sensitivity_models_asthma.do"




