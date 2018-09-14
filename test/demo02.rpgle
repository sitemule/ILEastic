        // -----------------------------------------------------------------------------
        // This example runs a simple servlet using ILEastic framework
        // Note: It requires your RPG code to be reentrant and compiled
        // for multithreading. Each client request is handled by a seperate thread.
        // Start it:
        // SBMJOB CMD(CALL PGM(DEMO02)) JOB(ILEASTIC2) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)        
        // -----------------------------------------------------------------------------     
        ctl-opt copyright('Sitemule.com  (C), 2018');
        ctl-opt decEdit('0,') datEdit(*YMD.) main(main);
        ctl-opt debug(*yes) bndDir('ILEASTIC');
        ctl-opt thread(*CONCURRENT);
        
        /include ./headers/ILEastic.rpgle
        
        // -----------------------------------------------------------------------------
        // Main
        // -----------------------------------------------------------------------------     
        dcl-proc main;

            dcl-ds config likeds(configDS);

            config.port = 44002; 
            config.host = '*ANY';

            il_listen (config : %paddr(myservlet));

        end-proc;
        // -----------------------------------------------------------------------------
        // Servlet call back implementation
        // -----------------------------------------------------------------------------     
        dcl-proc myservlet;

            dcl-pi *n;
                request  likeds(REQUESTDS);
                response likeds(RESPONSEDS);
            end-pi;
  
            dcl-s counter int(10);
            dcl-s payload varchar(4096:4);
            dcl-s contentType varchar(256);
            

            // test payload:
            payload     = il_getContent(request);
            contentType = il_getRequestHeader(request : 'content-type');


            for counter = 1 to 10;
                il_responseWrite(response: 'counter : ' + %char(counter) + ' ');
            endfor;

        end-proc;
