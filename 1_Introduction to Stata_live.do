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

*Generate a variable called name that contains my frist name
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
	gen date = "22052023"
