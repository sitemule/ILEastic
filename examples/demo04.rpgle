**FREE
// -----------------------------------------------------------------------------
// Yet more advanced, using the router feature
// Note: It requires your RPG code to be reentrant and compiled
// for multithreading. Each client request is handled by a seperate thread.
// Start it:
// SBMJOB CMD(CALL PGM(DEMO04)) JOB(ILEASTIC4) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)        
// -----------------------------------------------------------------------------     
ctl-opt copyright('Sitemule.com  (C), 2018');
ctl-opt decEdit('0,') datEdit(*YMD.) main(main);
ctl-opt debug(*yes) bndDir('ILEASTIC');
ctl-opt thread(*CONCURRENT);

/include ./headers/ILEastic.rpgle

// -----------------------------------------------------------------------------
// Main, using router
// -----------------------------------------------------------------------------     
dcl-proc main;

    dcl-ds config likeds(il_config);

    config.port = 44004; 
    config.host = '*ANY';

    // Build the list of routes in sequential order
    // Note: it's unsig reg-exp
    il_addRoute  (config : %paddr(myAbout)   : IL_GET + IL_POST : '/about' );
    il_addRoute  (config : %paddr(myFiles)   : IL_ANY            : '/' );
    il_addRoute  (config : %paddr(my404));

    // If the listen dont have a callback, it will run thourgh the 
    // router list from top to bottom
    il_listen    (config );

    // The above will also implement stuff like:
    //il_addRoute  (config : %paddr(myFiles)   : IL_ANY   : '/.(html|png|jpeg)$');
    //il_addRoute  (config : %paddr(myServices): IL_PUT + IL_POST + IL_GET : '^/services/' : '(application/json)|(text/json)');
 
end-proc;
// -----------------------------------------------------------------------------
// Servlet call back implementation
// -----------------------------------------------------------------------------     
dcl-proc myAbout;

    dcl-pi *n ind;
        request  likeds(il_request);
        response likeds(il_response);
    end-pi;

    il_responseWrite(response:'About ILEastic');

    return *ON; // I have handled the request

end-proc;
// -----------------------------------------------------------------------------
// Servlet call back implementation
// -----------------------------------------------------------------------------     
dcl-proc myFiles;

    dcl-pi *n ind;
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
    
    // If i did not serve the file, then bubble the error up in the router
    return err = *OFF; 
    
end-proc;
// -----------------------------------------------------------------------------
// Servlet call back implementation
// -----------------------------------------------------------------------------     
dcl-proc my404;

    dcl-pi *n ind;
        request  likeds(il_request);
        response likeds(il_response);
    end-pi;

    dcl-s file varchar(256);

    response.status = 404;
    file = il_getRequestResource(request);
    il_responseWrite(response:'File ' + file + ' not found');

    return *ON; // I have handled the request

end-proc;
