/***********************************************************************
Final SAS Exam by: Carly Hulse 20034006
***********************************************************************/


/***********************************************************************
Question 1 - 2 points
***********************************************************************/
title 'Carly Hulse';

/***********************************************************************
Question 2 - STAT466-18 points, STAT866-23 points
***********************************************************************/
title2 'Question 2';
%let N=2;
%let NumSamples=10000;

    data Normal(keep=SampleID x);
      call streaminit(123);
      do SampleID=1 to &NumSamples; /*number of samples. This is the simulation loop*/
        do j = 1 to &N; /*size of each sample*/
           x = rand('normal'); /*x ~ N(0,1)*/
           output;
         end;
      end;
    run;
          
/*Now we need the statistics for each sample */
proc means data=Normal noprint;
   by SampleID;
   var x;
   output out=OutStats mean=SampleMean lclm=Lower uclm=Upper;
run;          

/*Count the proportion of samples for which the confidence interval contains the value of the parameter*/
/*How many CIs include parameter? */
data OutStats;
label coverage="Parameter in CI";
set OutStats;
coverage=(Lower<0 & Upper>0); /*will give indicator var: recall 0=NO 1=YES*/
run;

/*Get coverage rates/frequency of coverage for 95% CI 
i.e. Nominal coverage probability is 95% so we are estimating the true coverage.*/
proc freq data=OutStats;
   tables coverage / nocum binomial(level='1' p=0.95); 
run;

/***********************************************************************
Question 3 - 27 points
***********************************************************************/
title2 'Question 3';
data maps;
set '/folders/myfolders/STAT466/map.sas7bdat';
run;

*a;
PROC CONTENTS data=maps;
run;

*b;
/* The following in-stream data is delineated by a comma. Two commas in 
a row indicate a missing value. The data should be read into 3 variables 
named Med, Pre and Post. You will need to create a variable named Change 
by subtracting Pre from Post.
*/

data maps2;
infile datalines dlm=',' dsd; /*note by default, consecutive delimiters are not recognized*/
label Med='Treatment' Pre='Pre-treatment MAP (mmHg)' Post='Post-treatment MAP (mmHg)' Change='MAP Change (mmHg)';
input Med $ :30. Pre Post @@;
Change=Post-Pre;
datalines;
Calcium Channel Blocker,108,89,Diuretic,104,79,Diuretic,108,75,Diuretic,105,68,Diuretic,104,89
Calcium Channel Blocker,103,85,Diuretic,109,70,Diuretic,138,86,Calcium Channel Blocker,119,92
Diuretic,120,,Calcium Channel Blocker,111,90,Calcium Channel Blocker,106,71,Diuretic,127,81
Diuretic,100,97,Calcium Channel Blocker,102,72,Diuretic,103,107,Calcium Channel Blocker,102,90
Diuretic,96,86,Calcium Channel Blocker,113,86,Calcium Channel Blocker,109,94
Calcium Channel Blocker,103,81,Diuretic,103,77,Diuretic,124,80,Calcium Channel Blocker,109,83
Diuretic,94,74,Calcium Channel Blocker,100,95,Calcium Channel Blocker,101,86
Calcium Channel Blocker,112,100,Calcium Channel Blocker,124,100,Calcium Channel Blocker,98,88
Diuretic,102,83,Calcium Channel Blocker,116,96,Diuretic,102,110,Diuretic,98,91
Calcium Channel Blocker,126,104,Diuretic,106,78,Diuretic,117,87,Diuretic,109,96
;
run;

*To check that they have the same attributes;
proc contents data=maps2;
run;

*c;
Proc compare
base=maps compare=maps2;
run;

*d;
proc univariate data=maps NORMAL PLOT;
Var Change;
Histogram / normal kernel;
class Med;
run;

/*i. The data does support some assumptions of normality- the distribution plots are 
centered fairly well with the normal plots, however the plots for Change are too wide and short. This indicates 
that we should not be assuming that their distribution is normal. Moreover, we can see that the assumption of normality 
should be disputed by the histogram plot and the qq plots of the Change variable.*/

/*RECALL (for ii): If the p-value associated with the t-test is small (usually set at p < 0.05), 
there is evidence to reject the null hypothesis in favor of the alternative. 
In other words, the mean is statistically significantly different than the hypothesized value. */

/*ii. Since the p-value for the Student's t test, the Sign, and the Signed Rank test for Calcium Channel Blocker 
 are <.0001, and for Diuretic are <.0001, 0.0007, <.0001 respectively, we have evidence that we should reject the 
 null hypothesis. Thus,there does appear to be a statistically signifiance difference in the change between medicines 
 (i.e. yes, there is a significant decrease in blood pressure between either medicines)*/

*e;
Proc ttest data=maps;
var Change;
class med;
run;

/*Which ttest method should we use for this data? Why?
We are using a two-independent-sample t-test, because we have two populations; Calcium Channel Blocker and Diuretic.
We should use the Satterthwaite, or unequal variance, t-test because we should not assume equal variance 
(and we saw from Proc Univariate that the assumption of equal variance would be false)*/

/*Does one medication significantly decrease blood pressure more than the other?
No. The p-value of the Satterthwaite t-test is 0.5049, so is  quite large (much greater than 0.05), thus 
the decease in blood pressure per medications is not statistically significant.*/

*f;
 proc glm data=maps;
      class Med;
      model Change=Pre Med / solution clparm;
      run;
      
/*The p-value for comparing the Change between Med groups after controlling Pre is 0.2612*/
      
*g;
proc tabulate data=maps format=3.0 order=data;
var Pre Post Change;
table (Pre='Baseline MAP' Post='Post-treatment MAP' Change='MAP Change')*(n='N' mean std min max), Med='' / box='MAP in mmHg';
class Med;
run;


/***********************************************************************
Question 4 - 13 points
***********************************************************************/
/*to NOTE: All positional parameters must precede keyword parameters.*/
title 'Question 4';

options symbolgen mlogic;
%MACRO replace(from, to, vars=, data=);
data &data (replace=yes);
input &vars;
if &var=&from then &from=&to;
end;
run;
%MEND replace;

%put MESSAGE: Replacing &from to &to in &data.;

%replace(., 999, vars=Post Change, data=maps);

/*trying to get the datastep to run not in the macro*/
data maps2;
   set maps;
   array switch _numeric_;
        do over switch;
            if switch='.' then switch=999;
        end;
 run ; 
 /*this type of datastep should be wrapped in my macro, where _numeric_ is actually the variables 
 and if=switch=&from then switch=&to*/
 