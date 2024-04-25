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
/include 'IfsDfn.rpgle'

//////dcl-s signKey like(jwt_signKey_t) static(*allthread) ccsid(*utf8);  // Not used

dcl-ds verifyStruct  Qualified static(*allthread);
  num_cnt    Packed(2 : 0) Inz(1);  // Location 1 is reserved for *DEFAULT value
  dcl-ds keyDs  LikeDS(jwt_keyOrUriDs_t) Dim(15);
end-ds;

//////dcl-proc il_jwt_setSignKey export;
//////  dcl-pi *n;
//////    pSignKey like(jwt_signKey_t) const ccsid(*utf8);
//////  end-pi;
//////
//////  signKey = pSignKey;
//////end-proc;


//The PEM certificate used as input to the Verify Signature Cryptographic Services API
//  needs to be reviewed to ensure it adheres to the following rules:
//
//1) The certificate must start with the appropriate header such as, "-----BEGIN CERTIFICATE-----",
//    and end with the appropriate footer such as, "-----END CERTIFICATE-----".
//    Always copy the certificate with the header and footer notes.
//2) The number of dashs ("-----") in the certificate header and footer is meaningful, and must be correct.
//3) When saving the certificate to a pem file, make sure you are using the correct form of line termination.
//    PEM certificates adhere to Unix standards and require each line in the file be terminated with a single
//    "Line Feed ( LF)" character only.  If the PEM certificate include Carriage Returns (CR) and Line Feeds (LF),
//    the IBM i OS Cryptographic Services APIs will not be able to parse the certificate, resulting in a CPF9DA9.
dcl-proc il_jwt_addKey export;
  dcl-pi *n;
    key         Char(5000) ccsid(*utf8) const; // In case of asymetric alg, this value will be converted to ASCII later
    alg         Char(5) const;  // https://www.rfc-editor.org/rfc/rfc7518#section-3.1
    kid         Char(50) Options(*NoPass : *Omit) const;  // *DEFAULT or kid value
    resetList   Ind Options(*NoPass : *Omit) const; // Reset key list. Default is *OFF;
  end-pi;

  dcl-s loc   Packed(2 : 0);

  if %Parms >= %ParmNum(resetList) And %Addr(resetList) <> *Null;
    reset verifyStruct; // reset is used to initialize num_cnt to 2
  endIf;

  // Check if current KID already in the list.
  if kid = '*DEFAULT';
    verifyStruct.keyDs(1).kid = '*DEFAULT';
    verifyStruct.keyDs(1).key = key; // DEFAULT key is parked under element 1
    verifyStruct.keyDs(1).alg = alg;
    verifyStruct.keyDs(1).method = 'KEY';
  else;
    loc = %Lookup(kid : verifyStruct.keyDs(*).kid);

    // If not found, add a new member else modify
    if loc = 0 and verifyStruct.num_cnt < 15;
      verifyStruct.num_cnt += 1;
      verifyStruct.keyDs(verifyStruct.num_cnt).kid = kid;
      verifyStruct.keyDs(verifyStruct.num_cnt).alg = alg;
      verifyStruct.keyDs(verifyStruct.num_cnt).method = 'KEY';
      verifyStruct.keyDs(verifyStruct.num_cnt).key = key; // This must be ascii value
    else;
      verifyStruct.keyDs(loc).kid = kid;
      verifyStruct.keyDs(verifyStruct.num_cnt).alg = alg;
      verifyStruct.keyDs(verifyStruct.num_cnt).method = 'KEY';
      verifyStruct.keyDs(loc).key = key; // This must be ascii value
    endif;
  endif;

end-proc;

// Most of IdP's provide an authorization end-point. While it is costly to call an external end-point to validate,
// for low volumn use cases that turned out to be best and easy method
//
// Below procedure register authorization end point that will enable
//  exteranl Rest call to validate JWT
dcl-proc il_jwt_addAuthorization_endpoint export;
  dcl-pi *n;
    procPtr     pointer(*PROC) value;  // Procedure implemented with your IdP's authorization endpoint
    alg         Char(5) const;
    kid         Char(50) Options(*NoPass : *Omit) const;  // *DEFAULT or kid value
    resetList   Ind Options(*NoPass : *Omit) const; // Reset key list. Default is *OFF;
  end-pi;

  dcl-s loc   Packed(2 : 0);

  if %Parms >= %ParmNum(resetList) And %Addr(resetList) <> *Null;
    reset verifyStruct; // reset is used to initialize num_cnt to 2
  endIf;

  // Check if current KID already in the list.
  if kid = '*DEFAULT';
    verifyStruct.keyDs(1).kid = '*DEFAULT'; // DEFAULT key is parked under element 1
    verifyStruct.keyDs(1).alg = alg;
    verifyStruct.keyDs(1).procPtr = procPtr;
    verifyStruct.keyDs(1).method = 'PROC'; // Indicate this is an external URL/URI to validate JWT
  else;
    loc = %Lookup(kid : verifyStruct.keyDs(*).kid);

    // If not found, add a new member else modify
    if loc = 0 and verifyStruct.num_cnt < 25;
      verifyStruct.num_cnt += 1;
      verifyStruct.keyDs(verifyStruct.num_cnt).kid = kid;
      verifyStruct.keyDs(verifyStruct.num_cnt).alg = alg;
      verifyStruct.keyDs(verifyStruct.num_cnt).method = 'PROC';
      verifyStruct.keyDs(verifyStruct.num_cnt).procPtr = procPtr;
    else;
      verifyStruct.keyDs(loc).kid = kid;
      verifyStruct.keyDs(loc).alg = alg;
      verifyStruct.keyDs(loc).method = 'PROC';
      verifyStruct.keyDs(loc).procPtr = procPtr;
    endif;
  endif;

end-proc;

dcl-proc il_jwt_addVerifyStructFromPEMFile export;
  dcl-pi *n;
    fileLoc     Char(250) const;  // IFS fle location, CCSID must be 819
    alg         Char(5) const;
    kid         Char(50) Options(*NoPass : *Omit) const;  // *DEFAULT or kid value
    resetList   Ind Options(*NoPass : *Omit) const; // Reset key list. Default is *OFF;
  end-pi;

  dcl-s keyVal       Char(5000) ccsid(*UTF8);
  dcl-s l_resetList  Ind Inz(*Off);
  dcl-s l_kid        char(50) Inz;
  dcl-s fd           Int(10) Inz;


    if %Parms >= %ParmNum(kid) And %Addr(kid) <> *Null;
      l_kid = kid;
    else;
      l_kid = '*DEFAULT';
    endIf;

    if %Parms >= %ParmNum(resetList) And %Addr(resetList) <> *Null;
      l_resetList = resetList;
    else;
      l_resetList = *Off;
    endIf;

    fd = IFS_OpenFile(%Trim(fileLoc) : O_RDONLY : S_IRUSR+S_IRGRP+S_IROTH);
    if  fd >= 0;
      IFS_ReadFile(fd : %addr(keyVal) : %Size(KeyVal));  // Data read as ASCII
      il_jwt_addKey(KeyVal : alg : l_kid : l_resetList);

    endif;
    IFS_CloseFile(fd);
end-proc;

dcl-proc il_jwt_addVerifyStructFromJWKS export;
  dcl-pi *n;
    procPtr     pointer(*PROC) value;  // procedure to retrieve your IdP's JWKS endpoint
    resetList   Ind Options(*NoPass : *Omit); // Reset key list. Default is *OFF;
  end-pi;

  dcl-pr readJwksEndpoint    ExtProc(procPtr);
    jwksDs  LikeDS(jwksDs_t) Dim(10);
    keyCnt       Packed(3 :0);
  end-pr;

  dcl-ds jwksDs  LikeDS(jwksDs_t) Dim(10);

  dcl-s keyVal       Char(5000) ccsid(*utf8);
  dcl-s l_resetList  Ind Inz(*Off);
  dcl-s keyCnt       Packed(3 :0) Inz;
  dcl-s idx          Packed(3 :0) Inz;

  //monitor;

    if %Parms >= %ParmNum(resetList) And %Addr(resetList) <> *Null;
      l_resetList = resetList;
    else;
      l_resetList = *Off;
    endIf;

    // Given IdPs demand varying headers or other parameters to retrieve JWKS,
    // it is left to the user to implement this procedure. Below SQL example is one way to
    // implement this in your code.
    readJwksEndpoint(jwksDs : keyCnt);

// you could either use IBM SQL HTTP functions as below 'or'
//   use any other Rest call mechanism to get x5c value from your IdP
//
//  If your IdP returns multiple kid and corresponding x5c, then use cursors to load them all
//

//    Exec SQL Declare JwksPEM CURSOR for
//            Select x.*, 'RS256' as Alg from json_table(qsys2.HTTP_GET(:uri, NULL),
//              '$.keys[*]' columns(KeyTp  Char(5)  Path '$.kty',
//                                  KeyId  Char(50) Path'$.kid',
//                                  Usage  Char(5)  Path '$.use',
//                                  PEM    char(4048) Path  '$.x5c') error on error) as x;
//
//    Exec SQL Open JwksPEM;
//    // usually IdPs will have up to 2 keys at once. But modify as it suits
//    Exec SQL Fetch NEXT From JwksPEM For 10 Rows INTO :jwksDs;
//    Exec SQL Get Diagnostics :KeyCnt = ROW_COUNT;
//    Exec SQL Close  JwksPEM;

    for idx = 1 to keyCnt;
      if %Trim(jwksDs(idx).Key) <> *Blanks and jwksDs(idx).KeyId <> ' ';

        // x5c generally have just the key, IBM API expect it to be in PEM format so adding
        //   -----BEGIN CERTIFICATE-----  & -----END CERTIFICATE----- along with LF.
        // Refer Document number: 728315 from IBM.
        // https://www.ibm.com/support/pages/cpf9da9-thrown-verifysignature-qc3vfysg-qc3verifysignature-cryptographic-services-api
        keyVal = x'2D2D2D2D2D424547494E2043455254494649434154452D2D2D2D2D' +
                     x'0A' + %Trim(jwksDs(idx).Key) +
                     x'0A' + x'2D2D2D2D2D454E442043455254494649434154452D2D2D2D2D';
        If idx = 1;
          il_jwt_addKey(KeyVal : jwksDs(idx).alg : jwksDs(idx).KeyId : l_resetList);
        else;
          il_jwt_addKey(KeyVal : jwksDs(idx).alg : jwksDs(idx).KeyId);
        endif;
      endif;
    endfor;

  //endmon;
end-proc;

dcl-proc il_jwt_filter export;
  dcl-pi *n ind;
    request  likeds(IL_REQUEST);
    response likeds(IL_RESPONSE);
  end-pi;

  dcl-s validRequest ind inz(*off);
  dcl-s token like(jwt_token_t);
  dcl-s header like(jwt_token_t);
  dcl-s payload like(jwt_token_t);
  dcl-s json pointer;
  dcl-s threadLocal pointer;
  dcl-s jwtNode pointer;
  dcl-s kid char(50);
  dcl-s loc  Packed(3 : 0);

  // Check if the client id is a valid value
  monitor;
    token = getToken(request);
    if (token = *blank);
      response.status = 401;
      il_responseWrite(response : 'Invalid/No JWT token provided.');
      return validRequest;
    endif;

    header = jwt_decodeHeader(token);
    json = json_parseString(header);
    kid = json_GetStr(json : 'kid' : ' ');
    // Getting alg from token could be dangerous if bad actors use public key for
    //  Symmetric encryption. So limiting it with alg set at key load time.
    //alg = json_GetStr(json : 'alg' : ' ');
    json_close(json);

    loc = %Lookup(kid : verifyStruct.keyDs(*).kid : 1 : verifyStruct.num_cnt);
    if loc = 0 And verifyStruct.keyDs(1).kid <> *Blanks;
      loc = 1; // Set to default.
    endif;

    // If we are unable to extract 'kid' or given kid not found in our list then return error.
    if kid = *Blanks Or loc = 0;
      response.status = 401;
      il_responseWrite(response : 'Invalid JWT token provided.');
      return validRequest;
    endif;

    ////if (jwt_verify(token : signKey));
    if (jwt_verify(token : verifyStruct.keyDs(loc)));
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
      il_responseWrite(response : 'Invalid/No JWT token provided.');
    endif;

  on-error *all;
    // Else return an error code to the caller: 500
    response.status = 500;
    response.statusText = 'Internal Server Error';
    il_responseWrite(response : 'Could not process request for JWT token.');
  endmon;

  return validRequest;
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
