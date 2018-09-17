**FREE

// -----------------------------------------------------------------------------
// This example runs a simple servlet using ILEastic framework
// Note: It requires your RPG code to be reentrant and compiled
// for multithreading. Each client request is handled by a seperate thread.
// Start it:
// SBMJOB CMD(CALL PGM(DEMO01)) JOB(ILEASTIC1) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)        
// -----------------------------------------------------------------------------     
ctl-opt copyright('Sitemule.com  (C), 2018');
ctl-opt decEdit('0,') datEdit(*YMD.) main(main);
ctl-opt debug(*yes) bndDir('ILEASTIC':'NOXDB');
ctl-opt thread(*CONCURRENT);
/include ./headers/ILEastic.rpgle
// -----------------------------------------------------------------------------
// Main
// -----------------------------------------------------------------------------     
dcl-proc main;

    dcl-ds config likeds(il_config);

    config.port = 44001; 
    config.host = '*ANY';

    il_listen (config : %paddr(myservlet));

end-proc;
// -----------------------------------------------------------------------------
// Servlet call back implementation
// -----------------------------------------------------------------------------     
dcl-proc myservlet;

    dcl-pi *n;
        request  likeds(il_request);
        response likeds(il_response);
    end-pi;

    dcl-s file varchar(256);
    dcl-s err  ind;

    // Get the resource a.k.a. the file name 
    file = il_getRequestResource(request);

    // add route for IFS:
    file = '/www/ext-6.0.0/build/examples/admin-dashboard' + file;

    // No resource then default to: index.html
    if %subst(file:%len(file):1) = '/';  // terminates at a / 
        file += 'index.html';
    endif; 

    // Serve any static files from the IFS
    err = il_serveStatic (response : file);
    if err;
        response.status = 404;
        il_responseWrite(response:'File ' + file + ' not found');
    endif;

end-proc;
