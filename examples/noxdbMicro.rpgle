**FREE

///
// Integration to noxDB - Note it requires the NOXDB installed
// You need to run the SQL scripts in "demo.sql" by ACS to have the test data
//
//
// Start it:
// ADDLIBLE ILEASTIC
// SBMJOB CMD(CALL PGM(NOXDBMICRO)) JOB(NOXDBMICRO) JOBQ(QSYSNOMAX)  ALWMLTTHD(*YES)        
// 
// The web service can be tested with the browser by entering the following URL:
// http://my_ibm_i:44005/getservicesinfo
// http://my_ibm_i:44005/getservicesinfo?search=ptf
// http://my_ibm_i:44005/getservicesinfo?search=obj
// 
// Other examples, that needs the demo database 
// http://my_ibm_i:44005/getuserbyview
// http://my_ibm_i:44005/getuserbyproc
//
// @info: It requires your RPG code to be reentrant and compiled for 
//        multithreading. Each client request is handled by a seperate thread.
///
   
ctl-opt copyright('Sitemule.com  (C), 2018-2022');
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
    config.port = 44005; 
    config.host = '*ANY';

    // The request end point is an regular expression: 
    // ^ means that a matching request must start here
    // $ means that a matching request must end here
    //
    // This means that if you have a match this routing code will 
    // call the procedure assigned to the endpoint. All other 
    // end points will return 404 NOT FOUND.
    il_addRoute(config : %paddr(getServicesInfo) : IL_ANY : 'getservicesinfo');
    il_addRoute(config : %paddr(getUserByView)   : IL_ANY : 'getuserbyview');
    il_addRoute(config : %paddr(getUserByProc)   : IL_ANY : 'getuserbyproc');
    il_addRoute(config : %paddr(hello)           : IL_ANY : 'hello');
    il_addRoute(config : %paddr(huge)            : IL_ANY : 'huge');
  
    il_listen(config);

end-proc;

// -----------------------------------------------------------------------------
// Servlet callback implementation
// -----------------------------------------------------------------------------     
dcl-proc getServicesInfo;

    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;

    dcl-s pResult pointer;
    dcl-s search  varchar(64);


    // Assume everything is OK
    response.status = 200;
    response.contentType = 'application/json';

    search = il_getParmStr(request : 'search');


    // Use noxDB to produce a JSON resultset to return
    pResult = json_sqlResultSet ('-
        select * -
        from qsys2.services_info -
        where service_name like upper(' + strQuot('%' + search + '%') + ')':
        1:                  // Position: Starting from row
        JSON_ALLROWS:       // Limit   : Number of rows to read - here take all
        JSON_META +         // Option  : Produce a result object with a "meta" object   
        //JSON_FIELDS +       // Option  : The "meta" object will contain column atributes 
        JSON_COLUMN_TEXT +  // Option  : the "meta" will also contain the extra text/label info
        JSON_CAMEL_CASE     // Option  : name of the data will be cammel cased
    );

    // Use the stream to input data from noxdb and output it to ILEastic 
    il_responseWriteStream(response : json_stream( pResult));


end-proc;

// -----------------------------------------------------------------------------
// Servlet callback implementation
// -----------------------------------------------------------------------------     
dcl-proc getUserByView;

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
        select name from microdemo.users_full-
    ');

    // Use the stream to input data from noxdb and output it to ILEastic 
    il_responseWriteStream(response : json_stream( pResult));

    json_delete(pResult);


end-proc;
// -----------------------------------------------------------------------------
// Servlet callback implementation
// -----------------------------------------------------------------------------     
dcl-proc getUserByProc;

    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;

    dcl-s pResult pointer;
    dcl-s search  varchar(64);

    // Assume everything is OK
    response.status = 200;
    response.contentType = 'application/json';

    search = il_getParmStr(request : 'search');

    // Use noxDB to produce a JSON resultset to return
    pResult = json_sqlResultSet ('-
        call microdemo.user_list (search => ''' + search + ''') -
    ');

    // Use the stream to input data from noxdb and output it to ILEastic 
    il_responseWriteStream(response : json_stream( pResult));
    json_delete(pResult);



end-proc;
// -----------------------------------------------------------------------------
// Servlet callback implementation
// -----------------------------------------------------------------------------     
dcl-proc hello;

    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;

    dcl-s pResult pointer;
    dcl-s name  varchar(64);

    // Assume everything is OK
    response.status = 200;
    response.contentType = 'text/plain';

    name = il_getParmStr(request : 'name');

   
    // Use the stream to input data from noxdb and output it to ILEastic 
    il_responseWrite (response : 'hello  ' + name);


end-proc;
// -----------------------------------------------------------------------------
// Servlet callback implementation
// Just offload a lots of data;
// -----------------------------------------------------------------------------     
dcl-proc huge;

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
        select * from qsys2.systables -
    ');

    // Use the stream to input data from noxdb and output it to ILEastic 
    il_responseWriteStream(response : json_stream( pResult));

    json_delete(pResult);

end-proc;
// ------------------------------------------------------------------------------------
// strQuot - helper to avoid SQL injections
// ------------------------------------------------------------------------------------
dcl-proc strQuot;

    dcl-pi strQuot varchar(256);
        input varchar(256) const;
    end-pi;
    dcl-c  q '''';

    return q + %scanRpl (q : q+q : input ) + q;

end-proc;
