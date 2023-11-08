**FREE

///
// Routing to a program adding openAPI ( swagger) 
//
// This example shows how to add multiple end points with differnt URLs.
//
//
// Start it:
// SBMJOB CMD(CALL PGM(SWAGROUTE)) JOB(SWAGROUTE) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)        
//
// The web service can be tested with the browser by entering the following URL:
// http://my_ibm_i:44045/hello 
//
// @info: It requires your RPG code to be reentrant and compiled for 
//        multithreading. Each client request is handled by a seperate thread.
///

ctl-opt copyright('Sitemule.com  (C), 2023');
ctl-opt decEdit('0,') datEdit(*YMD.) main(main);
ctl-opt debug(*yes) bndDir('ILEASTIC':'OPENAPI');
ctl-opt thread(*CONCURRENT);

/include ./headers/ileastic.rpgle
/include ./plugins/openAPI/headers/openAPI.rpgleinc

// -----------------------------------------------------------------------------
// Program Entry Point
// -----------------------------------------------------------------------------     
dcl-proc main;

    dcl-ds config likeds(il_config);
    
    config.port = 44045; 
    config.host = '*ANY';

    // The resource paths must be entered as a regular expression.
    //
    // ^ means that a matching request must start here
    // $ means that a matching request must end here
    //
    // This means that a request for /timestamp or /api/date will
    // not be routed to the end point will return 404 NOT FOUND.
    il_addProgramRoute( config : '*LIBL' : 'HELLOPGM'  : IL_ANY : 'hello');
  
    il_listen(config);
 
end-proc;

