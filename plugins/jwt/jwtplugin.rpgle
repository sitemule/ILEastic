**FREE

///
// ILEastic : JWT Token Filter
//
// The filter looks for a HTTP header with the key "Authorization" with an 
// authorization type "Bearer" for a JWT token string.
// 
// The JWT token payload is stored in the thread local memory under 
// /ileastic/jwt/payload. The whole token is available under 
// /ileastic/jwt/token.
//
// @author Mihael Schmidt
// @date 04.05.2019
// @project ILEastic
///


ctl-opt nomain thread(*concurrent);


/include 'headers/ileastic.rpgle'
/include 'noxdb/headers/jsonparser.rpgle'
/include 'jwt_h.rpgle'
/include 'jwtplugin_h.rpgle'

  
dcl-s signKey like(jwt_signKey_t) static(*allthread) ccsid(*utf8);


dcl-proc il_jwt_setSignKey export;
  dcl-pi *n;
    pSignKey like(jwt_signKey_t) const;
  end-pi;
  
  signKey = pSignKey;
end-proc;


dcl-proc il_jwt_filter export;
  dcl-pi *n ind;
    request  likeds(IL_REQUEST);
    response likeds(IL_RESPONSE);
  end-pi;

  dcl-s validRequest ind inz(*off);
  dcl-s token like(jwt_token_t);
  dcl-s payload like(jwt_token_t);
  dcl-s json pointer;
  dcl-s threadLocal pointer;
  dcl-s jwtNode pointer;

  // Check if the client id is a valid value
  monitor;
    token = getToken(request);
    if (token = *blank);
      response.status = 401;
      il_responseWrite(response : 'No JWT token provided.');
      return validRequest;
    endif;

    if (isValidToken(token));
      payload = jwt_decodePayload(token);
      json = json_parseString(payload);

      threadLocal = il_getThreadMem(request);
      jwtNode = json_LocateOrCreate(threadLocal : '/ileastic/jwt');
      json_MoveObjectInto(jwtNode : 'payload' : json);
      json_setStr(jwtNode : 'token' : token);

      // Everything is ok => request can be passed to the next plugin and/or
      // routed to the servlet
      validRequest = *on;
    else;
      response.status = 401;
      il_responseWrite(response : 'Invalid JWT token provided.');
    endif;

  on-error *all;
    // Else return an error code to the caller: 500
    response.status = 500;
    response.statusText = 'Internal Server Error';
    il_responseWrite(response : 'Could not process request for JWT token.');
  endmon;

  return validRequest;
end-proc;


dcl-proc isValidToken;
  dcl-pi *n ind;
    token like(jwt_token_t) const;
  end-pi;

  dcl-s valid ind inz(*off);
  dcl-s payload like(jwt_token_t);

  if (jwt_verify(token : signKey));
    valid = *on;
  endif;

  return valid;
end-proc;


dcl-proc getToken;
  dcl-pi *n like(jwt_token_t);
    request likeds(il_request);
  end-pi;

  dcl-c UPPER 'ABER';
  dcl-c LOWER 'aber';

  dcl-s header like(jwt_token_t);
  dcl-s type char(10);

  header = il_getRequestHeader(request : 'Authorization');
  if (header <> *blank and %len(header) > 7);
    type = %subst(header : 1 : 7);
    type = %xlate(UPPER : LOWER : type);
    if (type = 'bearer ');
      return %subst(header : 8);
    endif;
  endif;

  return *blank;
end-proc;
