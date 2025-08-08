use final_dataset.dta, clear



******************************** ANALYSIS ********************************



* --------- part b --------- 

* balance table
eststo clear

estpost ttest gender_hoh age_hoh readwrite_hoh noclasspassed_hoh primaryeduc_hoh secondaryeduc_hoh higheduc_hoh hhnomembers_above18 hhnomembers_below18 hhreg_muslim-hhcaste_sc_st, by(treated)

#delimit ; 
esttab using "tables/table02_balance.tex",
	replace
	star(* 0.1 ** 0.05 *** 0.01)
	cells("mu_1(fmt(3)) mu_2(fmt(3)) b(star) se(par)")
	nonumber
	label
	refcat(gender_hoh "\textbf{Demographics of head of household}"
		   readwrite_hoh "\textbf{Highest education level of head of household}"
		   hhnomembers_above18 "\textbf{Household size and composition}"
		   hhreg_muslim "\textbf{Religion and caste/tribe of household}", nolabel)
	collabels("Control" "Treated" "Difference" "SE" "N")
	coeflabels(age_hoh "Age" gender_hoh "Male"
			   readwrite_hoh "Able to read and write"
			   noclasspassed_hoh "No formal education"
			   primaryeduc_hoh "Primary (classes 1-5)"
			   secondaryeduc_hoh "Secondary (classes 8-13)"
			   higheduc_hoh "Graduate/postgraduate/vocational/industrial");
#delimit cr	   

			   

			   


eststo clear


* --------- part c --------- 

* level level regression

reghdfe hhinc_topcoded i.treated, absorb(pair_id) cluster(group_id)
eststo base


* --------- part d --------- 

* log level regression 
gen log_hhinc_topcoded = log(hhinc_topcoded)


reghdfe log_hhinc_topcoded i.treated, absorb(pair_id) cluster(group_id)

eststo log_outcome



* --------- part e --------- 

* log level regressoin with controls
#delimit ;
reghdfe log_hhinc_topcoded i.treated
		i.gender_hoh
		c.age_hoh
		i.readwrite_hoh
		i.educ_cat
		c.hhnomembers_above18
		c.hhnomembers_below18
		i.hhreg_muslim i.hhreg_christian
		i.caste
		, absorb(pair_id) cluster(group_id);
#delimit cr

eststo with_controls



#delimit ;
esttab base log_outcome with_controls using "tables/table03_regression.tex",
	replace
	label
	mtitles("Income (Rs.)" "Log income" "Log income (with controls)")
	nonumbers
	drop(0.gender_hoh 0.readwrite_hoh 0.educ_cat 1.caste 0.hhreg_christian 0.hhreg_muslim 0.treated)
	coeflabels(1.treated "Treated"
			   1.gender_hoh "Household head is male"
			   age_hoh "Age of household head"
			   1.readwrite_hoh "Household head can read and write"
			   1.educ_cat "Primary"
			   2.educ_cat "Secondary"
			   3.educ_cat "Higher"
			   2.caste "Backward caste"
			   3.caste "Most backward caste"
			   4.caste "Scheduled caste/tribe"
			   1.hhreg_christian "Christian household"
			   1.hhreg_muslim "Muslim household")

	refcat(1.gender_hoh "\textbf{Household head characteristics}"
		   1.educ_cat "\textbf{Highest education of head of household} \\ (no formal education omitted)"
		   hhnomembers_above18 "\textbf{Household characteristics}"
		   2.caste "\textbf{Household caste} \\ (Forward caste omitted)", nolabel);
#delimit cr





* --------- part f --------- 

xtile income_quartile=hhinc, n(4)
label define incq_lbl 1 "Q1 (Poorest)" 2 "Q2" 3 "Q3" 4 "Q4 (Richest)"
label values income_quartile incq_lbl
label var income_quartile "Household income quartiles"


statsby, by(income_quartile treated) clear: ci mean total_borrowed

levelsof(income_quartile), local(incq_levels)

foreach i in `incq_levels' {
	
	sum mean if income_quartile==`i' & treated==1
	
	local treated_outcometxt`i' = r(mean)+3300
	
	sum mean if income_quartile==`i' & treated==0
	
	local control_outcometxt`i' = r(mean)+3300
	
}

#delimit ;
twoway bar mean income_quartile if treated==1 || 
	   rcap lb ub income_quartile if treated==1 ||
	   (scatter mean income_quartile if treated==1, mcolor(red)),
	   legend(off)
	   xlabel(, valuelabel nogrid)
	   title("Treated group")
	   ytitle("Average total borrowed (₹)")
	   name(treated, replace)
	   text( `treated_outcometxt1' 1.25  "`=string(`treated_outcometxt1', "%15.0fc")'₹", size(small))
	   text( `treated_outcometxt2' 2.25  "`=string(`treated_outcometxt2', "%15.0fc")'₹", size(small))
	   text( `treated_outcometxt3' 3.25  "`=string(`treated_outcometxt3', "%15.0fc")'₹", size(small))
	   text( `treated_outcometxt4' 4.25  "`=string(`treated_outcometxt4', "%15.0fc")'₹", size(small));

twoway bar mean income_quartile if treated==0 || rcap lb ub income_quartile if treated==0  ||
	(scatter mean income_quartile if treated==0, mcolor(red)), 
	legend(off)
	xlabel(, valuelabel nogrid)
	title("Control group")
	ytitle("Average total borrowed (₹)")
	name(control, replace)
	text( `control_outcometxt1' 1.25  "`=string(`control_outcometxt1', "%15.0fc")'₹", size(small))
    text( `control_outcometxt2' 2.25 "`=string(`control_outcometxt2', "%15.0fc")'₹", size(small))
    text( `control_outcometxt3' 3.25  "`=string(`control_outcometxt3', "%15.0fc")'₹", size(small))
    text( `control_outcometxt4' 4.25  "`=string(`control_outcometxt4', "%15.0fc")'₹", size(small));
#delimit cr


graph combine treated control, ycommon xsize(9)


graph export "figures/figure03_loansbar.png", as(png) replace
