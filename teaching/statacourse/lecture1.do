* ============================================================================ *
* MEDEG STATA COURSE 2018 
* INSTRUCTOR: Tomas Martinez
* Based on Pedro Sant'Anna and Ursula Mattioli Mello original notes
*
* FIRST LECTURE:
*				- How to write your first do-file
*				- Small demo on Stata features
*				- Using the help 
*				- Log file
*				- Miscellaneous details
*
* DATA USED: 
*				- United States 2000 Census (source: IPUMS International)
* 				- Modified Sample: Age>=25 and information on key variables
* ============================================================================ *



* ============================================================================ *
* HOUSEKEEPING
* ============================================================================ *

/* before starting the project, I am cleaning all the data loaded in Stata, if any */
clear	

/* I am selecting my working directory */			
cd  "/Users/tomasrm/Google Drive/Teaching/Stata Course/2018_2019/lecture_1" 
		             
/* I always use this command at the begining of the do file, so the result window 
does not get stucked */
set more off 		

/* I want to allocate some memory to Stata manually - this is good if you are 
dealing with big datasets */
set memory 1200M	

* Now, I can open the data
use microdata_lecture1.dta

* We will use a log file to save the session
log using my_log.log, replace

* ============================================================================ *
* SUMMARIZE
* ============================================================================ *

/*  WE HAVE MORE THAN 9 MILLION DATA POINTS!!! Now, you can see how powerful is 
STATA comparing to Excel? */
describe

* Let's have a look at it
browse

* Let's count how many have income/Wage equal to 0
count if incwage==0

* some statistics by sex and age

sum age

sum incwage
sum incwage if age>=25 & age<40
sum incwage if age>=40 & age<60
sum incwage if age>=60

sum incwage if sex==1 
sum incwage if sex==2


* ============================================================================ *
* Now that we have the dataset ready, let's do some plots
* ============================================================================ *

* Density plot of wages for those who are working
kdensity incwage if incwage>0, lwidth(medthick) title(Wage density for those with wage bigger than zero)

*let's save the plot
graph export "plots_wage.png", as(png) replace

*let's compare it for Male and Female
kdensity incwage if incwage>0 & sex==1, lcolor(midblue) lwidth(medthick) addplot ///
((kdensity incwage if sex==2 & incwage>0, lcolor(red) lwidth(medthick))) title(Wage density: Male vs Female) ///
legend(on order(1 "Kernel Density for Males" 2 "Kernel Density for Females"))

*let's save the graph
 graph export "plots_male_female_wage.png", as(png) replace

*Also, let's put multiple graphs in one page

*first, let me create some age categories to group the ages
gen age_5years=1 if age<=35
replace age_5years=2 if age>35 & age<=45
replace age_5years=3 if age>45 & age<=55
replace age_5years=4 if age>55 & age<=65
replace age_5years=5 if age>65 & age<=75
replace age_5years=6 if age>75

* let me create the label for the age groups

label define age_group 1 "Age<=35"
label define age_group 2 "Age>35 & Age<=45", add
label define age_group 3 "Age>45 & Age<=55", add
label define age_group 4 "Age>55 & Age<=56", add
label define age_group 5 "Age>65 & Age<=75", add
label define age_group 6 "Age>75", add
label values age_5years age_group

/* Now, let's create the variable income for men and income for women 
(just to illustrate new commands - we could impose restrictions on the graphs also) */

gen  incwage_male= incwage if  sex==1
label var incwage_male " Wage and Salary income for Men"
gen  incwage_female= incwage if  sex==2
label var incwage_female " Wage and Salary income for Women"

* plot the graphs comparing the density of male and female wage, but for different age range

* first, let's do it with the same Y-scale
twoway (kdensity incwage_male, lcolor(midblue) lwidth(medthick)) (kdensity incwage_female, lcolor(red) lwidth(medthick)) ///
if incwage>0, by(, title(Wage distribution: Male vs Female - by Age)) ///
legend(order(1 "Kernel Density for Males" 2 "Kernel Density for Females")) ///
by(age_5years, ixaxes iyaxes) xlab(,labs(vsmall)) ylab(,labs(vsmall))

* let's save the graph
 graph export "plots_male_female_wage_age1.png", as(png) replace
 
* Now, with different Y-scales
twoway (kdensity incwage_male, lcolor(midblue) lwidth(medthick)) (kdensity incwage_female, lcolor(red) lwidth(medthick)) ///
if incwage>0, by(, title(Wage distribution: Male vs Female - by Age)) ///
legend(order(1 "Kernel Density for Males" 2 "Kernel Density for Females")) ///
by(age_5years, ixaxes iyaxes yrescale) xlab(,labs(vsmall)) ylab(,labs(vsmall))
 
* save the graph
graph export "plots_male_female_wage_age2.png", as(png) replace
 
* plot also the Marginal effects 
reg  incwage  c.age##c.age sex if incwage>0, robust // c.age##c.age allows you to use factors withou creating a new variable
margins, dydx(age) at(age=(25 30 35 40 45 50 55 60 65 70 75 80))
marginsplot 

*let's save the graph
graph export "plots_margins_age.png", as(png) replace

*let's also plot the effect of sex on different quantiles
*The command does not accept factor variables, so let's create the variable age squared
gen age2=age^2
label var age2 "Age Squared"

*in order to speed it up, we will use only a 1% sample from the original
sample 1
*now, let's do the quantile regression
qreg incwage age age2 sex if incwage>0

ssc install grqreg 
grqreg sex, ols ci olsci qmin(0.05) qmax(0.95) qstep(0.10)

*let's save the graph
graph export "plots_quantile_sex.png", as(png) replace

log close
