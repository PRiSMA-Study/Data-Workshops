//Workshop 2 Lab 2
//Purpose: This file contains the code for lab 2
//This version: 8 August, 2023; Jennifer Seager (jseager@gwu.edu)

clear
cap log close

gl date "230810"

log using "$dl/PRISMA-DSII_WS2_lab_$date.log", replace
//Q3

//Open my data set

use "$dr/MNH13_sample.dta", clear

//Q3a

//i. How many observations are in the dataset? 648
//ii. How many variables are in the dataset? 24

desc, sh // describe, short

//iii. What is the unit of observation in the dataset?
//iv. What variable(s) uniquely identifies a unit of observation in the data set?

	//does momid uniquely identify each observation in the data?
	gen count = 1 // gen is shorthand for generate
	egen check = sum(count),by(MOMID)
	tab check
	drop check
	
	egen check = sum(count),by(MOMID PREGNANCYID)
	tab check
	drop check
	
	egen check = sum(count), by(MOMID M13_visit_num)
	tab check
	
	//The unit of observation in the dataset is the office vist for a specific mother
	//THis important to know when interpreting the statistics that come out of the data.
	
	//Summarize the  M13_POC_HB_VSSTAT (if hemoglobin was measured)
	
	sum  M13_POC_HB_VSSTAT if  M13_POC_HB_VSSTAT<99
		//interpretation here is that hemoglobin is measured at 14.35% of visits 
		
	//If I wanted to know what % of mothers have their hemoglobin measured, 
	//I need to do *something* to convert the unit of observation to the mother 
	//(rather than the visit)
	
	//1. create a variable that contains mother-level data in the same dataset
	
	egen hb_measured = max(M13_POC_HB_VSSTAT), by(MOMID)
		//this creates an indicator for the mother that hemoglobin was measured 
		//at some point. There is still the issue that the mother appears
		//multiple times in the data
		
	egen mom_tag = tag(MOMID)
		//creates an indicator so that I can filter the data to a single 
		//observation for each mother 
		
	sum hb_measured if mom_tag==1
	tab hb_measured if mom_tag==1
	
	//2. Use the "collapse command" in stata to collapse the data to the mother 
	//level
	
	preserve
	
	collapse (max) hb_max=M13_POC_HB_VSSTAT (mean) hb_mean=M13_POC_HB_VSSTAT, ///
		by(MOMID)
		//Gives me a mom-level data set that tells me if the mother ever had 
		//her HB measured.
	
	sum hb_max
	tab hb_max
	
		//Downside of this method is that now I have a summarized data set and 
		//have "lost" the other data and need to reopen it again to get back.
		//Solution: Use preserve < > restore
		
	restore
	
	//also could have done the following, combining method 1 with the 
	//collapse command
		
	preserve
	
	collapse (mean) hb_measured  if mom_tag==1
	
	restore
	
	//3. Use the reshape command to reshape the data to be at the mother level
	
	//In this case I care about whether HB was measured, so keeping that variable
	//plus the two identifier variables
	
	preserve 
	keep MOMID M13_visit_num M13_POC_HB_VSSTAT
	
	//reshape my data to be at the mother level
	reshape wide  M13_POC_HB_VSSTAT, i(MOMID) j(M13_visit_num)
	
	//generate a summary measure of whether hemoglobin was ever measured
	//the below three viarables are identical, but using different ways to 
	//specify the variable list
	#delimit;
	egen hb_measured1 = rowmax(M13_POC_HB_VSSTAT1 M13_POC_HB_VSSTAT2 
	M13_POC_HB_VSSTAT3 M13_POC_HB_VSSTAT4 M13_POC_HB_VSSTAT5 
	M13_POC_HB_VSSTAT6 M13_POC_HB_VSSTAT7 M13_POC_HB_VSSTAT8 
	M13_POC_HB_VSSTAT9 M13_POC_HB_VSSTAT10	M13_POC_HB_VSSTAT11
	M13_POC_HB_VSSTAT12 M13_POC_HB_VSSTAT13 M13_POC_HB_VSSTAT14 
	M13_POC_HB_VSSTAT15 M13_POC_HB_VSSTAT16);
	#delimit cr
	
	egen hb_measured2 = rowmax(M13_POC_HB_VSSTAT1-M13_POC_HB_VSSTAT16)
	
	egen hb_measured3 = rowmax(M13_POC_HB_VSSTAT*)
	
	sum hb_measured*


restore

//what if i wanted to reshape the full dataset with all variables
preserve
reshape wide M13_VISIT_OBSSTDAT M13_PNC_N_VISIT M13_PATIENT_DSDECOD ///
			 M13_POC_HB_VSSTAT M13_POC_HB_VSORRES M13_MALARIA_MHOCCUR ///
			 M13_HIV_MHOCCUR M13_PULM_EDEMA_MHOCCUR M13_PULM_EDEMA_MHSTDAT ///
			 M13_STROKE_MHOCCUR M13_STROKE_MHSTDAT M13_CARE_OHOYN ///
			 M13_HOSP_LAST_VISIT_OHOOCCUR M13_MATERNAL_DSDECOD ///
			 M13_MAT_DEATH_DTHDAT M13_MAT_DDORRES M13_BIRTH_COMP_DDORRES ///
			 M13_INFECTION_DDORRES M13_OTHR_DDORRES M13_visit_date ///
			 M13_visit_tot count check hb_measured mom_tag, ///
			 i(MOMID) j(M13_visit_num)

restore

//Q3b. What type of information does MNH13 contain?

	//Information on care provided during the PNC visit


//Collapse command to create summary statistics that are output to an excel book
//Summary statistcs by PNC visit number for whether different diagnostics were done

//first I need to clean the data 
foreach x in M13_POC_HB_VSSTAT M13_MALARIA_MHOCCUR M13_HIV_MHOCCUR ///
			 M13_STROKE_MHOCCUR M13_CARE_OHOYN {
	
	//in this case I am going to replace 99 with missing.
	disp "****`x'****"
	disp "replace `x' = . if `x' == 99"
	replace `x' = . if `x' == 99
	
}

	/*the above is equivalent to:
	
	replace M13_POC_HB_VSSTAT = . if M13_POC_HB_VSSTAT == 99
	replace M13_MALARIA_MHOCCUR = . if M13_MALARIA_MHOCCUR==99
	replace M13_HIV_MHOCCUR = . if M13_HIV_MHOCCUR==99
	replace M13_STROKE_MHOCCUR = . if M13_STROKE_MHOCCUR==99
	replace M13_CARE_OHOYN = . if M13_CARE_OHOYN ==99
	
	*/
#delimit ;
collapse (count) hb_n =M13_POC_HB_VSSTAT mal_n=M13_MALARIA_MHOCCUR 
			     hiv_n=M13_HIV_MHOCCUR stroke_n=M13_STROKE_MHOCCUR 
				 care_n=M13_CARE_OHOYN 
		 (min) hb_min =M13_POC_HB_VSSTAT mal_min=M13_MALARIA_MHOCCUR 
			   hiv_min=M13_HIV_MHOCCUR stroke_min=M13_STROKE_MHOCCUR 
			   care_min=M13_CARE_OHOYN 
		 (max) hb_max =M13_POC_HB_VSSTAT mal_max=M13_MALARIA_MHOCCUR 
		       hiv_max=M13_HIV_MHOCCUR stroke_max=M13_STROKE_MHOCCUR 
			   care_max=M13_CARE_OHOYN 
		 (mean) hb_mean =M13_POC_HB_VSSTAT mal_mean=M13_MALARIA_MHOCCUR 
				hiv_mean=M13_HIV_MHOCCUR stroke_mean=M13_STROKE_MHOCCUR 
				care_mean=M13_CARE_OHOYN
		 ,by(M13_visit_num) ;
		 
#delimit cr

/*
collapse (count) hb_n=M13_POC_HB_VSSTAT mal_n=M13_MALARIA_MHOCCUR  hiv_n=M13_HIV_MHOCCUR stroke_n=M13_STROKE_MHOCCUR care_n=M13_CARE_OHOYN  (min) hb_min =M13_POC_HB_VSSTAT mal_min=M13_MALARIA_MHOCCUR hiv_min=M13_HIV_MHOCCUR stroke_min=M13_STROKE_MHOCCUR care_min=M13_CARE_OHOYN  (max) hb_max =M13_POC_HB_VSSTAT mal_max=M13_MALARIA_MHOCCUR hiv_max=M13_HIV_MHOCCUR stroke_max=M13_STROKE_MHOCCUR  care_max=M13_CARE_OHOYN (mean) hb_mean =M13_POC_HB_VSSTAT mal_mean=M13_MALARIA_MHOCCUR hiv_mean=M13_HIV_MHOCCUR stroke_mean=M13_STROKE_MHOCCUR care_mean=M13_CARE_OHOYN,by(M13_visit_num) 
*/

keep M13_visit_num hb_n *_mean

export excel using "$output/PRISMA-DSII_WS2_PNC-visit-summary", replace ///
	sheet("Visit Summary") firstrow(variables)
	
la var M13_visit_num "PNC Visit"
la var hb_n "Number of observations"
la var hb_mean "HB checked"
la var mal_mean "Positive for Malaria"
la var hiv_mean "Positive for HIV"
la var stroke_mean "Had a stroke"
la var care_mean "Had other care"

export excel using "$output/PRISMA-DSII_WS2_PNC-visit-summary", ///
	sheet("Visit Summary-2") firstrow(varlabels) 


//Q4

use "$dr/MNH02_WS2.dta", clear

*1. identify duplicates
	//check if momid uniquely identifies the data.
	
	gen count  = 1
	egen check = sum(count), by(momid)
	tab check
	
*	browse if check==2 | check==3
*	browse if check !=1

	sort check momid
	bysort check momid: gen serno = sum(count)
	
	//Typically for workflow, easier to export duplicates to excel, to then 
	//look into the cause and identify an observation to keep vs drop
preserve	
	
	keep if check==2 | check==3

*2. Export the duplicate observations into excel to make corrections to the observations.

	//I want to export this duplicated information so that I can look into the 
	//information and indicate the necessary corrections to the data in excel
	//with data / field teams.
	export excel using "$output/PRISMA-DSII_WS2_Data-Checks.xlsx", ///
		sheet("Duplicate IDs") firstrow(variables) replace
	
	//In excel I am incorporating data fixes.

restore	


	//Now I want to bring in the corrected information from the excel file.
*3. Incportate the data fixes into your data file.
preserve

	import excel using "$output/PRISMA-DSII_WS2_Data-Checks-updated.xlsx", ///
		sheet("Duplicate IDs") firstrow clear /*cellrange(A1:N20)*/

	keep momid serno check correct_entry correct_momid

	tempfile corrected_data 
		//this is a local macro, so to call on it again in the future you put 
		// ` ' around
	save `corrected_data'

restore

	//Now I want to "merge" the corrected information into my original MNH02 data.
	
	merge 1:1 momid serno using `corrected_data'

	
	//Now we want to use the corrected information to update our data and IDs.
	
	replace momid = correct_momid if correct_entry==0
	drop if momid == .
	
	
	drop check 
	egen check = sum(count),by(momid)
	tab check
	
	//Drop the variables that were used purely for data cleaning.
	drop coung count serno correct_entry correct_momid _merge check
	
	save "$da/MNH02_clean.dta", replace
	
//Q5: Checking on status of survey attempts

	use "$dr/MNH01_WS2.dta", clear
	
	//Variables that determine inclusion into the study:
	/*m01_age_ieorres 
	  m01_pc_ieorres 
	  m01_reside_catch_yn_scorres 
	  m01_enr_mother_village_scorres 
	  m01_con_yn_dsdecod 
	  m01_con_signyn_dsdecod 
	  m01_excl_yn_ieorres
	*/
	
	//Create a of indicators that are = 1 if the woman should be excluded from the study.
	
	//Age exclusion
	gen exclude_age = 0 if m01_age_ieorres==1
	replace exclude_age = 1 if m01_age_ieorres==0
	la var exclude_age "=1 if woman excluded because < 15"
	
		//alternate way to generate dummy variable;
		*gen exclude_age2 = (m01_age_ieorres==0) if m01_age_ieorres!=.
	
	//Pregnancy exclusion
	gen exclude_notpreg = 0 if  m01_pc_ieorres ==1
	replace exclude_notpreg = 1 if  m01_pc_ieorres ==0
	la var exclude_notpreg "=1 if woman excluded because no pregnancy confirmed"
	
	//Outside catchment area exclusion
	gen exclude_catchment = 0 if m01_reside_catch_yn_scorres==1
	replace exclude_catchment = 1 if m01_reside_catch_yn_scorres==0
	lab var exclude_catchment "=1 if woman excluded because outside catchment area"
	
	//Exclude because we don't know village of residence.
	
	gen exclude_novillage = 0 if m01_enr_mother_village_scorres!="-7"
	replace exclude_novillage = 1 if m01_enr_mother_village_scorres=="-7"
	la var exclude_novillage "=1 if no village information for the woman"
	
	//Exclude because mother did not consent
	
	gen exclude_noconsent = 0 if m01_con_yn_dsdecod==1
	replace exclude_noconsent = 1 if m01_con_yn_dsdecod==0
	la var exclude_noconsent "=1 if woman did not consent"
	
	//An overall indicator that the woman should be excluded from the study
	
	gen exclude = (exclude_notpreg==1 | ///
				   exclude_catchment==1 | ///
				   exclude_novillage==1 | ///
				   exclude_noconsent==1)
	
	la var exclude "=1 if should be excluded from the study"
	
	drop if region==.
	
	collapse (count) n=exclude (sum) exclude*, by(region)
	
	export excel using "$output/PRISMA-DSII_WS2_Data-Checks.xlsx", sheet("Exclusions") firstrow(variables)
	
	
	
	
	
	
	
	
	
	
	
	
	

log close

