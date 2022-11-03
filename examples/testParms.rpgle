**FREE

/// ------------------------------------------------------------------------------------
// TESTPARMS - REST API Driver
//
// Start it:
// SBMJOB CMD(CALL PGM(TESTPARMS)) JOB(TESTPARMS) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)
//
// @info: It requires your RPG code to be reentrant and compiled for
// multithreading. Each client request is handled by a seperate thread.
/// ------------------------------------------------------------------------------------

ctl-opt decEdit('0,') datEdit(*YMD.) main(main);
ctl-opt debug(*yes) bndDir('ILEASTIC');
ctl-opt thread(*CONCURRENT);
// ctl-opt CCSID(*CHAR:37);

// Header file for ILEastic framework
/include ./headers/ILEastic.rpgle
// Header file for NOXDB (Thread Memory Functions)
/include ./noxdb/headers/jsonParser.rpgle

// Program Status Data Structute
dcl-ds pgmStatus PSDS qualified;
    status *STATUS;
    exceptionCode char(7) pos(40);
end-ds;

// Names Constants
dcl-c true const(*On);
dcl-c false const(*Off);
dcl-c null const(-1);
dcl-c lowercase const('abcdefghijklmnopqrstuvwxyz');
dcl-c uppercase const('ABCDEFGHIJKLMNOPQRSTUVWXYZ');

// --------------------------------------------------------------------------------------
// Program Entry Point
// --------------------------------------------------------------------------------------
dcl-proc main;

    // ILEastic Configuration Data Structure
    dcl-ds config likeds(il_config);

    // Set port and host values
    config.port = 1302;
    config.host = '*ANY';

    // The resource paths must be entered as a regular expression.
    //
    // Paramter names are in the form {parmName}
    //
    // If none of these endpoints are satified
    // it will return 404 NOT FOUND.

    il_addRoute(config : %paddr($TestParmError) : IL_GET :
        '/test/{thisValuel}'
    );

    il_listen(config);
end-proc;

// --------------------------------------------------------------------------------------
dcl-proc $TestParmError;

    // Procedure Interface
    dcl-pi *n;
        request     likeds(IL_REQUEST);
        response    likeds(IL_RESPONSE);
    end-pi;

    // Local variable declarations
    dcl-s parmValURL1               varchar(78)             inz;
    dcl-s parmValURL2               varchar(78)             inz;
    dcl-s parmValName1              varchar(78)             inz;
    dcl-s parmValName2              varchar(78)             inz;
    dcl-s parmValIndex1             varchar(78)             inz;
    dcl-s parmValIndex2             varchar(78)             inz;

    parmValURL1 = il_getRequestUrl(request);
    parmValName1 = il_getPathParameter (request: 'thisValuel' : ' ');
    parmValIndex1 = il_getPathParameter (request: 'thisValuel' : ' ' : 1);

    // Stop here and run second request from Postman

    parmValURL2 = il_getRequestUrl(request);
    parmValName2 = il_getPathParameter (request: 'thisValuel' : ' ');
    parmValIndex2 = il_getPathParameter (request: 'thisValuel' : ' ' : 1);

    il_responseWrite(response : 'Done:' + parmValURL2 + ':' + parmValName2 + ':' +  parmValIndex2);
    return;
end-proc;

