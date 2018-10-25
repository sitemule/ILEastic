**FREE

///
// Chunked Data Example
//
// This example show how to output data in chunks instead of building the
// whole response in memory.
// 
// The demo customer file (QIWS/QCUSTCDT) is written to the response as 
// plain text. The data is accessed via embedded SQL.
//
// Start it:
// SBMJOB CMD(CALL PGM(DATACHUNKS)) JOB(ILEASTIC3) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)
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

    dcl-c CRLF x'0D25';
    dcl-c DELIMITER ';';
    dcl-s abnormallyEnded ind;
    dcl-ds record qualified;
      id packed(6:0);
      name char(8);
      street char(13);
      city char(6);
      state char(2);
      zipcode packed(5:0);
    end-ds;
    
    response.status = 200;
    response.contentType = 'text/plain';
    
    exec sql DECLARE c1 CURSOR FOR
             SELECT cusnum, lstnam, street, city, state, zipcod
             FROM QIWS/QCUSTCDT
             ORDER BY cusnum;
    exec sql OPEN c1;
    exec sql FETCH c1 INTO :record;
    if (sqlcode < 0);
        response.status = 500;
        il_responseWrite(response : 'Error retrieving customer data.');
        return;
    endif;
    
    dow (sqlcode = 0);
        il_responseWrite(
            response : 
            %char(record.id) + DELIMITER +
            %trimr(record.name) + DELIMITER +
            %trimr(record.street) + DELIMITER +
            %trimr(record.city) + DELIMITER +
            %trimr(record.state) + DELIMITER +
            %char(record.zipcode) + CRLF);
    
        exec sql FETCH c1 INTO :record;
    enddo;
    
    on-exit abnormallyEnded;
       exec sql CLOSE c1;
end-proc;
