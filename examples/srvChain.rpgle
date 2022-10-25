**FREE

///
// Integration to noxDB - Note it requires the NOXDB installed
// You need to run the SQL scripts in "demo.sql" by ACS to have the test data
//
//
// Start it:
// ADDLIBLE ILEASTIC
// SBMJOB CMD(CALL PGM(SRVCHAIN)) JOB(SRVCHAIN) JOBQ(QSYSNOMAX)  ALWMLTTHD(*YES)        
// 
// The web service can be tested with the browser by entering the following URL:
// http://my_ibm_i:44008/OptionsInfo
// http://my_ibm_i:44008/ServicesInfo
//
// @info: It requires your RPG code to be reentrant and compiled for 
//        multithreading. Each client request is handled by a seperate thread.
///
   
ctl-opt copyright('Sitemule.com  (C), 2022');
ctl-opt decEdit('0,') datEdit(*YMD.) ;
ctl-opt debug(*yes) bndDir('ILEASTIC':'NOXDB');
ctl-opt thread(*CONCURRENT);
ctl-opt main(main);


/include ./headers/ILEastic.rpgle
/include ./noxdb/headers/jsonParser.rpgle
/include ./plugins/jwt/jwt_h.rpgle
/include ./plugins/jwt/jwtplugin_h.rpgle


// -----------------------------------------------------------------------------
// Program Entry Point
// -----------------------------------------------------------------------------     
dcl-proc main;

    dcl-ds config likeds(IL_CONFIG);
    config.port = 44008; 
    config.host = '*ANY';

    // Sets the key which will be used for verifying the JWT token.
    // This key should be kept secure (and not like this =) )!!!
    //il_jwt_setSignKey('eW91ci0yNTYtYml0LXNlY3JldA======');
    
    // Adds the JWT plugin to the chain of plugins
    // This will only check if each request has a valid JWT token.
    // It does not check if the requester is authorized to use this service!
    // It puts the payload of the JWT token in the thread local storage at
    // /ileastic/jwt/payload where it can be retrieve by any other plugin or 
    // servlet in this thread.
    //
    // The plugin will expect to have a HTTP header like
    // Authorization: Bearer <my_token>
    //il_addPlugin(config : %paddr('il_jwt_filter') : IL_PREREQUEST);


    // The request end point is an regular expression: 
    // ^ means that a matching request must start here
    // $ means that a matching request must end here
    //
    // This means that if you have a match this routing code will 
    // call the procedure assigned to the endpoint. All other 
    // end points will return 404 NOT FOUND.
    il_addRoute(config : %paddr(OptionsInfo)    : IL_ANY : 'OptionsInfo');
    il_addRoute(config : %paddr(ServicesInfo)   : IL_ANY : 'ServicesInfo');
  
    il_listen(config);

end-proc;

// -----------------------------------------------------------------------------
// Servlet callback implementation
// -----------------------------------------------------------------------------     
dcl-proc OptionsInfo;

    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;

    dcl-s pResult pointer;
    dcl-s pInput  pointer;
    dcl-s p       pointer;
    dcl-s payload varchar(32000);


    // Parse input from JSON - Note: il_getRequestContent returns UTF-8 whear as json_parseString need current CCSID
    payload = il_getRequestContent(request);
    pInput = json_parseString(payload);

    // Assume everything is OK
    response.status = 200;
    response.contentType = 'application/json';

    // Do we have the 'ServicesInfo' as aparameter the call our self in a new thread.
    if json_getStr(pInput:'query') = 'ServicesInfo' ; 
        pResult = json_httprequest ( 'http://127.0.0.1:44008/ServicesInfo' : pInput  );
        il_responseWriteStream(response : json_stream( pResult));

    else;
        pResult = json_newObject();
        json_setStr (pResult : 'messages' : 
            'If you provide a JWT You can query the servies available with /OptionsInfo and a "search"');
        json_setStr (pResult : 'query' : json_getStr(pInput:'query'));
        
        il_responseWriteStream(response : json_stream( pResult));
    endif; 

    json_delete (pResult);
    json_delete (pInput);


end-proc;
// -----------------------------------------------------------------------------
// Servlet callback implementation
// -----------------------------------------------------------------------------     
dcl-proc ServicesInfo;

    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;

    dcl-s pResult pointer;
    dcl-s pInput  pointer;
    dcl-s search  varchar(32);
    dcl-s payload varchar(32000);


    // Parse input from JSON - Note: il_getRequestContent returns UTF-8 whear as json_parseString need current CCSID
    payload = il_getRequestContent(request);
    pInput = json_parseString(payload);

    // Assume everything is OK
    response.status = 200;
    response.contentType = 'application/json';

    // Pick the "search from the quesy object - need check for injections
    search = json_getStr( pInput : 'search');

    // Use noxDB to produce a JSON resultset to return
    pResult = json_sqlResultSet ('-
        select * from qsys2.services_info  -
        where service_name like upper(''%' + search + '%'')' 
    );

    // Use the stream to input data from noxdb and output it to ILEastic 
    il_responseWriteStream(response : json_stream( pResult));
    json_delete (pResult);


end-proc;

