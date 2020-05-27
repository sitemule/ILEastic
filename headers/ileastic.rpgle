**FREE

/if defined (ILEASTIC)
/eof
/endif

/define ILEASTIC

///
// ILEastic - Embedded application server for ILE on IBM i
//
// It is a self contained web application server for the ILE environment on
// IBM i for implementing microservices alike applications.
// <p>
// ILEastic is a service program that provides a simple, blazing fast
// programmable HTTP server for your application so you can easily plug your RPG
// code into a service infrastructure or make simple web applications without
// the need of any third party webserver products.
//
// @author Niels Liisberg
// @date 27.08.2018
// @project ILEastic
// @link https://github.com/sitemule/ILEastic Project page
// @version 1.1.3
///


///
// Template for UTF8 varchars.
///
dcl-s IL_LONGUTF8VARCHAR varchar(524284:4) ccsid(*utf8) template;

///
// Variable length string
//
// This data structure holds a string with variable length.
// Note - it only occupies as much data as required only with the length and pointer as overhead.
///
dcl-ds il_varchar qualified template;
    length  uns(10);
    string  pointer;
end-ds;


///
// Protocol plain HTTP 
///
dcl-c IL_HTTP       0;

///
// Protocol HTTPS (Secure HTTP: Certificate and certificate password required)
///
dcl-c IL_HTTPS      1;

///
// Protocol FastCGI (For application plugin to NGINX or APACHE)
///
dcl-c IL_FASTCGI    2;

///
// Protocol FastCGI secure (For application plugin to NGINX or APACHE.Certificate and certificate password required)
///
dcl-c IL_SECFASTCGI 3;

///
// Configuration
///
dcl-ds il_config qualified template;
    host                varchar(64);
    port                int(10);
    protocol            int(5);
    certificateFile     varchar(256);
    certificatePassword varchar(64);
    filler              char(4096); // required - contains the private internal handlers
end-ds;

///
// HTTP request
//
// This data structure contains the values of the incoming
// HTTP request. The values can be retrieve by using the
// il_getVarcharValue procedure or by using one of the
// il_getRequest... procedures.
///
dcl-ds il_request qualified template;
    config         pointer;
    method         likeds(il_varchar);
    url            likeds(il_varchar);
    resource       likeds(il_varchar);
    queryString    likeds(il_varchar);
    protocol       likeds(il_varchar);
    headers        likeds(il_varchar);
    content        likeds(il_varchar);
    contentType    varchar(256);
    contentLength  uns(20);
    completeHeader likeds(il_varchar);
    headerList     pointer;
    parameterList  pointer;
    threadLocal    pointer;
end-ds;

///
// HTTP response
//
// This data structure contains the details of the HTTP
// response which will be sent by one of the il_response...
// procedures.
///
dcl-ds il_response qualified template;
    config      pointer;
    status      int(5);
    statusText  varchar(256);
    contentType varchar(256);
    charset     varchar(32) ;
end-ds;

///
// Get string value
//
// Returns the value of a string data structure (il_varchar).
//
// @param String
// @return Value of the string data structure
///
dcl-pr il_getVarcharValue varchar(524284:4) ccsid(*utf8) rtnparm
                extproc(*CWIDEN:'lvpc2lvc');
    string likeds(il_varchar);
end-pr;

///
// Get HTTP request method
//
// Returns the HTTP method from the request (like GET, POST, DELETE, ...).
//
// @param Request
// @return HTTP method
///
dcl-pr il_getRequestMethod  varchar(256:2) ccsid(*utf8) rtnparm
                extproc(*CWIDEN:'il_getRequestMethod');
    request likeds(il_request);
end-pr;

///
// Get request URL
//
// Returns the request URL consisting of the resource and the query string.
// http://localhost:8080/api/v1/iledocs/search?q=map&scope=full would return
// /api/v1/iledocs/search?q=map&scope=full .
// <br/><br/>
// Any fragment entered in the request URL is not part of the return value.
//
// @param Request
// @return URL
///
dcl-pr il_getRequestUrl  varchar(524284:4) ccsid(*utf8) rtnparm
                extproc(*CWIDEN:'il_getRequestUrl');
    request likeds(il_request);
end-pr;

///
// Get request resource
//
// Return the full resources path excluding the query string and the fragment.
// http://localhost:8080/api/v1/iledocs/search?q=map&scope=full would return
// /api/v1/iledocs/search .
//
// @param Request
// @return Resource
///
dcl-pr il_getRequestResource  varchar(524284:4) ccsid(*utf8) rtnparm
                extproc(*CWIDEN:'il_getRequestResource');
    request likeds(il_request);
end-pr;

///
// Get request query string
//
// Returns the request query string (without the starting ? separator). So for
// a request like http://localhost:8080/path?query=string you would get
// query=string as the return value. The ? sign as a separator of the resource
// path and the query string is not part of the return value. If the URL does
// not contain a query string a zero length string is returned.
//
// @param Request
// @return Query string
///
dcl-pr il_getRequestQueryString  varchar(524284:4) ccsid(*utf8) rtnparm
                extproc(*CWIDEN:'il_getRequestQueryString');
    request likeds(il_request);
end-pr;

///
// Get single parameter from query string
//
// Returns the starting value for a request query string. So for
// a request like http://localhost:8080/path?query=string you would get
// 'string' as the return value for the input of 'query'. The ? sign as a
// separator of the resource path and the query string is not part of the
// return value. If the URL does not contain a query string the default string
// is returned.
//
// @param Request
// @param Query parameter key
// @param Default value (returned if key does not exist in query string)
// @return Query parameter string value
///
dcl-pr il_getParmStr varchar(524284:4) ccsid(*utf8) rtnparm
                extproc(*CWIDEN:'il_getParmStr');
    request     likeds(il_request);
    parmName    pointer value options(*string);
    default     varchar(524284:4) ccsid(*utf8) options(*varsize:*nopass) const;
end-pr;

///
// Get request protocol
//
// Returns the request protocol, f. e. HTTP/1.1 .
//
// @param Request
// @return Protocol
///
dcl-pr il_getRequestProtocol  varchar(256:2)  ccsid(*utf8) rtnparm
                extproc(*CWIDEN:'il_getRequestProtocol');
    request likeds(il_request);
end-pr;

///
// Get request headers
//
// Returns the request headers as they are in the HTTP message.
//
// @param Request
// @return HTTP headers
///
dcl-pr il_getRequestHeaders  varchar(524284:4)  ccsid(*utf8) rtnparm
                extproc(*CWIDEN:'il_getRequestHeaders');
    request likeds(il_request);
end-pr;

///
// Get request header
//
// Returns a single request header.
//
// @param Request
// @param HTTP header key
// @return HTTP header value
///
dcl-pr il_getRequestHeader  varchar(524284:4)  ccsid(*utf8) rtnparm
                extproc(*CWIDEN:'il_getRequestHeader');
    request  likeds(il_request);
    header   pointer value options(*string);
end-pr;

///
// Get request content
//
// Returns the body content of the HTTP message. If the content exceeds
// the length of the return value the subfield <em>content</em> of the
// request data structure can be accessed directly to process the
// content block by block, see il_request.content.
//
// @param Request
// @return HTTP message content
///
dcl-pr il_getRequestContent  varchar(524284:4)  ccsid(*utf8) rtnparm
                extproc(*CWIDEN:'il_getRequestContent');
    request likeds(il_request);
end-pr;

///
// Get file MIME type
//
// If the requested resource is a file then the corresponding MIME type to
// the file will be returned.
//
// @param File name
// @return MIME type
///
dcl-pr il_getFileMimeType  varchar(256:2)  rtnparm
                extproc(*CWIDEN:'il_getFileMimeType');
    fileName    varchar(256:2);
end-pr;

///
// Get file extension
//
// If the requested resource is a file then the file extension will be returned.
// A request for http://localhost:8080/index.html will return html.
//
// @param File name
// @return File extension
///
dcl-pr il_getFileExtension  varchar(256:2)  rtnparm
                extproc(*CWIDEN:'il_getFileExtension');
    fileName    varchar(256:2);
end-pr;

///
// Start server
//
// Starts the server with the passed configuration and for the passed servlet.
//
// @param Configuration
// @param Servlet
///
dcl-pr il_listen extproc(*CWIDEN:'il_listen');
    config      likeds(il_config);
    servlet     pointer(*PROC) value options(*nopass) ;
end-pr;

///
// Add HTTP header entry to the response 
//
// Adds an HTTP header to the response sent to the client. The same HTTP header
// key can be added multiple times to the response, the old value is not replaced.
//
// @param response Response
// @param HTTP header key
// @param HTTP header value
///
dcl-pr il_addHeader extproc(*CWIDEN:'il_addHeader');
    response    likeds(il_response);
    header      varchar(256:2) const;
    value       varchar(3072:2) const;
end-pr;

///
// Write response
//
// Writes the passed buffer to the HTTP message. This procedure can be called
// multiple times for a single HTTP response. Each call will get send as a 
// HTTP message in chunked transport mode. The receiving side builds one 
// HTTP message from all sent chunks.
//
// @param Response
// @param Response message content.
//
// @info The response data structure must be filled with the correct values
//       (f. e. the HTTP status code) for the response on the first call of
//       this procedure for the HTTP response.
///
dcl-pr il_responseWrite extproc(*CWIDEN:'il_responseWrite');
    response    likeds(il_response);
    buffer      varchar(524284:4) ccsid(*utf8) options(*varsize) const ;
end-pr;

///
// Write binary response
//
// Writes the passed buffer to the HTTP message. This procedure can be called
// multiple times for a single HTTP response. Each call will get send as a 
// HTTP message in chunked transport mode. The receiving side builds one 
// HTTP message from all sent chunks. The content of the message will be
// written without any character conversion.
//
// @param Response
// @param Response message content.
//
// @info The response data structure must be filled with the correct values
//       (f. e. the HTTP status code) for the response on the first call of
//       this procedure for the HTTP response.
///
dcl-pr il_responseWriteBin extproc(*CWIDEN:'il_responseWrite');
    response    likeds(il_response);
    buf         varchar(524284:4) options(*varsize) const ;
end-pr;

///
// Serve file
//
// Writes the content of the file to the response message.
//
// @param Response
// @param File name
///
dcl-pr il_serveStatic ind extproc(*CWIDEN:'il_serveStatic');
    response    likeds(il_response);
    fileName    varchar(256) options(*varsize) const;
end-pr;

///
// Write stream
//
// Writes the content of the stream to the response message.
//
// @param Response
// @param Stream - Pointer returned by i.e. json_stream from noxDB
///
dcl-pr il_responseWriteStream extproc(*CWIDEN:'il_responseWriteStream');
    response    likeds(il_response);
    stream      pointer value;
end-pr;

///
// HTTP method GET
///
dcl-c IL_GET     1;
///
// HTTP method POST
///
dcl-c IL_POST    2;
///
// HTTP method DELETE
///
dcl-c IL_DELETE  4;
///
// HTTP method PUT
///
dcl-c IL_PUT     8;
///
// HTTP method OPTIONS
///
dcl-c IL_OPTIONS 16;
///
// HTTP method HEAD
///
dcl-c IL_HEAD 32;
///
// HTTP method PATCH
///
dcl-c IL_PATCH 64;
///
// Any HTTP method (used for adding servlets to the server for any HTTP method)
///
dcl-c IL_ANY     const(1023);

///
// Add servlet to server
//
// A servlet is added to the server with the passed routing information.
//
// @param Configuration
// @param Servlet
// @param HTTP Method (multiple methods can be specified like this:
//        IL_GET + IL_POST, default: IL_ANY)
// @param Path (default: / )
// @param Content type (default: application/json)
///
dcl-pr il_addRoute extproc(*CWIDEN:'il_addRoute');
    config       likeds(il_config);
    servlet      pointer(*PROC) value;
    httpMethods  int(5) value options(*nopass);
    route        varchar(1024) const options(*nopass);
    contentType  varchar(1024) const options(*nopass);
end-pr;

///
// Defining plugin execution time for a plugin before the request has been
// handed to the endpoint.
///
dcl-c IL_PREREQUEST   1;
///
// Defining plugin execution time for a plugin after the last response part
// has been sent.
///
dcl-c IL_POSTRESPONSE 2;


///
// Add plugin server
//
// A servlet that can handle pre and post request. A prerequest can return
// *OFF to stop futher processing.
//
// @param Configuration
// @param Plugin
// @param Type (when to run): IL_PREREQUEST + IL_POSTRESPONSE : can be
//        either/or simply add together
///
dcl-pr il_addPlugin extproc(*CWIDEN:'il_addPlugin');
    config       likeds(il_config);
    plugin       pointer(*PROC) value;
    pluginType   int(5) value;
end-pr;


///
// Add scheduler callback plugin procedure ie for houskeeping / termination detection
//
// This starts an extra thread that calls your callback procedure.
// Returning *OFF will terminate the ILEastic application server.
//
// @param Configuration
// @param Address to plugin procedure
// @param Seconds between calls
///
dcl-pr il_setSchedulerPlugin extproc(*CWIDEN:'il_setSchedulerPlugin');
    config       likeds(il_config);
    plugin       pointer(*PROC) value;
    timerSec     int(5) value;
end-pr;

///
// Enter thread safe mode
//
// Enter mode for non threaded application like "normal" RPG / CLLE.
///
dcl-pr il_enterThreadSerialize extproc(*CWIDEN:'il_enterThreadSerialize');
end-pr;

///
// Leave thread safe mode
//
// Leave mode for non threaded application like "normal" RPG / CLLE.
///
dcl-pr il_exitThreadSerialize extproc(*CWIDEN:'il_exitThreadSerialize');
end-pr;

///
// Base64 decode value
//
// Decodes a base64 encoded string.
//
// @param Encoded string
// @return Decoded string
//
// @info The character encoding for the original value is expected to be UTF-8.
///
dcl-pr il_decodeBase64 varchar(524284:4) ccsid(*utf8) extproc(*CWIDEN : 'il_decodeBase64') rtnparm;
  string varchar(524284:4) ccsid(*utf8) options(*varsize) const;
end-pr;

///
// Base64 encoding value
//
// Encodes a string into base64 .
//
// @param string to encode
// @return Encoded string
//
// @info The character encoding for the original value is expected to be UTF-8.
///
dcl-pr il_encodeBase64 varchar(524284:4) ccsid(*utf8) extproc(*CWIDEN : 'il_encodeBase64') rtnparm;
  string varchar(524284:4) ccsid(*utf8) options(*varsize) const;
end-pr;

///
// Add message to job log
//
// Convenience function: put message in joblog.
// Works like printf but with strings only like
//
//    il_joblog('This is %s a test' : 'Super');
//
// @param format string
// @param Parms : list of strings
//
///
dcl-pr il_joblog extproc(*CWIDEN : 'il_joblog') ;
  formatString  pointer  options(*string)  value;
  string0       pointer  options(*string:*nopass) value;
  string1       pointer  options(*string:*nopass) value;
  string2       pointer  options(*string:*nopass) value;
  string3       pointer  options(*string:*nopass) value;
  string4       pointer  options(*string:*nopass) value;
  string5       pointer  options(*string:*nopass) value;
  string6       pointer  options(*string:*nopass) value;
  string7       pointer  options(*string:*nopass) value;
  string8       pointer  options(*string:*nopass) value;
  string9       pointer  options(*string:*nopass) value;
end-pr;

///
// Get thread local storage
//
// Returns a graph of the thread local storage. You can access the graph with
// the noxDB API. Paths starting with /ileastic are framework specific values.
//
// @return Pointer to thread local storage
///
dcl-pr il_getThreadMem pointer extproc('il_getThreadMem');
  request likeds(il_request);
end-pr;

