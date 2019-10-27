**FREE

///
// Integration to noxDB - Note it requires the NOXDB installed
//
//
// Start it:
// ADDLIBLE ILEASTIC
// SBMJOB CMD(CALL PGM(NOXDBCUST)) JOB(NOXDBCUST) JOBQ(QSYSNOMAX)  ALWMLTTHD(*YES)        
// 
// The web service can be tested with the browser by entering the following URL:
// http://my_ibm_i:44001/index.html
//
// @info: It requires your RPG code to be reentrant and compiled for 
//        multithreading. Each client request is handled by a seperate thread.
///
   
ctl-opt copyright('Sitemule.com  (C), 2018');
ctl-opt decEdit('0,') datEdit(*YMD.) ;
ctl-opt debug(*yes) bndDir('ILEASTIC':'NOXDB');
ctl-opt thread(*CONCURRENT);
ctl-opt main(main);


/include ./headers/ILEastic.rpgle
/include ./noxdb/headers/jsonParser.rpgle

// -----------------------------------------------------------------------------
// Program Entry Point
// -----------------------------------------------------------------------------     
dcl-proc main;

    dcl-ds config likeds(IL_CONFIG);
    config.port = 44001; 
    config.host = '*ANY';

    il_listen (config : %paddr(customerList));
 
end-proc;

// -----------------------------------------------------------------------------
// Servlet callback implementation
// -----------------------------------------------------------------------------     
dcl-proc customerList;

    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;

    dcl-s pResult pointer;

    // Assume everything is OK
    response.status = 200;
    response.contentType = 'application/json';

    // Use noxDB to produce a JSON resultset to return
    pResult = json_sqlResultSet ('-
        select *                  -
        FROM QIWS/QCUSTCDT        -
    ');

    // Use the stream to input data from noxdb and output it to ILEastic 
    il_responseWriteStream(response : json_stream( pResult));


end-proc;
