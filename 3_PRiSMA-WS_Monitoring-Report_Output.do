//Generating the tables for the monitoring report

clear
clear all
eststo clear
estimates clear
cap log close


use "$da/PRiSMA_Monitoring-Report_screen-data-construct.dta", clear


//Table 1a Pre-screening numbers for PRiSMA MNH Study for the most recent one week


//Creating Label variables for my table;
gen l_total = .
la var l_total "Pre-screening"
gen l_notel = .
la var l_notel "Reason for exclusion in pre-screening, N (%)"

label var count "Pre-screened for PRiSMA, n (MNH00)"

preserve

//Restricting to screening in the last 7 days.
keep if week==1

//Generating a global variable set for the table outcomes.
gl out l_total count eligible l_notel not_preg_i over25wk_i not_age_i outside_i other_i no_consent_i 

tabstat $out , stat(sum mean) col(statistics) long save
matrix overall = r(StatTotal)'
*matrix list overall

tabstat $out if site=="Kenya", stat(sum mean) col(statistics) long save
matrix kenya = r(StatTotal)'

tabstat $out if site=="Pakistan", stat(sum mean) col(statistics) long save
matrix pakistan = r(StatTotal)'

matrix table1a = overall, kenya, pakistan
matrix example = overall \ kenya \ pakistan
matrix list table1a


putexcel set "$output/PRiSMA_Monitoring-Reporting.xlsx", sheet(Table1) replace

putexcel A1 = "Table 1a. Pre-screening numbers for PRiSMA MNH Study for the most recent one week"
putexcel B2 = "All sites"
putexcel D2 = "Kenya"
putexcel F2 = "Pakistan"

putexcel A3 = matrix(table1a), names nformat(number)


foreach l in B D F {
putexcel `l'3 = "N"
}

foreach l in C E G {
putexcel `l'3 = "%"
}

local i = 4
foreach v of global out {
	local ColVar`i' = "`v'"
	local ColVarLabel`i' : variable label `ColVar`i''
	putexcel A`i' = "`ColVarLabel`i''"
	macro drop ColVar`i' ColVarLabel`i'
		local i = `i' + 1
	}
	
	foreach l in C E G {
	putexcel `l'5:`l'100, nformat("0.00%") overwritefmt
	}

restore

//Table 1b Cumulative Pre-screening numbers for PRiSMA MNH Study

tabstat $out, stat(sum mean) col(statistics) long save
matrix overall = r(StatTotal)'

tabstat $out if site=="Kenya", stat(sum mean) col(statistics) long save
matrix kenya = r(StatTotal)'

tabstat $out if site=="Pakistan", stat(sum mean) col(statistics) long save
matrix pakistan = r(StatTotal)'

matrix table1b = overall, kenya, pakistan
matrix list table1b

putexcel set "$output/PRiSMA_Monitoring-Reporting.xlsx", sheet(Table1) modify

putexcel A14 = "Table 1b. Cumulative Pre-screening numbers for PRiSMA MNH Study"
putexcel B15 = "All sites"
putexcel D15 = "Kenya"
putexcel F15 = "Pakistan"
putexcel A16 = matrix(table1b), names nformat(number)

foreach l in B D F {
putexcel `l'16 = "N"
}

foreach l in C E G {
putexcel `l'16 = "%"
}

local i = 17
foreach v of global out {
	local ColVar`i' = "`v'"
	local ColVarLabel`i' : variable label `ColVar`i''
	putexcel A`i' = "`ColVarLabel`i''"
	macro drop ColVar`i' ColVarLabel`i'
		local i = `i' + 1
	}
	
	foreach l in C E G {
	putexcel `l'5:`l'100, nformat("0.00%") overwritefmt
	}
	

	
	
//Figure 2

use "$da/PRiSMA_Monitoring-Report_enroll-data-construct.dta", clear



*collapse (sum) enrolled, by(scrn_obsstdat site)

gen kenya_enr = enrolled if site=="Kenya"
gen pakistan_enr = enrolled if site=="Pakistan"

collapse (sum) enrolled kenya_enr pakistan_enr, by(scrn_obsstdat)



local N=_N
disp `N'

foreach c in enrolled kenya_enr pakistan_enr {
gen cum_`c' = `c'

forvalues i=1/`N' {
	local j=`i'+1
	replace cum_`c'=cum_`c'[`j']+cum_`c'[`i'] if _n==`j'
}

}

sort scrn_obsstdat
encode scrn_obsstdat, gen(date)

#delimit;
twoway connected cum_enrolled date, color(gs0) ||
	   connected cum_kenya_enr date, color(green) || 
	   connected cum_pakistan_enr date, color(red)  
	xmtick(1(7)62) xlabel(1(7)62, valuelabel labsize(vsmall) angle(vertical))
	legend(label(1 "All Sites") label(2 "Kenya") label(3 "Pakistan"))
	ytitle("Participant Enrolled") xtitle("Enrollment Week");
	
#delimit cr

local M = ceil(`N'/7)
disp `M'
gen rest = 0

forvalues i=1/`M' {
	local j=`i'+6*(`i'-1)
	replace rest = 1 if date==`j'
	
}

keep if rest==1

local end = ceil(`N'/7)+6*(ceil(`N'/7)-1)
disp `end'


#delimit;
twoway connected cum_enrolled date, color(gs0) ||
	   connected cum_kenya_enr date, color(green) || 
	   connected cum_pakistan_enr date, color(red)  
	xmtick(1(7)`end') xlabel(1(7)`end', valuelabel labsize(vsmall) angle(vertical))
	legend(label(1 "All Sites") label(2 "Kenya") label(3 "Pakistan"))
	ytitle("Participant Enrolled") xtitle("Enrollment Week");
	
#delimit cr

exit
#delimit;
twoway scatter cum_enrolled date, color(gs0)  || line cum_enrolled date, lcolor(gs0) ||
	   scatter cum_kenya_enr date, color(green) || line cum_kenya_enr date, lcolor(green) ||
	   scatter cum_pakistan_enr date, color(red) || line cum_pakistan_enr date, lcolor(red) 
	xmtick(1(5)`N') xlabel(1(5)`N', valuelabel labsize(vsmall) angle(vertical));
	
#delimit cr
