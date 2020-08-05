**FREE

/if defined (ILJWTPLUG)
/eof
/endif

/define ILJWTPLUG

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


///
// Set Sign Key
//
// Sets the sign key which will be used on verification and signing of JWT tokens.
//
// @param Sign key
///
dcl-pr il_jwt_setSignKey extproc(*dclcase);
  signKey like(jwt_signKey_t) const ccsid(*utf8);
end-pr;


///
// JWT Filter
//
// This plugin filters the JWT token from the response and adds the token and
// the payload to the thread local memory.
//
// @param Request
// @param Response
// @return *on = the request is valid and can be passed to the next plugin/servlet
//         else *off
///
dcl-pr il_jwt_filter ind extproc(*dclcase);
  request  likeds(IL_REQUEST);
  response likeds(IL_RESPONSE);
end-pr;

