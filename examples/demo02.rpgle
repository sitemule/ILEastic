        // -----------------------------------------------------------------------------
        // This example runs a simple servlet using ILEastic framework
        // Note: It requires your RPG code to be reentrant and compiled
        // for multithreading. Each client request is handled by a seperate thread.
        // Start it:
        // SBMJOB CMD(CALL PGM(DEMO01)) JOB(ILEASTIC1) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)        
        // -----------------------------------------------------------------------------     
        ctl-opt copyright('Sitemule.com  (C), 2018');
        ctl-opt decEdit('0,') datEdit(*YMD.) main(main);
        ctl-opt debug(*yes) bndDir('ILEASTIC/ILEASTIC');
        ctl-opt thread(*CONCURRENT);
        
        /include headers/ileastic.rpgle
        
        // -----------------------------------------------------------------------------
        // Main
        // -----------------------------------------------------------------------------     
        dcl-proc main;

            dcl-ds config likeds(il_config);

            config.port = 44002; 
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
  
            dcl-s counter int(10);

            for counter = 1 to 1000;
                il_responseWrite(response: 'counter : ' + %char(counter) + ' ');
            endfor;

        end-proc;
