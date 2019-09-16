* ============================================================================ *
* MEDEG STATA COURSE 2019
* INSTRUCTOR: Tomas Martinez
*
* EIGHTH AND NINETH LECTURE:
*				- Regressions
* 				- Tme Series and Panel Data
*				- Post estimation
* 				- Exporting results
*				
* ============================================================================ *

use "/Users/tomasrm/Google Drive/Teaching/Stata Course/2019_2020/lecture_8_9/elemapi.dta", clear

corr api00 acs_k3 meals full

reg api00 acs_k3 meals full

reg api00 acs_k3 meals full, r

display _b[_cons] // display constant
display _b[acs_k3] // display beta acs_k3
display _se[acs_k3] // display standard error acs_k3

g betaacs=_b[acs_k3]*acs_k3  // generate variable beta*acs_k3

predict yhat // predict
predict resid, residuals // predict

sum api00 acs_k3 meals full

tab acs_k3

list snum dnum acs_k3 if acs_k3<0 // all school from district 140 has negative class size!

reg api00 acs_k3 meals full, r

histogram acs_k3
histogram meals
histogram full

tab full 

tab dnum if full<=1 // district 401

graph matrix api00 acs_k3 meals full, half

twoway (scatter api00 meals) (lfit api00 meals)

reg api00 acs_k3 meals full, r

replace acs_k3=. if acs_k3<0
reg api00 acs_k3 meals full, r

replace full=. if full<1
reg api00 acs_k3 meals full, r


reg api00 ell meals yr_rnd mobility acs_k3 acs_46 full emer enroll, robust
test acs_k3 meals full // f-test
test acs_k3 //

test full=1 //
test meals=-3.5, accumulate // the command accumulate let you include more restritions!
test full=meals // test coefficient of meals equal to full


reg api00 ell meals yr_rnd mobility acs_k3 acs_46 full emer enroll
lvr2plot, mlabel( snum)

regress api00 ell meals yr_rnd mobility acs_k3 acs_46 full emer enroll

predict api00_hat
predict residuals, residuals

qnorm residuals
kdensity residuals, normal

rvfplot, yline(0)

estat hettest // Breusch-Pagan test
estat imtest // white test

* ============================================================================ *

* Time Series
clear
import excel "/Users/tomasrm/Google Drive/Teaching/Stata Course/2019_2020/lecture_8_9/US_real_gdp.xls", sheet("Quarterly") firstrow case(lower)

* Set date
tsset date

generate qtr = quarter(date)
generate yr = year(date)
generate date2=yq(yr,qtr)

tsset date2, quarterly

gen lgdp=l.gdpc1
gen l2gdp=l2.gdpc1

gen loggdp=log(gdpc1)

gen growth=d.loggdp
gen lgrowth=l.growth

reg gdpc1 lgdp // unit root!
reg growth lgrowth 

corrgram growth
ac growth
pac growth, lag(20)

line growth date2, sort

arima growth, arima(1,0,1) // ARMA(1,1)

tsfilter hp cyclical=loggdp,trend(trnd)


* ============================================================================ *

* Panel Data
clear
use "/Users/tomasrm/Google Drive/Teaching/Stata Course/2019_2020/lecture_8_9/NLSY_data.dta"

* 
gen date = ym(year, month)
xtset id date

* log real wage 
g lw=log(wage/cpi)  
g ly=log(wage*hours/cpi) // total income

g agesq=age^2

* if they are advacend enough you can teach [_n-1]...
bysort id: g t=_n
g working=(job>0)
g exp=0 if t==1
replace exp=exp[_n-1]+working[_n-1] if t>1 & id==id[_n-1]

* Wage growth
g wage_growth=d.ly

* Create a tenure variable
bysort id spell: g tenure=_n-1

* perform some regressions
xtreg ly i.educ i.race  age agesq tenure // dummies

xtreg ly educ##race  age agesq tenure // all interactions

xtreg ly educ#race  age agesq tenure // just interactions (no dummies

* with fixed effects:
xtreg ly i.educ i.race  age agesq tenure i.year, fe // why the dummies disappears

* Export results
ssc install outreg2


xtreg ly age agesq tenure i.year, fe r // with FE
estimates store myreg	//. store
outreg2 myreg using "/Users/tomasrm/Google Drive/Teaching/Stata Course/2018_2019/lecture_8_9/regressions.xls", ///
append label drop(i.year) addtext(Individual FE, YES, Year  FE, YES)

xtreg ly age agesq tenure, fe r // without year FE
estimates store myreg	//. store
outreg2 myreg using "/Users/tomasrm/Google Drive/Teaching/Stata Course/2018_2019/lecture_8_9/regressions.xls", ///
append label addtext(Individual FE, YES, Year  FE, NO)

xtreg ly age agesq tenure i.year, r // without id FE
estimates store myreg	//. store
outreg2 myreg using "/Users/tomasrm/Google Drive/Teaching/Stata Course/2018_2019/lecture_8_9/regressions.xls", ///
append label drop(i.year) addtext(Individual FE, NO, Year  FE, YES)

xtreg ly age agesq tenure, r // without both FE
estimates store myreg	//. store
outreg2 myreg using "/Users/tomasrm/Google Drive/Teaching/Stata Course/2018_2019/lecture_8_9/regressions.xls", ///
append label addtext(Individual FE, NO, Year  FE, YES)

erase "/Users/tomasrm/Google Drive/Teaching/Stata Course/2018_2019/lecture_8_9/regressions.txt"

* ps. relabel the variables 
