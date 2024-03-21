**FREE

///
// Routing to a program adding openAPI ( swagger) 
//
// This example shows how traditional programs compiled with 
//    ctl-opt pgminfo(*PCML:*MODULE) thread(*CONCURRENT);
// can be used with ILEastic, and also serve the openAPI.json ( yet to come)
//
// The routing is shown in swagroute.rpgle
//
// Start it:
// SBMJOB CMD(CALL PGM(SWAGROUTE)) JOB(SWAGROUTE) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)        
//
// The web service can be tested with the browser by entering the following URL:
// http://my_ibm_i:44045/hello?name=john 
//
// @info: It requires your RPG code to be reentrant and compiled for 
//        multithreading. Each client request is handled by a seperate thread.
///
ctl-opt pgminfo(*PCML:*MODULE) thread(*CONCURRENT);
ctl-opt copyright('Sitemule.com  (C), 2023');
ctl-opt decEdit('0,') datEdit(*YMD.);
ctl-opt debug(*yes);

dcl-pi *N;
    name char (10) const;
    text char(200);
end-pi;

text = 'hello ' + name;
return;


