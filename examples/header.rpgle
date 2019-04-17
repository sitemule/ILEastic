**FREE

///
// Header Example (14)
//
// This example shows how to create a simple web service which returns the
// value of query parameter 'header' as a http header.
//
// Compile program:
// CD DIR('[ILEastic]/examples')
// ADDLIBLE LIB(ILEASTIC)
// CRTBNDRPG PGM(ILEASTIC/HEADER) SRCSTMF('header.c') OPTION(*NOUNREF)
//   DBGVIEW(*LIST)  OUTPUT(*PRINT) INCDIR('./..')
//
// Start it:
// SBMJOB CMD(CALL PGM(HEADER)) JOB(ILEASTIC14) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)
//
// The web service can be tested with the browser by entering the following URL:
// http://my_ibm_i:44014?header=FirstTry
//
// @info: It requires your RPG code to be reentrant and compiled for
//        multithreading. Each client request is handled by a seperate thread.
///

ctl-opt copyright('Sitemule.com  (C), 2018');
ctl-opt decEdit('0,') datEdit(*YMD.) main(main);
ctl-opt debug(*yes) bndDir('ILEASTIC');
ctl-opt thread(*CONCURRENT);

/include ./headers/ileastic.rpgle

// -----------------------------------------------------------------------------
// Program Entry Point
// -----------------------------------------------------------------------------
dcl-proc main;

    dcl-ds config likeds(il_config);

    config.port = 44014;
    config.host = '*ANY';

    il_listen (config : %paddr(myservlet));

end-proc;

// -----------------------------------------------------------------------------
// Servlet callback implementation
// -----------------------------------------------------------------------------
dcl-proc myservlet;

    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;

    dcl-c CRLF x'0D25';
    dcl-c HEADER_NAME 'il-response-header';
    dcl-s headerValue varchar(100);
    dcl-s message varchar(200);

    // Get the header value from the query string. It should have been passed like
    // this: http://my_ibm_i:44014?header=MyHeaderValue
    headerValue = il_getParmStr(request : 'header');
    if (headerValue <> '');
       il_addHeader(response: HEADER_NAME: headerValue);
       message = 'Response header ''' + HEADER_NAME + ''' set to: ' + headerValue;
    else;
       message = 'Query attribute ''header'' not specified!' + CRLF +
                 'Usage: http://my_ibm_i:44014?header=FirstTry';
    endif;

    // Write the response. The default HTTP status code is 200 - OK so we
    // don't have to set it explicitly.
    il_responseWrite(response: 'Header example. Time is ' + %char(%timestamp)
                               + CRLF + message);

end-proc;

