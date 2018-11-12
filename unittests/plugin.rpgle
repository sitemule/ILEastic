**FREE

///
// Plugin Test
//
// The execution and chaining of plugins is tested in this module.
//
// @author Mihael Schmidt
// @date   12.11.2018
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
dcl-pr test_noPlugins end-pr;
dcl-pr test_pluginPass end-pr;
dcl-pr test_pluginFail end-pr;
dcl-pr test_pluginChainPass end-pr;
dcl-pr test_pluginChainFailFirst end-pr;
dcl-pr test_pluginChainFailLast end-pr;


// lookForHeaders ( PREQUEST pRequest, PUCHAR buf , ULONG bufLen)
dcl-pr lookForHeaders extproc(*CWIDEN:*dclcase);
  request pointer value;
  buffer pointer value;
  bufferLength uns(10) value;
end-pr;

//BOOL runPlugins (PSLIST plugins , PREQUEST pRequest, PRESPONSE pResponse)
dcl-pr runPlugins int(3) extproc(*CWIDEN:*dclcase);
  plugins pointer value;
  request pointer value;
  response pointer value;
end-pr;

dcl-pr sList_new pointer extproc(*dclcase) end-pr;
dcl-pr sList_free extproc(*dclcase);
  list pointer value;
end-pr;
dcl-pr sList_push pointer extproc(*dclcase);
  list pointer value;
  length int(10) value;
  data pointer value;
  head ind value;
end-pr;

dcl-ds plugin_t qualified template;
  pluginType int(5);
  procedure pointer(*proc);
end-ds;

dcl-s CRLF char(2) inz(x'0d0a') ccsid(819);

dcl-s plugins pointer;
dcl-ds request likeds(il_request);
dcl-ds response likeds(il_response) inz;


//
// Procedures
//
dcl-proc test_noPlugins export;
  iEqual(1 : runPlugins(plugins : %addr(request) : %addr(response)));
end-proc;


dcl-proc test_pluginPass export;
  dcl-s returnCode int(3);
  dcl-ds plugin likeds(plugin_t) inz;
  
  plugin.pluginType = IL_PREREQUEST;
  plugin.procedure = %paddr(plugin_pass);
  sList_push(plugins : %size(plugin_t) : %addr(plugin) : *off);
 
  returnCode = runPlugins(plugins : %addr(request) : %addr(response));
 
  iEqual(1 : returnCode);
end-proc;


dcl-proc test_pluginFail export;
  dcl-s returnCode int(3);
  dcl-ds plugin likeds(plugin_t) inz;
 
  plugin.pluginType = IL_PREREQUEST;
  plugin.procedure = %paddr(plugin_fail);
  sList_push(plugins : %size(plugin_t) : %addr(plugin) : *off);
 
  returnCode = runPlugins(plugins : %addr(request) : %addr(response));
 
  iEqual(0 : returnCode);
end-proc;


dcl-proc test_pluginChainPass export;
  dcl-s returnCode int(3);
  dcl-ds plugin likeds(plugin_t);
 
  clear plugin;
  plugin.pluginType = IL_PREREQUEST;
  plugin.procedure = %paddr(plugin_pass);
  sList_push(plugins : %size(plugin_t) : %addr(plugin) : *off);
 
  clear plugin;
  plugin.pluginType = IL_PREREQUEST;
  plugin.procedure = %paddr(plugin_filterClient1);
  sList_push(plugins : %size(plugin_t) : %addr(plugin) : *off);
 
  returnCode = runPlugins(plugins : %addr(request) : %addr(response));
 
  iEqual(1 : returnCode);
end-proc;


dcl-proc test_pluginChainFailFirst export;
  dcl-s returnCode int(3);
  dcl-ds plugin likeds(plugin_t);
 
  clear plugin;
  plugin.pluginType = IL_PREREQUEST;
  plugin.procedure = %paddr(plugin_fail);
  sList_push(plugins : %size(plugin_t) : %addr(plugin) : *off);
 
  clear plugin;
  plugin.pluginType = IL_PREREQUEST;
  plugin.procedure = %paddr(plugin_shouldNotReach);
  sList_push(plugins : %size(plugin_t) : %addr(plugin) : *off);
 
  returnCode = runPlugins(plugins : %addr(request) : %addr(response));
 
  iEqual(0 : returnCode);
end-proc;


dcl-proc test_pluginChainFailLast export;
  dcl-s returnCode int(3);
  dcl-ds plugin likeds(plugin_t);
 
  clear plugin;
  plugin.pluginType = IL_PREREQUEST;
  plugin.procedure = %paddr(plugin_pass);
  sList_push(plugins : %size(plugin_t) : %addr(plugin) : *off);
 
  clear plugin;
  plugin.pluginType = IL_PREREQUEST;
  plugin.procedure = %paddr(plugin_fail);
  sList_push(plugins : %size(plugin_t) : %addr(plugin) : *off);
 
  returnCode = runPlugins(plugins : %addr(request) : %addr(response));
 
  iEqual(0 : returnCode);
end-proc;


dcl-proc plugin_filterClient1;
  dcl-pi *n ind;
    request likeds(il_request);
    response likeds(il_response);
  end-pi;

  dcl-s clientId varchar(50) ccsid(*utf8);
  clientId = il_getParmStr(request : 'client');
  return clientId = '1';
end-proc;


dcl-proc plugin_shouldNotReach;
  dcl-pi *n ind;
    request likeds(il_request);
    response likeds(il_response);
  end-pi;

  fail('This plugin should not have been reached.');
  return *off;
end-proc;


dcl-proc plugin_pass;
  dcl-pi *n ind;
    request likeds(il_request);
    response likeds(il_response);
  end-pi;

  return *on;
end-proc;


dcl-proc plugin_fail;
  dcl-pi *n ind;
    request likeds(il_request);
    response likeds(il_response);
  end-pi;

  return *off;
end-proc;


dcl-proc parseHttpMessage;
  dcl-s httpMessage varchar(1000) ccsid(819);
 
  httpMessage = 'GET /index.html?client=1&callback=angular.callback.1 HTTP/1.1' +
      CRLF + 'Host: localhost' + CRLF + CRLF;
  lookForHeaders(%addr(request) : %addr(httpMessage : *data) : %len(httpMessage));
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
  plugins = sList_new();
  
  parseHttpMessage();
end-proc;


dcl-proc teardown export;
  disposeRequest(request);
  sList_free(plugins);
end-proc;
