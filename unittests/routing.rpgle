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

// SERVLET findRoute(PSLIST pRouts, LVARPUCHAR resource);
dcl-pr findRoute pointer(*proc) extproc(*dclcase);
  router pointer value;
  resource pointer value;
end-pr;

dcl-s CRLF char(2) inz(x'0d0a') ccsid(819); 


dcl-pr test_exactMatch end-pr;


dcl-proc test_exactMatch export;
  dcl-ds config likeds(il_config) inz;
  dcl-ds resource likeds(il_varchar) inz;
  dcl-s matchingRoute pointer(*proc);
  
  resouce.string = %alloc(100);
  %str(resource.string) = '/index.html';
  resource.length = 11;
  
  il_addRoute(config : %paddr(routeIndex) : IL_ANY : '/index.html');
  il_addRoute(config : %paddr(routeTime) : IL_GET : '/time');
  il_addRoute(config : %paddr(routeDate) : IL_GET : '/date');
  
  matchingRoute = findRoute(config, %addr(resource));
  assert(matchingRoute = %paddr(routeIndex));
  
  dealloc resource.string;
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


dcl-proc routeIndex;
  dcl-pi *n;
    request  likeds(il_request);
    response likeds(il_response);
  end-pi;

  il_responseWrite(response : 'nothing');
end-proc;
