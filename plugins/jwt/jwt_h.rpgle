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
// @info The token generated with this service program are not necessarily 
//       compatible with every JWT library because the parts of the token are 
//       base64 encoded and some libraries use base64url encoding which is 
//       not really compatible with base64 (see characters / and + which are 
//       replace with - and _).
//
// @info At the moment only HS256 is supported.
//
// @author Mihael Schmidt
// @date   04.05.2019
// @project ILEastic
///

///
// HMAC SHA256 algorithm for creating the token signature.
///
dcl-c JWT_HS256 'HS256';

///
// Template for JWT token.
///
dcl-s jwt_token_t varchar(8090) template;

///
// Template for the signing key which is used to create the token signature.
///
dcl-s jwt_signKey_t varchar(1000) template;

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
  signKey like(jwt_signKey_t) const ccsid(*utf8);
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
// the passed signing key.
//
// @param Algorithm (HS256)
// @parma Payload
// @param Signing key (it has to be of a valid length corresponding to the 
//        selected algorithm (HS256 => 256 key = char(32))
// @return Signed token
//
// @info At the moment only HS256 is supported for signature creation.
///
dcl-pr jwt_sign like(jwt_token_t) ccsid(*utf8) extproc(*dclcase);
  algorithm char(100) const;
  payload like(jwt_token_t) const ccsid(*utf8);
  signKey like(jwt_signKey_t) const ccsid(*utf8);
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
