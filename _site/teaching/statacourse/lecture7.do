* ============================================================================ *
* MEDEG STATA COURSE 2019
* INSTRUCTOR: Tomas Martinez
*
* SEVENTH LECTURE:
*				- Graphs
* 				
*
* ============================================================================ *

use "/Users/tomasrm/Google Drive/Teaching/Stata Course/2019_2020/lecture_5_6/cps/cps05.dta", clear
merge m:1 occ1990dd using "/Users/tomasrm/Google Drive/Teaching/Stata Course/2019_2020/lecture_5_6/cps/indx_ONET.dta"
drop _merge

* Generate some auxiliary variables
gen married=(marst==1 | marst==2) 
gen employed=(empstat==10 | empstat==12)  if empstat!=0 & empstat!=1

replace incwage=. if incwage>=9999998 // top coded
replace uhrsworkly=. if uhrsworkly>=998 

recode educ99 (0/9=1) (10=2) (11/14=3) (15/max=4), gen(educ)
label var educ "Education"
label define educ 1 "Less than HS" 2 "High School" 3 "Some College" 4 "College Grad"
label values educ educ

recode race (100=1) (200=2) (651=3) (652/max=4) (300=4), gen(race2)
label define race2 1 "White" 2 "Black" 3 "Asian" 4 "Other"
label values race2 race2

bysort occ1990dd: egen mean_occ=mean(incwage) 
bysort occ1990dd sex: egen mean_occ_s=mean(incwage)

* Some graphs
keep if age>18 & age<65
drop if incwage==. | incwage==0


* Twoway

twoway scatter mean_occ routine  if occ1990dd!=0 & occ1990dd!=.

twoway scatter incwage sex  // scatter plot does not make much sense with categorical variables

twoway scatter mean_occ routine  if occ1990dd!=0 & occ1990dd!=., ///
title("Avg. Wage by routinization") note("Source: CPS 2005 and ONET")
label var mean_occ "Avg. Wage"
label var routine "Routine"

twoway (scatter mean_occ routine) (lfit mean_occ routine)  if occ1990dd!=0 & occ1990dd!=., ///
title("Avg. Wage by task share") note("Source: CPS 2005 and ONET")

twoway (scatter mean_occ routine) (qfit mean_occ routine)  if occ1990dd!=0 & occ1990dd!=., ///
title("Avg. Wage by task share") note("Source: CPS 2005 and ONET") 


twoway (scatter mean_occ_s routine) (lfitci mean_occ_s routine) if occ1990dd!=0 & occ1990dd!=., ///
title("Avg. Wage by task share") note("Source: CPS 2005 and ONET") by(sex) 

twoway (scatter mean_occ routine) (scatter mean_occ abstract) if occ1990dd!=0 & occ1990dd!=., ///
title("Avg. Wage by task share") note("Source: CPS 2005 and ONET") graphregion(color(white)) ///
legend(label(1 "Routine") label(2 "Abstract")) yscale(range(0 500000))

twoway (scatter mean_occ routine) (scatter mean_occ abstract) if occ1990dd!=0 & occ1990dd!=., ///
title("Avg. Wage by task share") note("Source: CPS 2005 and ONET") graphregion(color(white)) ///
legend(label(1 "Routine") label(2 "Abstract"))
graph export "/Users/tomasrm/Google Drive/Teaching/Stata Course/2018_2019/lecture_7/graph1.png"

* Distribution

graph twoway kdensity incwage
graph twoway kdensity incwage, bwidth(200)
graph twoway kdensity incwage, bwidth(200000) //bwidth is data dependent!

graph twoway (kdensity incwage if sex==1) (kdensity incwage if sex==2), ///
legend(order(1 "Male" 2 " Female")) 

histogram incwage
histogram incwage, bin(10)
histogram incwage, bin(1000)
histogram incwage, by(sex)

twoway (histogram incwage) (kdensity incwage) 

cumul incwage, generate(cdfwage)
twoway line cdfwage incwage, sort

* Other graphs
graph bar (mean) incwage (sd) incwage, over(educ) // you can include more variables but the y axis would be the limited factor

graph pie, over(educ) plabel(_all percent, color(white))

graph box incwage, over(educ) noout

help graph dot
