**FREE

///
// Query String Example
//
// This example shows how to get a values from the query string part of the 
// request URL.
//
// In this case the web service expects the caller to pass the client id as a 
// query string value and it should also be a number else an error message is
// returned.
//
// Start it:
// SBMJOB CMD(CALL PGM(base64)) JOB(BASE64) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)        
//
// The web service can be tested with the browser by entering the following URL:
//http://my_ibm_i:44001?encode=abc&decode=YWJj
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

    dcl-ds config likeds(IL_CONFIG);
    
    config.port = 44001; 
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
    
    dcl-s encode    like(IL_LONGUTF8VARCHAR);
    dcl-s decode    like(IL_LONGUTF8VARCHAR);
    dcl-s encodeOut like(IL_LONGUTF8VARCHAR);
    dcl-s decodeOut like(IL_LONGUTF8VARCHAR);
    

    // Translate between base64 and plane text
    // this: http://my_ibm_i:44001?encode=abc&decode=YWJj
    encode = il_getParmStr(request : 'encode');
    decode = il_getParmStr(request : 'decode');
    
    encodeOut = il_encodeBase64(encode);
    decodeOut = il_decodeBase64(decode);


    il_responseWrite(response : 'Encode:<br/>');
    il_responseWrite(response : encodeOut);
    il_responseWrite(response : '<br/>Decode:<br/>');
    il_responseWrite(response : decodeOut);
    

end-proc;
