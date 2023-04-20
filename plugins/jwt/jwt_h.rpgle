**FREE

/if defined (JWT)
/eof
/endif

/define JWT

///
// ILEastic : JWT Service Program
//
// This service program offers procedures for signing and verifying JWT tokens.
//
// The padding character = is stripped from the end of the token.
//
// @info Only HS256 is supported.
//
// @author Mihael Schmidt
// @date   04.05.2019
// @project ILEastic
//
// @rev 06.06.2020 Mihael Schmidt
//      Added registered claims to token generation.
///

///
// HMAC SHA256 algorithm for creating the token signature.
///
dcl-c JWT_HS256 'HS256';
dcl-c JWT_RS256 'RS256';
dcl-c JWT_RS384 'RS256';
dcl-c JWT_RS512 'RS512';

///
// Template for JWT token.
///
dcl-s jwt_token_t varchar(8090) template;

///
// Template for the signing key which is used to create the token signature.
///
dcl-s jwt_signKey_t varchar(1000) template;

///
// Template for registered claims. The data structure needs to be created with
// inz(*likeds). Default values mean that the claim will not be added to the
// token. Note: Fields are varchar and any space will be added to the token, use
// %trimr if you are using char variables.
///
dcl-ds jwt_claims_t qualified template;
  issuer varchar(1000) inz;
  subject varchar(1000) inz;
  audience varchar(1000) inz;
  expirationTime timestamp inz(*loval);
  notBefore timestamp inz(*loval);
  issuedAt timestamp inz(*loval);
  jwtId varchar(1000) inz;
end-ds;

///
// Tempalte for Public/Private keys or authorization URI.
dcl-ds jwt_keyOrUriDs_t qualified template;
    kid         Char(50);
    method      Char(5);  //KEY for public key 'or' PROC for authorization end-point
    //We are binding key to a fixed alg to avoid bad actors using public key to symmetric
    // encryption to get access. https://auth0.com/blog/critical-vulnerabilities-in-json-web-token-libraries/
    // This is not an implementation requirement, but we are placing this restriction for safety.
    alg         Char(5);
    key         Char(5000) ccsid(819); //Public key for Asymetric alg, key for Symetric alg
    procPtr     pointer(*PROC);  // Call back proc for token validation. Caller will have to implement
end-ds;

///
// Verify token
//
// Verifies the token validity. It also checks if it is expired if the token
// contains an "exp" claim. The "exp" claim is expected to be a number
// representing the seconds from the Unix Epoch UTC.
//
// @param Token
// @param Signing key
// @return *on = valid and not expired else *off
///
dcl-pr jwt_verify ind extproc(*dclcase);
  token like(jwt_token_t) const ccsid(*utf8);
  //signKey like(jwt_signKey_t) const ccsid(*utf8);
  keyOrUriDs likeDs(jwt_keyOrUriDs_t) const;
  noCaching  Ind  Options(*NoPass : *Omit) const; // for future
end-pr;

///
// Decode header
//
// Returns the decoded header from the passed token.
//
// @param Token
// @return Decoded header
///
dcl-pr jwt_decodeHeader like(jwt_token_t) ccsid(*utf8) extproc(*dclcase);
  token like(jwt_token_t) const ccsid(*utf8);
end-pr;

///
// Decode payload
//
// Returns the decoded payload from the passed token.
//
// @param token
// @return Decoded payload
///
dcl-pr jwt_decodePayload like(jwt_token_t) ccsid(*utf8) extproc(*dclcase);
  token like(jwt_token_t) const ccsid(*utf8);
end-pr;

///
// Create JWT token
//
// Creates a JWT token by creating a signature from the header + payload with
// the passed signing key. If the claims data structure is passed then every
// non-default value will be added to the token payload.
//
// @param Algorithm (HS256)
// @param Payload
// @param Signing key (it has to be of a valid length corresponding to the
//        selected algorithm (HS256 => 256 key = char(32))
// @param Registered claims
// @return Signed token
//
// @info At the moment only HS256 is supported for signature creation.
///
dcl-pr jwt_sign like(jwt_token_t) ccsid(*utf8) extproc(*dclcase);
  algorithm char(100) const;
  payload like(jwt_token_t) const ccsid(*utf8);
  signKey like(jwt_signKey_t) const ccsid(*utf8);
  claims likeds(jwt_claims_t) const options(*nopass);
end-pr;

///
// Check token expiration
//
// Checks if the token is expired. If the token contains no "exp" claim the
// token is has not expired.
//
// @param Payload
// @return *on = token has expired else *off
///
dcl-pr jwt_isExpired ind extproc(*dclcase);
  payload like(jwt_token_t) const ccsid(*utf8);
end-pr;
