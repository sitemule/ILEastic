**FREE

///
// Multiple Routes Example
//
// This example shows how to add multiple end points with differnt URLs.
//
// Here we add one end point /time which returns the current time and one end 
// point /date which returns the current date.
//
// Start it:
// SBMJOB CMD(CALL PGM(QUERYSTR)) JOB(ILEASTIC6) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)        
//
// The web service can be tested with the browser by entering the following URL:
// http://my_ibm_i:44001/date and respectively http://my_ibm_i:44001/time
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
    
    config.port = 44001; 
    config.host = '*ANY';

    // The resource paths must be entered as a regular expression.
    //
    // ^ means that a matching request must start here
    // $ means that a matching request must end here
    //
    // This means that a request for /timestamp or /api/date will
    // not be routed to one of these end points and will return 404 NOT FOUND.
    il_addRoute(config : %paddr(getTime) : IL_ANY : '^/time$');
    il_addRoute(config : %paddr(getDate) : IL_ANY : '^/date$');
  
    il_listen(config);
 
end-proc;

// -----------------------------------------------------------------------------
// Servlet callback implementation
// -----------------------------------------------------------------------------     
dcl-proc getTime;

    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;
    
    il_responseWrite(response : %char(%time()));
end-proc;

dcl-proc getDate;

    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;
    
    il_responseWrite(response : %char(%date()));
end-proc;

