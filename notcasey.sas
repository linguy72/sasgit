title "MSRP Distribution Chart";
proc sgplot data=sashelp.cars;
histogram msrp / fillattrs=(color=red);
density msrp;
run;

title "listing of class4";
proc print data=sashelp.class;
run;
