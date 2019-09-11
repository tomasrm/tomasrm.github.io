* ============================================================================ *
* MEDEG STATA COURSE 2019
* INSTRUCTOR: Tomas Martinez
*
* FOURTH LECTURE:
*				- Manipulating Data
*
* ============================================================================ *

use "/Users/tomasrm/Google Drive/Teaching/Stata Course/2019_2020/lecture_4/ecinf2003.dta", clear



* Brazilian regions
gen region=1 if (31<=state & state<=35)
replace region=2 if (41<=state & state<=43)
replace region=3 if (21<=state & state<=29)
replace region=4 if (11<=state & state<=17)
replace region=5 if (50<=state & state<=53)

label define region 1 southeast 2 south 3 northeast 4 north 5 centerwest
label values region region
label variable region "region"

tab state, g(st_d)

*Gender
g male = (gender == 1)
replace male = . if gender == 9

* Education
recode education (1 2 3 4 5 =1) (6 7 =2) (8 9 =3), gen(educ2) // 3 education types

* Occupation
tab occupation, g(occ_d)

bysort id_firm: egen n_owner = sum(occ_d1)
bysort id_firm: egen n_formal_w = sum(occ_d2)
bysort id_firm: egen n_informal_w = sum(occ_d3)
bysort id_firm: egen n_unpaid = sum(occ_d4)

* wages
replace payment=.  if payment<=0 | payment==9999999
g wages= payment if occupation ==2 | occupation==3
g prolab = payment if occupation == 1
bysort id_firm: egen totwage = sum(wages)
bysort id_firm: egen totprolab = sum(prolab)

g wagebill = totwage + totprolab


* Firm variables
replace debt=. if debt==9999999 // 133 obs
replace revenue=. if revenue==9999999 | rev<0
replace cost=. if cost==9999999 | cost<0


foreach var in v4327v_1 v4327v_2 v4327v_3 v4327v_4 v4327v_5 v4327v_6 v4327v_7 v4327v_8 v4327v_9 ///
v4327v_10 v4327v_11 v4327v_12 v4327v_13 v4327v_14{
	replace `var'=.  if `var'<=0 | `var'==9999999
	replace `var'=0 if `var'==.
}


* intermediary consumption:
g int_cons=v4327v_1 + v4327v_2 + v4327v_5 + v4327v_9  // raw_inputs + goods + eletricity/water/phone + fuel
* Capital rent (intermediary consumption):
g cap_rent=v4327v_6 + v4327v_7 + v4327v_8 // rent + machine rent + vehicle rent
* Total labor cost:
g total_labor_cost = v4327v_3 + v4327v_4 // wages + encargos sociais (payroll + benefits)


g profits = revenue - cost
g va = revenue - int_cons

g vapw = va/size

**** 
bysort id_firm: egen avg_pay = mean(payment)
bysort id_firm: egen avg_hrs = mean(hours)
corr avg_pay avg_hrs if id_worker == 1


**** 
keep if id_worker ==1


* collapse
preserve
collapse (mean) size n_owner n_formal_w n_informal_w tenure ///
capital debt profit revenue vapw cost investment avg_wage wagebill cap_rent ///
[aw = pesouni], by(informal)
export excel using summary_ECINF.xls, sheet("stats") firstrow(varlabels)  replace
restore
