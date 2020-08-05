**FREE

///
// Plugin Example
//
// This example shows how to add a plugin to the server which gets called before
// any request is routed to the end point (servlet).
//
// Every request which doesn't contain the query parameter "client" will be 
// rejected. The filter itself sends the response message to the caller if the
// request is invalid.
//
// Start it:
// SBMJOB CMD(CALL PGM(QUERYSTR)) JOB(ILEASTIC7) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)        
//
// The web service can be tested with the browser by entering the following URL:
// http://my_ibm_i:44001?client=123 and respectively without the query string 
// value http://my_ibm_i:44001.
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

    // add a plugin to the server which will be executed before the request is
    // processed by the servlet
    il_addPlugin(config : %paddr(clientFilter) : IL_PREREQUEST);

    il_listen(config : %paddr(myservlet));
 
end-proc;

// -----------------------------------------------------------------------------
// Servlet callback implementation
// -----------------------------------------------------------------------------     
dcl-proc myservlet;
    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;
    
    il_responseWrite(response : %char(%time()));
end-proc;


///
// Client Plugin
//
// This plugin filters requests and rejects those without the client query string 
// value.
//
// @param Request
// @param Response
// @return *on = the request is valid and can be passed to the next plugin/servlet
//         else *off
///
dcl-proc clientFilter;
    dcl-pi *n ind;
      request  likeds(IL_REQUEST);
      response likeds(IL_RESPONSE);
    end-pi;

    dcl-s cClient char(10);
    dcl-s client int(10);
    dcl-s validRequest ind inz(*off);
    
    // Get the client id from the query string. It should have been passed like
    // this: http://my_ibm_i:44001?client=123
    cClient = il_getParmStr(request : 'client');
    
    // Check if the client id is a valid value
    monitor;
      
      client = %int(cClient);
      
      // Everything is ok => request can be passed to the next plugin and/or 
      // routed to the servlet
      validRequest = *on;
      
    on-error *all;
      // Else return an error code to the caller: 400 - BAD REQUEST
      response.status = 400;
      response.statusText = 'BAD REQUEST';
      il_responseWrite(response : 'Invalid client id passed. Client id: ' + %trim(cClient));
    endmon;    
    
    return validRequest;
end-proc;
