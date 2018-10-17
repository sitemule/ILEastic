**FREE
// -----------------------------------------------------------------------------
// Yet more advanced, using the router feature
// Note: It requires your RPG code to be reentrant and compiled
// for multithreading. Each client request is handled by a seperate thread.
// Start it:
// SBMJOB CMD(CALL PGM(DEMO00)) JOB(ILEASTIC0) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)        
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
    
    config.port = 44000; 
    config.host = '*ANY';

    il_listen (config : %paddr(myservlet));
 
end-proc;
// -----------------------------------------------------------------------------
// Servlet call back implementation
// -----------------------------------------------------------------------------     
dcl-proc myservlet;

    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;
    
    il_responseWrite(response: 'Hello world. Time is ' + %char(%timestamp));
    
end-proc;

