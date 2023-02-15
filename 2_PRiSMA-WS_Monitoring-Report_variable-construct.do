//This Do file constructs the data for the monitoring report tables.

clear

//Table 1

//Total number screened in the most recent 1 week

use "$dr/MNH00.dta",clear

desc, sh //checking the observations and variables in the data

//What is the unique identifying variable in the data: momid
isid momid


//Sorting by screening date
sort scrn_obsstdat

gen count = 1 


gen week = scrn_obsstdat >= "2023-01-25"
la var week "Filter for last week"


encode  scrn_obsstdat, gen(date)

/*
gen complete_week = 0
replace complete_week = 1 if scrn_obsstdat>="2023-1-23" & scrn_obsstdat<="2023-01-29"
la var complete_week "Filter for last complete week"
*/


/*Information that we need for table 1a:

Pre-screened
	Total Screened
	Total Eligible
	
	
Reasons for exclusion
	No sign of pregnancy
	Viable pregnancy >= 25 weeks
	Did not meet age requirement
	Outside catchment area
	Other Reason
	Did not consent
	
*/

//First going to create the variables needed to generate Table 1a.

*Total screened is just the sample size in the data

*Eligibility is dependent upon all the reasons for the exclusion.

gen not_preg = pregnant_ieorres == 0 if pregnant_ieorres!=.
la var not_preg "No clinical sign of pregnancy"

gen over25wk = ega_lt25_ieorres == 0 if ega_lt25_ieorres!=.
la var over25wk "Viable pregnancy >25 weeks"

gen not_age = age_ieorres == 0 if age_ieorres!=.
la var not_age "Did not meet age requirement"

gen outside = catchment_ieorres==0 if catchment_ieorres!=.
la var outside "Outside of catchment area"

gen other = othr_ieorres ==1 if othr_ieorres!=.
la var other "Other Reason to exclude"

gen no_consent = con_yn_dsdecod ==0 if con_yn_dsdecod!=.
la var no_consent "Did not consent"

gen eligible = not_preg==0&over25wk==0&not_age==0&outside==0&other==0& ///
			   no_consent==0
la var eligible "Eligible"

*Double Checking the calculation for eligibility:
gen elig = pregnant_ieorres==1 & ega_lt25_ieorres==1 & age_ieorres==1 & ///
		   catchment_ieorres==1 & othr_ieorres==0 & con_yn_dsdecod==1
		   
		   
*Also want to create a version of the eligibility variables that are only 
*defined for those who are not eligible - to get percents

/*
	gen not_preg_i= not_preg if eligible==0
	replace not_preg_i = 0 if not_preg==.&eligible==0
	*/


foreach var in not_preg over25wk not_age outside other no_consent {
	
	gen `var'_i= `var' if eligible==0
	replace `var'_i = 0 if `var'==. & eligible==0
	
	local l`var': variable label `var'
	la var `var'_i "`l`var''"
	
}

keeporder site scrnid momid pregid scrn_obsstdat scrn_obsloc week count eligible ///
		  not_preg over25wk not_age outside other no_consent not_preg_i ///
		  over25wk_i not_age_i outside_i other_i no_consent_i

save "$da/PRiSMA_Monitoring-Report_screen-data-construct.dta", replace
exit

//Figure 1 , Table 2
//Enrollment

use "$dr/MNH02.dta", clear

gen enrolled = consent_ieorres==1

keeporder site scrnid momid pregid scrn_obsstdat scrn_obsloc enrolled

save "$da/PRiSMA_Monitoring-Report_enroll-data-construct.dta", replace
