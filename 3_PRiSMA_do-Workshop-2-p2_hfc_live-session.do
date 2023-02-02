
//PRiSMA Data Workshops
//Workshop 2: Tools for Data Quality Assessment - High Frequency checks
//First verion: 21 Sept 2022; This version 22 Sept 2022
//Author: Jennifer Seager; jseager@gwu.edu

//This do file demonstrates high frequency check utilities


use "$da/MNH11_WS2.dta", clear


global date 220922

//1. Ensure that key variables are nonmissing
preserve

global var momid pregnancyid m11_mat_ld_ohostdat m11_anc_tot_vists

local momid "individual id"
local pregnancyid "pregnancyid"
local m11_mat_ld_ohostdat "visit date"
local m11_anc_tot_vists "ANC visit"

foreach var in $var {
    
	egen m_`var'= rmiss2(`var')
	
	la var `var' "Variable ``var'' missing values"

}

/*
The for loop is equivalent to :

egen m_momid = rmiss2(momid)
egen m_pregnancyid = rmiss2(pregnancyid)
egen m_m11_mat_ld_ohostdat = rmiss2(m11_mat_ld_ohostdat)
egen m_m11_anc_tot_vists = rmiss2(m11_anc_tot_vists)

*/

tabstat m_*, stat(sum) col(statistics) long save

matrix m =r(StatTotal)'

matrix list m

putexcel set "$output/PRiSMA_Workshop-2_hfc_$date.xlsx", replace sheet("1.missing")

putexcel B1 = matrix(m), names


*Create macros to get labels into Excel:
local i = 2
foreach v of global var {
	local ColVar`i' = "`v'"
	local ColVarLabel`i' : variable label `ColVar`i''
	putexcel A`i' = "`ColVarLabel`i''"
	macro drop ColVar`i' ColVarLabel`i'
		local i = `i' + 1
	}

gen flag =0
foreach var in $var {
	
	replace flag = flag+1 if m_`var'>0
	
}

keep  if flag>0 // keep if flag==1
keep $var m_*

export excel "$output/PRiSMA_Workshop-2_hfc_$date.xlsx", sheet("1.missing",modify) ///
			cell(E1) firstrow(variables)
putexcel M1 = "Notes"

restore
/*Alternative check for missings
browse $var if pregnancyid==.
*/

//2. Checking Skip Pattern

preserve

global var m11_hb_lbperf m11_hb_lborres m11_infants_faorres m11_pph_estimate_faorres

local m11_hb_lbperf 		   m11_anemia_mhoccur
local m11_hb_lborres 		   m11_hb_lbperf
local m11_infants_faorres 	   m11_multi_birth_faorres
local m11_pph_estimate_faorres m11_pph_estimate_fastat

local k = 1
gen flag = 0
foreach var in $var {
	
	gen fl_`k' = 1 if ``var''==1 & `var'==.
	replace flag=flag+1 if ``var''==1 & `var'==.
	
	local k =`k'+1

}
tab flag

keep if flag>0
keep momid fl_* flag

export excel "$output/PRiSMA_Workshop-2_hfc_$date.xlsx", sheet("2.skip",modify) cell(A1) firstrow(variables)

/*
Can use cross-tabs to check skip patterns

*/

restore


//3. Soft constraints 

preserve

gen infant_flag = 0 if m11_infants_faorres!=.
replace infant_flag = 1 if m11_infants_faorres>2 & m11_infants_faorres!=.

/* Alternative
gen infant_flag2 = 1 if m11_infants_faorres!=.
replace infant_flag2 = 0 if m11_infants_faorres<=2
*/

keep if infant_flag==1
keep momid infant_flag

export excel "$output/PRiSMA_Workshop-2_hfc_$date.xlsx", sheet("3.constraints",modify) cell(A1) firstrow(variables)

restore


//4. Outliers

*first identify variables that you think might have outliers

global var m11_pph_estimate_faorres

foreach v in $var {
sum `v', detail

gen outlier = 0
replace outlier = 1 if `v'>r(p99)&`v'!=.

}
preserve
keep if outlier==1
keep momid  m11_pph_estimate_faorres outlier 

export excel "$output/PRiSMA_Workshop-2_hfc_$date.xlsx", sheet("4.outliers",modify) cell(A1) firstrow(variables)
restore










