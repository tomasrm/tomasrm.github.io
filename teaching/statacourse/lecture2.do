* ============================================================================ *
* MEDEG STATA COURSE 2019
* INSTRUCTOR: Tomas Martinez
*
* SECOND LECTURE:
*				- How import data
* 				- Reshape
*
* ============================================================================ *

* PS. This commands were written for Stata 14! It may not work in older versions

* Importing Piketty data for Spain
	/* Remember import command does not work in old versions of stata! */
clear
import excel "/Users/tomasrm/Google Drive/Teaching/Stata Course/2018_2019/lecture_2/spain_data.xlsx", sheet("Series-layout A") firstrow 

clear 
import delimited "/Users/tomasrm/Google Drive/Teaching/Stata Course/2018_2019/lecture_2/spain_data.csv", numericcols(2) encoding(UTF-8)

clear
import delimited "/Users/tomasrm/Google Drive/Teaching/Stata Course/2018_2019/lecture_2/spain_data.txt", numericcols(2) encoding(UTF-8)

* Exercise 2

import excel "/Users/tomasrm/Google Drive/Teaching/Stata Course/2018_2019/lecture_2/API_SI.POV.DDAY_DS2_en_excel_v2_10081490.xls", sheet("Data") cellrange(A4:BJ268)  case(lower)  firstrow clear

// Years are imported with crazy names!!!

import excel "/Users/tomasrm/Google Drive/Teaching/Stata Course/2018_2019/lecture_2/API_SI.POV.DDAY_DS2_en_excel_v2_10081490.xls", sheet("Data") cellrange(A4:BJ268) case(lower) firstrow clear

drop indicatorname indicatorcode

reshape long yr, i(countryname) j(year)

saveold "/Users/tomasrm/Google Drive/Teaching/Stata Course/2018_2019/lecture_2/mydata.dta", version(12) replace
