********************************************************************************
* The following Stata do.file is one of the coding tests that I completed. This test involves using Stata to clean, wrangle, and visualize datasets. The codes are my own work. Please do not distribute it without my permission. The folder can also be accessed on my GitHub at https://github.com/GGGGUKIM/Stata_codingsample4.
********************************************************************************

*Basic setup
clear all
set more off
global username "/Users/raymond/Desktop/writing_sample/stata_codingsample4"
cd "${username}"

*Test1
//1
use CPSDtest_DD
rename a_#_#_# inda_#_#_# // change variables' names into appropriate formats
rename b_#_#_# indb_#_#_#
rename c_#_#_# indc_#_#_#
rename d_#_#_# indd_#_#_#
rename e_#_#_# inde_#_#_#
rename f_#_#_# indf_#_#_#
rename a_#_#_#_# inda_#_#_#_#

reshape long ind, i(countryname time) j(indicator) string

//2
tempfile df1 // create a temporary dataset
rename ind index
rename indicator ind
save "df1.dta", replace emptyok

import excel "CPSDindicators.xlsx", firstrow clear // import xlsx
merge 1:m ind using df1 // merge

//3
drop if chart_type=="line"
drop _merge

//4
save "final1.dta", replace
erase "df1.dta"

//5
drop if index==.

bys countryname ind: egen max_year = max(time) // get the lastest data for each indicator of each country

keep if time==max_year // only keep the latest data
drop max_year

tempfile df2 // create a temporary dataset
save "df2.dta", replace emptyok

//6
keep if countryname=="United States"|countryname== "Canada"|countryname== "United Kingdom" |countryname=="Germany"|countryname== "France" // drop unnescessary obs
tempfile df3 // create a temporary dataset
save "df3.dta", replace emptyok

drop if ind=="a_4_4_14_1" // this indicator name is too long and cannout automatically use it as the output name
levelsof name, local(indicator)
foreach x of local indicator {
	use "df3.dta", clear
	drop if ind=="a_4_4_14_1"
	keep if name == "`x'"
	graph bar index, over(countryname) asyvars bar(1, color(red)) bar(2, color(blue)) bar(3, color(green)) bar(4, color(orange)) bar(5, color(yellow)) bargap(30) title("`x'") scale(.5) legend(row(1)) blabel(bar, format(%9.2f)) ytitle("")  note("Source: WITS") graphregion(fcolor(white)) // plot
	graph export "`x'.pdf", replace
	
}

use "df3.dta", clear
keep if ind=="a_4_4_14_1" // create the plot for this indicator separately
graph bar index, over(countryname) asyvars bar(1, color(red)) bar(2, color(blue)) bar(3, color(green)) bar(4, color(orange)) bar(5, color(yellow)) bargap(30) title("International Internet bandwidth, in Gbps/s per capita") scale(.5) legend(row(1)) blabel(bar, format(%9.2f)) ytitle("")  note("Source: WITS") graphregion(fcolor(white)) // plot
graph export "International Internet bandwidth.pdf", replace


erase "df2.dta"
erase "df3.dta"

*Test2
clear all
use STATAtest2

// Get a key dataset
tempfile df4 // create a temporary dataset
rename origin destination1
rename destination origin1
rename origin1 origin
rename destination1 destination
save "df4.dta", replace emptyok // flip the first two variables

use STATAtest2, clear
append using "df4.dta"
duplicates drop origin destination year, force
tempfile df5
save "df5.dta", replace emptyok
erase "df4.dta"

// Generate a default dataset with 5*5*4 obs
clear

tempfile df6
save "df6.dta", replace emptyok
foreach i of numlist 1/5 {
clear
set obs 20
gen origin1=`i'
gen destination1=_n
gen n=destination1

gen year=2015
replace year=2016 if n == 2|n==6|n==10|n==14|n==18
replace year=2017 if n== 3|n==7|n==11|n==15|n==19
replace year=2018 if n== 4|n==8|n==12|n==16|n==20

replace destination1 = 1 if n<5
replace destination1 = 2 if n>4&n<9
replace destination1 = 3 if n>8&n<13
replace destination1 = 4 if n>12&n<17
replace destination1 = 5 if n>16

	append using "df6.dta", force
	save "df6.dta", replace
	} 
	
drop n


save "df6.dta", replace

// Apply label and transfer numeric values into strings
label define country 1 "United States" 2 "Canada" 3 "United Kingdom" 4 "Germany" 5 "France" // define the label
label value origin1 country // apply label
label value destination1 country
decode origin1, gen(origin)
decode destination1, gen(destination)
keep origin destination year

save "df6.dta", replace

// Merge 
merge 1:m origin destination year using "df5.dta" 
drop _merge
replace investment=0 if investment==.

save "final2.dta", replace
erase "df5.dta"
erase "df6.dta"




