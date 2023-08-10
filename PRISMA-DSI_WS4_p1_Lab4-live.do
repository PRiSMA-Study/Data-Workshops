
//PRiSMA Data Workshops
//Workshop 4: Descriptive Analysis in Stata
//First verion: 12 Dec 2022; 
//Author: Jennifer Seager; jseager@gwu.edu
//Purpose: This do file replicates output from Baird et. al (2019)

//Directory paths in 0 file
gl dir = "/Users/jenniferseager/Dropbox/PRiSMA Data Workshops/Data Files"

gl da = "$dir/data"
gl dr = "$dir/data raw"
gl dt = "$dir/temp"
gl dl = "$dir/logs"
gl do = "$dir/do"
gl output = "$dir/output"

clear
clear all
cap log close

global date "221213"

log using "$dl/PRiSMA_Data-Workshop-4_$date.log", replace


//Open the data

use "$da/GEH_Ethiopia_Final.dta", clear


//Q1 How many observations in the data set? In urban areas?

desc, short

tab urban

//Q2 Creating a global variable list

*Create category labels for the table output

gen l_attnorm = .
label variable l_attnorm "Attitudes and Norms"

gen l_physhealth = . 
la var l_physhealth "Physical Health"

gen l_mentalhealth = .
la var l_mentalhealth "Mental Health"

gen l_control = .
la var l_control "Control Variables"


gl out  l_attnorm cr_att cr_norm_c ///
		l_physhealth zhawho zbmiwho cr_selfhealth cr_symptom cr_seriousill cr_hungry ///
		l_mentalhealth cr_ghq12 cr_ress40 ///
		l_control asset_10 cr_trustfr cr_talkf female age urban 


//Q3 Generate summary statistics to save to a matrix for output

//*Q3a. generate summary stats
tabstat $out [aweight=weight], statistics(mean sd) columns(statistics) save long
return list
matrix Overall=r(StatTotal)'
matrix list Overall

*rural
tabstat $out [aweight=weight] if urban==0, statistics(mean) columns(statistics) save long
return list
matrix Rural=r(StatTotal)'

*urban
tabstat $out [aweight=weight] if urban==1, statistics(mean) columns(statistics) save long
return list
matrix Urban=r(StatTotal)'

*Combine these matrices into a single matrix

matrix define Summary= Overall , Rural , Urban 
*matrix define Summary1=  Rural \ Urban  

matrix colnames Summary = Overall SD Rural Urban

//*Q3a. Add sample sizes

*Individual sample sizes
tab urban 
return list 
matrix OverallN = r(N)

tab urban if urban==0
return list 
matrix RuralN = r(N)

tab urban if urban==1
return list 
matrix UrbanN = r(N)

matrix define IndN = OverallN, ., RuralN, UrbanN

*Community sample sizes
egen tag = tag(VillageID)

tab urban if tag==1
return list 
matrix AllCommN = r(N)

tab urban if urban==0&tag==1
return list 
matrix RuralCommN = r(N)

tab urban if urban==1&tag==1
return list 
matrix UrbanCommN = r(N)

matrix define CommN = AllCommN, ., RuralCommN, UrbanCommN

matrix define N = IndN \ CommN

matrix rownames N = "Sample Size Individuals" "Sample Size Communities"

*Combine Summary matrix with the sample size matrix

matrix define Table1b = Summary \ N


//Putting the Summary Statistics into an excel book.

putexcel set "$output/PRiSMA_Data-Workshop-4_Tables_$date.xlsx", ///
	replace sheet(Table 1b)
	

putexcel A3 = matrix(Table1b), names


*Put the variable labels into the table.

local i = 4

foreach v of global out {
	local ColVar`i' = "`v'"
	local ColVarLabel`i' : variable label `ColVar`i''
	putexcel A`i' = "`ColVarLabel`i''"
	macro drop ColVar`i' ColVarLabel`i'
		local i = `i' + 1
	}
	
putexcel A1 = "Table 1b"
putexcel A2 = "Descriptive statistics of attitudes, norms, physical health, mental health, andcontrols (Ethiopia)"

putexcel B3:E23, nformat("0.000") overwritefmt
putexcel B24:E25, nformat("0") overwritefmt






log close
