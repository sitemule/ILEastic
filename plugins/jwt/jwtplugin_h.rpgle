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
// Data structure to return JWKS end point contents.
  dcl-ds jwksDs_t  qualified Template;
    KeyTp      Char(5);
    KeyId      Char(50);
    Usage      Char(5);
    Key        Char(5000) ccsid(*utf8);
    Alg        Char(5);
  end-ds;

///
// Set Sign Key
//
// Sets the sign key which will be used on verification and signing of JWT tokens.
//
// @param Sign key
///
//dcl-pr il_jwt_setSignKey extproc(*dclcase);
//  signKey like(jwt_signKey_t) const ccsid(*utf8);
//end-pr;


///
// Add verify key structure in ASCII format
//
// This procedure enable to store public key in PEM format for JWT verification
//
// @param key value in ASCII
// @param alg 5 char algorith name where the key be used.
// @param kid key id
// @param reset list * On = clear/reset the list, default is *Off
///
dcl-pr il_jwt_addKey extproc(*dclcase);
  key         Char(5000) ccsid(*utf8) const;    // CCSID must be 819
  alg         Char(5) const;  // https://www.rfc-editor.org/rfc/rfc7518#section-3.1
  kid         Char(50) Options(*NoPass : *Omit) const;  // *DEFAULT or kid value
  resetList   Ind Options(*NoPass : *Omit) const; // Reset key list. Default is *OFF;
end-pr;

///
// Register an authorization end point
//
// Below procedure register your IdP authorization end point that will enable
//  exteranl Rest call to validate JWT
//
// @param procPtr client supplied data retrieval proc ptr
// @param alg 5 char algorith name where the key be used.
// @param kid key id
// @param reset list * On = clear/reset the list, default is *Off
//
dcl-pr il_jwt_addAuthorization_endpoint extproc(*dclcase);
  procPtr     pointer(*PROC) value;  // Procedure implemented with your IdP's authorization endpoint
  alg         Char(5) const;
  kid         Char(50) Options(*NoPass : *Omit) const;  // *DEFAULT or kid value
  resetList   Ind Options(*NoPass : *Omit) const; // Reset key list. Default is *OFF;
end-pr;

///
// Register a key from PEM file under IFS
//
// Below procedure register a key from IFS located PEM file
//
// @param fileLoc IFS location where PEM file is located.
// @param alg 5 char algorith name where the key be used.
// @param kid key id
// @param reset list * On = clear/reset the list, default is *Off
//
dcl-pr il_jwt_addVerifyStructFromPEMFile extproc(*dclcase);
  fileLoc     Char(250) const;  // IFS fle location, CCSID must be 819
  alg         Char(5) const;
  kid         Char(50) Options(*NoPass : *Omit) const;  // *DEFAULT or kid value
  resetList   Ind Options(*NoPass : *Omit) const; // Reset key list. Default is *OFF;
end-pr;

///
// Register one or more keys from JWKS endpoint
//
// Below procedure register keys from your IdP JWKS end point
//
// @param procPtr client supplied data retrieval proc ptr
// @param reset list * On = clear/reset the list, default is *Off
//
dcl-pr il_jwt_addVerifyStructFromJWKS extproc(*dclcase);
  procPtr     pointer(*PROC) value;  // procedure to retrieve your IdP's JWKS endpoint
  resetList   Ind Options(*NoPass : *Omit); // Reset key list. Default is *OFF;
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
