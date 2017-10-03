libname ses2 "U:/Documents/sasSession2/";
*filename session2 "U:/Documents/sasSession2/"; *comment faire ?;
data ses2.dose;
*infile "session2/dose_patients.csv";
length identifiant 5 statut $10 biomarqueur 3 dose 8; /* Longueur d'un numérique est obligatoirement entre 3 et 8 ! */
infile "U:/Documents/sasSession2/dose_patients.csv" firstobs=2 DLM=";";
input identifiant statut$ biomarqueur dose;
run;

proc contents data=ses2.dose;
run;

proc print data=ses2.dose noobs;
format /*identifiant . statut$ biomarqueur .*/ dose 10.1;
run; 

proc sort data=ses2.dose out=ses2.doseTriE;
	by statut descending dose; /* Ici "descending" est pour la variable "dose" !! Toujours devant. */ 
run;

proc sort data=ses2.dose;
	by statut dose;
run;

proc delete data=ses2.dosetrie (gennum=all);
run;

/* 5) */
proc import datafile = "U:/Documents/sasSession2/info_patient.txt"
	out = ses2.info
	dbms=dlm
	relace; delimiter = '09'x;
run;

proc sort data = ses2.dose; by identifiant; run;
proc sort data = ses2.info; by id_patient; run;

data out;
	merge ses2.dose ses2.info (rename=(id_patient=identifiant));
		by identifiant;
run;

/* proc SQL écriture possible avec join...on : */
proc sql;
	title "Table croisée avec l'instruction SQL";
	create table Out3 as 
	select * from
	ses2.dose as table1 join ses2.info as table2 on table1.identifiant = table2.id_patient;
	/*out = Out2*/ /* C'est pas out, c'est create qui se trouve avant select. */
run;

/* proc SQL écriture possible avec select from where : */
proc sql;
	title "Table croisée avec l'instruction SQL";
	create table Out2 as 
	select * from
	ses2.dose, ses2.info where identifiant = id_patient;
	/*out = Out2*/ /* C'est pas out, c'est create qui se trouve avant select. */
run;
/* Avantage : pas besoin de trier les tables en avance */

proc transpose data = Out2 out = patient_t prefix = Dose_Bmq; /* Sans mettre prefix=, SAS va nommer les colonnes par défaut Col_. */
	var dose;
	by identifiant statut age sexe fumeur;
	id biomarqueur; /* Tout ce qu'on indique ici va apparaitre tel quel aux noms des colonnes. */
run;

/* 8) et 9) à faire plus tard. */

/* 10) */
title; /* Nettoyer le titre saisi */
/* table de fréquence */
proc freq data=Out2;
	table sexe statut*fumeur; /* C'eset bien "table" qui fait la table de fréquence ! */ /* "table" ou "tables" c'est pas important. */
run;

/* Table de contingence 2*2 */
proc freq data=Out2 order=data;
   *format ;
   tables statut*fumeur / chisq relrisk;
   exact pchi or;
   *weight Count;
   title 'Table de Contingence Statut et Fumeur';
run;
title;

/* 11) */
/* proc means + by pour résumer par sous-groupe ! */
proc sort data=ses2.info;
	by sexe;
run;

proc means data=ses2.info; 
	by sexe;
run;
proc means data=ses2.info;
	by sexe;
	where age >= 40;
run;

proc sort data=ses2.dose;
	by biomarqueur statut;
run;
proc means data=ses2.dose; 
	by biomarqueur statut;
run;

/* fin de proc means */
