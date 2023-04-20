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

/////dcl-s signKey like(jwt_signKey_t) static(*allthread) ccsid(*utf8);


dcl-proc jwt_verify export;
//////  dcl-pi *n ind;
//////    token like(jwt_token_t) const ccsid(*utf8);
//////    signKey like(jwt_signKey_t) const ccsid(*utf8);
//////  end-pi;
  dcl-pi *n ind;
    token like(jwt_token_t) const ccsid(*utf8);
    keyOrUriDs likeDs(jwt_keyOrUriDs_t) const;
    noCaching  Ind  Options(*NoPass : *Omit) const; // for future
  end-pi;

  dcl-pr jwtAuthorizeEP  Ind    ExtProc(procPtr);
    token like(jwt_token_t) const ccsid(*utf8);
  end-pr;

  dcl-s valid ind inz(*off);
  dcl-s serverSignedToken like(jwt_token_t) ccsid(*utf8);
  dcl-s header like(jwt_token_t) ccsid(*utf8);
  dcl-s payload like(jwt_token_t);
  dcl-s json pointer;
  dcl-s procPtr    pointer(*PROC);
  dcl-s data like(jwt_token_t) ccsid(*utf8);
  dcl-s signatureTmp like(jwt_token_t) ccsid(*utf8);
  dcl-s signature like(jwt_token_t) ccsid(*utf8);
  dcl-s utfcomma  Char(1) inz('.') ccsid(*utf8);
  dcl-s payloadPos   Packed(3 : 0);
  dcl-s expOrNotAct  Ind Inz(*Off);
  dcl-s disableCaching  Ind Inz(*Off);

  monitor;

    if %Parms >= %ParmNum(noCaching) And %Addr(noCaching) <> *Null;
      disableCaching = noCaching; // Disable/Enable caching. Default value is caching is active
    endIf;
    header = jwt_decodeHeader(token);
    payload = jwt_decodePayload(token);
    json = json_parseString(payload);
    expOrNotAct = (not isExpired(json)) and isActive(json);
    json_close(json);

    Select;
     When Not(expOrNotAct);
      // Do nothing. Encryption/signature validation is costly and time consuming business.
      // If the token is expired, do not even bother to waste time on checking signature.

     // Token caching implementation for faster response.
  //   When Not(disableCaching) And expOrNotAct And foundInCache(token);
  //    valid = *On;

     When keyOrUriDs.alg = 'none';
      //No digital signature or MAC performed.
      // Care should be taken on what you expose to consumers who supply JWT with no Encryption done
      // If your organization implementation prohibits alg:'none', return *Off here.

     When keyOrUriDs.method = 'PROC';
      procPtr = keyOrUriDs.procPtr;
      valid = jwtAuthorizeEP(token);

     When %subSt(keyOrUriDs.alg : 1 : 2) = 'HS';
     // Symmetric key encryption
      serverSignedToken = jwt_sign(jwt_HS256 : payload : keyOrUriDs.key);
      if (token = serverSignedToken);
        valid = *On;

        //Store token into Cache for faster validation next time
        //if Not(disableCaching)
        //  pushToCache(token);
        //endif
      endif;

     When %subSt(keyOrUriDs.alg : 1 : 2) = 'RS';
     // Asymmetric key encryption
      payloadPos = %ScanR(utfcomma : token);

      // If no '.' found, then this is not a valid JWT
      If payloadPos <> 0;
        data = %SubSt(token : 1 : payloadPos - 1);
        signatureTmp = %SubSt(token : payloadPos + 1);
        signature = decodeBase64Url(signatureTmp); // This is done to cheat system to convert UTF to EBCDIC.
        If valAsymmetricEncryption(data : signature : keyOrUriDs.key);
          valid = *On;

          //Store token into Cache for faster validation next time
          //if Not(disableCaching)
          //  pushToCache(token);
          //endif
        endif;

      endif;

     //When %subSt(keyOrUriDs.alg : 1 : 2) = 'ES';
     // future - Elliptic Curve Digital Signature Algorithm

    endsl;



    return valid;

  on-error;
    // If the given token is with wrong strucutre, base64 will fail.
    return *Off;

  endmon;


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
    json_close(json);
    return payload;
  else;
    json_close(json);
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

  payload = pPayload;

  json = json_parseString(payload);
  expired = isExpired(json);
  json_close(json);

  return expired;
end-proc;


dcl-proc isExpired;
  dcl-pi *n ind;
    json pointer const;
  end-pi;

  dcl-s expired ind inz(*off);
  dcl-s exp int(20);
  dcl-s expTimestamp timestamp;
  dcl-s now timestamp;
  dcl-s offsetHours int(10);
  dcl-s offsetMinutes int(10);
  dcl-s offsetSeconds float(8);

  now = %timestamp();
  sys_getUtcOffset(offsetHours : offsetMinutes : offsetSeconds : *omit);

  exp = json_getInt(json : 'exp' : -1);

  if (exp >= 0);
    expTimestamp = UNIX_EPOCH_START + %seconds(exp + %int(offsetSeconds));
    expired = (now >= expTimestamp);
  endif;

  return expired;
end-proc;


dcl-proc isActive;
  dcl-pi *n ind;
    json pointer const;
  end-pi;

  dcl-s active ind inz(*on);
  dcl-s nbf int(20);
  dcl-s nbfTimestamp timestamp;
  dcl-s now timestamp;
  dcl-s offsetHours int(10);
  dcl-s offsetMinutes int(10);
  dcl-s offsetSeconds float(8);

  now = %timestamp();
  sys_getUtcOffset(offsetHours : offsetMinutes : offsetSeconds : *omit);

  nbf = json_getInt(json : 'nbf' : -1);

  if (nbf >= 0);
    nbfTimestamp = UNIX_EPOCH_START + %seconds(nbf + %int(offsetSeconds));
    active = (now >= nbfTimestamp);
  endif;

  return active;
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

dcl-proc valAsymmetricEncryption;
  dcl-pi  *n Ind;
    DatatoCheck   Char(8000) const ccsid(*utf8);       // original data
    signature     char(4096) const ccsid(*utf8);       // fingerprInt to verify
    key           varChar(4096)  const ccsid(*utf8);   // certificate content in DER format (PEM)
  end-pi;

  dcl-pr verifySignature ExtProc('Qc3VerifySignature');
    signature      Char(4096) ccsid(*utf8) const; // fingerprInt
    signatureLen   Int(10) const;
    Data           Char(8000) ccsid(*utf8) const; // original data
    Datalen        Int(10) const;
    Dataformat     Char(8) const;    //DATA0100 = data directly
    Algo           likeds(algoDS);   // encryption algo -> RSA
    AlgoFormat     Char(8) const;    //ALGD0400 = key parameters
    Key            likeds(pemDS);    // content of PEM certificate
    KeyFormat      Char(8) const;    //KEYD0600 = use key from PEM
    CSPcertificate Char(1) const;    // 1=Soft,2=hard(fill in DEVICE),0=Any
    CSPDEVICE      Char(10) const;   // blank if no co-processor
    ErrorCode      Char(16);
  end-pr;

  dcl-ds ErrCd Qualified;
    bytesProv Int(10) inz(0); // or 64 to see MSGID
    bytesAvail Int(10) inz(0);
    MSGID Char(7);
    filler Char(1);
    data Char(48);
  end-ds;
  dcl-ds algoDS qualified;
    cipher   Int(10) inz(50) ; //RSA
    PKA      Char(1) inz('1'); //PKCS block 0 or 1, 3=ISO 9796-1
    filler   Char(3) inz(x'000000');
    // the token must indicate RS256 (RSA) and not HS256 (HMAC = symmetric)
    hash     Int(10) inz(5); // 3=SHA256 5=SHA512
  End-Ds;
  dcl-ds pemDS qualified;
    keylen Int(10);
    filler Char(4) INZ(x'00000000');
    key Char(4096) ccsid(819);
  End-Ds;

  dcl-s signatureLen Int(10); // could be 256 or 512
  dcl-s DataLen Int(10);

  pemDS.key = key;
  pemDS.keylen = %len(pemDS.key);

  signatureLen = %len(%trimr(signature));
  dataLen = %len(%trimr(datatocheck));


  // IBM Crypto API.
  monitor;
    // Qc3VerifySignature will send ESCAPE message if in case it fails
    verifySignature( signature : signatureLen : DatatoCheck : dataLen : 'DATA0100' :
                algoDS : 'ALGD0400' : pemds : 'KEYD0600' : '0' : ' ' : ErrCd);
  on-error;
    return *Off;
  endmon;

  return *On;
end-proc;
