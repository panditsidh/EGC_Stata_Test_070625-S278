


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
label var primaryeduc_hoh "Head of Household: primary highest education"

gen secondaryeduc_hoh = inrange(educyears_hoh, 8, 14)
label var secondaryeduc_hoh "Head of Household: secondary highest education level"

estpost ttest gender_hoh age_hoh readwrite_hoh-primaryeduc_hoh, by(treated)

#delimit ; 
esttab,
	replace
	star(* 0.1 ** 0.05 *** 0.01)
	cells("mu_1 mu_2 b(star) se(par) count")
	nonumber
	label
	collabels("Control" "Treated" "Difference" "SE" "N");
