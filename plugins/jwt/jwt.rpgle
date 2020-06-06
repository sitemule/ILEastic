**FREE

///
// ILEastic : JWT Service Program
//
// This service program offers procedures for signing and verifying JWT tokens.
//
// @author Mihael Schmidt
// @date 04.05.2019
// @project ILEastic
///


ctl-opt nomain thread(*concurrent);


/if not defined(QUSEC)
/define QUSEC
/copy QSYSINC/QRPGLESRC,QUSEC
/endif

/include 'jwt_h.rpgle'
/include 'headers/ileastic.rpgle'
/include 'noxdb/headers/jsonparser.rpgle'

dcl-pr sys_getUtcOffset extproc('CEEUTCO');
  offsetHours int(10);
  offsetMinutes int(10);
  offsetSeconds float(8);
  feedback char(12) options(*omit);
end-pr;

dcl-c UNIX_EPOCH_START z'1970-01-01-00.00.00.000000';
dcl-s UTF8_PERIOD char(1) inz('.') CCSID(*UTF8);

dcl-s signKey like(jwt_signKey_t) static(*allthread) ccsid(*utf8);


dcl-proc jwt_verify export;
  dcl-pi *n ind;
    token like(jwt_token_t) const ccsid(*utf8);
    signKey like(jwt_signKey_t) const ccsid(*utf8);
  end-pi;

  dcl-s valid ind inz(*off);
  dcl-s serverSignedToken like(jwt_token_t) ccsid(*utf8);
  dcl-s header like(jwt_token_t) ccsid(*utf8);
  dcl-s payload like(jwt_token_t) ccsid(*utf8);

  header = jwt_decodeHeader(token);
  payload = jwt_decodePayload(token);

  serverSignedToken = jwt_sign(jwt_HS256 : payload : signKey);

  if (token = serverSignedToken);
    valid = not jwt_isExpired(payload);
  endif;

  return valid;
end-proc;


dcl-proc jwt_decodeHeader export;
  dcl-pi *n like(jwt_token_t) ccsid(*utf8);
    token like(jwt_token_t) const ccsid(*utf8);
  end-pi;

  dcl-s x int(10);
  dcl-s decoded like(jwt_token_t) ccsid(*utf8);
  dcl-s header like(jwt_token_t) ccsid(*utf8);

  // JWT header
  x = %scan(UTF8_PERIOD : token);
  if (x = 0);
    return *blank;
  endif;

  header = %subst(token : 1 : x - 1);
  decoded = decodeBase64Url(header);

  return decoded;
end-proc;


dcl-proc jwt_decodePayload export;
  dcl-pi *n like(jwt_token_t) ccsid(*utf8);
    token like(jwt_token_t) const ccsid(*utf8);
  end-pi;

  dcl-s x int(10);
  dcl-s x2 int(10);
  dcl-s decoded like(jwt_token_t) ccsid(*utf8);
  dcl-s payload like(jwt_token_t) ccsid(*utf8);

  // JWT header
  x = %scan(UTF8_PERIOD : token);
  if (x = 0);
    return *blank;
  endif;

  // JWT payload
  x2 = %scan(UTF8_PERIOD : token : x+1);
  if (x2 = 0);
    return *blank;
  endif;

  payload = %subst(token : x+1 : x2 - x);
  decoded = decodeBase64Url(payload);

  return decoded;
end-proc;


dcl-proc jwt_sign export;
  dcl-pi *n like(jwt_token_t) ccsid(*utf8);
    algorithm char(100) const;
    pPayload like(jwt_token_t) const ccsid(*utf8);
    signKey like(jwt_signKey_t) const ccsid(*utf8);
    claims likeds(jwt_claims_t) const options(*nopass);
  end-pi;

  dcl-pr memcpy pointer extproc('memcpy');
    dest pointer value;
    source pointer value;
    count uns(10) value;
  end-pr;

  dcl-pr sys_calculateHmac extproc('Qc3CalculateHMAC');
    input pointer value;
    inputLength int(10) const;
    inputDataFormat char(8) const;
    algorithm char(65535) const;
    algorithmFormat char(8) const;
    key char(1000) const;
    keyFormat char(8) const;
    cryptoServiceProvier char(1) const;
    cryptoDeviceName char(10) const;
    hash char(32);
    errorCode likeds(QUSEC);
  end-pr;

  dcl-ds algd0500_t qualified template;
    algorithm int(10);
  end-ds;

  dcl-c ALGORITHM_SHA256 3;

  dcl-ds keyd0200_t qualified template;
    type int(10);
    length int(10);
    format char(1);
    reserved char(3);
    key char(100) ccsid(*utf8);
  end-ds;

  dcl-s headerPayload char(65535) ccsid(*utf8);
  dcl-s header like(jwt_token_t) ccsid(*utf8);
  dcl-s encoded like(jwt_token_t) ccsid(*utf8);
  dcl-s hash char(32);
  dcl-s tmpHash char(32) ccsid(*utf8);
  dcl-ds algd0500 likeds(algd0500_t);
  dcl-ds keyparam likeds(keyd0200_t) inz;
  dcl-s base64Encoded like(jwt_token_t) ccsid(*utf8);
  dcl-s paddingChar char(1) inz('=') ccsid(*utf8);
  dcl-s payload like(jwt_token_t) ccsid(*utf8);
  
  
  if (algorithm <> jwt_HS256);
    il_joblog('Unsupported algorithm %s' : algorithm);
    return *blank;
  endif;

  header = '{"alg":"' + jwt_HS256 + '","typ":"JWT"}';

  payload = pPayload;
  if (%parms() >= 4);
    payload = addClaims(payload : claims);
  endif;
  
  base64Encoded = encodeBase64Url(payload);
  base64Encoded = %trimr(base64Encoded : paddingChar);
  headerPayload = encodeBase64Url(header) + '.' + base64Encoded;

  algd0500.algorithm = ALGORITHM_SHA256;
  keyparam.type = 3;
  keyparam.length = %len(%trimr(signKey));
  keyparam.key = signKey;
  keyparam.format = '0';
  // minimum 32 bytes for SHA-256
  if (keyparam.length < 32);
    keyparam.length = 32;
  endif;

  clear QUSEC;
  sys_calculateHmac(
      %addr(headerPayload) :
      %len(%trimr(headerPayload)) :
      'DATA0100' :
      algd0500 :
      'ALGD0500' :
      keyparam :
      'KEYD0200' :
      '0' : // crypto
      *blank : // crypto dev
      hash :
      QUSEC);

  memcpy(%addr(tmpHash) : %addr(hash) : 32);

  encoded = encodeBase64Url(tmpHash);
  encoded = %trimr(encoded : paddingChar);

  return %trimr(headerPayload) + UTF8_PERIOD + encoded;
end-proc;


dcl-proc addClaims;
  dcl-pi *n like(jwt_token_t) ccsid(*utf8);
    pPayload like(jwt_token_t) const ccsid(*utf8);
    claims likeds(jwt_claims_t) const;
  end-pi;

  dcl-s payload like(jwt_token_t) ccsid(*utf8);
  dcl-s json pointer;
  dcl-s value like(jwt_token_t);
  dcl-s uxts int(10);
  dcl-s changed ind inz(*off);
  
  payload = %trimr(pPayload) + x'00';
  
  json = json_parseString(%addr(payload : *DATA));
  
  if (%len(claims.issuer) > 0);
    value = claims.issuer + x'00';
    json_setStr(json : 'iss' : %addr(value : *DATA));
    changed = *on;
  endif;
  
  if (%len(claims.subject) > 0);
    value = claims.subject + x'00';
    json_setStr(json : 'sub' : %addr(value : *DATA));
    changed = *on;
  endif;
  
  if (%len(claims.audience) > 0);
    value = claims.audience + x'00';
    json_setStr(json : 'aud' : %addr(value : *DATA));
    changed = *on;
  endif;
  
  if (%len(claims.jwtId) > 0);
    value = claims.jwtId + x'00';
    json_setStr(json : 'jti' : %addr(value : *DATA));
    changed = *on;
  endif;
  
  if (claims.expirationTime <> *loval);
    uxts = toUnixTimestamp(claims.expirationTime);
    json_setInt(json : 'exp' : uxts);
    changed = *on;
  endif;
  
  if (claims.notBefore <> *loval);
    uxts = toUnixTimestamp(claims.notBefore);
    json_setInt(json : 'nbf' : uxts);
    changed = *on;
  endif;
  
  if (claims.issuedAt <> *loval);
    uxts = toUnixTimestamp(claims.issuedAt);
    json_setInt(json : 'iat' : uxts);
    changed = *on;
  endif;
  
  if (changed);
    payload = json_asJsonText(json);
    return payload;
  else;
    return pPayload;
  endif;
end-proc;


dcl-proc jwt_isExpired export;
  dcl-pi *n ind;
    pPayload like(jwt_token_t) const ccsid(*utf8);
  end-pi;

  dcl-s payload like(jwt_token_t);
  dcl-s expired ind inz(*off);
  dcl-s json pointer;
  dcl-s exp int(20);
  dcl-s expTimestamp timestamp;
  dcl-s now timestamp;
  dcl-s offsetHours int(10);
  dcl-s offsetMinutes int(10);
  dcl-s offsetSeconds float(8);

  now = %timestamp();
  sys_getUtcOffset(offsetHours : offsetMinutes : offsetSeconds : *omit);

  json = json_parseString(payload);
  exp = json_getInt(json : 'exp' : -1);

  if (exp >= 0);
    expTimestamp = UNIX_EPOCH_START + %seconds(exp + %int(offsetSeconds));
    expired = (now >= expTimestamp);
  endif;

  return expired;
end-proc;


dcl-proc encodeBase64Url;
  dcl-pi *n varchar(65530) ccsid(*utf8);
    string varchar(65530) const ccsid(*utf8);
  end-pi;

  dcl-s FROM char(2) inz('+/') ccsid(*utf8);
  dcl-s TO   char(2) inz('-_') ccsid(*utf8);
  dcl-s encoded varchar(65530) ccsid(*utf8);

  encoded = il_encodeBase64(string);
  encoded = %xlate(FROM : TO : encoded);

  return encoded;
end-proc;


dcl-proc decodeBase64Url;
  dcl-pi *n varchar(65530) ccsid(*utf8);
    string varchar(65530) const ccsid(*utf8);
  end-pi;

  dcl-s TO   char(2) inz('+/') ccsid(*utf8);
  dcl-s FROM char(2) inz('-_') ccsid(*utf8);
  dcl-s decoded varchar(65530) ccsid(*utf8);
  dcl-s value varchar(65530) ccsid(*utf8);

  value = %xlate(FROM : TO : string);
  decoded = il_decodeBase64(value);

  return decoded;
end-proc;


dcl-proc toUnixTimestamp;
  dcl-pi *n int(10);
    ts timestamp const;
  end-pi;

  dcl-s offsetHours int(10);
  dcl-s offsetMinutes int(10);
  dcl-s offsetSeconds float(8);
  dcl-s uxts int(10);
  
  sys_getUtcOffset(offsetHours : offsetMinutes : offsetSeconds : *omit);
  
  uxts = %diff(ts : UNIX_EPOCH_START : *SECONDS) - %int(offsetSeconds);
  
  return uxts;
end-proc;

