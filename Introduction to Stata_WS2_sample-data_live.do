*Setting up the Directory paths and opening data files
*First Version 5 June 2023
*Author: Jennifer Seager (jseager@gwu.edu)

clear

cd "/Users/jenniferseager/Dropbox/PRiSMA/PRISMA Summer 2023 Stata Basics Introductory Workshop/0_Data Files"

/*Examples of Alternate ways to specify file paths depending on your machine
	*cd "/Users/jenniferseager/Desktop/0_Data Files"

*If I were on a pc
	*cd "C:\Users\jenniferseager\Desktop\0_Data Files"
	*cd "C:/Users/jenniferseager/Desktop/0_Data Files"

*A microsoft machine can equally understand \ and / in a file path name. 
*Macbooks can only understand / in a file path name.
*If your team is working with both a macbook and a microsoft machine, it is 
*best practice to use the / so that everyone can run the same code file.
*/

*Open a file in stata .dta format
	use "data raw/MNH00.dta", clear
/*
*Open a file in .csv format 
*Method 1:
	insheet using "data raw/dummy_mnh00.csv", clear

*Method 2:
	import delimited "data raw/dummy_mnh00.csv", clear

*Saving my csv file as .dta file for future use
	save "data/mnh00.dta", replace 

*I can also export my data as an excel file.
	export excel using "output/mnh00.xlsx", firstrow(variables) replace
*/
*Lets look at the summarize command
	summarize
	sum 
	su //Stata will understand that this is shorthand for summarize
	
*Summarize a subset of variables by listing them after the command name.
	sum school_scorres school_yrs_scorres
	
*Use the detail option
	sum school_scorres school_yrs_scorres, detail
	
*Summary only for those in our catchment area. This is equivalent to
*filtering the data to only show information for those in the data who are
*in the study area
	sum school_scorres school_yrs_scorres if catchment_ieorres == 1
	
*Summarize for the first 10 observations in my dataset. This is equivalent
*to filtering the data to only show information for the first 10 observations.
	sum school_scorres school_yrs_scorres in 1/10

	
*Good practice to confirm the unique identifier in your data.
	isid momid 
		//this will check if there is a unique momid value for each observations
	
	*Can also manually check for the unique identifier
	
	*Method 1
	gen count = 1
	egen check = sum(count), by(pregnant_ieorres) //this is not a unique ID

	egen check2 = sum(count), by(momid) // this is a unique ID.
		//If check = 1 for all obs, momid is unique ID

	drop count check check2
	
	*Method 2
	egen check = tag(momid) //If check = 1 for all obs, momid is unique ID
	
*Note that stata treats missing values as infinity for numeric data.
*So it extremely important to keep that in mind as you are generating new 
*variables
*Especially if you are using > conditions to filter your data.

*Example: generate a variable that indicates attended more than 5 years of 
*school.
	gen more_than_5schyr = 0 if school_scorres!=.
	replace more_than_5schyr = 1 if school_yrs_scorres > 5 & ///
									school_yrs_scorres!=.
									
*It's good practice to add labels to your new variables that give information
*about what the variable contains.
	*syntax: label variable [variable_name] "Variable Label"

	label variable more_than_5schyr ///
		"=1 if attended more than 5 years of schooling"
	
*Can also define value label
	*syntax: label define [label_name] # "Label" # "Label" etc.
	label define yesno 1 "Yes" 0 "No"
*Apply that label to the values of my variable.
	*syntax: label values [variable_name] [value_name]
	label values more_than_5schyr yesno
	
*Example from a classmate:
	*label define schooling 1 "yes" 0 "no"
	*label values more_5scyr schooling
	
*Once you define a value label, it can be applied to any variable you would
*like to apply it to.

label values pregnant_ieorres yesno
label values known_dobyn_scorres yesno
label values school_scorres yesno
label values catchment_ieorres yesno

*You can change the delimitor from the "return" key to the ; using the #delimit 
*command

#delimit ;

label values pregnant_ieorres 
			 known_dobyn_scorres 
			 school_scorres 
			 catchment_ieorres 
			 yesno;

#delimit cr			 
			 exit
*Can create loops of commands, when you want to repeat the same steps over and 
*over again.

foreach rainbow in  pregnant_ieorres known_dobyn_scorres school_scorres ///
			 catchment_ieorres {
	disp "`rainbow'"		 	
	label values `rainbow' yesno		
	
			 }

//delimitors and for loops














