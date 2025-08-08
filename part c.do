* table 1: endline raw data summary statistics

estpost tabstat hhinc totformalborrow_24 totinformalborrow_24 income_net_debt hhnomembers hhinc_pc hhinc_pc_daily, stats(mean sd p1 p50 p99 max) columns (statistics)



#delimit ; 
esttab using "tables/table01_summary.tex", 
	replace
	cells("mean(fmt(%15.2fc)) sd(fmt(%15.2fc)) p1(fmt(%15.0fc)) p50(fmt(%15.0fc)) p99(fmt(%15.0fc)) max(fmt(%15.0fc))")
	collabels("Mean" "SD" "1st pctl." "Median" "99th pctl." "Max")
	nonumber
	coeflabels(hhinc "Household income in last 30 days (Rs)" 
			   totformalborrow_24 "Total formal loans in last 24 mo. (Rs)"
			   totinformalborrow_24 "Total informal loans in last 24 mo. (Rs)"
			   income_net_debt "24-month income estimate minus total loans (Rs)"
			   hhnomembers "Number of household members"
			   hhinc_pc "Household income per capita in last 30 days (Rs)"
			   hhinc_pc_daily "Daily household income per capita, last 30 days (Rs)")
	note("24-month income is estimated by 24*household income in last 30 days.");
#delimit cr



* figure 1: distribution and composition of household income in last 30 days

preserve

keep if hhinc<85000

#delimit ;
kdensity hhinc, 
	title("A: Distribution of household income")
	xtitle("Housheold income in last 30 days (Rs.)")
	ytitle("Density")
	name(a, replace) ;


twoway (lpoly hhinc hhnomembers, legend(label(1 "Total household income (last 30 days)")))
	   (lpoly hhinc_pc hhnomembers, legend(label(2 "Per-capita income (last 30 days)"))),
	   ylabel(0(2500)20000)
	   legend(position(5) ring(1) cols(1))
	   title("B: Household income by household size")
	   xtitle("Number of household members")
	   ytitle("Income in last 30 days (Rs.)")
	   name(b, replace);
#delimit cr	   

restore
	
	
graph combine a b, cols(2) iscale(0.75) note("Household income in last 30 days truncated at 99th percentile  (₹85,000 Rs.) to reduce distortion from extreme outliers.")

graph export "figures/figure01_hhinc.png", as(png) replace


* figure 2:  distribution of total borrowing (loans) in last 24 months

#delimit ;
twoway (kdensity totformalborrow_24 if totformalborrow_24<=250000, legend(label(1 "Total formal borrowed amount"))) 
       (kdensity totinformalborrow_24 if totinformalborrow_24<=200000, legend(label(2 "Total informal borrowed amount"))), 
       legend(cols(1) position(6))
       xtitle("Amount borrowed in past 24 months (Rs., truncated at )")
       ytitle("Density", placement(outside))
       note("Distributions truncated at 95th percentiles - ₹250,000 (formal) and ₹200,000 (informal)")
	   title("B: Distribution of formal and informal borrowing")
       name(c, replace);

hist income_net_debt if income_net_debt<1813000,
	xtitle("24-month income estimate minus total loans (Rs)")
	name(d, replace)
	note("Distributions truncated at 99th percentile - ₹1,813,000. 24 month income estimated as 24*last 30 days income.")
	title("A: Distribution of income net debt estimate");
#delimit cr

graph combine d c, cols(2) xsize(11)

graph export "figures/figure02_loandistribution.png", as(png) replace
