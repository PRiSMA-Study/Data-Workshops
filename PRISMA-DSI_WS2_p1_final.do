
//PRiSMA Data Workshops
//Workshop 2: Tools for Data Quality Assessment
//First verion: 18 Sept 2022; This version 20 Sept 2022
//Author: Jennifer Seager; jseager@gwu.edu

//This do file prepares data for the workshop

clear
clear all 
cap log close

global date = "220920"


log using "$dl/PRiSMA_Workshop2_$date.log", replace


//Q3

use "$dr/MNH01_sample.dta", clear

gen count=1

egen check = sum(count), by(MOMID)

tab check


//use a for loop to merge in MNH02 and MNH03

foreach x in 02 11 03a 03b {
    
	merge 1:1 MOMID using "$dr/MNH`x'_sample.dta", gen(m`x')
	
}

use "$dr/MNH01_sample.dta", clear //master data
merge 1:1 MOMID using "$dr/MNH02_sample.dta", gen(m02)
merge 1:1 MOMID using "$dr/MNH11_sample.dta", gen(m11)
merge 1:1 MOMID using "$dr/MNH03a_sample.dta", gen(m03a)
merge 1:1 MOMID using "$dr/MNH03b_sample.dta", gen(m03b)


//Q4 Tracking

use "$da/MNH01_WS2.dta", clear

/*Side note on renaming upper case variables
. rename M01_* *

. rename * M01_*

. rename * , lower


*/

//Create indicators for reasons of exclusion from the study

gen reason_age = m01_age_ieorres==0 //age excluson
gen reason_nopreg = m01_pc_ieorres==0 if m01_pc_ieorres!=.  
	//unconfirmed pregnancy excluson

gen reason_othr = m01_excl_yn_ieorres==1 if m01_excl_yn_ieorres!=. 
	//some other reason exclusion
gen reason_consent = m01_con_yn_dsdecod==0 if m01_con_yn_dsdecod!=. 
	// did not consent to survey
gen reason_loc = m01_reside_catch_yn_scorres==0 if m01_reside_catch_yn_scorres!=. 
	//does not live in stuy area

gen reason_noloc = m01_enr_mother_village_scorres=="-7" 
	//do not have village information


//Create a final indicator that the individual is in the final sample

gen insample = 0
replace insample = 1 if reason_age!=1 & reason_nopreg!=1 & reason_othr!=1 & ///
					   reason_consent!=1 & reason_loc!=1 & reason_noloc!=1
					   
la var insample "Female in the study sample"

gen count = 1

//Now we want to summarize by survey location / sub characteristic of the sample

preserve

collapse (sum) total_approached=count total_included=insample reason_age reason_nopreg reason_othr reason_consent reason_loc reason_noloc, by(region)

local age "under 15 years"
local nopreg "woman not pregnant"
local othr "excluded for other reason"
local consent "did not consent"
local loc "lived outside catchment area"
local noloc "no location information"

la var total_included "Females in sample"
la var total_approached "Total Approached"

foreach var in age nopreg othr consent loc noloc {

la var reason_`var' "Excluded because ``var''"	

}

export excel using "$output/PRiSMA_Workshop2_Tracking-Sheet_$date.xlsx", replace firstrow(varlabels) sheet("By Region")

restore 

preserve 

collapse (sum) total_approached=count total_included=insample reason_age reason_nopreg reason_othr reason_consent reason_loc reason_noloc, by(m01_enr_mother_village_scorres)

local age "under 15 years"
local nopreg "woman not pregnant"
local othr "excluded for other reason"
local consent "did not consent"
local loc "lived outside catchment area"
local noloc "no location information"

la var total_included "Females in sample"
la var total_approached "Total Approached"

foreach var in age nopreg othr consent loc noloc {

la var reason_`var' "Excluded because ``var''"	

}
export excel using "$output/PRiSMA_Workshop2_Tracking-Sheet_$date.xlsx", firstrow(varlabels) sheet("By Village", replace)

restore 


//Q5 Duplicate IDs

use "$da/MNH02_WS2.dta", clear

gen count =1
egen check = sum(count),by(momid)
tab check

sort momid
browse if check > 1

list momid if check>1

preserve 

keep if check>1

export excel using "$output/PRiSMA_Workshop2_Tracking-Sheet_$date.xlsx", firstrow(varlabels) sheet("Duplicates MNH02", replace)

