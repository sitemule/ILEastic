**FREE

///
// ILEastic : BasicAuth Plugin
//
// This module is an ILEastic plugin which retrieves the BasicAuth information
// from a HTTP request and stores the credentials in the thread local memory
// of the request.
//
// /ileastic/auth/username and /ileastic/auth/password
//
// Access to the thread local memory can be achieved through the procedure
// il_getThreadMem(request). It returns a json graph from the noxDB project.
// The single values from the graph can be retrieved with
// jx_getStr(json : '/ileastic/auth/username') to get the username f. e. .
//
// @author Mihael Schmidt
// @date   05.03.2019
//
// @info The realm should be set with il_basicauth_setRealm().
//
// @info The plugin should be registered on the IL_PREREQUEST event.
//
// @warning The credentials need to be in UTF-8 before being Base64 encoded.
///


ctl-opt nomain thread(*concurrent);


/include 'basicauth_h.rpgle'
/include 'headers/ileastic.rpgle'
/include 'noxDB/headers/JSONXML.rpgle'

dcl-pr il_basicauth ind extproc(*dclcase);
  request  likeds(il_request);
  response likeds(il_response);
end-pr;
  

dcl-s realm varchar(100) inz('unknown') static(*allthread);


///
// BasicAuth support
//
// The username and password will be extracted from the HTTP headers and put
// into the thread local storage of the request. If the credentials cannot 
// be fetched from the HTTP headers a 401 HTTP message will be sent.
//
// @param Request
// @param Response
///
dcl-proc il_basicauth export;
  dcl-pi *n ind;
    request  likeds(il_request);
    response likeds(il_response);
  end-pi;

  dcl-s basicAuthHeader varchar(4094:2);
  dcl-s decodedHeader varchar(4094:2);
  dcl-s x int(10);
  dcl-s username varchar(4094:2);
  dcl-s password varchar(4094:2);
  dcl-s json pointer;

  basicAuthHeader = il_getRequestHeader(request : 'Authorization');
  if (basicAuthHeader = *blank);
    sendUnauthorizedResponse(request : response);
  else;
    if (isAuthTypeBasic(basicAuthHeader));
      x = %scan(' ' : basicAuthHeader);
      decodedHeader = il_decodeBase64(%trim(%subst(basicAuthHeader : x+1)));

      x = %scan(':' : decodedHeader);
      if (x = 0);
        username = decodedHeader;
      else;
        username = %subst(decodedHeader : 1 : x-1);
        password = %subst(decodedHeader : x+1);
      endif;

      json = il_getThreadMem(request);
      jx_setStr(json : '/ileastic/auth/username' : username);
      if (password <> *blank);
        jx_setStr(json : '/ileastic/auth/password' : password);
      endif;

      return *on;

    else;
      sendUnauthorizedResponse(request : response);
    endif;
  endif;

  return *off;
end-proc;


dcl-proc il_basicauth_setRealm export;
  dcl-pi *n;
    pRealm like(realm) const;
  end-pi;
  
  realm = pRealm;
end-proc;


dcl-proc isAuthTypeBasic;
  dcl-pi *n ind;
    header varchar(4094:2) const;
  end-pi;

  dcl-c UPPER 'BASIC';
  dcl-c LOWER 'basic';
  dcl-s authType char(10);
  dcl-s x int(10);
  
  x = %scan(' ' : header);
  if (x > 0);
    authType = %trim(%subst(header : 1 : x-1));
    authType = %xlate(UPPER : LOWER : authType);
    
    return authType = 'basic';
  endif;
  
  return *off;
end-proc;


dcl-proc sendUnauthorizedResponse;
  dcl-pi *n;
    request  likeds(il_request);
    response likeds(il_response);
  end-pi;

  // return 401 with the http header: WWW-Authenticate: Basic realm="User Visible Realm", charset="UTF-8"
  response.status = 401;
  response.statusText = 'Unauthorized';
  il_addHeader(response : 'WWW-Authenticate' : 'Basic realm="' + realm + '", charset="UTF-8"');
  il_responseWrite(response : 'Invalid Authorization');
end-proc;
