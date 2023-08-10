*PRISMA Stata Basics: Introduction to Stata
*Purpose: This do file contains the commands for Workshop 1 activities.
*Version 1.0: May 21, 2023; Jennifer Seager (jseager@gwu.edu)

clear

*******************
*Mathematic Operators
*Using the Display Command
*******************

*Calculating 25*4+9/3
	display 25*4+9/3

*Calculating 3 cubed
	display 3*3*3
	display 3^3

*Displaying text
	display "This is the start of my do file"
	
*******************
*Generate Variables in Stata
*******************

*Creating a dataset in stata
	set obs 1
	
*Generating a string variable called name
	generate name = "Jennifer"

*Display the contents of name
	display name
	
*Describe the variable 'name'
	describe name
	
*Generate a variable called age that contains your age
	generate age = 35
	
*Describe the variable 'age'
	describe age
	
*Generate 'age_2' as a byte variable type, desribe the new variable
	gen byte age_2 = 35
	desc age_2
	
*Generate a variable that contains today's date as a string variable type in 
*DDMMYYYY 
	gen date = "22052023"
	
	
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

*Create a new variable called name_age that contains both you name and age 
*with a "_" between them.
	gen name_age = name + "_" + new_age
	
*Now, let's generate a new variable with the age that you started started 
*school and call it school_age
	gen school_age = 5


* Now, using mathematical operators, calculate how many years ago you 
*started school. Store the result in a variable called years_since_school.
	gen years_since_school = age-school_age

	
*******************
*Separating variables
*******************

* Create three new variables called day, month, and year that contain the 
*relevant piece of the date variable
	gen day = substr(date,1,2)
	gen month = substr(date,3,2)
	gen year = substr(date,-4,.)

*Convert the variables to numeric, replacing the original values
	destring day month year, replace
	
*******************
*Ordering variables
*******************

*Say you wanted the day, month, and year variables to come immediately after 
*the "date" variable. 
	order day month year, after(date)

*We want the first variable to be the name_age variable
	order name_age, first

*Now, we want to move the new_age variable to come before the age variable
	order new_age, before(age)
	

*******************
*Labelling variables
*******************

*Create informative labels for all variables
	label variable name_age "First name and current age"
	label variable name "First name"
	label variable age "Age in years"
	label variable new_age "Age in years (string)"
	label variable date "Date in DDMMYYYY format"
	label variable day "Day of the month"
	label variable month" Month of the year"
	label variable year "Year"
	label variable school_age "Age when started schooling"
	label variable years_since_school "Years since starting school"
	
*Let's create a value label for the age variables and apply it to the values
	label define l_age 5 "5 years old" 35 "35 years old"
	label values age l_age
	label values school_age l_age
	
*******************
*Labelling the data
*******************
*Add a label note to the dataset
	label data "This dataset contains information on age of starting school."
	describe


