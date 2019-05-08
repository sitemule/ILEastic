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
// @author Mihael Schmidt
// @date   04.05.2019
// @project ILEastic
///

dcl-c JWT_HS256 'HS256';

dcl-s jwt_token_t varchar(8090) template;
dcl-s jwt_signKey_t varchar(1000) template;


dcl-pr jwt_verify ind extproc(*dclcase);
  token like(jwt_token_t) const;
  signKey like(jwt_signKey_t) const;
end-pr;

dcl-pr jwt_decodeHeader like(jwt_token_t) extproc(*dclcase);
  token like(jwt_token_t) const;
end-pr;

dcl-pr jwt_decodePayload like(jwt_token_t) extproc(*dclcase);
  token like(jwt_token_t) const;
end-pr;

dcl-pr jwt_sign like(jwt_token_t) extproc(*dclcase);
  algorithm char(100) const;
  payload like(jwt_token_t) const;
  signKey like(jwt_signKey_t) const;
end-pr;

dcl-pr jwt_isExpired ind extproc(*dclcase);
  payload like(jwt_token_t) const;
end-pr;
