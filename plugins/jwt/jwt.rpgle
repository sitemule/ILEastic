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


dcl-c UNIX_EPOCH_START z'1970-01-01-00.00.00.000000';

dcl-s signKey like(jwt_signKey_t) static(*allthread) ccsid(*utf8);


dcl-proc jwt_verify export;
  dcl-pi *n ind;
    token like(jwt_token_t) const;
    signKey like(jwt_signKey_t) const;
  end-pi;

  dcl-s valid ind inz(*off);
  dcl-s serverSignedToken like(jwt_token_t);
  dcl-s header like(jwt_token_t);
  dcl-s payload like(jwt_token_t);

  header = jwt_decodeHeader(token);
  payload = jwt_decodePayload(token);

  serverSignedToken = jwt_sign(jwt_HS256 : payload : signKey);

  if (token = serverSignedToken);
    valid = not jwt_isExpired(payload);
  endif;

  return valid;
end-proc;


dcl-proc jwt_decodeHeader export;
  dcl-pi *n like(jwt_token_t);
    token like(jwt_token_t) const;
  end-pi;

  dcl-s x int(10);
  dcl-s decoded like(jwt_token_t);
  dcl-s header like(jwt_token_t);

  // JWT header
  x = %scan('.' : token);
  if (x = 0);
    return *blank;
  endif;

  header = %subst(token : 1 : x - 1);
  decoded = il_decodeBase64(header);

  return decoded;
end-proc;


dcl-proc jwt_decodePayload export;
  dcl-pi *n like(jwt_token_t);
    token like(jwt_token_t) const;
  end-pi;

  dcl-s x int(10);
  dcl-s x2 int(10);
  dcl-s decoded like(jwt_token_t);
  dcl-s payload like(jwt_token_t);

  // JWT header
  x = %scan('.' : token);
  if (x = 0);
    return *blank;
  endif;

  // JWT payload
  x2 = %scan('.' : token : x+1);
  if (x2 = 0);
    return *blank;
  endif;

  payload = %subst(token : x+1 : x2 - x);
  decoded = il_decodeBase64(payload);

  return decoded;
end-proc;


dcl-proc jwt_sign export;
  dcl-pi *n like(jwt_token_t);
    algorithm char(100) const;
    payload like(jwt_token_t) const;
    signKey like(jwt_signKey_t) const;
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
  dcl-s header like(jwt_token_t);
  dcl-s token like(jwt_token_t);
  dcl-s encoded like(jwt_token_t) ccsid(*utf8);
  dcl-s hash char(32);
  dcl-s tmpHash char(32) ccsid(*utf8);
  dcl-ds algd0500 likeds(algd0500_t);
  dcl-ds keyparam likeds(keyd0200_t) inz;
  dcl-s base64Encoded like(jwt_token_t) ccsid(*utf8);
  dcl-s paddingChar char(1) inz('=') ccsid(*utf8);

  if (algorithm <> jwt_HS256);
    il_joblog('Unsupported algorithm %s' : algorithm);
    return *blank;
  endif;

  header = '{"alg":"' + jwt_HS256 + '","typ":"JWT"}';

  base64Encoded = il_encodeBase64(payload);
  base64Encoded = %trimr(base64Encoded : paddingChar);
  headerPayload = il_encodeBase64(header) + '.' + base64Encoded;

  algd0500.algorithm = ALGORITHM_SHA256;
  keyparam.type = 3;
  keyparam.length = %len(%trimr(signKey));
  keyparam.key = signKey;
  keyparam.format = '0';

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

  encoded = il_encodeBase64(tmpHash);
  encoded = %trimr(encoded : paddingChar);

  return %trimr(headerPayload) + '.' + encoded;
end-proc;


dcl-proc jwt_isExpired export;
  dcl-pi *n ind;
    payload like(jwt_token_t) const;
  end-pi;

  dcl-pr sys_getUtcOffset extproc('CEEUTCO');
    offsetHours int(10);
    offsetMinutes int(10);
    offsetSeconds float(8);
    feedback char(12) options(*omit);
  end-pr;

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
