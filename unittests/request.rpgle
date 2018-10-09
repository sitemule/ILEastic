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

// BOOL lookForHeaders ( PREQUEST pRequest, PUCHAR buf , ULONG bufLen)
dcl-pr lookForHeaders extproc(*CWIDEN:*dclcase);
  request pointer value;
  buffer pointer value;
  bufferLength uns(10) value;
end-pr;

dcl-s CRLF char(2) inz(x'0d0a') ccsid(819); 


//
// Procedures
//
dcl-proc test_parseSimpleRequest export;
  dcl-s abnormallyEnded ind;
  dcl-s httpMessage varchar(1000) ccsid(819);
  dcl-ds request likeds(il_request);
  
  request = createRequest();
  
  httpMessage = 'GET /index.html HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + CRLF;
  lookForHeaders(%addr(request) : %addr(httpMessage : *data) : %len(httpMessage));
  
  aEqual(utf8('GET') : il_getRequestMethod(request));
  aEqual(utf8('localhost') : il_getRequestHeader(request : 'Host'));
  aEqual(utf8('/index.html') : il_getRequestResource(request));
  
  on-exit abnormallyEnded;
    disposeRequest(request);
end-proc;


dcl-proc test_parseGetMultipleHeader export;
  dcl-s abnormallyEnded ind;
  dcl-s httpMessage varchar(1000) ccsid(819);
  dcl-ds request likeds(il_request);
  
  request = createRequest();
  
  httpMessage = 'GET /index.html HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + 'Accept: application/json' + CRLF + CRLF;
  lookForHeaders(%addr(request) : %addr(httpMessage : *data) : %len(httpMessage));
  
  aEqual(utf8('GET') : il_getRequestMethod(request));
  aEqual(utf8('localhost') : il_getRequestHeader(request : 'Host'));
  aEqual(utf8('application/json') : il_getRequestHeader(request : 'Accept'));
  
  on-exit abnormallyEnded;
    disposeRequest(request);
end-proc;


dcl-proc test_headerCaseInsensitivity export;
  dcl-s abnormallyEnded ind;
  dcl-s httpMessage varchar(1000) ccsid(819);
  dcl-ds request likeds(il_request);
  
  request = createRequest();
  
  httpMessage = 'GET /index.html HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + 'Accept: application/json' + CRLF + CRLF;
  lookForHeaders(%addr(request) : %addr(httpMessage : *data) : %len(httpMessage));
  
  aEqual(utf8('application/json') : il_getRequestHeader(request : 'Accept'));
  aEqual(utf8('application/json') : il_getRequestHeader(request : 'accept'));
  aEqual(utf8('application/json') : il_getRequestHeader(request : 'ACCEPT'));
  aEqual(utf8('application/json') : il_getRequestHeader(request : 'aCCept'));
  
  on-exit abnormallyEnded;
    disposeRequest(request);
end-proc;


dcl-proc test_headerNotExist export;
  dcl-s abnormallyEnded ind;
  dcl-s httpMessage varchar(1000) ccsid(819);
  dcl-ds request likeds(il_request);
  
  request = createRequest();
  
  httpMessage = 'GET /index.html HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + CRLF;
  lookForHeaders(%addr(request) : %addr(httpMessage : *data) : %len(httpMessage));
  
  aEqual(utf8('') : il_getRequestHeader(request : 'NotExistingHeader'));
  
  on-exit abnormallyEnded;
    disposeRequest(request);
end-proc;


dcl-proc test_headerEmptyHeaderValue export;
  dcl-s abnormallyEnded ind;
  dcl-s httpMessage varchar(1000) ccsid(819);
  dcl-ds request likeds(il_request);
  
  request = createRequest();
  
  httpMessage = 'GET /index.html HTTP/1.1' + CRLF + 'Host: ' + CRLF + CRLF;
  lookForHeaders(%addr(request) : %addr(httpMessage : *data) : %len(httpMessage));
  
  aEqual(utf8('') : il_getRequestHeader(request : 'Host'));
  
  on-exit abnormallyEnded;
    disposeRequest(request);
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

end-proc;


dcl-proc teardown export;

end-proc;