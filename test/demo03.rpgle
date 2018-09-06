        // -----------------------------------------------------------------------------
        // This example runs a simple servlet using ILEastic framework
        // Note: It requires your RPG code to be reentrant and compiled
        // for multithreading. Each client request is handled by a seperate thread.
        // Start it:
        // SBMJOB CMD(CALL PGM(DEMO03)) JOB(ILEASTIC3) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)        
        // -----------------------------------------------------------------------------     
        ctl-opt copyright('Sitemule.com (C), 2018');
        ctl-opt decEdit('0,') datEdit(*YMD.) main(main);
        ctl-opt debug(*yes) bndDir('ILEASTIC':'NOXDB');
        ctl-opt thread(*CONCURRENT);

        /include ./headers/ILEastic.rpgle
        /include ./headers/JSONparser.rpgle
        
        
        // -----------------------------------------------------------------------------
        // Main
        // -----------------------------------------------------------------------------     
        dcl-proc main;

            dcl-ds config likeds(configDS);

            config.port = 44003; 
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

            dcl-s pOutput   pointer;

            response.contentType = 'application/json';

            pOutput = json_sqlResultSet(' -
                select * from qiws.QCUSTCDT    -
            ');

            il_responseWriteStream(response : json_stream(pOutput));

            json_delete(pOutput);
            

        end-proc;
