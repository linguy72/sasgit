title "MSRP Distribution Chart";
proc sgplot data=sashelp.cars;
histogram msrp;
density msrp;
run;

title "print title";
proc print data=sashelp.class;
run;
