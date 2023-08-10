//Purpose: This do file executes the code for the PRISMA Data Series 
//II Workshop 1 lab

clear
clear all
cap log close

gl date 230711

log using "$dl/PRISMA-DSII_Workshop-1_$date.log", replace

*******************
*******************
*MNH01_WS1 Data****
*******************
//Open the data set.
use "$dr/MNH01_WS1.dta", clear 

//How many observations and variables are in the dataset?

desc, sh

//What is the unit of observation in the dataset? Which variable(s)
// defines unique observations.

*momid and pregnancyid

gen count = 1
egen check = sum(count), by(momid pregnancyid)
tab check


drop check

//Let's say that I thought that m01_scrn_obsstdat uniquely identified the dataset

egen check = sum(count),by(m01_scrn_obsstdat)
tab check

//there is a stata command that will tell you if you are correct or not
//about the unique identifier

isid momid pregnancyid

*isid m01_scrn_obsstdat

*******************
*******************
*MNH13_sample Data*
*******************

use "$dr/MNH13_sample.dta", clear

*How many observations and variables are in the data set?
describe, short // shorthand: desc, sh

*How can we check for the unique identifier(s)?

//isid - will throw an error if the variable does not uniquely identify
//codebook, c - will tell you if there are any veraibles with the same # of 
	//unique values as there are observations
	
codebook, c 

// egen tag function should be =1 for all values if the variable uniquely identifies

egen uni = tag(MOMID)
tab uni //if all values =1 then MOMID uniquely identfies
drop uni

//use the count + sum algorithm.

gen count = 1

egen check = sum(count), by(MOMID)
tab check // if all values = 1 then MOMID uniquely identifies 
drop count check //do not need these after we check

//No single variable uniquely identifies the data, but if you combine MOMID with
//M13_visit_num, this uniquely identifies the data.

egen uni = tag(MOMID M13_visit_num)
tab uni //if all values =1 then MOMID and M13_visit_num uniquely identifies the dataset

//It does, so this means that the unit of observation in the data is the "Mother-PNC visit" 

*******************
*******************
*MNH02_ws1 Data*
*******************

*checking for unique IDs

use "$dr/MNH02_WS1.dta", clear
//This data set *should* be uniquely identified by momid, but it is not. Now what?


*First, identify the IDs that are duplicated.
//use the count + sum algorithm.
gen count = 1
egen check = sum(count),by(momid)
tab check

sort momid //make sure data is sorted according to unique identifier
browse if check >1

preserve 

keep if check > 1
	//If you only want a subset of the variables in the output to excel
	*keep momid //marital_status marraige age

export excel using "$output/PRISMA_DSII_MN02-duplicates.xlsx", firstrow(variables) replace sheet("Duplicate IDs")


restore 

	//what if we used the egen tag command
	egen uni = tag(momid)
	tab uni
	//This will also let you identify the IDs that are replicated, but provides
	//less information at once.

*Once you've identified which variables are replicated, now what?
*First question: Are the duplicated IDs identical entries?
	*If the entries are identical, drop one.
	*If they are different, no we need to identify which is "correct" and which
	*observation is mislabeled with the id
		*Update the incorrect id to what it should be and requirs manual cleaning. This requires liaising with with the data collection team.

//MOMID 21 is married. The other 21 is mislabeled, so I need to correct the id
replace momid = 1000 if momid==21 & m02_marital_scorres==2

//MOMID 37 was 23 when she got married, the other 37 is mislabeled
replace momid = 1001 if momid==37 & m02_marital_age==18

//MOMID 47 was 21 when she got married, the 47 who was 18 is someone else, and
//the correct entry was duplicated

replace momid = 1002 if momid==47 & m02_marital_age==18

	//Now I need a way to choose one of the correct 47s to drop
	
	bysort momid: gen dupno = sum(count) //dupno = duplicate number
	drop if momid==47 & dupno==2




log close

cap log close
