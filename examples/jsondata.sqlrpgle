**FREE

///
// Chunked Data Example
//
// This example show how to output data in chunks instead of building the
// whole response in memory.
// 
// The demo customer file (QIWS/QCUSTCDT) is written to the response as 
// json. The data is accessed via embedded SQL.
// The main feature is to show that CLOB and BLOB are directly supported in ILEastic
// making it easy to integrateILEastic and SQL. An even better solution is
// to use noxDB which is 100% dynamic 
//
// Start it:
// SBMJOB CMD(CALL PGM(JSONDATA)) JOB(JSONDATA) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)
// 
// The web service can be tested with the browser by entering the following URL:
// http://my_ibm_i:44001
//
// @info: It requires your RPG code to be reentrant and compiled for 
//        multithreading. Each client request is handled by a seperate thread.
///

ctl-opt copyright('Sitemule.com  (C), 2018');
ctl-opt decEdit('0,') datEdit(*YMD.) main(main);
ctl-opt debug(*yes) bndDir('ILEASTIC');
ctl-opt thread(*CONCURRENT);

/include ./headers/ILEastic.rpgle


// -----------------------------------------------------------------------------
// Program Entry Point
// -----------------------------------------------------------------------------     
dcl-proc main;

    dcl-ds config likeds(il_config);

    config.port = 44001; 
    config.host = '*ANY';

    il_listen (config : %paddr(listCustomers));

end-proc;

// -----------------------------------------------------------------------------
// Servlet call back implementation
// -----------------------------------------------------------------------------     
dcl-proc listCustomers;

    dcl-pi *n;
        request  likeds(il_request);
        response likeds(il_response);
    end-pi;

    dcl-s result varchar(10000); // ccsid(*UTF8);
    
    
    response.status = 200;
    response.contentType = 'application/json';

    exec sql 
        SELECT json_arrayagg(
            json_object (
                'id' value cusnum, 
                'lastName' value lstnam, 
                'street' value street, 
                'city' value city, 
                'state' value state, 
                'zipCode' value zipcod
            )
        )
        INTO :result
        FROM QIWS/QCUSTCDT;
    
    if (sqlcode < 0);
        response.status = 500;
        il_responseWrite(response : 'Error retrieving customer data.');
        return;
    endif;
    
    il_responseWrite( response : result);
    
end-proc;
