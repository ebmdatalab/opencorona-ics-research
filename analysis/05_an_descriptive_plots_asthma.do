/*==============================================================================
DO FILE NAME:			05_an_descriptive_plots
PROJECT:				ICS in COVID-19 
AUTHORS:				A Schultze, A Wong, C Rentsch 
						adapted from K Baskharan, E Williamson 
DATE: 					12th of May 2020 
VERSION: 				Stata 16.1
DESCRIPTION OF FILE:	create KM plot
						save KM plot 
						
DATASETS USED:			$tempdir\analysis_dataset_STSET_$outcome.dta
DATASETS CREATED: 		None
OTHER OUTPUT: 			Results in svg: $outdir\kmplot1
						Log file: $logdir\05_an_descriptive_plots_asthma 
						
==============================================================================*/

* Open a log file
capture log close
log using $logdir\05_an_descriptive_plots_asthma, replace t

* Open Stata dataset
use $tempdir\analysis_dataset_STSET_$outcome, clear

/* Sense check outcomes=======================================================*/ 
tab exposure $outcome

/* Generate KM PLOT===========================================================*/ 

count if exposure != .u
noi display "RUNNING THE KM PLOT FOR `r(N)' PEOPLE WITH NON-MISSING EXPOSURE"

sts graph, by(exposure) failure 							    			///	
		   title("Time to $tableoutcome, $population population", justification(left) size(medsmall) )  	   ///
		   xtitle("Days since 1 Mar 2020", size(small))						///
		   yscale(range(0, 0.0011)) 											///
		   ylabel(0 "0.0" 0.0005 "0.05" 0.001 "0.1" 0.0015 "0.15" 0.002 "0.2", angle(0) format(%5.4f) labsize(small))	///
		   xscale(range(30, 84)) 											///
		   ytitle("Cumulative mortality (%)", size(small))   				///
		   xlabel(0 (20) 100, labsize(small))				   				///				
		   legend(size(vsmall) label(1 "SABA only") label (2 "ICS (Low/Medium Dose)") label (3 "ICS (High Dose)")region(lwidth(none)) position(12))	///
		   graphregion(fcolor(white)) ///	
		   risktable(,size(vsmall) order (1 "SABA only" 2 "ICS (Low/Medium Dose)" 3 "ICS (High Dose)") title(,size(vsmall))) ///
		   text(0.0019 13 " un. HR (lm ICS) = 1.36, 95%CI = 1.01 - 1.84", size(vsmall)) ///
		   text(0.0016 13 " un. HR (hd ICS) = 2.30, 95%CI = 1.64 - 3.23", size(vsmall)) ///
		   text(0.0013 13 " ad. HR (lm ICS) = 1.14, 95%CI = 0.84 - 1.54", size(vsmall)) ///
		   text(0.0010 13 " ad. HR (hd ICS) = 1.55, 95%CI = 1.10 - 2.18", size(vsmall)) ///
		   saving(kmplot1, replace)

graph export "$outdir/kmplot1.svg", as(svg) replace

* Close window 
graph close

* Delete unneeded graphs
erase kmplot1.gph

* Close log file 
log close
















