/*==============================================================================
DO FILE NAME:			03_an_descriptive_table
AUTHOR:					A Schultze, A Wong, C Rentsch 
						Adapted from K Baskharan, A Wong 
DATE: 					10th of May 2020 
DESCRIPTION OF FILE:	Produce a table of baseline characteristics, by exposure 
						Output to a textfile for further formatting
DATASETS USED:			!! UPDATE NAME 
DATASETS CREATED: 		None
OTHER OUTPUT: 			Results in txt: output/table1 
						Log file: output/an_checks
							
==============================================================================*/

* Open a log file
capture log close
log using output\03_an_descriptive_table, replace t

* Open Stata dataset
use tempdata\analysis_dataset, clear

/* PROGRAMS TO AUTOMATE TABULATIONS===========================================*/ 

describe

count if exposure == 0 & total_pop 

********************************************************************************
* All below code from K Baskharan 
* Generic code to output one row of table

cap prog drop generaterow
program define generaterow
syntax, variable(varname) condition(string) 
	
	cou
	local overalldenom=r(N)
	
	cou if `variable' `condition'
	local rowdenom = r(N)
	local colpct = 100*(r(N)/`overalldenom')
	file write tablecontent (`rowdenom')  (" (") %3.1f (`colpct') (")") _tab

	cou if exposure == 0 & `variable' `condition'
	local pct = 100*(r(N)/`rowdenom') 
	file write tablecontent (r(N)) (" (") %3.1f (`pct') (")") _tab

	cou if exposure == 1 & `variable' `condition'
	local pct = 100*(r(N)/`rowdenom')
	file write tablecontent (r(N)) (" (") %3.1f  (`pct') (")") _tab

	cou if exposure == 2 & `variable' `condition'
	local pct = 100*(r(N)/`rowdenom')
	file write tablecontent (r(N)) (" (") %3.1f  (`pct') (")") _tab

	cou if exposure == . & `variable' `condition'
	local pct = 100*(r(N)/`rowdenom')
	file write tablecontent (r(N)) (" (") %3.1f (`pct') (")") _n
	
end

/* Explanatory Notes 

defines a program (SAS macro/R function equivalent), generate row
the syntax row specifies two inputs for the program: 

	a VARNAME which you stick in the variable 
	a CONDITION which is a string of some condition you impose 
	
the program counts if variable and condition and returns the counts
column percentages are then automatically generated
this is then written to the text file 'tablecontent' 
the number followed by space, brackets, formatted pct, end bracket and then tab

the format %3.1f specifies length of 3, followed by 1 dp. 

*/ 


********************************************************************************
* Generic code to output one section (varible) within table (calls above)

cap prog drop tabulatevariable
prog define tabulatevariable
syntax, variable(varname) min(real) max(real) [missing]

	local lab: variable label `variable'
	file write tablecontent ("`lab'") _n 

	forvalues varlevel = `min'/`max'{ 
		generaterow, variable(`variable') condition("==`varlevel'")
	}
	
	if "`missing'"!="" generaterow, variable(`variable') condition(">=.")

end

********************************************************************************

/* Explanatory Notes 

defines program tabulate variable 
syntax is : 

	- a VARNAME which you stick in variable 
	- a numeric minimum 
	- a numeric maximum 
	- optional missing option, default value is . 

forvalues lowest to highest of the variable, manually set for each var
run the generate row program for the level of the variable 
if there is a missing specified, then run the generate row for missing vals


*/ 

/* INVOKE PROGRAMS FOR TABLE 1================================================*/ 

*Set up output file
cap file close tablecontent
file open tablecontent using ./output/03_an_output_table1.txt, write text replace

* DEMOGRAPHICS (more than one level, potentially missing) 

gen byte cons=1
tabulatevariable, variable(cons) min(1) max(1) 
file write tablecontent _n _n

tabulatevariable, variable(agegroup) min(1) max(6) 
file write tablecontent _n _n

tabulatevariable, variable(male) min(0) max(1) 
file write tablecontent _n _n

tabulatevariable, variable(bmicat) min(1) max(6) missing
file write tablecontent _n _n

tabulatevariable, variable(smoke) min(1) max(3) missing 
file write tablecontent _n _n

tabulatevariable, variable(ethnicity) min(1) max(5) missing 
file write tablecontent _n _n

tabulatevariable, variable(imd) min(1) max(5) missing
file write tablecontent _n _n

file write tablecontent _n 

** TREATMENT VARIABLES (binary)
foreach comorb of varlist 	ics_single		///
							saba_single 	///
							sama_single 	///
							laba_single	 	///
							lama_single		///
							laba_ics 		///
							laba_lama 		///
							laba_lama		///
                            ltra_single		///	
							oral_steroids 	///
							nebules 		///
						{    		
						
generaterow, variable(`comororal_steroids b') condition("==1")
generaterow, variable(`comorb') condition("==0")
file write tablecontent _n

}


** COMORBIDITIES (categorical)




** COMORBIDITIES (binary)

foreach comorb of varlist 	copd							///
							hypertension			 		///
							heart failure			 		///
							other heart disease		 		///
							diabetes 						///
							cancer_ever 					///
							chronic_kidney_disease 			///
							immuno_ever		 				///

						
						{
generaterow, variable(`comorb') condition("==1")
generaterow, variable(`comorb') condition("==0")
file write tablecontent _n

}


file close tablecontent

