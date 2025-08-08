* To run on your machine, please customize this

if "`c(username)'" == "" {
	
	* please change this to your path to "EGC_Stata_Test_2022" (the starting materials)
	global provided_data ""
	
	* please change this to your path to "EGC_Stata_Test_070625-S278" (my project folder)
	cd "" 
	

}



log using "logs/log master.log", replace

do "dofiles/preparing data (part 1).do"
do "dofiles/analysis (part 2).do"


log close
