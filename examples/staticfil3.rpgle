**FREE

///
// Integration to noxDB - Note it requires the NOXDB installed
//
//
// Start it:
// SBMJOB CMD(CALL PGM(STATICFIL3)) JOB(STATICFIL3) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)        
// 
// The web service can be tested with the browser by entering the following URL:
// http://my_ibm_i:44012/index.html
//
// @info: It requires your RPG code to be reentrant and compiled for 
//        multithreading. Each client request is handled by a seperate thread.
///
    
ctl-opt copyright('Sitemule.com  (C), 2018-2023');
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
    config.port = 44012;  // Is overridden if envvar I_PORT is set
    config.host = '*ANY'; // Is overridden if envvar I_INTERFACE is set

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

    il_serveStatic (response : '/home/nli/base64json.json');

end-proc;
