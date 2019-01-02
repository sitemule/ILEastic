**FREE
///
// Hello World Example
//
// This example shows how to create a simple hello service
// connected fro i.e. NGINX
//
// Start it:
// SBMJOB CMD(CALL PGM(FASTCGI01)) JOB(FASTCGI01) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)        
// 
// The web service can be tested with the browser by entering the following URL:
// http://my_ibm_i:44000
// 
// @info: It requires your RPG code to be reentrant and compiled for 
//        multithreading. Each client request is handled by a seperate thread.
///
ctl-opt copyright('Sitemule.com  (C), 2019');
ctl-opt decEdit('0,') datEdit(*YMD.) main(main);
ctl-opt debug(*yes) bndDir('ILEASTIC');
ctl-opt thread(*CONCURRENT);

/include ./headers/ileastic.rpgle

// -----------------------------------------------------------------------------
// Program Entry Point
// -----------------------------------------------------------------------------     
dcl-proc main;

    dcl-ds config likeds(IL_CONFIG);
    
    config.port = 50000;            // The FastCGI port from NGINX 
    config.host = '*ANY';           // Any interface
    config.protocol = IL_FASTCGI;   // The protocol is Set to FAST CGI
    
    il_listen (config : %paddr(myservlet));
 
end-proc;

// -----------------------------------------------------------------------------
// Servlet callback implementation
// Note - the servlet implemtation is compatible with the HTTP/HTTPS servlet
// From the servlet the FastCGI is transparent
// -----------------------------------------------------------------------------     
dcl-proc myservlet;

    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;
    
    dcl-s name varchar(256);
    dcl-s i int(10);
        
    // Get the input paramter from the querystring
    name  = il_getParmStr(request : 'name');
    
    // Write the response. The default HTTP status code is 200 - OK so we
    // don't have to set it explicitly.
    for i=1 to 1000;
        il_responseWrite(response: 'Hello ' + name + '. Time is ' + %char(%timestamp));
    endfor;

end-proc;

