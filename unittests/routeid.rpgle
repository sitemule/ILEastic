**FREE

///
// Route Id Test
//
// The setting and retrieving of the route id is tested.
//
// @author Mihael Schmidt
// @date   22.09.2022
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
dcl-pr setupSuite end-pr;
dcl-pr teardownSuite end-pr;
dcl-pr test_noRouteIdOnFirstResource end-pr;
dcl-pr test_routeIdOnFirstResource end-pr;
dcl-pr test_routeIdOnSecondResource end-pr;
dcl-pr test_routeIdOnThirdResource end-pr;
dcl-pr test_routeIdOnOuterResource end-pr;


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

dcl-ds routing_t qualified template align(*full);
  routeType int(5);
  routeReqex pointer;
  contentRegex pointer;
  servlet pointer(*proc);
  parmNumbers int(10);
  parmNames pointer dim(256);
  routeId varchar(256);
end-ds;

dcl-s CRLF char(2) inz(x'0d0a') ccsid(819); 

dcl-c REGEX_START u'005E';
dcl-c BRACKET_OPEN u'005B';
dcl-c BRACKET_CLOSE u'005D';
dcl-c CURLY_OPEN u'007B';
dcl-c CURLY_CLOSE u'007D';
dcl-c DOLLAR u'0024';

dcl-s firstHttpMessage varchar(1000) ccsid(819);
dcl-ds firstRequest likeds(il_request);
dcl-s secondHttpMessage varchar(1000) ccsid(819);
dcl-ds secondRequest likeds(il_request);
dcl-s thirdHttpMessage varchar(1000) ccsid(819);
dcl-ds thirdRequest likeds(il_request);

dcl-pr sList_free extproc(*dclcase);
  list pointer value;
end-pr;

//
// Test Procedures
//
dcl-proc test_noRouteIdOnFirstResource export;
  dcl-ds routing likeds(routing_t) based(pRouting);
  dcl-ds config likeds(il_config) inz;
  
  il_addRoute(config : %paddr(routeFirst) : IL_ANY : REGEX_START + '/first' + DOLLAR);
  il_addRoute(config : %paddr(routeSecond) : IL_ANY : REGEX_START + '/second' + DOLLAR);
  il_addRoute(config : %paddr(routeThird) : IL_ANY : REGEX_START + '/third' + DOLLAR);
  
  pRouting = findRoute(%addr(config) : %addr(firstRequest));
  assert(pRouting <> *null : 'No route found.');
  assert(routing.servlet = %paddr(routeFirst) : 'Wrong route.');
  assert(routing.routeId = '' : 'Wrong route id in routing information on first route.');
  
  pRouting = findRoute(%addr(config) : %addr(secondRequest));
  assert(pRouting <> *null : 'No route found.');
  assert(routing.servlet = %paddr(routeSecond) : 'Wrong route.');
  assert(routing.routeId = '' : 'Wrong route id in routing information on second route.');
  
  pRouting = findRoute(%addr(config) : %addr(thirdRequest));
  assert(pRouting <> *null : 'No route found.');
  assert(routing.servlet = %paddr(routeThird) : 'Wrong route.');
  assert(routing.routeId = '' : 'Wrong route id in routing information on third route.');
end-proc; 


dcl-proc test_routeIdOnFirstResource export;
  dcl-ds routing likeds(routing_t) based(pRouting);
  dcl-ds config likeds(il_config) inz;
  
  il_addRoute(config : %paddr(routeFirst) : IL_ANY : REGEX_START + '/first' + DOLLAR : *omit : 'first');
  il_addRoute(config : %paddr(routeSecond) : IL_ANY : REGEX_START + '/second' + DOLLAR);
  il_addRoute(config : %paddr(routeThird) : IL_ANY : REGEX_START + '/third' + DOLLAR);
  
  pRouting = findRoute(%addr(config) : %addr(firstRequest));
  assert(pRouting <> *null : 'No route found.');
  assert(routing.servlet = %paddr(routeFirst) : 'Wrong route.');
  assert(routing.routeId = 'first' : 'Wrong route id in routing information on first route: ' + routing.routeId);
  
  pRouting = findRoute(%addr(config) : %addr(secondRequest));
  assert(pRouting <> *null : 'No route found.');
  assert(routing.servlet = %paddr(routeSecond) : 'Wrong route.');
  assert(routing.routeId = '' : 'Wrong route id in routing information on second route: ' + routing.routeId);
  
  pRouting = findRoute(%addr(config) : %addr(thirdRequest));
  assert(pRouting <> *null : 'No route found.');
  assert(routing.servlet = %paddr(routeThird) : 'Wrong route.');
  assert(routing.routeId = '' : 'Wrong route id in routing information on third route: ' + routing.routeId);
end-proc; 


dcl-proc test_routeIdOnSecondResource export;
  dcl-ds routing likeds(routing_t) based(pRouting);
  dcl-ds config likeds(il_config) inz;
  
  il_addRoute(config : %paddr(routeFirst) : IL_ANY : REGEX_START + '/first' + DOLLAR);
  il_addRoute(config : %paddr(routeSecond) : IL_ANY : REGEX_START + '/second' + DOLLAR : *omit : 'second');
  il_addRoute(config : %paddr(routeThird) : IL_ANY : REGEX_START + '/third' + DOLLAR);
  
  pRouting = findRoute(%addr(config) : %addr(firstRequest));
  assert(pRouting <> *null : 'No route found.');
  assert(routing.servlet = %paddr(routeFirst) : 'Wrong route.');
  assert(routing.routeId = '' : 'Wrong route id in routing information on first route: ' + routing.routeId);
  
  pRouting = findRoute(%addr(config) : %addr(secondRequest));
  assert(pRouting <> *null : 'No route found.');
  assert(routing.servlet = %paddr(routeSecond) : 'Wrong route.');
  assert(routing.routeId = 'second' : 'Wrong route id in routing information on second route: ' + routing.routeId);
  
  pRouting = findRoute(%addr(config) : %addr(thirdRequest));
  assert(pRouting <> *null : 'No route found.');
  assert(routing.servlet = %paddr(routeThird) : 'Wrong route.');
  assert(routing.routeId = '' : 'Wrong route id in routing information on third route: ' + routing.routeId);
end-proc;


dcl-proc test_routeIdOnThirdResource export;
  dcl-ds routing likeds(routing_t) based(pRouting);
  dcl-ds config likeds(il_config) inz;
  
  il_addRoute(config : %paddr(routeFirst) : IL_ANY : REGEX_START + '/first' + DOLLAR);
  il_addRoute(config : %paddr(routeSecond) : IL_ANY : REGEX_START + '/second' + DOLLAR);
  il_addRoute(config : %paddr(routeThird) : IL_ANY : REGEX_START + '/third' + DOLLAR : *omit : 'third');
  
  pRouting = findRoute(%addr(config) : %addr(firstRequest));
  assert(pRouting <> *null : 'No route found.');
  assert(routing.servlet = %paddr(routeFirst) : 'Wrong route.');
  assert(routing.routeId = '' : 'Wrong route id in routing information on first route: ' + routing.routeId);
  
  pRouting = findRoute(%addr(config) : %addr(secondRequest));
  assert(pRouting <> *null : 'No route found.');
  assert(routing.servlet = %paddr(routeSecond) : 'Wrong route.');
  assert(routing.routeId = '' : 'Wrong route id in routing information on second route: ' + routing.routeId);
  
  pRouting = findRoute(%addr(config) : %addr(thirdRequest));
  assert(pRouting <> *null : 'No route found.');
  assert(routing.servlet = %paddr(routeThird) : 'Wrong route.');
  assert(routing.routeId = 'third' : 'Wrong route id in routing information on third route: ' + routing.routeId);
end-proc; 


dcl-proc test_routeIdOnOuterResource export;
  dcl-ds routing likeds(routing_t) based(pRouting);
  dcl-ds config likeds(il_config) inz;
  
  il_addRoute(config : %paddr(routeFirst) : IL_ANY : REGEX_START + '/first' + DOLLAR : *omit : 'first');
  il_addRoute(config : %paddr(routeSecond) : IL_ANY : REGEX_START + '/second' + DOLLAR);
  il_addRoute(config : %paddr(routeThird) : IL_ANY : REGEX_START + '/third' + DOLLAR : *omit : 'third');
  
  pRouting = findRoute(%addr(config) : %addr(firstRequest));
  assert(pRouting <> *null : 'No route found.');
  assert(routing.servlet = %paddr(routeFirst) : 'Wrong route.');
  assert(routing.routeId = 'first' : 'Wrong route id in routing information on first route: ' + routing.routeId);
  
  pRouting = findRoute(%addr(config) : %addr(secondRequest));
  assert(pRouting <> *null : 'No route found.');
  assert(routing.servlet = %paddr(routeSecond) : 'Wrong route.');
  assert(routing.routeId = '' : 'Wrong route id in routing information on second route: ' + routing.routeId);
  
  pRouting = findRoute(%addr(config) : %addr(thirdRequest));
  assert(pRouting <> *null : 'No route found.');
  assert(routing.servlet = %paddr(routeThird) : 'Wrong route.');
  assert(routing.routeId = 'third' : 'Wrong route id in routing information on third route: ' + routing.routeId);
end-proc;


dcl-proc setupSuite export;
  // the HTTP message strings needs to be available throughout the whole unit test 
  // as the request does not copy the string but just points to its memory address
  firstHttpMessage = 'GET /first HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + CRLF;
  firstRequest = createRequest(firstHttpMessage);
  secondHttpMessage = 'GET /second HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + CRLF;
  secondRequest = createRequest(secondHttpMessage);
  thirdHttpMessage = 'GET /third HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + CRLF;
  thirdRequest = createRequest(thirdHttpMessage);
end-proc;


dcl-proc teardownSuite export;
  disposeRequest(firstRequest);
  disposeRequest(secondRequest);
  disposeRequest(thirdRequest);
end-proc;


dcl-proc routeFirst;
  dcl-pi *n;
    request  likeds(il_request);
    response likeds(il_response);
  end-pi;

  il_responseWrite(response : 'first');
end-proc;


dcl-proc routeSecond;
  dcl-pi *n;
    request  likeds(il_request);
    response likeds(il_response);
  end-pi;

  il_responseWrite(response : 'second');
end-proc;


dcl-proc routeThird;
  dcl-pi *n;
    request  likeds(il_request);
    response likeds(il_response);
  end-pi;

  il_responseWrite(response : 'third');
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