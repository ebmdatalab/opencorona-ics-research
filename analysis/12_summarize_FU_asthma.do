/*==============================================================================
DO FILE NAME:			12_summarize FU
PROJECT:				ICS in COVID-19 
AUTHORS:				A Schultze
						adapted from K Baskharan A Wong
DATE: 					19th September 2020
VERSION: 				Stata 16.1 
DESCRIPTION OF FILE:	tabulate median (IQR), min max FU time 
						added due to RECORD-PE guidance
DATASETS USED:			$tempdir\analysis_dataset_STSET_$outcome.dta
DATASETS CREATED: 		None
OTHER OUTPUT: 			Results in txt format, output folder
						Log file: $logdir\12_summarize_FU_asthma 
						
==============================================================================*/

* Open a log file
capture log close
log using $logdir\12_summarize_FU_asthma, replace t

* Open Stata dataset
use $tempdir\analysis_dataset_STSET_$outcome, clear

* Output summary of FU time into a table, by treatment group 

cap prog drop summarizevariable 
prog define summarizevariable
syntax, variable(varname) 

	local lab: variable label `variable'
	file write tablecontent ("`lab'") _n 
	
	qui summarize `variable', d
	file write tablecontent ("Median (IQR)") _tab 
	file write tablecontent (round(r(p50)),0.01) (" (") (round(r(p25)),0.01) ("-") (round(r(p75)),0.01) (")") _tab
							
	qui summarize `variable' if exposure == 0, d
	file write tablecontent (round(r(p50)),0.01) (" (") (round(r(p25)),0.01) ("-") (round(r(p75)),0.01) (")") _tab

	qui summarize `variable' if exposure == 1, d
	file write tablecontent (round(r(p50)),0.01) (" (") (round(r(p25)),0.01) ("-") (round(r(p75)),0.01) (")") _tab
	
	qui summarize `variable' if exposure == 2, d
	file write tablecontent (round(r(p50)),0.01) (" (") (round(r(p25)),0.01) ("-") (round(r(p75)),0.01) (")") _tab

	qui summarize `variable' if exposure >= ., d
	file write tablecontent (round(r(p50)),0.01) (" (") (round(r(p25)),0.01) ("-") (round(r(p75)),0.01) (")") _n
	
	qui summarize `variable', d
	file write tablecontent ("Mean (SD)") _tab 
	file write tablecontent (round(r(mean)),0.01) (" (") (round(r(sd)),0.01) (")") _tab
							
	qui summarize `variable' if exposure == 0, d
	file write tablecontent (round(r(mean)),0.01) (" (") (round(r(sd)),0.01) (")") _tab

	qui summarize `variable' if exposure == 1, d
	file write tablecontent (round(r(mean)),0.01) (" (") (round(r(sd)),0.01) (")") _tab
	
	qui summarize `variable' if exposure == 2, d
	file write tablecontent (round(r(mean)),0.01) (" (") (round(r(sd)),0.01) (")") _tab

	qui summarize `variable' if exposure >= ., d
	file write tablecontent (round(r(mean)),0.01) (" (") (round(r(sd)),0.01) (")") _n
	
	
	qui summarize `variable', d
	file write tablecontent ("Min, Max") _tab 
	file write tablecontent (round(r(min)),0.01) (", ") (round(r(max)),0.01) ("") _tab
							
	qui summarize `variable' if exposure == 0, d
	file write tablecontent (round(r(min)),0.01) (", ") (round(r(max)),0.01) ("") _tab

	qui summarize `variable' if exposure == 1, d
	file write tablecontent (round(r(min)),0.01) (", ") (round(r(max)),0.01) ("") _tab
	
	qui summarize `variable' if exposure == 2, d
	file write tablecontent (round(r(min)),0.01) (", ") (round(r(max)),0.01) ("") _tab

	qui summarize `variable' if exposure >= ., d
	file write tablecontent (round(r(min)),0.01) (", ") (round(r(max)),0.01) ("") _n
	
end

*Set up output file
cap file close tablecontent
file open tablecontent using ./$outdir/tableSFU.txt, write text replace

file write tablecontent ("Table S: Follow-up Time - $population") _n

* Exposure labelled columns

local lab0: label exposure 0
local lab1: label exposure 1
local lab2: label exposure 2
local labu: label exposure .u


file write tablecontent _tab ("Total")				  			  _tab ///
							 ("`lab0'")			 			      _tab ///
							 ("`lab1'")  						  _tab ///
							 ("`lab2'")			  				  _tab ///
							 ("`labu'")			  				  _n 
							 
summarizevariable, variable(_t)

file close tablecontent

* Close log file 
log close
