* ============================================================================ *
* MEDEG STATA COURSE 2019
* INSTRUCTOR: Tomas Martinez
*
* THIRD LECTURE:
*				- How import data using a dictionary
* 				- Defining labels 
* 				- Generating fourth
*
* ============================================================================ *


* First let's use IPUMS' dictionary
* Inspect the file and change the directory to the one it has the data ipumsi_00006.dat

clear
do IPUMS_lecture3.do


* PNAD Dictionary (exercise 3)

clear

#delimit ; // now our command spans multiple lines

infix

v0101 1-4
uf 5-6
v0102 5-12
v0103 13-15
v0301 16-17
v0302 18
v8005 27-29
v0401 30
v0404 33
v4803 663-664
v4805 666
v4704 665
v4706 667-668
v4711 675
v4718 685-696
v4727 749
v4728 750
v4729 751-755

using "/Users/tomasrm/Google Drive/Teaching/Stata Course/2018_2019/lecture_3/PES2011.txt";

#delimit cr // switch back

***gen, replace, drop, keep, recode***

label var uf "state"
label var v0101 "year"
label var v0102 "control"
label var v0103 "series"
label var v0301 "number in household"
label var v0302 "gender"
label var v8005 "age"
label var v0401 "position in the household"
label var v0404 "race"
label var v4803  "years of schooling"
label var v4805  "condition of occupation"
label var v4704  "condition of activity"
label var v4706  "type of occupation"
label var v4711  "contributes to social security"
label var v4718  "income from work"
label var v4727  "area code"
label var v4728  "area code 2"
label var v4729  "weight"

rename v8005 age

* Gender
label define v0302 2 male 4 female
label values v0302 v0302
rename v0302 gender

tab gender

saveold "/Users/tomasrm/Google Drive/Teaching/Stata Course/2018_2019/lecture_3/dataset2011.dta", replace version(12)

* ============================================================================ *










