import delimited `c(pwd)'/analysis/input.csv, clear


set more off 


cd  `c(pwd)'/analysis


/*  Pre-analysis data manipulation  */

**********************************************
*IF PARALLEL WORKING - THIS MUST BE RUN FIRST*
**********************************************
do "01_cr_create_analysis_dataset.do"






/*  Run analyses  */

*********************************************************************
*IF PARALLEL WORKING - FOLLOWING CAN BE RUN IN ANY ORDER/IN PARALLEL*
*       PROVIDING THE ABOVE CR_ FILE HAS BEEN RUN FIRST				*
*********************************************************************
**do "an_tablecontent_PublicationDescriptivesTable.do"

do "02_an_checks.do"
do "03_an_descriptive_tables.do"
do "04_an_descriptive_plots.do"




***CTR NOTE: I have checked and confirmed 01, 02, and 04. I havent done anything to 03 apart from updating filepaths and dataset names to be read in 