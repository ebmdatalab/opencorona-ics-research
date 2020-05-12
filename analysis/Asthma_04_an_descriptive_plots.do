/*=========================================================================
DO FILE NAME:			04_an_descriptive_plots

PROJECT:				Effect of ICS on Covid-19 outcomes

AUTHOR:					Christopher Rentsch, Anna Schultze, Angel Wong
		
												
VERSION:				v1

DATE VERSION CREATED: 	2020-05-06
	
DESCRIPTION OF FILE:	Aim: create kaplan meier plots

DATASETS USED:			cr_create_analysis_dataset

DATASETS CREATED: 		none

OTHER OUTPUT:			Kaplan-Meier plots (intended for publication)
*							output/km_age_sex_cpnsdeath.svg 	
*							
*					To be added later: 
*							output/km_age_sex_onscoviddeath.svg 
*							output/km_age_sex_ituadmission.svg	 
*					Line plots of cumulative deaths
*							output/events_onscoviddeath.svg
*							output/events_cpnsdeath.svg
*							output/events_ituadmission.svg
							
********************************************************************************
*
*	Purpose:		This do-file creates Kaplan-Meier plots by age and sex. 
*  
********************************************************************************
*	
*	Stata routines needed:	grc1leg	
*
*********************************************************************************/



use "cr_create_analysis_dataset_STSET_cpnsdeath.dta", clear


****************************
*  KM plot by exposure  *
****************************

* KM plot of CPNS death by exposure		
sts graph , title("Hospital COVID-19 death by ICS exposure") 	///
			failure by(exposed) 								///
			xtitle("Days since 1 Feb 2020")						///
			yscale(range(0, 0.005)) 							///
			ylabel(0 (0.001) 0.005, angle(0) format(%4.3f))		///
			xscale(range(30, 84)) 								///
			xlabel(30 (10) 80)									///
			legend(order(1 0)									///
			subtitle("Exposure", size(small)) 					///
			label(1 "Comparator") 								///
			label(2 "ICS") 										///
			col(3) colfirst size(small))	noorigin			///
			plot1opts(lcolor(red)) 								///
			plot2opts(lcolor(blue)) 							///
			saving(cpns_overall, replace)
	
* KM plot for males and females 
grc1leg cpns_overall.gph , 						///
	t1(" ") l1title("Cumulative probability", size(medsmall))
graph export "output/km_cpnsdeath_overall.svg", as(svg) replace

* Delete unneeded graphs
erase cpns_overall.gph
















