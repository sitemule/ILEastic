**FREE

///
// Request Test
//
// The parsing of the HTTP request and returning of the parts of the request
// will be tested here.
//
// @author Mihael Schmidt
// @date   20.09.2018
///


ctl-opt nomain;


//
// Includes
//
/include '../headers/ileastic.rpgle'
/include assert


//
// Prototypes
//
dcl-pr setup end-pr;
dcl-pr teardown end-pr;
dcl-pr test_parseSimpleRequest end-pr;
dcl-pr test_parseGetMultipleHeader end-pr;
dcl-pr test_headerCaseInsensitivity end-pr;
dcl-pr test_headerNotExist end-pr;
dcl-pr test_headerEmptyHeaderValue end-pr;
dcl-pr test_noQueryString end-pr;
dcl-pr test_emptyQueryString end-pr;
dcl-pr test_fullQueryString end-pr;
dcl-pr test_queryStringWithReservedChars end-pr;
dcl-pr test_simpleResource end-pr;
dcl-pr test_rootResource end-pr;
dcl-pr test_deeplyStructuredResource end-pr;
dcl-pr test_resouceWithQueryStringWithReservedChars end-pr;
dcl-pr test_rootResourceWithMissingQueryStringValue end-pr;


// BOOL lookForHeaders ( PREQUEST pRequest, PUCHAR buf , ULONG bufLen)
dcl-pr lookForHeaders extproc(*CWIDEN:*dclcase);
  request pointer value;
  buffer pointer value;
  bufferLength uns(10) value;
end-pr;

dcl-s CRLF char(2) inz(x'0d0a') ccsid(819); 

dcl-ds request likeds(il_request);


//
// Procedures
//
dcl-proc test_parseSimpleRequest export;
  dcl-s httpMessage varchar(1000) ccsid(819);
  
  httpMessage = 'GET /index.html HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + CRLF;
  lookForHeaders(%addr(request) : %addr(httpMessage : *data) : %len(httpMessage));
  
  aEqual(utf8('GET') : il_getRequestMethod(request));
  aEqual(utf8('localhost') : il_getRequestHeader(request : 'Host'));
  aEqual(utf8('/index.html') : il_getRequestResource(request));
end-proc;


dcl-proc test_parseGetMultipleHeader export;
  dcl-s httpMessage varchar(1000) ccsid(819);
  
  request = createRequest();
  
  httpMessage = 'GET /index.html HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + 'Accept: application/json' + CRLF + CRLF;
  lookForHeaders(%addr(request) : %addr(httpMessage : *data) : %len(httpMessage));
  
  aEqual(utf8('GET') : il_getRequestMethod(request));
  aEqual(utf8('localhost') : il_getRequestHeader(request : 'Host'));
  aEqual(utf8('application/json') : il_getRequestHeader(request : 'Accept'));
end-proc;


dcl-proc test_headerCaseInsensitivity export;
  dcl-s httpMessage varchar(1000) ccsid(819);
  
  request = createRequest();
  
  httpMessage = 'GET /index.html HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + 'Accept: application/json' + CRLF + CRLF;
  lookForHeaders(%addr(request) : %addr(httpMessage : *data) : %len(httpMessage));
  
  aEqual(utf8('application/json') : il_getRequestHeader(request : 'Accept'));
  aEqual(utf8('application/json') : il_getRequestHeader(request : 'accept'));
  aEqual(utf8('application/json') : il_getRequestHeader(request : 'ACCEPT'));
  aEqual(utf8('application/json') : il_getRequestHeader(request : 'aCCept'));
end-proc;


dcl-proc test_headerNotExist export;
  dcl-s httpMessage varchar(1000) ccsid(819);
  
  request = createRequest();
  
  httpMessage = 'GET /index.html HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + CRLF;
  lookForHeaders(%addr(request) : %addr(httpMessage : *data) : %len(httpMessage));
  
  aEqual(utf8('') : il_getRequestHeader(request : 'NotExistingHeader'));
end-proc;


dcl-proc test_headerEmptyHeaderValue export;
  dcl-s httpMessage varchar(1000) ccsid(819);
  
  request = createRequest();
  
  httpMessage = 'GET /index.html HTTP/1.1' + CRLF + 'Host: ' + CRLF + CRLF;
  lookForHeaders(%addr(request) : %addr(httpMessage : *data) : %len(httpMessage));
  
  aEqual(utf8('') : il_getRequestHeader(request : 'Host'));
end-proc;


dcl-proc test_noQueryString export;
  dcl-s httpMessage varchar(1000) ccsid(819);
  
  request = createRequest();
  
  httpMessage = 'GET /index.html HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + CRLF;
  lookForHeaders(%addr(request) : %addr(httpMessage : *data) : %len(httpMessage));
  
  aEqual(utf8('') : il_getRequestQueryString(request));
end-proc;


dcl-proc test_emptyQueryString export;
  dcl-s httpMessage varchar(1000) ccsid(819);
  
  request = createRequest();
  
  httpMessage = 'GET /index.html? HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + CRLF;
  lookForHeaders(%addr(request) : %addr(httpMessage : *data) : %len(httpMessage));
  
  aEqual(utf8('') : il_getRequestQueryString(request));
end-proc;


dcl-proc test_fullQueryString export;
  dcl-s httpMessage varchar(1000) ccsid(819);
  
  request = createRequest();
  
  httpMessage = 'GET /index.html?callback=angular.callback.1 HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + CRLF;
  lookForHeaders(%addr(request) : %addr(httpMessage : *data) : %len(httpMessage));
  
  aEqual(utf8('callback=angular.callback.1') : il_getRequestQueryString(request));
end-proc;


dcl-proc test_queryStringWithReservedChars export;
  dcl-s httpMessage varchar(1000) ccsid(819);
  
  httpMessage = 'GET /api/v1/books?category=/books/romance/?&rows=20 HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + CRLF;
  lookForHeaders(%addr(request) : %addr(httpMessage : *data) : %len(httpMessage));
  
  aEqual(utf8('category=/books/romance/?&rows=20') : il_getRequestQueryString(request));
end-proc;


dcl-proc test_rootResource export;
  dcl-s httpMessage varchar(1000) ccsid(819);
  
  request = createRequest();
  
  httpMessage = 'GET / HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + CRLF;
  lookForHeaders(%addr(request) : %addr(httpMessage : *data) : %len(httpMessage));
  
  aEqual(utf8('/') : il_getRequestResource(request));
end-proc;

dcl-proc test_simpleResource export;
  dcl-s httpMessage varchar(1000) ccsid(819);
  
  httpMessage = 'GET /index.html HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + CRLF;
  lookForHeaders(%addr(request) : %addr(httpMessage : *data) : %len(httpMessage));
  
  aEqual(utf8('/index.html') : il_getRequestResource(request));
end-proc;


dcl-proc test_deeplyStructuredResource export;
  dcl-s httpMessage varchar(1000) ccsid(819);
  
  httpMessage = 'GET /api/v1/books HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + CRLF;
  lookForHeaders(%addr(request) : %addr(httpMessage : *data) : %len(httpMessage));
  
  aEqual(utf8('/api/v1/books') : il_getRequestResource(request));
end-proc;


dcl-proc test_resouceWithQueryStringWithReservedChars export;
  dcl-s httpMessage varchar(1000) ccsid(819);
  
  httpMessage = 'GET /api/v1/books?category=/books/romance/?&rows=20 HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + CRLF;
  lookForHeaders(%addr(request) : %addr(httpMessage : *data) : %len(httpMessage));
  
  aEqual(utf8('/api/v1/books') : il_getRequestResource(request));
end-proc;


dcl-proc test_rootResourceWithMissingQueryStringValue export;
  dcl-s httpMessage varchar(1000) ccsid(819);
  
  httpMessage = 'GET / HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + CRLF;
  lookForHeaders(%addr(request) : %addr(httpMessage : *data) : %len(httpMessage));
  
  aEqual(utf8('') : il_getParmStr(request : 'client'));
end-proc;


dcl-proc utf8;
  dcl-pi *n varchar(1024) ccsid(*utf8);
    string varchar(1024) const;
  end-pi;
  
  return string;
end-proc;


dcl-proc createRequest;
  dcl-pi *n likeds(il_request) end-pi;

  dcl-ds request likeds(il_request) inz;
  dcl-ds headerList likeds(il_varchar) based(headerListPtr);
  
  request.config = %alloc(%size(il_config));
  
  headerListPtr = %alloc(%size(il_varchar));
  clear headerList;
  request.headerList = headerListPtr;
  
  return request;
end-proc;


dcl-proc disposeRequest;
  dcl-pi *n;
    request likeds(il_request);
  end-pi;
  
  dealloc request.config;
  dealloc request.headerList;
end-proc;


dcl-proc setup export;
  request = createRequest();
end-proc;


dcl-proc teardown export;
  disposeRequest(request);
end-proc;
