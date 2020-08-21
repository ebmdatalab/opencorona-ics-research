/*==============================================================================
DO FILE NAME:			05_an_descriptive_plots_copd
PROJECT:				ICS in COVID-19 
AUTHORS:				A Schultze, A Wong, C Rentsch 
						adapted from K Baskharan, E Williamson 
DATE: 					12th of May 2020
VERSION: 				Stata 16.1 
DESCRIPTION OF FILE:	create KM plot
						save KM plot 
						
DATASETS USED:			$tempdir\analysis_dataset_STSET_cpnsdeath.dta
DATASETS CREATED: 		None
OTHER OUTPUT: 			Results in svg: $outdir\kmplot1
						Log file: $logdir\05_an_descriptive_plots_copd 
						
==============================================================================*/

* Open a log file
capture log close
log using $logdir\05_an_descriptive_plots_copd, replace t

* Open Stata dataset
use $tempdir\analysis_dataset_STSET_$outcome, clear

/* Sense check outcomes=======================================================*/ 
tab exposure $outcome

/* Generate KM PLOT===========================================================*/ 
*  Note, at editorial request, manually added in HRs into this plot 
*  These are calculated in 06 

count if exposure != .u
noi display "RUNNING THE KM PLOT FOR `r(N)' PEOPLE WITH NON-MISSING EXPOSURE"

sts graph, by(exposure) failure 							    			///	
		   title("Time to $tableoutcome, $population population", justification(left) size(medsmall) )  	   ///
		   xtitle("Days since 1 Mar 2020", size(small))						///
		   yscale(range(0, $ymax)) 											///
		   ylabel(0 0.001 "0.1" 0.002 "0.2" 0.003 "0.3" 0.004 "0.4" 0.005 "0.5", angle(0) labsize(small))	///
		   ytitle("Cumulative mortality (%)", size(small)) ///
		   xscale(range(30, 84)) 											///
		   xlabel(0 (20) 100, labsize(small))				   				///				
		   legend(size(vsmall) label(1 "LABA/LAMA Combination") label (2 "ICS Combination") region(lwidth(none)) position(12))	///
		   graphregion(fcolor(white)) ///	
		   risktable(,size(vsmall) order (1 "LABA/LAMA Combination" 2 "ICS Combination") title(,size(vsmall))) ///
		   text(0.004 13  " un. HR = 1.53, 95%CI = 1.22 - 1.93", size(vsmall)) ///
		   text(0.0032 13 " ad. HR = 1.39, 95%CI = 1.10 - 1.76", size(vsmall)) ///
		   saving(kmplot1, replace) 

graph export "$outdir/kmplot1.svg", as(svg) replace

* Close window 
graph close

* Delete unneeded graphs
erase kmplot1.gph

* Close log file 
log close














