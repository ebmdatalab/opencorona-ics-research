/*==============================================================================
DO FILE NAME:			S1-08_an_model_checks_copd
PROJECT:				ICS in COVID-19 
DATE: 					22nd of May 2020  
AUTHOR:					A Schultze 									
DESCRIPTION OF FILE:	program 08 
						check the PH assumption, produce graphs 
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						S1table4, printed to analysis/$outdir
						schoenplots1-x, printed to analysis?$outdir 
							
==============================================================================*/

* Open a log file

cap log close
log using $logdir\S1-08_an_model_checks_copd, replace t

* Open Stata dataset
use $tempdir\analysis_dataset_STSET_$outcome, clear

* Exposure labels 
local lab1: label exposure 1
local lab2: label exposure 2

/* Quietly run models, perform test and store results in local macro==========*/

qui stcox i.exposure 
estat phtest, detail
local univar_p1 = round(r(phtest)[2,4],0.001)
local univar_p2 = round(r(phtest)[3,4],0.001)

di `univar_p1'
di `univar_p2'
 
estat phtest, plot(1.exposure) ///
			  graphregion(fcolor(white)) ///
			  ylabel(, nogrid labsize(small)) ///
			  xlabel(, labsize(small)) ///
			  xtitle("Time", size(small)) ///
			  ytitle("Scaled Shoenfeld Residuals", size(small)) ///
			  msize(small) ///
			  mcolor(gs6) ///
			  msymbol(circle_hollow) ///
			  scheme(s1mono) ///
			  title ("Schoenfeld residuals against time, univariable `lab1'", position(11) size(medsmall)) 

graph export "$outdir/schoenplotS1a.svg", as(svg) replace

estat phtest, plot(2.exposure) ///
			  graphregion(fcolor(white)) ///
			  ylabel(, nogrid labsize(small)) ///
			  xlabel(, labsize(small)) ///
			  xtitle("Time", size(small)) ///
			  ytitle("Scaled Shoenfeld Residuals", size(small)) ///
			  msize(small) ///
			  mcolor(gs6) ///
			  msymbol(circle_hollow) ///
			  scheme(s1mono) ///
			  title ("Schoenfeld residuals against time, univariable `lab2'", position(11) size(medsmall)) 

graph export "$outdir/schoenplotS1b.svg", as(svg) replace

* Close window 
graph close  
			  
stcox i.exposure i.male age1 age2 age3 
estat phtest, detail
local multivar1_p1 = round(r(phtest)[2,4],0.001)
local multivar1_p2 = round(r(phtest)[3,4],0.001)
 
estat phtest, plot(1.exposure) ///
			  graphregion(fcolor(white)) ///
			  ylabel(, nogrid labsize(small)) ///
			  xlabel(, labsize(small)) ///
			  xtitle("Time", size(small)) ///
			  ytitle("Scaled Shoenfeld Residuals", size(small)) ///
			  msize(small) ///
			  mcolor(gs6) ///
			  msymbol(circle_hollow) ///
			  scheme(s1mono) ///
			  title ("Schoenfeld residuals against time, age and sex adjusted `lab1'", position(11) size(medsmall)) 			  

graph export "$outdir/schoenplotS2a.svg", as(svg) replace

estat phtest, plot(2.exposure) ///
			  graphregion(fcolor(white)) ///
			  ylabel(, nogrid labsize(small)) ///
			  xlabel(, labsize(small)) ///
			  xtitle("Time", size(small)) ///
			  ytitle("Scaled Shoenfeld Residuals", size(small)) ///
			  msize(small) ///
			  mcolor(gs6) ///
			  msymbol(circle_hollow) ///
			  scheme(s1mono) ///
			  title ("Schoenfeld residuals against time, age and sex adjusted `lab2'", position(11) size(medsmall)) 			  

graph export "$outdir/schoenplotS2b.svg", as(svg) replace

* Close window 
graph close
		  
stcox i.exposure i.male age1 age2 age3 	i.obese4cat					///
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
										i.exacerbations, strata(stp)	
estat phtest, detail
local multivar2_p1 = round(r(phtest)[2,4],0.001)
local multivar2_p2 = round(r(phtest)[3,4],0.001)
 
estat phtest, plot(1.exposure) ///
			  graphregion(fcolor(white)) ///
			  ylabel(, nogrid labsize(small)) ///
			  xlabel(, labsize(small)) ///
			  xtitle("Time", size(small)) ///
			  ytitle("Scaled Shoenfeld Residuals", size(small)) ///
			  msize(small) ///
			  mcolor(gs6) ///
			  msymbol(circle_hollow) ///
			  scheme(s1mono) /// 
			  title ("Schoenfeld residuals against time, fully adjusted `lab1'", position(11) size(medsmall)) 		  
			  
graph export "$outdir/schoenplotS3a.svg", as(svg) replace

estat phtest, plot(2.exposure) ///
			  graphregion(fcolor(white)) ///
			  ylabel(, nogrid labsize(small)) ///
			  xlabel(, labsize(small)) ///
			  xtitle("Time", size(small)) ///
			  ytitle("Scaled Shoenfeld Residuals", size(small)) ///
			  msize(small) ///
			  mcolor(gs6) ///
			  msymbol(circle_hollow) ///
			  scheme(s1mono) ///
			  title ("Schoenfeld residuals against time, fully adjusted `lab2'", position(11) size(medsmall)) 		  
			  
graph export "$outdir/schoenplotS3b.svg", as(svg) replace

* Close window 
graph close

* Print table of results======================================================*/	


cap file close tablecontent
file open tablecontent using ./$outdir/S1table4.txt, write text replace

* Column headings 
file write tablecontent ("S1 Table 4: Testing the PH assumption - $population Population") _n
file write tablecontent _tab ("Univariable") _tab ("Age/Sex Adjusted") _tab ///
						("Age/Sex and Comorbidity Adjusted") _tab _n
						
file write tablecontent _tab ("p-value") _tab ("p-value") _tab ("p-value") _tab _n

* Row heading and content  
file write tablecontent ("`lab1'") _tab
file write tablecontent ("`univar_p1'") _tab ("`multivar1_p1'") _tab ("`multivar2_p1'") _n

file write tablecontent ("`lab2'") _tab
file write tablecontent ("`univar_p2'") _tab ("`multivar1_p2'") _tab ("`multivar2_p2'") _n

file write tablecontent _n
file close tablecontent

* Close log file 
log close
		  
			  