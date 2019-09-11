* ============================================================================ *
* MEDEG STATA COURSE 2019
* INSTRUCTOR: Tomas Martinez
*
* FIFTH AND SIXTH LECTURE:
*				- Describing the Data
* 				- Performing some tests
*				- Append and Merging data
* 				
*
* ============================================================================ *

use "/Users/tomasrm/Google Drive/Teaching/Stata Course/2018_2019/lecture_6/cps05.dta", clear

describe
codebook
inspect
summarize
count


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

* Examples
summarize age sex
tabulate age

count if incwage>0
count if incwage>0 & incwage!=. // remember . is considered as infinity!
count if employed==1

tabulate marst if sex==1 // male
tabulate marst if sex==2 // female
tabulate marst sex 

sum incwage if age>17 & age<65
sum incwage if age>17 & age<65 & incwage!=0
sum incwage if age>17 & age<65 & incwage!=0 , detail

bysort educ: sum incwage if age>17 & age<65 & incwage!=0
bysort educ: tab married if age>17 & age<65 

tab1 age sex married

tab educ, gen(ed_) // generate binary variable

tab educ race2, row
tab educ race2 [iw=asecwt], row

bysort sex: tab educ race2 [iw=asecwt], row nofreq
bysort sex: tab race2 educ  [iw=asecwt], row nofreq

tabstat incwage wkswork1 uhrsworkly if age>17 & age<65 & incwage!=0, statistics(mean sd p90 p75 p50 p25 n) // simple table stat

tabstat incwage wkswork1 uhrsworkly if age>17 & age<65 & incwage!=0 & uhrsworkly!=0 & wkswork1!=0, ///
statistics(mean sd p90 p75 p50 p25 p10 n) // simple table stat

table employed sex
table sex, contents(mean employed)

table sex educ race2, contents(mean incwage sd incwage)

***** Using internal results
sum incwage if age>17 & age<65 & incwage!=0, d
return list

g dmean_wage=incwage-r(mean) if age>17 & age<65 & incwage!=0
sum dmean_wage

tabulate sex
return list

***** Some tests and statistics
corr age incwage if age>17 & age<65 & incwage!=0
corr age incwage if age>17 & age<65 & incwage!=0, means
corr age incwage if age>17 & age<65 & incwage!=0, means covariance

spearman age incwage if age>17 & age<65 & incwage!=0

return list

ttest incwage = 23400 
return list
ttest incwage = 20000
ttest incwage = 50000

ttest incwage if age>17 & age<65 & incwage!=0, by(sex) level(95) unequal

tabulate married sex, chi2

* ============================================================================ *

* Lecture 6

use "/Users/tomasrm/Google Drive/Teaching/Stata Course/2018_2019/lecture_6/cps05.dta", clear

append using "/Users/tomasrm/Google Drive/Teaching/Stata Course/2018_2019/lecture_6/cps06.dta"
append using "/Users/tomasrm/Google Drive/Teaching/Stata Course/2018_2019/lecture_6/cps07.dta"
append using "/Users/tomasrm/Google Drive/Teaching/Stata Course/2018_2019/lecture_6/cps08.dta"
append using "/Users/tomasrm/Google Drive/Teaching/Stata Course/2018_2019/lecture_6/cps09.dta"

merge m:1 occ1990dd using "/Users/tomasrm/Google Drive/Teaching/Stata Course/2018_2019/lecture_6/indx_ONET.dta"
drop _merge

keep if age>17 & age<66

bysort sex: sum routine
bysort sex: sum abstract
bysort sex: sum manual

ttest routine, by(sex) unequal

corr incwage routine
corr incwage abstract
corr incwage manual

bysort occ1990dd: egen mean_w=mean(incwage) 
sort mean_w // occ1990dd=84! Physicians
tab sex if occ1990dd==84



