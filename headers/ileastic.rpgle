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
//
// @info Source for HTTP status documentation is the Mozilla developer website
//       at https://developer.mozilla.org/en-US/docs/Web/HTTP/Status .
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
// The request has succeeded. The meaning of the success depends on the HTTP method: 
// <ul>
//   <li>GET: The resource has been fetched and is transmitted in the message body.</li>
//   <li>HEAD: The entity headers are in the message body.</li>
//   <li>PUT or POST: The resource describing the result of the action is transmitted in the message body.</li>
//   <li>TRACE: The message body contains the request message as received by the server.</li>
// </ul>
///
dcl-c IL_HTTP_OK 200;
///
// The request has succeeded and a new resource has been created as a result. 
// This is typically the response sent after POST requests, or some PUT requests.
///
dcl-c IL_HTTP_CREATED 201;
///
// The request has been received but not yet acted upon. It is noncommittal, 
// since there is no way in HTTP to later send an asynchronous response indicating 
// the outcome of the request. It is intended for cases where another process or 
// server handles the request, or for batch processing.
///
dcl-c IL_HTTP_ACCEPTED 202;
///
// This response code means the returned meta-information is not exactly the same 
// as is available from the origin server, but is collected from a local or a 
// third-party copy. This is mostly used for mirrors or backups of another resource. 
// Except for that specific case, the "200 OK" response is preferred to this status.
///
dcl-c IL_HTTP_NON_AUTHORITIVE_INFO 203;
///
// There is no content to send for this request, but the headers may be useful. 
// The user-agent may update its cached headers for this resource with the new ones.
///
dcl-c IL_HTTP_NO_CONTENT 204;
///
// Tells the user-agent to reset the document which sent this request.
///
dcl-c IL_HTTP_RESET_CONTENT 205;
///
// This response code is used when the Range header is sent from the client to 
// request only part of a resource.
///
dcl-c IL_HTTP_PARTIAL_CONTENT 206;
///
// Conveys information about multiple resources, for situations where multiple 
// status codes might be appropriate.
///
dcl-c IL_HTTP_MULTI_STATUS 207;
///
// Used inside a &lt;dav:propstat&gt; response element to avoid repeatedly enumerating 
// the internal members of multiple bindings to the same collection.
///
dcl-c IL_HTTP_ALREADY_REPORTED 208;
///
// The server has fulfilled a GET request for the resource, and the response is 
// a representation of the result of one or more instance-manipulations applied 
// to the current instance.
///
dcl-c IL_HTTP_IM_USED 226;
///
// The server could not understand the request due to invalid syntax.
///
dcl-c IL_HTTP_BAD_REQUEST 400;
///
// Although the HTTP standard specifies "unauthorized", semantically this response 
// means "unauthenticated". That is, the client must authenticate itself to get 
// the requested response.
///
dcl-c IL_HTTP_UNAUTHORIZED 401;
///
// This response code is reserved for future use. The initial aim for creating 
// this code was using it for digital payment systems, however this status code 
// is used very rarely and no standard convention exists.
///
dcl-c IL_HTTP_PAYMENT_REQUIRED 402;
///
// The client does not have access rights to the content; that is, it is 
// unauthorized, so the server is refusing to give the requested resource. 
// Unlike 401, the client's identity is known to the server.
///
dcl-c IL_HTTP_FORBIDDEN 403;
///
// The server can not find the requested resource. In the browser, this means 
// the URL is not recognized. In an API, this can also mean that the endpoint is 
// valid but the resource itself does not exist. Servers may also send this 
// response instead of 403 to hide the existence of a resource from an 
// unauthorized client. This response code is probably the most famous one due 
// to its frequent occurrence on the web.
///
dcl-c IL_HTTP_NOT_FOUND 404;
///
// The request method is known by the server but has been disabled and cannot be 
// used. For example, an API may forbid DELETE-ing a resource. The two mandatory 
// methods, GET and HEAD, must never be disabled and should not return this error 
// code.
///
dcl-c IL_HTTP_METHOD_NOT_ALLOWED 405;
///
// This response is sent when the web server, after performing server-driven 
// content negotiation, doesn't find any content that conforms to the criteria 
// given by the user agent.
///
dcl-c IL_HTTP_NOT_ACCEPTABLE 406;
///
// This is similar to 401 but authentication is needed to be done by a proxy.
///
dcl-c IL_HTTP_PROXY_AUTH_REQUIRED 407;
///
// This response is sent on an idle connection by some servers, even without any 
// previous request by the client. It means that the server would like to shut 
// down this unused connection. This response is used much more since some 
// browsers, like Chrome, Firefox 27+, or IE9, use HTTP pre-connection mechanisms 
// to speed up surfing. Also note that some servers merely shut down the 
// connection without sending this message.
///
dcl-c IL_HTTP_REQUEST_TIMEOUT 408;
///
// This response is sent when a request conflicts with the current state of the server.
///
dcl-c IL_HTTP_CONFLICT 409;
///
// This response is sent when the requested content has been permanently deleted 
// from server, with no forwarding address. Clients are expected to remove their 
// caches and links to the resource. The HTTP specification intends this status 
// code to be used for "limited-time, promotional services". APIs should not feel 
// compelled to indicate resources that have been deleted with this status code.
///
dcl-c IL_HTTP_GONE 410;
///
// Server rejected the request because the Content-Length header field is not 
// defined and the server requires it.
///
dcl-c IL_HTTP_LENGTH_REQUIRED 411;
///
// The client has indicated preconditions in its headers which the server does not meet.
///
dcl-c IL_HTTP_PRECONDITION_FAILED 412;
///
// Request entity is larger than limits defined by server; the server might 
// close the connection or return an Retry-After header field.
///
dcl-c IL_HTTP_PAYLOAD_TOO_LARGE 413;
///
// The URI requested by the client is longer than the server is willing to interpret.
///
dcl-c IL_HTTP_REQUEST_URI_TOO_LONG 414;
///
// The media format of the requested data is not supported by the server, so the 
// server is rejecting the request.
///
dcl-c IL_HTTP_UNSUPPORTED_MEDIA_TYPE 415;
///
// The range specified by the Range header field in the request can't be 
// fulfilled; it's possible that the range is outside the size of the target 
// URI's data.
///
dcl-c IL_HTTP_REQUESTED_RANGE_NOT_SATISFIABLE 416;
///
// This response code means the expectation indicated by the Expect request 
// header field can't be met by the server.
///
dcl-c IL_HTTP_EXPECTATION_FAILED 417;
///
// The server refuses the attempt to brew coffee with a teapot.
///
dcl-c IL_HTTP_TEAPOT 418;
///
// The request was directed at a server that is not able to produce a response. 
// This can be sent by a server that is not configured to produce responses for 
// the combination of scheme and authority that are included in the request URI.
///
dcl-c IL_HTTP_MISDIRECTED_REQUEST 421;
///
// The request was well-formed but was unable to be followed due to semantic errors.
///
dcl-c IL_HTTP_UNPROCESSABLE_ENTITY 422;
///
// The resource that is being accessed is locked.
///
dcl-c IL_HTTP_LOCKED 423;
///
// The request failed due to failure of a previous request.
///
dcl-c IL_HTTP_FAILED_DEPENDENCY 424;
///
// Indicates that the server is unwilling to risk processing a request that 
// might be replayed.
///
dcl-c IL_HTTP_TOO_EARLY 425;
///
// The server refuses to perform the request using the current protocol but 
// might be willing to do so after the client upgrades to a different protocol. 
// The server sends an Upgrade header in a 426 response to indicate the required 
// protocol(s).
///
dcl-c IL_HTTP_UPGRADE_REQUIRED 426;
///
// The origin server requires the request to be conditional. This response is 
// intended to prevent the 'lost update' problem, where a client GETs a 
// resource's state, modifies it, and PUTs it back to the server, when meanwhile 
// a third party has modified the state on the server, leading to a conflict.
///
dcl-c IL_HTTP_PRECONDITION_REQUIRED 428;
///
// The user has sent too many requests in a given amount of time ("rate limiting").
///
dcl-c IL_HTTP_TOO_MANY_REQUESTS 429;
///
// The server is unwilling to process the request because its header fields are 
// too large. The request may be resubmitted after reducing the size of the 
// request header fields.
///
dcl-c IL_HTTP_REQUEST_HEADER_FIELDS_TOO_LARGE 431;
///
// The user-agent requested a resource that cannot legally be provided, such as 
// a web page censored by a government.
///
dcl-c IL_HTTP_UNAVAILABLE_FOR_LEGAL_REASONS 451;
///
// The server has encountered a situation it doesn't know how to handle.
///
dcl-c IL_HTTP_INTERNAL_SERVER_ERROR 500;
///
// The request method is not supported by the server and cannot be handled. 
// The only methods that servers are required to support (and therefore that 
// must not return this code) are GET and HEAD.
///
dcl-c IL_HTTP_NOT_IMPLEMENTED 501;
///
// This error response means that the server, while working as a gateway to get 
// a response needed to handle the request, got an invalid response.
///
dcl-c IL_HTTP_BAD_GATEWAY 502;
///
// The server is not ready to handle the request. Common causes are a server 
// that is down for maintenance or that is overloaded. Note that together with 
// this response, a user-friendly page explaining the problem should be sent. 
// This responses should be used for temporary conditions and the Retry-After: 
// HTTP header should, if possible, contain the estimated time before the 
// recovery of the service. The webmaster must also take care about the 
// caching-related headers that are sent along with this response, as these 
// temporary condition responses should usually not be cached.
///
dcl-c IL_HTTP_SERVICE_UNAVAILABLE 503;
///
// This error response is given when the server is acting as a gateway and 
// cannot get a response in time.
///
dcl-c IL_HTTP_GATEWAY_TIMEOUT 504;
///
// The HTTP version used in the request is not supported by the server.
///
dcl-c IL_HTTP_VERSION_NOT_SUPPORTED 505;
///
// The server has an internal configuration error: the chosen variant resource 
// is configured to engage in transparent content negotiation itself, and is 
// therefore not a proper end point in the negotiation process.
///
dcl-c IL_HTTP_VARIANT_ALSO_NEGOTIATES 506;
///
// The method could not be performed on the resource because the server is 
// unable to store the representation needed to successfully complete the request.
///
dcl-c IL_HTTP_INSUFFICIENT_STORAGE 507;
///
// The server detected an infinite loop while processing the request.
///
dcl-c IL_HTTP_LOOP_DETECTED 508;
///
// Further extensions to the request are required for the server to fulfil it.
///
dcl-c IL_HTTP_NOT_EXTENDED 510;
///
// The 511 status code indicates that the client needs to authenticate to gain 
// network access.
///
dcl-c IL_HTTP_NETWORK_AUTH_REQUIRED 511;


///
// Any media type.
///
dcl-c IL_MEDIA_TYPE_ALL '*/*';
///
// Default format for JSON data.
///
dcl-c IL_MEDIA_TYPE_JSON 'application/json';
///
// Default format for XML data.
///
dcl-c IL_MEDIA_TYPE_XML 'application/xml';


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
    config           pointer;
    method           likeds(il_varchar);
    url              likeds(il_varchar);
    resource         likeds(il_varchar);
    queryString      likeds(il_varchar);
    protocol         likeds(il_varchar);
    headers          likeds(il_varchar);
    content          likeds(il_varchar);
    contentType      varchar(256);
    contentLength    uns(20);
    completeHeade    likeds(il_varchar);
    headerList       pointer;
    parameterList    pointer;
    resourceSegments pointer;
    threadLocal      pointer;
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
dcl-pr il_getRequestResource varchar(524284:4) ccsid(*utf8) rtnparm
                extproc(*CWIDEN:'il_getRequestResource');
    request likeds(il_request);
end-pr;

///
// Get segment of request resource
//
// Returns the specified segment of the request resource. The index starts with
// 0 (null). An empty value will be returned if the index is out of range. Empty
// segments do count and will be returned as an empty value, f. e. 
// http://localhost:8000/folder//file : the second segment is empty and will
// be returned as an empty value and the third segment is "file".
//
// @param Request
// @param Index (0-based)
// @return Resource segment
///
dcl-pr il_getRequestSegmentByIndex varchar(524284:4) ccsid(*utf8) rtnparm
                extproc(*CWIDEN:'il_getRequestSegmentByIndex');
    request likeds(il_request);
    index int(10) value;
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

