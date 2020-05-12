/*==============================================================================
DO FILE NAME:			04_an_descriptive_plots
PROJECT:				ICS in COVID-19 
AUTHORS:				A Schultze, A Wong, C Rentsch 
						adapted from K Baskharan, E Williamson 
DATE: 					12th of May 2020 
DESCRIPTION OF FILE:	create KM plot
						save KM plot 
						
DATASETS USED:			copd_tempdata\analysis_dataset_STSET_cpnsdeath.dta
DATASETS CREATED: 		None
OTHER OUTPUT: 			Results in svg: copd_output\kmplot1
						Log file: copd_log\04_an_descriptive_plots 
						
==============================================================================*/

* Open a log file
capture log close
log using copd_log\04_an_descriptive_plots, replace t

* Open Stata dataset
use copd_tempdata\analysis_dataset_STSET_cpnsdeath, clear

/* Generate KM PLOT===========================================================*/ 

sts graph, by(exposure) 									    			///										
		   title("Time to Hospital COVID-19 death, by COPD combination treatment", size(medsmall))  	   ///
     	   failure 															///
		   xtitle("Days since 1 Mar 2020", size(small))						///
		   yscale(range(0, 0.005)) 											///
		   ylabel(0 (0.001) 0.005, angle(0) format(%4.3f) labsize(small))	///
		   xscale(range(30, 84)) 											///
		   xlabel(0 (20) 100, labsize(small))				   				///				
		   legend(size(small) label(1 "LABA/LAMA Combination") label(2 "ICS Combination") region(lwidth(none)) order(2 1))	///
		   graphregion(fcolor(white))										///
		   saving(km_cpns_bytreat)

graph export "copd_output/km_cpns_bytreat.svg", as(svg) replace

* Close window 
graph close

* Delete unneeded graphs
erase km_cpns_bytreat.gph

* Close log file 
log close














