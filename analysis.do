


******************************** ANALYSIS ********************************




* --------- part b --------- 


/*
* choose a few baseline household variables for the balance test



educyears is categorical and I can't make it numerical 



- all social groups
- age and gender of head of household
- education of head of household
- vocational educationof head of household



is 




*/







keep if _merge==3

drop _merge


gen primaryeduc_hoh = educyears_hoh==7
label var primaryeduc_hoh "primary"

gen secondaryeduc_hoh = inrange(educyears_hoh, 8, 14)
label var secondaryeduc_hoh "Head of Household: secondary highest education level"

label var hhnomembers_below18 "No of household members \textless{}18yo"



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
