**************************
/* Set output directory */
**************************

glob OUTPUT_DIR = ""

****************************
/* Input effect estimates */
****************************

* COPD
glob hr_copd = 1.38
glob lci_copd = 1.08
glob uci_copd = 1.75

* Asthma low-dose ICS
glob hr_asthma_ld = 1.10
glob lci_asthma_ld = 0.82
glob uci_asthma_ld = 1.49

* Asthma high-dose ICS
glob hr_asthma_hd = 1.52
glob lci_asthma_hd = 1.08
glob uci_asthma_hd = 2.14

**************************
/* Create e-value plots */
**************************

* COPD 
evalue hr $hr_copd, lcl($lci_copd) ucl($uci_copd) true(0.8) figure(scheme("s1color") aspect(1.01) ytitle(,size(small) margin(medium)) xtitle(,size(small) margin(medium)))
* addplot: 
graph save "${OUTPUT_DIR}evalue_COPD_protective.gph", replace
graph export "${OUTPUT_DIR}evalue_COPD_protective.jpg", replace quality(100) width(1000)

* Ashtma low-dose ICS
evalue hr $hr_asthma_ld, lcl($lci_asthma_ld) ucl($uci_asthma_ld) true(0.8) figure(scheme("s1color") aspect(1.01) ytitle(,size(small) margin(medium)) xtitle(,size(small) margin(medium))) 
graph save "${OUTPUT_DIR}evalue_Asthma_LD_protective.gph", replace
graph export "${OUTPUT_DIR}evalue_Asthma_LD_protective.jpg", replace quality(100) width(1000)

* Asthma high-dose ICS
evalue hr $hr_asthma_hd, lcl($lci_asthma_hd) ucl($uci_asthma_hd) true(0.8) figure(scheme("s1color") aspect(1.01) ytitle(,size(small) margin(medium)) xtitle(,size(small) margin(medium)))
graph save "${OUTPUT_DIR}evalue_Asthma_HD_protective.gph", replace 
graph export "${OUTPUT_DIR}evalue_Asthma_HD_protective.jpg", replace quality(100) width(1000)