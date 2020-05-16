cd  `c(pwd)'/analysis
import delimited input_copd.csv, clear
set more off 


/* COPD ======================================================================*/

* Create directories required 

capture mkdir copd_output
capture mkdir copd_log
capture mkdir copd_tempdata

* Set globals that will print in programs and direct output

global population "COPD"
global outdir  	  "copd_output" 
global logdir     "copd_log"
global tempdir    "copd_tempdata"

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
import delimited `c(pwd)'/input_asthma.csv, clear
set more off 

* Create directories required 

capture mkdir asthma_output
capture mkdir asthma_log
capture mkdir asthma_tempdata

global population "Asthma"
global outdir  "asthma_output" 
global logdir  "asthma_log"
global tempdir "asthma_tempdata"

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




