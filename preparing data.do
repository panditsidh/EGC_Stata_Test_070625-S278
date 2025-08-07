if "`c(username)'" == "sidhpandit" {
	
	
	cd "/Users/sidhpandit/Documents/EGC_Stata_Test_2022"
	
}




******************************** DATA PREPARATION ********************************



use endline, clear



* check what the non-numeric values are
// tab hhinc
// tab totformalborrow_24
// tab totinformalborrow_24
 

 
 * --------- part b ---------
 
foreach var in hhinc totformalborrow_24 totinformalborrow_24 {
	
	rename `var' `var'_str // save the original variable in case we need to come back to it
	gen `var' = `var'_str
	
	replace `var' = "0" if `var'=="None"
	
	replace `var' = "" if `var'=="Refuse to answer" // handle this case as missing
	
	destring(`var'), replace
	
		
}



 
* --------- part c --------- 
 
/*

table idea
- add 1 percentile? also
- add hhnomembers
- add normalized hh income


figure idea (4 panel)
- overlayed kdensity - totformal/informal borrowed
- kdensity - hhinc
- overlayed lpoly totformal/totinformal borrowed vs hhinc
- overlayed lpoly hhinc/hhinc_pc vs hhnomembers

*/







estpost tabstat hhinc totformalborrow_24 totinformalborrow_24, stats(mean sd p50 p99 max) columns (statistics)


#delimit ; 
esttab, 
	replace
	cells("mean sd p50 p99 max")
	collabels("Mean" "SD" "Median" "99th pctl." "Max")
	nonumber
	coeflabels(hhinc "Household income in last 30 days (Rs)" 
			   totformalborrow_24 "Total formal loans in last 24 mo. (Rs)"
			   totinformalborrow_24 "Total informal loans in last 24 mo. (Rs)");
#delimit cr







* --------- part d and e ---------

foreach var in hhinc totformalborrow_24 totinformalborrow_24 {
	
// 	sum `var'
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
import delimited treatment_status.csv, clear
 
tempfile treatment_status
save `treatment_status'

restore
 
merge m:1 group_id using `treatment_status', nogen




* --------- part i --------- 

gen bpl = hhinc_topcoded/30 < 26995




* --------- part k --------- 


merge 1:1 hhid using baseline_controls

* baseline but not endline is useless
* endline but not baseline is also useless






******************************** ANALYSIS ********************************




* --------- part b --------- 


/*
* choose a few baseline household variables for the balance test



educyears is categorical and I can't make it numerical 




is 




*/
