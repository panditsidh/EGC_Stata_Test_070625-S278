* To run on your machine, please customize this

if "`c(username)'" == "sidhpandit" {
	
	* please change this to your path to "EGC_Stata_Test_2022" (the starting materials)
	global provided_data "/Users/sidhpandit/Documents/GitHub/EGC_Stata_Test_070625-S278/EGC_Stata_Test_2022"
	
	* please change this to your path to "EGC_Stata_Test_070625-S278" (my project folder)
	cd "/Users/sidhpandit/Documents/GitHub/EGC_Stata_Test_070625-S278" 
	

}


do "dofiles/analysis (part 1).do"


do "dofiles/preparing data (part 2).do"
