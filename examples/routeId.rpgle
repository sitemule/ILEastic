**FREE

///
// Route Id Example
//
// This example shows how to add a route id to a route and how to query the route
// id in a plugin.
//
// Start it:
// ADDLIBLE ILEASTIC
// SBMJOB CMD(CALL PGM(ROUTEID)) JOB(ILEASTIC1) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)        
// 
// The web service can be tested with the browser by entering the following URL:
// http://my_ibm_i:44000
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
// Program Entry Points-------------------------     
dcl-proc main;

    dcl-ds config likeds(il_config);
    
    config.port = 44000; 
    config.host = '*ANY';

    il_addPlugin(config : %paddr(logRouteId) : IL_PREREQUEST);

    il_addRoute(config : %paddr(ping) : IL_GET : '/ping');
    il_addRoute(config : %paddr(sayHello) : IL_GET : '/api/hello' : *omit : 'hello');

    // Starts the server.
    il_listen(config);
end-proc;

// -----------------------------------------------------------------------------
// Servlet callback implementation
// -----------------------------------------------------------------------------     
dcl-proc ping;
    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;
  
    response.contentType = 'text/plain';
    il_responseWrite(response : 'Ping: ' + %char(%timestamp()));
end-proc;


dcl-proc sayHello export;
    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;
  
    response.contentType = 'text/plain';
    il_responseWrite(response : 'Hello');
end-proc;


dcl-proc logRouteId export;
    dcl-pi *n ind;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;
  
    if (request.routeId = *blank);
        il_joblog('No route id.');
    else;
        il_joblog('Route id: %s' : request.routeId);
    endif;
  
    return *on;
end-proc;
