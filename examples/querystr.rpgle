**FREE

///
// Query String Example
//
// This example shows how to get a values from the query string part of the 
// request URL.
//
// In this case the web service expects the caller to pass the client id as a 
// query string value and it should also be a number else an error message is
// returned.
//
// Start it:
// SBMJOB CMD(CALL PGM(QUERYSTR)) JOB(ILEASTIC5) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)        
//
// The web service can be tested with the browser by entering the following URL:
// http://my_ibm_i:44001?client=12
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
    
    dcl-s value char(10);
    dcl-s client int(10);
    
    // Get the client id from the query string. It should have been passed like
    // this: http://my_ibm_i:44001?client=123
    value = il_getParmStr(request : 'client');
    
    // Check if the client id is a valid value
    monitor;
      
      client = %int(value);
      
      // Everything is ok => return message to caller
      il_responseWrite(response : 'You passed the client id ' + %char(client));
      
    on-error *all;
      // Else return an error code to the caller: 400 - BAD REQUEST
      response.status = 400;
      il_responseWrite(response : 'Invalid client id passed. Client id: ' + %trim(value));
    endmon;
end-proc;
