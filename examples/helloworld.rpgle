**FREE

///
// Hello World Example
//
// This example shows how to create a simple web service which returns a 
// a fixed string (Hello World) and some at runtime created characters (time).
//
// Start it:
// SBMJOB CMD(CALL PGM(HELLOWORLD)) JOB(ILEASTIC1) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)        
// 
// The web service can be tested with the browser by entering the following URL:
// http://my_ibm_i:44001
// 
// @info: It requires your RPG code to be reentrant and compiled for 
//        multithreading. Each client request is handled by a seperate thread.
///

ctl-opt copyright('Sitemule.com  (C), 2018');
ctl-opt decEdit('0,') datEdit(*YMD.) main(main);
ctl-opt debug(*yes) bndDir('ILEASTIC');
ctl-opt thread(*CONCURRENT);

/include ./headers/ileastic.rpgle

// -----------------------------------------------------------------------------
// Program Entry Point
// -----------------------------------------------------------------------------     
dcl-proc main;

    dcl-ds config likeds(il_config);
    
    config.port = 44000; 
    config.host = '*ANY';

    il_listen (config : %paddr(myservlet));
 
end-proc;

// -----------------------------------------------------------------------------
// Servlet callback implementation
// -----------------------------------------------------------------------------     
dcl-proc myservlet;

    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;
    
    // Write the response. The default HTTP status code is 200 - OK so we
    // don't have to set it explicitly.
    il_responseWrite(response: 'Hello world. Time is ' + %char(%timestamp));
    
end-proc;

