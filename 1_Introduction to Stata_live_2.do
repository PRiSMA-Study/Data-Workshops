*PRISMA Data workshop: Stata Basics Code
*Purpose: The do file contains the code related to the first workshop in the 
*		  Stata Basics series
*Version 1.0: 22 May 2023; Jennifer Seager (jseager@gwu.edu)
*Version 2.0: NEW DATE; WHO IS THE PERSON THAT UPDATED IT (CONTACT INFORMATION)

clear

*******************
*Using Display Command
*******************

*Calculate the results of 25*4+9/3
	
	display 25 * 4 + 9 / 3
	display 25*4+9/3
	
*Display the text "This is the start of my do file"
	display "This is the start of my do file"
	

*******************
*Create a dataset
*******************

*Create a dataset with one observation
	set obs 1

*******************
*Generating Variables
*******************

*Generate a string variable called name that contains my frist name
	generate name = "Jennifer"

*Use the display command to show the contents of the variable name
	display name
	
*Use the describe command to describe
	describe 
	
*Generate a variable that stores your age 
	gen age = 35
	
*Generate a new variable called age_2 that stores age as a byte numeric data 
*type
	gen byte age_2 = 35
	
*Generate a variable that is equal to today's date in DDMMYYYY as a string
	gen date = "29052023"
	
	 
*******************
*Converting variables between types
*******************
	
*Convert the age variable to a string, generate a new variable called new_age
	tostring age, gen(new_age)

*Browse the data
	browse

*Convert the date variable to a numeric data type, generate a new variable 
*called "numeric_date"
	destring date, gen(numeric_date)

*Now try converting the name variable to a numeric type, replace the original
	destring name, replace
	
*You can add a "force" option to override this. Try again, this time generating
*a new variable called "name_2". Browse the data.
	destring name, gen(name_2) force
	

*******************
*Dropping variables
*******************
drop age_2 name_2 numeric_date

*keep name age new_age date

*******************
*Combining variables
*******************
*substring

*Create a new variable called name_age that contains both your name and age 
*with a "_" between them.
	gen name_age = name + "_" + new_age
	gen nameage = name+new_age
	drop nameage
	

*Now, let's generate a new variable with the age that you started started 
*school and call it school_age
	gen byte school_age = 5

* Now, using mathematical operators, calculate how many years ago you 
*started school. Store the result in a variable called years_since_school.
	gen years_since_school = age-school_age
	
*******************
*Separating string variables
*******************	

*Generate a variable that contains just the day information.
*29052023

	gen day = substr(date,1,2)

	gen month = substr(date,3,2)
	*gen month2 = substr(date,-6,2)

	gen year = substr(date,5,4)
	*gen year2 = substr(date,-4,.)
	*gen year3 = substr(date,-4,4)
	*gen year4 = substr(date,5,.)

	destring day month year, replace

*******************
*Reordering variables
*******************

order name_age, first
order new_age,before(age)

*A few altnerative ways you can specify the order command
	*order day month year, after(date)
	*order new_age, last
	*order name_age nameage name age date month day year school_age years_since_school



*******************
*Labelling variables
*******************

*Labelling the name_age variable
	label variable name_age "First name and age in years"
	
*Stata will understand that I want to label a variable if I simply type "la var"
	la var name "First name"
	
*Label other variables
	label variable age "age in years"
	lab varia date "Date in DDMMYYYY format"
	la var school_age "Age respondent started school"
	la var years_since_school "Number of years since respondent started school"
	

*******************
*Labelling values
*******************

*first, you define a new label for values
	label define l_age 5 "5 years old" 6 "6 years old" 7 "7 years old" ///
					   8 "8 years old" 9 "9 years old" 10 "10 years old" ///
					   35 "35 years old"
	
#delimit ;
					   
	*label define l_age 5 "5 years old" 6 "6 years old" 7 "7 years old"
					   8 "8 years old" 9 "9 years old" 10 "10 years old"
					   35 "35 years old"	;

#delimit cr
					   
*second, you apply that new value label to a list of variables
	label values age school_age l_age
	







