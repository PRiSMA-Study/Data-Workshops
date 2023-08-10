*PRiSMA Data Workshop: Introduction to STATA
*Purpose: This do file introduces basic STATA commands for exploring data
*First version: September 3, 2019; Jennifer Seager (jseager@gwu.edu)
*This version: August 16, 2022; Jennifer Seager (jseager@gwu.edu)

/**FILE SETUP**/
clear 			//clears the STATA memory of previous data that may be open
set more off 	//allows STATA to run long do files without pausing (no longer necessary after STATA 16)
cap log close 	//closes any log file that may be open due to do-file terminating early
	/*These are commands I include at the top of every do file. There are
	additional commands that I will add as we advance through the semester*/

*Note: directory structure is set in do file #0.

global date "220816"

//Table of contents
*INPUTTING THE DATA
*BUILDING DATASETS
	*Appending data
	*Merging data
*EXPLORING THE DATASET
*SPLITTING CODE ONTO MULTIPLE LINES
*CHECKING MISSING VALUES


log using "$dl/Seager_PRiSMA-WS1-p1_$date.log", replace
	/*opens the log file. Option "replace" is included so that every time you
	run this do file, it will overwrite the previous version of the log file.
	other options are "append", which will add to any previous instance ofthe 
	log file.*/
	
*****************************	
**INPUTTING DATA INTO STATA**
*****************************	

*Inputting .dta files

use "$dr/MNH01_sample.dta", clear

*********************
**BUILDING DATASETS**
*********************

**Merging together data files

	/*Need to merge on a unique identifier. In this case, that is going to be
	MOMID. I am going to check in both files that I am merging that MOMID
	uniquely identifies each observation.*/

isid MOMID //stata command to check if this is unique
	/*If participant_id is unique identifer, then stata will ignore this.
	if it isn't then you will get an error.
	
	Again, I prefer to do these things manually. Here is how I typically
	check if I have correctly identified a unique identifier*/
	
gen count = 1 // create a constant variable equal to 1 for all values.

egen check = sum(count), by(MOMID)
	/*egen is an alternate generate command that allows for special operations.
	sum(count), by(participant_id) will the count variable within the participant_id*/
	
tab check //all are 1 so I have identified the unique identifier.

drop check count

	*Now, I want to merge in the information from data file 04

use "$dr/MNH04_sample.dta",clear

*isid MOMID // throws an error but doesn't tell you WHY

gen count = 1 
egen check = sum(count), by(MOMID)

tab check

sort MOMID check
browse if check>1

drop check

egen check = sum(count),by(MOMID M04_visit_num)
tab check
drop count check

reshape wide M04_OBSSTDAT M04_ANC_N_1 M04_PATIENT_DSDECOD M04_DTHDAT ///
 M04_PRG_DSDECOD M04_PRG_DSSTDAT M04_PRG_DSSTERM M04_HTN_EVER_MHOCCUR ///
 M04_DIABETES_EVER_MHOCCUR M04_CARDIAC_EVER_MHOCCUR M04_BIRTH_RPORRES ///
 M04_PRETERM_RPORRES M04_PREECLAMPSIA_RPORRES M04_GEST_DIAB_RPORRES ///
 M04_UNPL_CESARIAN_PROCCUR M04_LOWBIRTHWT_RPORRES M04_MACROSOMIA_RPORRES ///
 M04_OLIGOHYDRAMNIOS_RPORRES M04_APH_RPORRES M04_PPH_RPORRES M04_PIH_MHOCCUR ///
 M04_PIH_MHSTDAT M04_PIH_MHTERM M04_HIV_MHOCCUR M04_SYPH_MHOCCUR ///
 M04_MALARIA_EVER_MHOCCUR M04_DX_OTHR_PG_MHOCCUR M04_FOLIC_ACID_CMOCCUR ///
 M04_IRON_CMOCCUR M04_CALCIUM_CMOCCUR M04_MICRONUTRIENT_CMOCCUR ///
 M04_ANTHELMINTHIC_CMOCCUR M04_visit_date M04_visit_tot, ///
 i(MOMID PREGNANCYID) j(M04_visit_num)
 
 gen count = 1
 egen check = sum(count), by(MOMID)
 tab check
 drop count check
 
 sum 

 tempfile m04
 
 save `m04'

use "$dr/MNH01_sample.dta", clear
	//option "clear" tells STATA to clear previous data from STATA memory
merge 1:1 MOMID PREGNANCYID using "$dr/MNH02_sample.dta", gen(m02) 
merge 1:1 MOMID PREGNANCYID using "$dr/MNH03a_sample.dta", gen(m03a)
merge 1:1 MOMID PREGNANCYID using "$dr/MNH03b_sample.dta", gen(m03b)
merge 1:1 MOMID PREGNANCYID using `m04', gen(m04)

save "$da/PRiSMA_WS1-data-construct.dta", replace

*************************
**EXPLORING THE DATASET**
*************************
desc
	/*Shows the number of observations, number of variables, lists out 
	all variables in the dataset, their type, display format, value lable
	if there is one and variable label*/
desc, sh
	/*shows only the size of the dataset and does not list the variables*/

notes: This dataset contains demographic information for the mothers in our sample	
notes 
	/*You will notice that for those variables for which the label is cutoff
	notes show the whole label text*/
notes M02_MARITAL_SCORRES: this variable contains information on the marital status ///
							of the mother 
							
notes M02_MARITAL_SCORRES M02_MARITAL_AGE
	/*Will show the notes only for particular variables*/

*pause on //turning pause on so that we can stop the do file and look at the codebook
	
codebook
	/*Will display information for all variables. Just as with the notes
	command, can list particular variables to see only a few*/
codebook, compact

*pause //when done looking at the screen, can type <end> in the command line
*pause off //turning the pause functionality off
summarize 


sum M02_MARITAL_AGE
sum M02_MARITAL_AGE, det
	/*Note tht STATA often has shorthand ways to reference key commands. You 
	can identify which shortened stems STATA recognizes by searching
	help commandName. The underlined characters tell you the minimum letter
	combo that stata will recognize*/
	
desc M02_SCHOOL_YRS_SCORRES
notes  M02_SCHOOL_YRS_SCORRES
codebook  M02_SCHOOL_YRS_SCORRES
summarize M02_SCHOOL_YRS_SCORRES
inspect  M02_SCHOOL_YRS_SCORRES


	
sort MOMID PREGNANCYID //sorting the data by MOMID, then PREGNANCY
	/*sort allows you to sort in ascending order while gsort will allow both
	directions. I could have said <gsort participant_id -endline> and the 
	endline data would be stacked on top of the baseline observation for each
	participant.*/

browse M02_MARITAL_AGE if M03A_PH_PREV_RPORRES==1
	/*this opens up the browse window and shows me the age of marriage of women
	who have ever been pregnant in the dataset. I usually use this when I have identified
	'problem' observations and I want to look at their characteristics. 
	I will provide an example next.*/
sum M02_MARITAL_AGE if M03A_PH_PREV_RPORRES==1


**************************************
**SPLITTING CODE ONTO MULTIPLE LINES**
**************************************


sum M01_SCRN_OBSSTDAT M01_AGE_IEORRES M01_PC_IEORRES M01_EXCL_YN_IEORRES
	M01_CON_YN_DSDECOD M01_CON_SIGNYN_DSDECOD M01_KNOWN_DOBYN_SCORRES 


sum M01_SCRN_OBSSTDAT M01_AGE_IEORRES M01_PC_IEORRES M01_EXCL_YN_IEORRES ///
	M01_CON_YN_DSDECOD M01_CON_SIGNYN_DSDECOD M01_KNOWN_DOBYN_SCORRES ///
	M01_BRTHDAT M01_ESTIMATED_AGE M01_KNOWN_LMP_SCORRES M01_LMP_SCDAT ///
	M01_LMP_RELIABLEYN_SCORRES M01_GEST_AGE_AVAILYN_SCORRES ///
	M01_GEST_AGE_WKS_SCORRES M01_GEST_AGE_MOS_SCORRES ///
	M01_EDD_AVAILYN_SCORRES M01_EDD_SCDAT M01_RESIDE_CATCH_YN_SCORRES ///
	M01_DELIVER_CATCH_YN_SCORRES M01_ENR_MOTHER_VILLAGE_SCORRES ///
	M02_MARITAL_SCORRES M02_MARITAL_AGE M02_SCHOOL_SCORRES ///
	M02_SCHOOL_YRS_SCORRES M02_JOB_SCORRES M02_SMOKE_OECOCCUR

* Change the Delimiter
#delimit;
sum M01_SCRN_OBSSTDAT M01_AGE_IEORRES M01_PC_IEORRES M01_EXCL_YN_IEORRES 
	M01_CON_YN_DSDECOD M01_CON_SIGNYN_DSDECOD M01_KNOWN_DOBYN_SCORRES 
	M01_BRTHDAT M01_ESTIMATED_AGE M01_KNOWN_LMP_SCORRES M01_LMP_SCDAT 
	M01_LMP_RELIABLEYN_SCORRES M01_GEST_AGE_AVAILYN_SCORRES;

#delimit cr
	
***************************	;
**CHECKING MISSING VALUES** ;
*************************** 
	
tab M02_MARITAL_AGE 
tab M02_MARITAL_AGE , m

*Why are there so many missing values for Marital age?

tab M02_MARITAL_AGE M02_MARITAL_SCORRES, m 

*Recoding missing valuesnonresponses.
	/*Best practice is to never modify the original variables but to create new
	ones and then modify. This ensures that you always have the original 
	variable to refer back to in case an error has been made. There is no undo
	button in STATA. So if you modify an original variable and make and error, 
	then you will have to close the data set and start over. (also a good
	reason to keep a do-file with all the commands you want to run)*/

*WHAT ABOUT YEARS OF SCHOOLING?
tab M02_SCHOOL_YRS_SCORRES M02_SCHOOL_SCORRES, m





log close
