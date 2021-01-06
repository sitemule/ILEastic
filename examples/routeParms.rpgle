**FREE

///
// Multiple Routes Example
//
// This example shows how to add multiple end points with differnt URLs.
//
// Here we add one end point using paramter names in the form {parmName}
// point /date which returns the current date.
//
// Start it:
// SBMJOB CMD(CALL PGM(routeParms)) JOB(ILEASTIC) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES) CCSID(37)        
//
// The web service can be tested with the browser by entering the following URL:
// http://my_ibm_i:44010/simpletest 
// http://my_ibm_i:44010/simpletest/123 
// http://my_ibm_i:44010/simpletest/123/list
// http://my_ibm_i:44010/simpletest/123/list/abc

//
// @info: It requires your RPG code to be reentrant and compiled for 
//        multithreading. Each client request is handled by a seperate thread.
///

ctl-opt copyright('Sitemule.com  (C), 2020');
ctl-opt decEdit('0,') datEdit(*YMD.) main(main);
ctl-opt debug(*yes) bndDir('ILEASTIC');
ctl-opt thread(*CONCURRENT);
ctl-opt ccsid(*CHAR:37);

/include ./headers/ileastic.rpgle

// -----------------------------------------------------------------------------
// Program Entry Point
// -----------------------------------------------------------------------------     
dcl-proc main;

    dcl-ds config likeds(il_config);
    
    config.port = 44010; 
    config.host = '*ANY';

    // The resource paths must be entered as a regular expression.
    //
    // ^ means that a matching request must start here
    // $ means that a matching request must end here
    // Paramter names are in the form {parmName}
    //
    // If none of these endpoints are satified 
    // it will return 404 NOT FOUND.
    il_addRoute(config : %paddr(test1) : IL_ANY : '/simpletest/{myId}/list/{myNumber}$');
    il_addRoute(config : %paddr(test1) : IL_ANY : '/simpletest/{myId}/list$');
    il_addRoute(config : %paddr(test2) : IL_ANY : '/simpletest/{myId}$');
    il_addRoute(config : %paddr(test2) : IL_ANY : '/simpletest$');
  
    il_listen(config);
 
end-proc;

// -----------------------------------------------------------------------------
// Servlet callback implementation
// -----------------------------------------------------------------------------     
dcl-proc test1;

    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;
    
    il_responseWrite(response : 'Test1');
    il_responseWrite(response : ' myId:');
    il_responseWrite(response : il_getPathParameter (request: 'myId' : '000'));
    il_responseWrite(response : ' myNumber:');
    il_responseWrite(response : il_getPathParameter (request: 'myNumber' : '9999'));
end-proc;
dcl-proc test2;

    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;
    
    il_responseWrite(response : 'Test2');
    il_responseWrite(response : ' myId:');
    il_responseWrite(response : il_getPathParameter (request: 'myId' : '000'));
    il_responseWrite(response : ' myNumber:');
    il_responseWrite(response : il_getPathParameter (request: 'myNumber' : '9999'));

end-proc;
