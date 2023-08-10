//Constructing data files from the csv files

clear
clear all

//First converting all data to stata files
foreach x in 00 01 02 03 04 05 06 07 08 25 26 {

insheet using "$dr/dummy_mnh`x'.csv", clear

save "$dr/MNH`x'.dta", replace
}


exit

//This equivalent to:

insheet using "$dr/dummy_mnh00.csv", clear
save "$dr/MNH00.dta", replace

insheet using "$dr/dummy_mnh02.csv", clear
save "$dr/MNH02.dta", replace

insheet using "$dr/dummy_mnh03.csv", clear
save "$dr/MNH03.dta", replace

