        // -----------------------------------------------------------------------------
        // This example runs a simple servlet using Node.RPG
        // Start it:
        // SBMJOB CMD(CALL PGM(DEMO01)) JOB(NODERPG) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)        
        // ----------------------------------------------------------------------------- */     
        ctl-opt copyright('Sitemule.com  (C), 2018');
        ctl-opt decEdit('0,') datEdit(*YMD.) main(main);
        ctl-opt debug(*yes) bndDir('NODERPG');
        ctl-opt THREAD(*CONCURRENT);
        /include noderpg.inc
        // -----------------------------------------------------------------------------
        // Main
        // ----------------------------------------------------------------------------- */     
        dcl-proc main;

            dcl-ds config likeds(configDS);
            dcl-s  description char(100) ccsid(*utf8);

            config.port = 44998;
            config.host = '*ANY';

            node_listen (config : %paddr(myservlet));

        end-proc;
        // -----------------------------------------------------------------------------
        // Servlet implementation
        // ----------------------------------------------------------------------------- */     
        dcl-proc myservlet;

            dcl-pi *n;
                request  likeds(REQUESTDS);
                response likeds(RESPONSEDS);
            end-pi;
            dcl-s counter int(10);

            for counter = 1 to 1000;
                node_Write(response:'counter : ' + %char(counter) + ' ');
            endfor;

        end-proc;
