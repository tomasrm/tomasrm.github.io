* ============================================================================ *
* MEDEG STATA COURSE 2019
* INSTRUCTOR: Tomas Martinez
*
* TENTH LECTURE:
*				- Macros
* 				- Loops
*			
*				
* ============================================================================ *

use "/Users/tomasrm/Google Drive/Teaching/Stata Course/2019_2020/lecture_5_6/cps/cps05.dta", clear

* Macros

local myvariables age sex marst
summarize `myvariables'
reg incwage `myvariables'


local sample1 if age>=18 & age<=65 & sex==1
tab marst `sample1'
reg incwage age `sample1'

local path /Users/tomasrm/Google Drive/Teaching/Stata Course/2018_2019/lecture_6/
cd "`path'"
use cps05.dta, clear
* or
use "`path'/cps05.dta" , clear

global myvariables age sex marst
summarize $myvariables

* Loops

foreach fruit in apple banana melon { // fruit is local macro
di "`fruit'"
}

forvalues i=18/65 {
di "age: `i'"
sum incwage if age==`i'
}

forvalues i=5(5)50 {
di "value: `i'"
}




local i=1
while `i'<=10 {
	local i=`i'+1
	di `i'
} 


* if
sum age
if r(mean)>30 {
di "Average age bigger than 30"
}
else {
di "Average age smalle than 30" 
}


