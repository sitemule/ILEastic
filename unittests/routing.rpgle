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
dcl-pr test_exactMatch end-pr;

// SERVLET findRoute(PSLIST pRouts, LVARPUCHAR resource);
dcl-pr findRoute pointer(*proc) extproc(*dclcase);
  config pointer value;
  resource likeds(il_varchar) value;
end-pr;

dcl-s CRLF char(2) inz(x'0d0a') ccsid(819); 
dcl-ds config likeds(il_config) inz;

dcl-pr memcpy pointer extproc('memcpy');
  dest pointer value;
  source pointer value;
  count  uns(10) value;
end-pr;

     
//
// Test Procedures
//
dcl-proc test_exactMatch export;
  dcl-s abnormallyEnded ind;
  dcl-ds resource likeds(il_varchar) inz;
  dcl-s matchingRoute pointer(*proc);
  dcl-s path char(100) ccsid(*utf8);
  
  path = '/index.html';
  resource.string = %alloc(100);
  memcpy(resource.string : %addr(path) : %len(%trimr(path)));
  resource.length = %len(%trimr(path));
  
  matchingRoute = findRoute(%addr(config) : resource);
  if (matchingRoute = *null);
    dsply 'nothing';
  endif;
  assert(matchingRoute = %paddr(routeIndex) : 'Returned wrong end point.');
  
  on-exit abnormallyEnded;
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
  il_addRoute(config : %paddr(routeIndex) : IL_ANY : '/index.html');
  il_addRoute(config : %paddr(routeTime) : IL_GET : '/time');
  il_addRoute(config : %paddr(routeDate) : IL_GET : '/date');
end-proc;


dcl-proc teardown export;
  
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
