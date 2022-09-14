*Q2bi.
*PRiSMA Data workshop Lab 1 do file
*Created by Jennifer Seager (August 18, 2022)

*Q2bii
clear
clear all
set more off
cap log close


*Q2biii
global date "220818"

*Q2biv
log using "$dl/Seager_PRiSMA_lab-1.log", replace


*Q3
use "$dr/MNH02_sample.dta", clear

*Q3a
describe, short 
	//stata will also understand desc

*Q3ai
*isid MOMID

gen count = 1
egen check = sum(count), by(MOMID)

egen check2 = sum(count), by(M02_MARITAL_SCORRES)

//Q4 parts a/b
tab M02_MARITAL_SCORRES
tab M02_MARITAL_AGE

*Q4ci, ii
tab M02_MARITAL_AGE M02_MARITAL_SCORRES, m

label define marital_status 1 "married" 2 "cohabiting" 3 "Divorced/Separated" ///
							4 "widowed" 5 "single-never married"
label values M02_MARITAL_SCORRES marital_status

*Q4ciii
gen ever_married = 0 if M02_MARITAL_SCORRES==2 | M02_MARITAL_SCORRES==5
replace ever_married = 1 if M02_MARITAL_SCORRES==1 | M02_MARITAL_SCORRES==3 | M02_MARITAL_SCORRES==4

*Q4civ
la var ever_married "Indic for ever married"
label define ever_married 1 "ever married" 0 "never married"
label values ever_married ever_married


*Q4d
tab M02_SCHOOL_YRS_SCORRES M02_SCHOOL_SCORRES
tab   M02_SCHOOL_SCORRES

*Q5 
use "$dr/MNH13_sample.dta", clear

*Q5a
desc, sh

gen count = 1 
egen check = sum(count), by(MOMID)
tab check

drop check count 

*Q5b
egen tag = tag(MOMID)
tab tag

gen count =1 
egen check = sum(count),by(MOMID M13_visit_num)
tab check
drop tag count check 

*Q5c, 5ci
gl varlist M13_VISIT_OBSSTDAT M13_PNC_N_VISIT M13_PATIENT_DSDECOD ///
 M13_POC_HB_VSSTAT M13_POC_HB_VSORRES M13_MALARIA_MHOCCUR ///
 M13_HIV_MHOCCUR M13_PULM_EDEMA_MHOCCUR M13_PULM_EDEMA_MHSTDAT ///
 M13_STROKE_MHOCCUR M13_STROKE_MHSTDAT M13_CARE_OHOYN ///
 M13_HOSP_LAST_VISIT_OHOOCCUR M13_MATERNAL_DSDECOD M13_MAT_DEATH_DTHDAT ///
 M13_MAT_DDORRES M13_BIRTH_COMP_DDORRES M13_INFECTION_DDORRES M13_OTHR_DDORRES ///
 M13_visit_date M13_visit_tot


foreach j of global varlist {

local l`j' : variable label `j'
*disp "l`j'"
*disp "`l`j''"
}

reshape wide $varlist , ///
 i(MOMID PREGNANCYID) j(M13_visit_num)

forvalues i=1/16 {
foreach v in $varlist {
label variable `v'`i' "`l`v''"
}
}

*Q5d

merge 1:1 MOMID using "$dr/MNH02_sample.dta", gen(m0213)



log close