title "MSRP Distribution Chart";
proc sgplot data=sashelp.cars;
histogram msrp / fillattrs=(color=red);
density msrp / lineattrs=(color=blue);
run;

title "listing of class";
proc print data=sashelp.class;
run;

title "means of class";
proc means data=sashelp.class;
run;