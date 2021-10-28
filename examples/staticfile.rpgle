**FREE

///
// Integration to noxDB - Note it requires the NOXDB installed
//
//
// Start it:
// SBMJOB CMD(CALL PGM(STATICFILE)) JOB(ILEASTIC2) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)        
// 
// The web service can be tested with the browser by entering the following URL:
// http://my_ibm_i:44001/index.html
//
// @info: It requires your RPG code to be reentrant and compiled for 
//        multithreading. Each client request is handled by a seperate thread.
///
    
ctl-opt copyright('Sitemule.com  (C), 2018');
ctl-opt decEdit('0,') datEdit(*YMD.) ;
ctl-opt debug(*yes) bndDir('ILEASTIC');
ctl-opt thread(*CONCURRENT);
ctl-opt main(main);


/include ./headers/ILEastic.rpgle


// -----------------------------------------------------------------------------
// Program Entry Point
// -----------------------------------------------------------------------------     
dcl-proc main;

    dcl-ds config likeds(IL_CONFIG);
    config.port = 44001; 
    config.host = '*ANY';

    il_listen (config : %paddr(serveStaticFiles));
 
end-proc;

// -----------------------------------------------------------------------------
// Servlet callback implementation
// -----------------------------------------------------------------------------     
dcl-proc serveStaticFiles;

    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;

    dcl-s file varchar(256);
    dcl-c FILE_NOT_FOUND  '1';

    // Get the resource a.k.a. the file name 
    file = il_getRequestResource(request);

    // No resource then default to: index.html
    if (%subst(file:%len(file):1) = '/');  // terminates at a / 
        file += 'index.html';
    endif;

    // You can now concatenate the file to point to 
    // any place on the IFS where your web content are located. i.e.:
    //file = '/www/ext-6.5.0/build/examples/classic/desktop/' + file;
    file = '/www/ext-6.5.0/build/examples/admin-dashboard/' + file;

    // Serve any static files from the IFS
    if (FILE_NOT_FOUND = il_serveStatic (response : file));
        response.status = 404;
        il_responseWrite(response : 'File ' + file + ' not found');
    endif;

end-proc;
