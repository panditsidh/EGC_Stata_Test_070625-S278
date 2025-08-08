
******************************** DATA PREPARATION ********************************



* --------- part a ---------

use "${provided_data}/endline.dta", clear
 
* --------- part b ---------
 
 
** check what the non-numeric values are before recoding
// tab hhinc
// tab totformalborrow_24
// tab totinformalborrow_24

 
foreach var in hhinc totformalborrow_24 totinformalborrow_24 {
	
	rename `var' `var'_str // save the original variable in case we need to come back to it
	gen `var' = `var'_str
	
	replace `var' = "0" if `var'=="None"
	
	replace `var' = "" if `var'=="Refuse to answer" // handle this case as missing
	
	destring(`var'), replace
	
		
}



* --------- part c --------- 

* for endline raw data analysis, create a variable for household income per capita 
gen hhinc_pc = hhinc/hhnomembers

* create a variable for daily household income per capita to benchmark to intl. poverty lines
gen hhinc_pc_daily = hhinc_pc/30

* create a variable for income net debt estimate (income in last 24 months estimated by hhinc in last 30 days * 24)
gen income_net_debt = hhinc*24 - (totformalborrow_24+totinformalborrow_24)

* 1 table and 2 multi panel figures
do "dofiles/endline raw data analysis (part 1c).do"

* --------- part d and e ---------

* top code to 3 sd above mean
foreach var in hhinc totformalborrow_24 totinformalborrow_24 {
	
	qui sum `var'
	local top_code = r(mean)+3*r(sd)
	
	* create a new, labeled version of the variable
	gen `var'_topcoded = `var'
	
	replace `var'_topcoded = `top_code' if `var'>`top_code'
		
}


* --------- part g --------- 


gen total_borrowed = totformalborrow_24 + totinformalborrow_24



* --------- part h --------- 

* pairid , groupid , treated

* unique and treated by groupid

preserve


import delimited "${provided_data}/treatment_status.csv", clear
 
tempfile treatment_status
save `treatment_status'

restore
 
merge m:1 group_id using `treatment_status', nogen





* --------- part i --------- 


gen hhinc_pc_topcoded = hhinc_topcoded/hhnomembers

gen bpl = hhinc_pc_topcoded/30 < 26.995




* --------- part k --------- 


merge 1:1 hhid using "${provided_data}/baseline_controls.dta"


gen baseline_only = _merge==2
gen endline_only = _merge==1


// bysort treated: sum baseline_only
// ttest endline_only, by(treated)

keep if _merge==3

drop _merge





* addl stuff

gen primaryeduc_hoh = educyears_hoh==7
label var primaryeduc_hoh "primary"

gen secondaryeduc_hoh = inrange(educyears_hoh, 8, 14)
label var secondaryeduc_hoh "Head of Household: secondary highest education level"

label var hhnomembers_below18 "No of household members \textless{}18yo"


gen educ_cat = 0 if noclasspassed_hoh==1
replace educ_cat = 1 if primaryeduc_hoh==1
replace educ_cat = 2 if secondaryeduc_hoh==1
replace educ_cat = 3 if higheduc_hoh==1

label define educlbl ///
    0 "No formal education" ///
    1 "Primary education (highest)" ///
    2 "Secondary education (highest)" ///
    3 "Graduate/vocational/industrial education" 
label values educ_cat educlbl

gen caste = 1 if hhcaste_fc==1
replace caste = 2 if hhcaste_bc==1
replace caste = 3 if hhcaste_mbc==1
replace caste = 4 if hhcaste_sc_st==1

label define castelbl ///
    1 "Forward caste" ///
    2 "Backward caste" ///
    3 "Most backward caste" ///
    4 "Scheduled caste/tribe" 
label values caste castelbl


label define treatedlbl ///
	1 "Treated" ///
	0 "Control" 
	
label values treated treatedlbl


save final_dataset.dta, replace
