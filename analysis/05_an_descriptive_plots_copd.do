/*==============================================================================
DO FILE NAME:			05_an_descriptive_plots
PROJECT:				ICS in COVID-19 
AUTHORS:				A Schultze, A Wong, C Rentsch 
						adapted from K Baskharan, E Williamson 
DATE: 					12th of May 2020 
DESCRIPTION OF FILE:	create KM plot
						save KM plot 
						
DATASETS USED:			$Tempdir\analysis_dataset_STSET_cpnsdeath.dta
DATASETS CREATED: 		None
OTHER OUTPUT: 			Results in svg: $Outdir\kmplot1
						Log file: $Logdir\04_an_descriptive_plots 
						
==============================================================================*/

* Open a log file
capture log close
log using $Logdir\05_an_descriptive_plots, replace t

* Open Stata dataset
use copd_tempdata\analysis_dataset_STSET_cpnsdeath, clear

/* Generate KM PLOT===========================================================*/ 
* STATA REVIEWER: I can't incorporate labels automatically here, as the 
* local macros don't seem to be red in the sts graph command
* would appreciate advice on how to do this.... 

count if exposure != .u
noi display "RUNNING THE KM PLOT FOR `r(N)' PEOPLE WITH NON-MISSING EXPOSURE"

sts graph, by(exposure) failure 							    			///	
		   title("Time to Hospital COVID-19 death, by treatment", justification(left) size(medsmall) )  	   ///
		   xtitle("Days since 1 Mar 2020", size(small))						///
		   yscale(range(0, 0.005)) 											///
		   ylabel(0 (0.005) 0.02, angle(0) format(%4.3f) labsize(small))	///
		   xscale(range(30, 84)) 											///
		   xlabel(0 (20) 100, labsize(small))				   				///				
		   legend(size(vsmall) label(1 "LABA/LAMA Combination") label (2 "ICS Combination") region(lwidth(none)) order(2 1) position(12))	///
		   graphregion(fcolor(white)) ///	
		   risktable(,size(vsmall) order (1 "LABA/LAMA Combination" 2 "ICS Combination") title(,size(vsmall))) 
		   saving(km_cpns_bytreat)

graph export "$Outdir/copd_km_cpns_bytreat.svg", as(svg) replace

* Close window 
graph close

* Delete unneeded graphs
erase km_cpns_bytreat.gph

* Close log file 
log close














