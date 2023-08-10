//Question 1, part a
//PRiSMA Data Workshops, Lab 2 
//Purpose: Do file executes the commands to complete the lab 2 assignment
//First created/version: October 25, 2022; Jennifer Seager (jseager@gwu.edu)
//Version 2.0: October 25, 2022; Clara Parsons (clara's email)
//Version 3.0: DATE ; Statie Loisate


//Question 2, part b:
clear 
clear all
clear matrix 
clear mata
cap log close
	//cap is shorthand for capture and is a command that "captures" any error response from STATA" 

//STATA 14 or earlier:
set more off

log using "$dl/Seager_PRiSMA-Data-Workshop_Lab-2.log", replace 


//Question 3
//3.	Use a for loop to merge together MNH01_sample.dta, MNH02_sample.dta, 
//		and MNH11_sample.dta.

use "$dr/MNH01_sample.dta",clear

foreach x in 02 11 {
	
	merge 1:1 MOMID using "$dr/MNH`x'_sample.dta", gen(m01`x')
	
}

/*The above forloop is equivalent to:
use "$dr/MNH01_sample.dta",clear
merge 1:1 MOMID using "$dr/MNH02_sample.dta", gen(m0102)
merge 1:1 MOMID using "$dr/MNH11_sample.dta", gen(m0111)
*/

/* since I am concerned that there are some observations in the demographic data 
file that are not screened into the study.

preserve 
keep if m0102==2

export excel "$output/PRiSMA_Workshop-3-p1_$date.xlsx", sheet("1.unmerged",replace) cell(A1) firstrow(variables)

restore
*/

//Question 4
//4. Open MNH01_WS2.dta. 

use "$da/MNH01_WS2.dta", clear

//4b. i.	Generate a series of indicators for each possible reason for 
//			excluding the mother from the sample.
//			Label these variables

//Generate indicators for inclusion in the study, where 1 means she meets the 
//criteria and 0 means she does not.

//Must be older than 15.

gen older_15 = 0 if m01_age_ieorres == 0 
replace older_15 = 1 if m01_age_ieorres == 1
label var older_15 "=1 if mother older than 15 years old"

//Must be pregnant -- indicator that pregnancy is confirmed.

gen pregnancy_confirmed = 0 if m01_pc_ieorres ==0
replace pregnancy_confirmed = 1 if m01_pc_ieorres==1
la var pregnancy_confirmed "=1 if confirmed pregnancy"

//Mother resides in the catchment area

gen reside_yn =  m01_reside_catch_yn_scorres==1 if m01_reside_catch_yn_scorres!=.
la variable reside_yn "=1 if reside in catchment area"

//Mother has identified village 

gen village_identified = 0 if m01_enr_mother_village_scorres!=""
replace village_identified = 1 if m01_enr_mother_village_scorres!="-7" ///
								  & m01_enr_mother_village_scorres!=""
								  
la variable village_identified "=1 if identified village of residence"


//Mother consented to participate in the study

gen consent = 0 if  m01_con_yn_dsdecod==0
replace consent = 1 if  m01_con_yn_dsdecod==1
la var consent "=1 if consented to survey"

//No other reason to exclude

gen no_other_rsn= 0 if m01_excl_yn_ieorres ==1
replace no_other_rsn = 1 if  m01_excl_yn_ieorres ==0

la var no_other_rsn "=1 if no other reason to exclude"

//Eligible for study indicator:

gen eligible = 0
replace eligible = 1 if older_15==1 & pregnancy_confirmed==1 & reside_yn==1 ///
						& village_identified==1 & consent==1 & no_other_rsn == 1
						
						
//ii.	Generate an indicator that the mother is in the sample
						
la variable eligible "=1 if eligible for the study"

sum older_15 pregnancy_confirmed reside_yn village_identified consent ///
	no_other_rsn eligible
	

/*iii. iii.	Use the collapse command to create a summary table, by region of:
1.	Total number of approached 
2.	Total number kept in sample
3.	Reasons for exclusion
a.	Export to Excel and keep the variable labels in the top row of the excel book.
	
*/


gen count = 1 // a variable equal to 1 for all observations.

//create indicators for exclusion

local older_15 young 
local pregnancy_confirmed not_pregnant
local reside_yn outside_area
local village_identified no_village
local consent no_consent
local no_other_rsn other_reason

foreach var in older_15 pregnancy_confirmed reside_yn village_identified ///
			   consent no_other_rsn {

			   gen ``var'' = `var'==0 if `var'!=.
				
				
			   }
			   
// gen young = older_15==0 if older_15!=.
// gen not_pregnant = pregnancy_confirmed==0 if pregnancy_confirmed!=. 
// ....

preserve 

collapse (sum) total_approached=count total_included=eligible ///
			   young not_pregnant outside_area no_village no_consent other_reason ///
		 (mean) pct_young=young pct_nopreg=not_pregnant pct_outside=outside_area ///
				pct_no_village=no_village pct_no_consent=no_consent ///
				pct_other=other_reason, ///
		 by(region)
		 

export excel "$output/PRiSMA_Workshop-3-p1_$date.xlsx", sheet("2.eligible-by-region",modify) cell(A1) firstrow(variables)

restore 

//iv.	Repeat iii at the village level and create a second sheet in the same excel

preserve

collapse (sum) total_approached=count total_included=eligible ///
			   young not_pregnant outside_area no_village no_consent other_reason ///
		 (mean) pct_young=young pct_nopreg=not_pregnant pct_outside=outside_area ///
				pct_no_village=no_village pct_no_consent=no_consent ///
				pct_other=other_reason, ///
		 by(village)
		 

export excel "$output/PRiSMA_Workshop-3-p1_$date.xlsx", sheet("2.eligible-by-village",modify) cell(A1) firstrow(variables)


restore 

log close










