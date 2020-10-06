**FREE

///
// ILEastic : CORS Plugin
//
// This plugin adds CORS-Headers to a Request.
//
// @author Paul Siefke
// @date 2020-07-31
///


ctl-opt nomain thread(*concurrent);


/include 'headers/ileastic.rpgle'
/include 'cors_h.rpginc'


///
// CORS support
//
// In the current Version this procedure adds the following Headers:
// - Access-Control-Allow-Origin
// - Access-Control-Allow-Headers
// - Access-Control-Allow-Methods
// - Access-Control-Expose-Headers
// All of these Headers are set to * at the Moment.
//
//
// @param ILEastic requesthandle
// @param ILEastic responsehandle
///
dcl-proc il_addCorsHeaders export;
  dcl-pi *n ind;
    request  likeds(il_request);
    response likeds(il_response);
  end-pi;
//---
  dcl-s success ind inz(*off);

  monitor;
    //TODO: add support for dynamic set headers
    il_addHeader(response: IL_HEADERS_CORS_ALLOW_HEADERS: '*');
    il_addHeader(response: IL_HEADERS_CORS_ALLOW_METHODS: '*');
    il_addHeader(response: IL_HEADERS_CORS_ALLOW_ORIGIN: '*');
    il_addHeader(response: IL_HEADERS_CORS_EXPOSE_HEADERS: '*');
    success = *on;
  on-error;
      success = *off;
  endMon;

  return success;
//---
end-proc; 