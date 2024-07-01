**FREE

///
// Routing Test
//
// The routing of the HTTP request is tested.
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
dcl-pr test_simpleRegex end-pr;
dcl-pr test_regexRange end-pr;
dcl-pr test_notDefinedSubresource end-pr;
dcl-pr test_root end-pr;
dcl-pr test_caseSensitivity end-pr;


// PROUTING findRoute(PSLIST pRouts, PREQUEST pRequest);
dcl-pr findRoute pointer extproc(*dclcase);
  config pointer value;
  request pointer value;
end-pr;

// BOOL lookForHeaders ( PREQUEST pRequest, PUCHAR buf , ULONG bufLen)
dcl-pr lookForHeaders extproc(*CWIDEN:*dclcase);
  request pointer value;
  buffer pointer value;
  bufferLength uns(10) value;
end-pr;

dcl-ds routing_t qualified template;
  routeType int(5);
  routeReqex pointer;
  contentRegex pointer;
  servlet pointer(*proc);
  parmNumbers int(10);
  parmNames pointer;
  routeId varchar(256);
end-ds;

dcl-pr sList_free extproc(*dclcase);
  list pointer value;
end-pr;

dcl-s CRLF char(2) inz(x'0d0a') ccsid(819); 

dcl-ds config likeds(il_config) inz;

dcl-c REGEX_START u'005E';
dcl-c BRACKET_OPEN u'005B';
dcl-c BRACKET_CLOSE u'005D';
dcl-c CURLY_OPEN u'007B';
dcl-c CURLY_CLOSE u'007D';
dcl-c DOLLAR u'0024';
     
//
// Test Procedures
//
dcl-proc test_exactMatchSimpleRegex export;
  dcl-s abnormallyEnded ind;
  dcl-ds request likeds(il_request);
  dcl-s matchingRoute pointer(*proc);
  dcl-s httpMessage varchar(1000) ccsid(819);
  dcl-ds routing likeds(routing_t) based(pRouting);
  
  httpMessage = 'GET /time HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + CRLF;
  request = createRequest(httpMessage);
  
  pRouting = findRoute(%addr(config) : %addr(request));
  matchingRoute = routing.servlet;
  assert(matchingRoute = %paddr(routeTime) : 'Returned wrong end point.');
  
  on-exit abnormallyEnded;
    disposeRequest(request);
end-proc; 


dcl-proc test_exactMatchRegexRange export;
  dcl-s abnormallyEnded ind;
  dcl-ds request likeds(il_request);
  dcl-s matchingRoute pointer(*proc);
  dcl-s httpMessage varchar(1000) ccsid(819);
  dcl-ds routing likeds(routing_t) based(pRouting);
  
  httpMessage = 'GET /config/INVOICE HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + CRLF;
  request = createRequest(httpMessage);
  
  pRouting = findRoute(%addr(config) : %addr(request));
  matchingRoute = routing.servlet;
  assert(matchingRoute = %paddr(routeConfig) : 'Returned wrong end point.');
  
  on-exit abnormallyEnded;
    disposeRequest(request);
end-proc; 


dcl-proc test_notDefinedSubresource export;
  dcl-s abnormallyEnded ind;
  dcl-ds request likeds(il_request);
  dcl-s matchingRoute pointer(*proc);
  dcl-s httpMessage varchar(1000) ccsid(819);
  dcl-ds routing likeds(routing_t) based(pRouting);
  
  httpMessage = 'GET /time/hour HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + CRLF;
  request = createRequest(httpMessage);
  
  pRouting = findRoute(%addr(config) : %addr(request));
  assert(matchingRoute = *null : 'Should have found no end point.');
  
  on-exit abnormallyEnded;
    disposeRequest(request);
end-proc;


dcl-proc test_caseSensitivity export;
  dcl-s abnormallyEnded ind;
  dcl-ds request likeds(il_request);
  dcl-s matchingRoute pointer(*proc);
  dcl-s httpMessage varchar(1000) ccsid(819);
  dcl-ds routing likeds(routing_t) based(pRouting);
  
  httpMessage = 'GET /Time HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + CRLF;
  request = createRequest(httpMessage);
  
  pRouting = findRoute(%addr(config) : %addr(request));
  assert(pRouting = *null : 'Should have found no end point.');
  
  on-exit abnormallyEnded;
    disposeRequest(request);
end-proc;


dcl-proc test_root export;
  dcl-s abnormallyEnded ind;
  dcl-ds request likeds(il_request);
  dcl-s matchingRoute pointer(*proc);
  dcl-s httpMessage varchar(1000) ccsid(819);
  dcl-ds routing likeds(routing_t) based(pRouting);
  
  httpMessage = 'GET / HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + CRLF;
  request = createRequest(httpMessage);
  
  pRouting = findRoute(%addr(config) : %addr(request));
  matchingRoute = routing.servlet;
  assert(matchingRoute = %paddr(routeRoot) : 'Returned not root end point.');
  
  on-exit abnormallyEnded;
    disposeRequest(request);
end-proc;


dcl-proc setup export;
  il_addRoute(config : %paddr(routeRoot) : IL_ANY : REGEX_START + '/' + DOLLAR);
  il_addRoute(config : %paddr(routeTime) : IL_GET : REGEX_START + '/time' + DOLLAR);
  il_addRoute(config : %paddr(routeConfig) : IL_GET : REGEX_START + '/config/' + 
      BRACKET_OPEN + 'a-zA-Z0-9_' + BRACKET_CLOSE + CURLY_OPEN + '1,10' + CURLY_CLOSE + DOLLAR);
end-proc;


dcl-proc teardown export;
  clear config;
end-proc;


dcl-proc routeTime;
  dcl-pi *n;
    request  likeds(il_request);
    response likeds(il_response);
  end-pi;

  il_responseWrite(response : %char(%time()));
end-proc;


dcl-proc routeDate;
  dcl-pi *n;
    request  likeds(il_request);
    response likeds(il_response);
  end-pi;

  il_responseWrite(response : %char(%date() : *EUR));
end-proc;


dcl-proc routeRoot;
  dcl-pi *n;
    request  likeds(il_request);
    response likeds(il_response);
  end-pi;

  il_responseWrite(response : 'nothing');
end-proc;


dcl-proc routeConfig;
  dcl-pi *n;
    request  likeds(il_request);
    response likeds(il_response);
  end-pi;

  il_responseWrite(response : 'configuration');
end-proc;


dcl-proc createRequest;
  dcl-pi *n likeds(il_request);
    httpMessage varchar(1000) ccsid(819);
  end-pi;

  dcl-ds request likeds(il_request) inz;
  dcl-ds headerList likeds(il_varchar) based(headerListPtr);
  
  request.config = %alloc(%size(il_config));
    
  lookForHeaders(%addr(request) : %addr(httpMessage : *data) : %len(httpMessage));
  
  return request;
end-proc;


dcl-proc disposeRequest;
  dcl-pi *n;
    request likeds(il_request);
  end-pi;
  
  dealloc request.config;
  sList_free(request.headerList);
end-proc;
