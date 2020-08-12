import delimited `c(pwd)'/output/input_copd.csv, clear
cd  `c(pwd)'/analysis
set more off 

adopath + "./extra_ado"

/* COPD ======================================================================*/

* Create directories required 

capture mkdir copd_output
capture mkdir copd_log
capture mkdir copd_tempdata

* Set globals that will print in programs and direct output

global population "COPD"
global outcome 	  "onscoviddeath"
global outdir  	  "copd_output" 
global logdir     "copd_log"
global tempdir    "copd_tempdata"
global varlist 		i.obese4cat					///
					i.smoke_nomiss				///
					i.imd 						///
					i.ckd	 					///
					i.hypertension			 	///
					i.heart_failure				///
					i.other_heart_disease		///
					i.diabcat 					///
					i.cancer_ever 				///
					i.statin 					///
					i.flu_vaccine 				///
					i.pneumococcal_vaccine		///
					i.exacerbations 			///
					i.asthma_ever				///
					i.immunodef_any
					
global tableoutcome "COVID-19 Death in ONS"
global ymax 0.005

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
do "06_an_models_copd.do"
do "07_an_models_interact_copd.do"
do "08_an_model_checks_copd.do"
do "09_an_model_explore_copd.do"
do "10_an_models_ethnicity_copd.do"

* Post peer review requested different adjustments
do "Extra_06_an_models_copd" 
 
/* 	ASTHMA ===================================================================*/
clear
cd ..
import delimited `c(pwd)'/output/input_asthma.csv, clear
cd  `c(pwd)'/analysis
set more off 

* Create directories required 

capture mkdir asthma_output
capture mkdir asthma_log
capture mkdir asthma_tempdata

global population   "Asthma"
global outcome 		"onscoviddeath"
global outdir  		"asthma_output" 
global logdir  		"asthma_log"
global tempdir 		"asthma_tempdata"
global varlist	 	i.obese4cat					///
					i.smoke_nomiss				///
					i.imd 						///
					i.ckd	 					///
					i.hypertension			 	///
					i.heart_failure				///
					i.other_heart_disease		///
					i.diabcat 					///
					i.cancer_ever 				///
					i.statin 					///
					i.flu_vaccine 				///
					i.pneumococcal_vaccine		///
					i.exacerbations 			///
					i.immunodef_any

global tableoutcome "COVID-19 Death in ONS"
global ymax 0.005

/*  Pre-analysis data manipulation  */

do "00_cr_create_analysis_dataset.do"

* COPD specific data manipulation   
do "01_cr_create_asthma_population.do"
do "02_cr_create_asthma_exposure.do"

/*  Checks  */

do "03_an_checks.do"

/* Run analysis */ 

* Asthma specific analyses 
do "04_an_descriptive_table_asthma.do"
do "05_an_descriptive_plots_asthma.do"
do "06_an_models_asthma.do"
do "07_an_models_interact_asthma.do"
do "08_an_model_checks_asthma.do"
do "09_an_model_explore_asthma.do"
do "10_an_models_ethnicity_asthma.do"

* Post peer review requested different adjustments
do "Extra_06_an_models_asthma" 

/* 	SENSITIVITY 1=============================================================*/
*   Redefine copd exposure to triple therapy 

clear
cd ..
import delimited `c(pwd)'/output/input_copd.csv, clear
cd  `c(pwd)'/analysis
set more off 

capture mkdir copd_output_sens1
capture mkdir copd_log_sens1
capture mkdir copd_tempdata_sens1

global population "COPD - Sensitivity Exposure Definition"
global outcome 	  "onscoviddeath"
global outdir  	  "copd_output_sens1" 
global logdir     "copd_log_sens1"
global tempdir    "copd_tempdata_sens1"
global varlist	 	i.obese4cat					///
					i.smoke_nomiss				///
					i.imd 						///
					i.ckd	 					///
					i.hypertension			 	///
					i.heart_failure				///
					i.other_heart_disease		///
					i.diabcat 					///
					i.cancer_ever 				///
					i.statin 					///
					i.flu_vaccine 				///
					i.pneumococcal_vaccine		///
					i.exacerbations 			///
					i.asthma_ever				///
					i.immunodef_any
					
global tableoutcome "COVID-19 Death in ONS"
global ymax 0.005

/*  Pre-analysis data manipulation  */

do "00_cr_create_analysis_dataset.do"

* COPD specific data manipulation   
do "01_cr_create_copd_population.do"

* Create the new exposure 
do "S1-02_cr_create_copd_exposure.do"

/*  Checks  */

do "03_an_checks.do"

/* Run analysis */ 

* COPD specific analyses 
do "S1-04_an_descriptive_table_copd.do"
do "S1-05_an_descriptive_plots_copd.do"
do "S1-06_an_models_copd.do"
do "S1-08_an_model_checks_copd.do"
do "S1-09_an_model_explore_copd.do"


/* 	SENSITIVITY 2=============================================================*/
*   ONS non-COVID death as the outcome 

/* COPD */

clear
cd ..
import delimited `c(pwd)'/output/input_copd.csv, clear
cd  `c(pwd)'/analysis
set more off 

* Create directories required 

capture mkdir copd_output_sens2
capture mkdir copd_log_sens2
capture mkdir copd_tempdata_sens2

* Set globals that will print in programs and direct output

global population "COPD"
global outcome "onsnoncoviddeath"
global outdir  	  "copd_output_sens2" 
global logdir     "copd_log_sens2"
global tempdir    "copd_tempdata_sens2"
global varlist	 	i.obese4cat					///
					i.smoke_nomiss				///
					i.imd 						///
					i.ckd	 					///
					i.hypertension			 	///
					i.heart_failure				///
					i.other_heart_disease		///
					i.diabcat 					///
					i.cancer_ever 				///
					i.statin 					///
					i.flu_vaccine 				///
					i.pneumococcal_vaccine		///
					i.exacerbations 			///
					i.asthma_ever				///
					i.immunodef_any
										
global tableoutcome "Non-COVID Death in ONS"
global ymax 1

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
do "06_an_models_copd.do"
do "08_an_model_checks_copd.do"
do "09_an_model_explore_copd.do"

/* 	ASTHMA  */

clear
cd ..
import delimited `c(pwd)'/output/input_asthma.csv, clear
cd  `c(pwd)'/analysis
set more off 

* Create directories required 

capture mkdir asthma_output_sens2
capture mkdir asthma_log_sens2
capture mkdir asthma_tempdata_sens2

global population "Asthma"
global outcome "onsnoncoviddeath"
global outdir  "asthma_output_sens2" 
global logdir  "asthma_log_sens2"
global tempdir "asthma_tempdata_sens2"
global varlist	 	i.obese4cat					///
					i.smoke_nomiss				///
					i.imd 						///
					i.ckd	 					///
					i.hypertension			 	///
					i.heart_failure				///
					i.other_heart_disease		///
					i.diabcat 					///
					i.cancer_ever 				///
					i.statin 					///
					i.flu_vaccine 				///
					i.pneumococcal_vaccine		///
					i.exacerbations 			///
					i.immunodef_any
					
global tableoutcome "Non-COVID Death in ONS"
global ymax 0.2

/*  Pre-analysis data manipulation  */

do "00_cr_create_analysis_dataset.do"

* COPD specific data manipulation   
do "01_cr_create_asthma_population.do"
do "02_cr_create_asthma_exposure.do"

/*  Checks  */

do "03_an_checks.do"

/* Run analysis */ 

* Asthma specific analyses 
do "04_an_descriptive_table_asthma.do"
do "05_an_descriptive_plots_asthma.do"
do "06_an_models_asthma.do"
do "08_an_model_checks_asthma.do"
do "09_an_model_explore_asthma.do"

/* 	SENSITIVITY 3=============================================================*/
*   Asthma population: ever diagnosis + recent treatment 

clear
cd ..
import delimited `c(pwd)'/output/input_asthma_sens_analysis.csv, clear
cd  `c(pwd)'/analysis
set more off 

* Create directories required 

capture mkdir asthma_output_sens3
capture mkdir asthma_log_sens3
capture mkdir asthma_tempdata_sens3

global population "Asthma - Ever"
global outcome "onscoviddeath"
global outdir  "asthma_output_sens3" 
global logdir  "asthma_log_sens3"
global tempdir "asthma_tempdata_sens3"
global varlist	 	i.obese4cat					///
					i.smoke_nomiss				///
					i.imd 						///
					i.ckd	 					///
					i.hypertension			 	///
					i.heart_failure				///
					i.other_heart_disease		///
					i.diabcat 					///
					i.cancer_ever 				///
					i.statin 					///
					i.flu_vaccine 				///
					i.pneumococcal_vaccine		///
					i.exacerbations 			///
					i.immunodef_any
					
global tableoutcome "COVID-19 Death in ONS"
global ymax 0.005

/*  Pre-analysis data manipulation  */

do "00_cr_create_analysis_dataset.do"

* COPD specific data manipulation   
do "01_cr_create_asthma_population.do"
do "02_cr_create_asthma_exposure.do"

/*  Checks  */

do "03_an_checks.do"

/* Run analysis */ 

* Asthma specific analyses 
do "04_an_descriptive_table_asthma.do"
do "05_an_descriptive_plots_asthma.do"
do "06_an_models_asthma.do"
do "08_an_model_checks_asthma.do"
do "09_an_model_explore_asthma.do"


/* 	SENSITIVITY 4=============================================================*/
*   Post peer review: Include LAMA monotherapy in the LABA/LAMA arm for COPD

clear
cd ..
import delimited `c(pwd)'/output/input_copd.csv, clear
cd  `c(pwd)'/analysis
set more off 

* Create directories required 

capture mkdir copd_output_sens4
capture mkdir copd_log_sens4
capture mkdir copd_tempdata_sens4

global population "COPD - LAMA monotherapy"
global outcome "onscoviddeath"
global outdir  "copd_output_sens4" 
global logdir  "copd_log_sens4"
global tempdir "copd_tempdata_sens4"
global varlist	 	i.obese4cat					///
					i.smoke_nomiss				///
					i.imd 						///
					i.ckd	 					///
					i.hypertension			 	///
					i.heart_failure				///
					i.other_heart_disease		///
					i.diabcat 					///
					i.cancer_ever 				///
					i.statin 					///
					i.flu_vaccine 				///
					i.pneumococcal_vaccine		///
					i.exacerbations 			///
					i.asthma_ever				///
					i.immunodef_any
					
global tableoutcome "COVID-19 Death in ONS"
global ymax 0.005

/*  Pre-analysis data manipulation  */

do "00_cr_create_analysis_dataset.do"

* COPD specific data manipulation   
do "01_cr_create_copd_population.do"
do "S4-02_cr_create_copd_exposure.do"

/*  Checks  */
do "03_an_checks.do"

/* Run analysis */ 

* COPD specific analyses 
do "04_an_descriptive_table_copd.do"
do "06_an_models_copd.do"

/* PSM =======================================================================*/
* Post hoc implementation of PS with IPTW (reviewer request)
* Create directories required 

clear
cd ..
import delimited `c(pwd)'/output/input_copd.csv, clear
cd  `c(pwd)'/analysis
set more off 

capture mkdir copd_output_psm
capture mkdir copd_log_psm
capture mkdir copd_tempdata_psm

* Set globals that will print in programs and direct output

global population "COPD - PS"
global outcome 	  "onscoviddeath"
global outdir  	  "copd_output_psm" 
global logdir     "copd_log_psm"
global tempdir    "copd_tempdata_psm"

global varlist 		i.obese4cat					///
					i.smoke_nomiss				///
					i.imd 						///
					i.ckd	 					///
					i.hypertension			 	///
					i.heart_failure				///
					i.other_heart_disease		///
					i.diabcat 					///
					i.cancer_ever 				///
					i.statin 					///
					i.flu_vaccine 				///
					i.pneumococcal_vaccine		///
					i.exacerbations 			///
					i.asthma_ever				///
					i.immunodef_any
					
global tableoutcome "COVID-19 Death in ONS"
global ymax 0.005

/*  Pre-analysis data manipulation  */

do "00_cr_create_analysis_dataset.do"

* COPD specific data manipulation   
do "01_cr_create_copd_population.do"
do "02_cr_create_copd_exposure.do"
do "02b_cr_derive_ps.do"

* COPD specific analyses 
do "05b_an_ps_descriptive_plots_copd"
do "06b_an_ps_models_copd.do"

/* 	MAKE FOREST PLOTS=========================================================*/

capture mkdir graph_out
capture mkdir graph_log

global outdir  "graph_out" 
global logdir  "graph_log"

do "gr_forestplot_copd"
do "gr_forestplot_asthma"

/* 	QBA=======================================================================*/
* Quantiative Bias - evalues outputted in plots

capture mkdir qba_out
capture mkdir qba_log

global outdir  "qba_out" 
global logdir  "qba_log"

do "gr_e-value_plot"

