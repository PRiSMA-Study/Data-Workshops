//Title: Do file for Workshop 3: Data cleaning
//We will be working with data files MNH03b, MNH05, MNH01
//First created/version: October 27, 2022; Jennifer Seager (jseager@gwu.edu)

clear
clear all
clear matrix
clear mata 

cap log close

set more off //Not necessary after Stata 14.

global date = "221027"

//Question 3
//Open MNH03b


use "$dr/MNH03B_sample.dta", clear

//How many observations are in the data set.

describe, short
//desc, sh

//How many observations in the Birth weight variable? 

sum M03B_LB_WEIGHT_RPORRES


//Question 4
// Use histogram to look at the data

histogram M03B_LB_WEIGHT_RPORRES

//Correct the observatiosn that are in the wrong unit.

gen birth_weight =  M03B_LB_WEIGHT_RPORRES
replace birth_weight =  M03B_LB_WEIGHT_RPORRES*1000 if  M03B_LB_WEIGHT_RPORRES <2000
la var birth_weight "Birth weight in grams"

histogram birth_weight

//Change the width of the bins

histogram birth_weight, width(1)
histogram birth_weight, width(10)
histogram birth_weight, width(100)


//Format the figure so that it is more informative to read

set scheme s1mono
set scheme s2color
histogram birth_weight, width(100) frequency lcolor(gs0) fcolor(gs12) ///
		  xlabel(2000(500)6000) xmtick(2000(100)6000) ///
		  ylabel(0(5)20) ymtick(0(1)20) title(Histogram for Birthweight, color(gs0)) ///
		  ytitle(Number of women)
		  
//save our figure as a .png 

graph export "$output/birthweight_$date.png", replace
graph export "$output/birthweight_$date.pdf", replace

//Now we want to create a histogram with a kdensity plot over top of it.


twoway histogram birth_weight, width(100) lcolor(gs0) fcolor(gs12) ///
		  xlabel(2000(500)6000) xmtick(2000(100)6000) ///
		  title(Histogram for Birthweight, color(gs0)) || ///
	   kdensity birth_weight, lcolor(gs0) legend(off) xtitle(Weight in grams)
	
twoway histogram birth_weight if birth_weight<5000, width(100) lcolor(gs0) fcolor(gs12) ///
		  xlabel(2000(500)5000) xmtick(2000(100)5000) ///
		  title(Histogram for Birthweight, color(gs0)) || ///
	   kdensity birth_weight if birth_weight<5000, lcolor(gs0) ///
	   legend(off) xtitle(Weight in grams)
	   
graph export "$output/birthweight2_$date.png", replace


//Question 5

use "$dr/MNH05_sample.dta", clear


// 5b. First we are collaps the data down to the mean weight by visit and generating a basic chart
collapse (mean) M05_WEIGHT_PERES M05_HEIGHT_PERES M05_MUAC_PERES , by(M05_visit_num)

twoway scatter M05_WEIGHT_PERES M05_visit_num || line M05_WEIGHT_PERES M05_visit_num


//Now we will go back to the full data and look at the weight pattern for the 
//individual who had 15 doctors visits.

//first, create a variable that indicates the total number of visits per woman.
use "$dr/MNH05_sample.dta", clear

egen total_visits = max(M05_visit_num), by(MOMID)
la var total_visits "Total number of visits"
order total_visits, after(M05_visit_num)

set scheme s1mono

//this is a chart specifically for the female who had 15 visits recorded.
twoway scatter M05_WEIGHT_PERES M05_visit_num if total_visits==15, color(gs0) || ///
	   line M05_WEIGHT_PERES M05_visit_num if total_visits==15, lcolor(gs0) ///
	   ylabel(40(5)75) ymtick(40(1)75) xmtick(0(1)15) legend(off) xtitle(Visit number) ///
	   ytitle(Weight in kg) title(Weight by visit)
	   
graph export "$output/weight-by-visit_$date.png", replace


//5c. Looking at histograms of weights overall and by visit number.

use "$dr/MNH05_sample.dta", clear

histogram M05_WEIGHT_PERES 

//5ci
twoway histogram M05_WEIGHT_PERES if M05_visit_num==1 || histogram M05_WEIGHT_PERES if M05_visit_num==5

twoway kdensity M05_WEIGHT_PERES if M05_visit_num==1 || ///
	   kdensity M05_WEIGHT_PERES if M05_visit_num==5, ///
	   xtitle(Weight in kg) title(Weight densities at visit 1 and visit 5) ///
	   ytitle(densities)  ///
	   legend(label(1 "1st visit") label(2 "5th visit"))

 
//5d. We are now going to be working with both the MNH05 data and the MNH01 data.

*use "$dr/MNH01_sample.dta", clear

use "$dr/MNH05_sample.dta", clear

merge m:1 MOMID using "$dr/MNH01_sample.dta", gen(m0501)
drop if m0501==2

//I want to compare weights of women < 25 and women >= 25 years old. 
//So I need an age variable

//Introducing the substr function.

gen temp = substr(M01_BRTHDAT,1,4)

*destring temp, force gen(newtemp)

destring temp, force replace

//Let's say the interviews happened in 2022..
//I can approximate age by taking the difference between birth year and current years

gen age = 2022-temp
replace age = M01_ESTIMATED_AGE if age==.


//I can be more precise about the age by taking into account the birth month.

gen temp2 = substr(M01_BRTHDAT,6,2)
destring temp2, force replace 

gen age2 = 2021 - temp if temp2<10 
replace age2 = 2022-temp if temp2>=10 & temp2!=.
replace age2 = M01_ESTIMATED_AGE if age==.

//Alternative way to splint the string in this case.
//split M01_BRTHDAT, parse("-")

//Now I want to generate an indicator that the women is older/younger than 25.

gen older25 = age>=25 if age!=. 

twoway kdensity M05_WEIGHT_PERES if older25==0 & M05_visit_num==1 || ///
	   kdensity M05_WEIGHT_PERES if older25==1 & M05_visit_num==1,  ///
	   xtitle(Weight in kg) title("Weight distribution at first visit, by age") ///
	   ytitle(Density) xmtick(20(1)120) xlabel(20(10)120) ///
	   legend(label(1 "Younger than 25") label(2 "25 or older"))

graph export "$output/weight-by-age_$date.png", replace


