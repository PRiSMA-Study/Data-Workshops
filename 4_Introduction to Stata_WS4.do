//the purpose of this do file is to demonstrate changing the delimiter

clear
cap log close

*Defining global directory paths

global dir "/Users/jenniferseager/Dropbox/PRiSMA/PRISMA Summer 2023 Stata Basics Introductory Workshop/0_Data Files"
global dir2 "/Users/jenniferseager/Dropbox/Project-PRiSMA Training Grant"

global da "$dir/data"
	*"/Users/jenniferseager/Dropbox/PRiSMA/PRISMA Summer 2023 Stata Basics Introductory Workshop/0_Data Files/data"
global dr "$dir/data raw"
	*"/Users/jenniferseager/Dropbox/PRiSMA/PRISMA Summer 2023 Stata Basics Introductory Workshop/0_Data Files/data raw"
global do "$dir/do"
global dl "$dir/logs"
global output "$dir/output"
global dt "$dir/temp"

global df "$dir/new folder"

*Starts a new log file
log using "$dl/PRISMA_Intro-to-Stata_WS4.log", replace

*In stata the default delimiter is "return"
*"Delimiter" indicates where something ends -- in this case it indicates to 
*stata where the end of the command is.

*there may be cases when you want to have more flexiblity in writing code
*on multiple lines. In this case you can change the delimiter to be the ;

*Change the delimiter

	#delimit ;
	*from here on, stata will not know you have completed a sentence / command
	until it sees a ;
	
clear;
/*
cd 
"/Users/jenniferseager/Dropbox/PRiSMA/PRISMA Summer 2023 Stata Basics Introductory Workshop/0_Data Files";
*"/Users/jenniferseager/Dropbox/PRiSMA/PRISMA Summer 2023 Stata Basics Introductory Workshop/0_Data Files/data raw";
*/;


use "$dr/MNH00.dta", clear;


*Create a value label;
	label define yesno 1 "Yes" 
					   0 "No" ;
			   
	label values pregnant_ieorres 
				 known_dobyn_scorres 
				 school_scorres 
				 catchment_ieorres 
				 yesno;			 
#delimit cr

*Now I no longer need a semicolon to tell stata I am done with a command

sum pregnant_ieorres 
					   			   
#delimit ;
	label define l_school 1 "Primary 1"
						  2 "Primary 2"
						  3 "Primary 3"
						  4 "Primary 4"
						  5 "Primary 5"
						  6 "Primary 6"
						  7 "Secondary 1"
						  8 "Secondary 2"
						  9 "Secondary 3"
						  10 "Secondary 4" ; 
	label values school_yrs_scorres l_school;
	
	
/*Example of code without changing the delimiter
#delimit cr

		label define l_school 1 "Primary 1" 2 "Primary 2" 3 "Primary 3" 4 "Primary 4" 5 "Primary 5" 6 "Primary 6" 7 "Secondary 1"  8 "Secondary 2" 9 "Secondary 3" 10 "Secondary 4"  
						 
*/	
	
/*If you want to break code into multiple lines but don't want to change the 
*delimiter, then you need to put /// at the end of each row of text until the end
*of the command

	label define l_school 1 "Primary 1" ///
						  2 "Primary 2" ///
						  3 "Primary 3" ///
						  4 "Primary 4" ///
						  5 "Primary 5" ///
						  6 "Primary 6" ///
						  7 "Secondary 1" ///
						  8 "Secondary 2" ///
						  9 "Secondary 3" ///
						  10 "Secondary 4"  
	
*/	;

#delimit cr

*global macro
global name "My name is jennifer"

global varlist pregnant_ieorres known_dobyn_scorres school_scorres ///
			  catchment_ieorres age_ieorres con_yn_dsdecod
			  
global eligible pregnant_ieorres catchment_ieorres con_yn_dsdecod
global demograph school_scorres age_ieorres

sum $varlist

/*
*local macro

local varlist pregnant_ieorres known_dobyn_scorres school_scorres catchment_ieorres

sum `varlist'
*/

foreach x in $eligible $demograph {
	
	sum `x'
}

//Let's look at MNH04.dta

use "$dr/MNH04.dta", clear
	*MNH04 data is in long format: for mothers with multiple ANC visit, she 
	*has multiple observations in the data set.
	*When you have more observations in the data set than you have individuals
	*(or units of interest, in this case the "mom"), the data is in Long Format
	*I have multiple observations per individual (unit of interest) so I call 
	*the data long.
	#delimit ;
reshape wide anc_obsstdat anc_obsloc anc_fac_spfy_obsloc anc_othr_spfy_obsloc 
			 coyn_mnh04 coval_mnh04 formcompldat_mnh04 formcomplid_mnh04, 
			 i(momid pregid) j(type_visit);
	
* I can change it back to long
#delimit;
reshape long anc_obsstdat anc_obsloc anc_fac_spfy_obsloc anc_othr_spfy_obsloc 
			 coyn_mnh04 coval_mnh04 formcompldat_mnh04 formcomplid_mnh04, 
			 i(momid pregid) j(type_visit);
	
log close 	;
	*Closes the log file
	
	
	