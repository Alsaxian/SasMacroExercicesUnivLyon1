
libname maalib 'D:\tempxian\';



data maalib.matable;
colonne1 = 1;
run;

data maalib.note1;
length Nom $10;
input Nom$ naissance DDMMYY10. sexe$ Note_Math Note_Physique;
format naissance DDMMYY10.;
card;
Anne_Laure 01/01/1990 F 90 80
Doug 01/02/1993 M 70 60
;
RUN;

proc print data=maalib.note1;
format naissance DDMMYY8.;
Run;


data maalib.note2;
infile "D:\tempxian\note2.csv" firstobs=2 DLM=";";
input Nom$ naissance DDMMYY10. sexe$ Note_Math Note_Physique;


data test;
input idendifiant 1-4 sexe$ 5 salaire 9-13;
cards;
2550F***32000
2214M***45650
2612M***63000
run;

data copie;
set maalib.note1 maalib.note2;  /* important pour concaténer ! */
run;

data maalib.femme;
set copie;
where sexe = "F";
run;

data maalib.homme;
set copie;
if sexe = "M";
run;

data maalib.homme2;
set copie;
if not (sexe = "F");
run;

data maalib.homme3;
set copie;
if sexe = "F" then delete;
run;

data maalib.notaa1 maalib.notaa2;
set copie;
if sexe = "F" & note_math in (10,12,14) then output maalib.notaa1;
else output maalib.notaa2;
run;

data maalib.bonsmoy maalib maalib.mauvaismoy;
set copie;
if mean(note_math, note_physique) >= 10 then output maalib.bonsmoy;
else output maalib.mauvaismoy;
run;

data maalib.bonsmoy2 maalib.mauvaismoy2;
set copie;
if mean(of note_:) >= 12 then output maalib.bonsmoy2;
else output maalib.mauvaismoy2;
run;


data maalib.math;
set copie (drop=note_physique);
run;

data maalib.physique (drop=note_math);
set copie;
run;

data maalib.fus;
merge maalib.physique maalib.math;
run;

data maalib.ajout;
set copie;
moyenne = mean(of note_:);
annee = year(naissance);
run;

data maalib.ajout;
set maalib.ajout;
rename moyenne=moy;
run;

data maalib.ajout;
set maalib.ajout;
if moy >= 10 then
        do;
                admission = "oui";
                rattrapage = "non";
        end;
else
        do;
                admission = "non";
                if moy >= 8 then
                        do;
                                rattrapage = "oui";
                        end;
                else
                        do;
                                rattrapage = "non";
                        end;
        end;
run; /* Il semble que besoin d'utiliser 'do' qu'en cas de plusieurs statements. */


/* 16) */
data maalib.normal noobs;  /* noobs ici est inutile ! A utiliser dans l'étape proc print. */
do i=1 to 1000;
X=2+3*rannor(0);
output;
end;
run;

proc sort data=maalib.ajout;
by annee;
run;

data maalib.somme;
set maalib.ajout;
by annee;
retain cumule;
if first.annee then cumule=note_math;
else cumule=cumule+note_math;
run;

data _null_;
set maalib.ajout;
where nom contains "u";
put nom;
run;


data maalib.somme;
set maalib.ajout;
