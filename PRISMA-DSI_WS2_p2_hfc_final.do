
//PRiSMA Data Workshops
//Workshop 2: Tools for Data Quality Assessment - High Frequency checks
//First verion: 21 Sept 2022; This version 22 Sept 2022
//Author: Jennifer Seager; jseager@gwu.edu

//This do file demonstrates high frequency check utilities

putexcel set "$output/PRiSMA_Workshop-2_hfc.xlsx", replace sheet("1.missing")

// Doing the assignment

use "$da/MNH11_WS2.dta", clear

//1. Ensuring key variables are nonmissing

preserve 

global var momid pregnancyid m11_mat_ld_ohostdat

//findit rmiss2
local k=1
local vlist "`var'"
foreach var in $var {
	
	egen m_`var' = rmiss2(`var')
	
	local k=`k'+1
}

tabstat m_*, stat(sum) col(statistics) long save
matrix m =r(StatTotal)'

putexcel A1 = matrix(m), names

gen flag =0
foreach var in $var {
	replace flag = flag+1 if m_`var'>0
	
}

keep  if flag>0
keep $var m_*
export excel "$output/PRiSMA_Workshop-2_hfc.xlsx", sheet("1.missing",modify) cell(D1) firstrow(variables)

restore

//2. Checking skip pattern 
preserve
local m11_hb_lbperf m11_anemia_mhoccur
local m11_hb_lborres m11_anemia_mhoccur
local m11_infants_faorres m11_multi_birth_faorres
local m11_pph_estimate_faorres m11_pph_estimate_fastat

global var  m11_hb_lbperf m11_hb_lborres m11_infants_faorres m11_pph_estimate_faorres

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

export excel "$output/PRiSMA_Workshop-2_hfc.xlsx", sheet("2.skip",modify) cell(A1) firstrow(variables)

restore
//3. Soft constraints
preserve 
gen inf_flag = 0
replace inf_flag = 1 if m11_infants_faorres>2 & m11_infants_faorres!=.

keep if inf_flag>0
keep momid inf_flag

export excel "$output/PRiSMA_Workshop-2_hfc.xlsx", sheet("3.constraints",modify) cell(A1) firstrow(variables)
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

export excel "$output/PRiSMA_Workshop-2_hfc.xlsx", sheet("4.outliers",modify) cell(A1) firstrow(variables)
restore


exit


