/*==============================================================================
DO FILE NAME:			S1-05_an_descriptive_plots
PROJECT:				ICS in COVID-19 
AUTHORS:				A Schultze, A Wong, C Rentsch 
						adapted from K Baskharan, E Williamson 
DATE: 					22nd of May 2020 
DESCRIPTION OF FILE:	create KM plot
						save KM plot 
						
DATASETS USED:			$tempdir\analysis_dataset_STSET_cpnsdeath.dta
DATASETS CREATED: 		None
OTHER OUTPUT: 			Results in svg: $outdir\kmplot1
						Log file: $logdir\S1-05_an_descriptive_plots_copd
						
==============================================================================*/

* Open a log file
capture log close
log using $logdir\S1-05_an_descriptive_plots, replace t

* Open Stata dataset
use $tempdir\analysis_dataset_STSET_$outcome, clear

/* Sense check outcomes=======================================================*/ 
tab exposure $outcome

/* Generate KM PLOT===========================================================*/ 

count if exposure != .u
noi display "RUNNING THE KM PLOT FOR `r(N)' PEOPLE WITH NON-MISSING EXPOSURE"

sts graph, by(exposure) failure 							    			///	
		   title("Time to COVID-19 death, $population population", justification(left) size(medsmall) )  	   ///
		   xtitle("Days since 1 Mar 2020", size(small))						///
		   yscale(range(0, 0.005)) 											///
		   ylabel(0 (0.005) 0.02, angle(0) format(%4.3f) labsize(small))	///
		   xscale(range(30, 84)) 											///
		   xlabel(0 (20) 100, labsize(small))				   				///				
		   legend(size(vsmall) label(1 "LABA/LAMA Combination") label (2 "ICS Dual Combination") label (3 "ICS Triple Combination") region(lwidth(none)) position(12))	///
		   graphregion(fcolor(white)) ///	
		   risktable(,size(vsmall) order (1 "LABA/LAMA Combination" 2 "ICS Dual Combination" 3 "ICS Triple Combination") title(,size(vsmall))) ///
		   saving(kmplotS1, replace)

graph export "$outdir/kmplotS1.svg", as(svg) replace

* Close window 
graph close

* Delete unneeded graphs
erase kmplotS1.gph

* Close log file 
log close
















