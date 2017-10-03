proc import
	datafile = "U:/Documents/sasSession2/dose_patients.csv"
	out = ses2.dose3
	dbms=csv
	
	replace; delimiter = ";";
run;
