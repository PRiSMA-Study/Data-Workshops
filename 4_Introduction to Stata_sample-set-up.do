//Title of the do file
//Author of the do file

clear 
cap log close 


//Set up the directory paths

gl dir " FOLDER DIRECTORY "

gl da "$dir/data"
gl dr "$dir/data raw"
gl do "$dir/do"
gl dl "$dir/logs"
gl output "$dir/output"
gl dt "$dir/temp"

//Beginning analysis

log using "$dl/Project-Name.log", replace

use "$dr/MNH00.dta", clear









log close
