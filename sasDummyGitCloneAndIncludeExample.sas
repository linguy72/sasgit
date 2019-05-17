options dlcreatedir;
%let repoPath = %sysfunc(getoption(WORK))/sas-dummy-blog;
libname repo "&repoPath.";
libname repo clear;
 
/* Fetch latest code from GitHub */
data _null_;
 rc = gitfn_clone("https://github.com/sascommunities/sas-dummy-blog/",
   "&repoPath.");
 put rc=;
run;
 
/* run the code in this session */
%include "&repoPath./rng_example_thanos.sas";