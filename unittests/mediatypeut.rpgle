**FREE

ctl-opt nomain;

/include 'assert'
/include '../headers/ileastic.rpgle'
/include '../headers/simpleList.rpginc'

dcl-ds response_extended qualified;
  dcl-ds response likeds(il_response);
  headerList pointer;
end-ds;

dcl-ds request likeds(il_request);
dcl-ds responseWithHeaders likeds(response_extended);
dcl-s optionsMethod varchar(8) inz('OPTIONS') ccsid(*utf8);
dcl-s getMethod varchar(3) inz('GET') ccsid(*utf8);
dcl-s marker char(8);

dcl-proc test_should_return_generic_mediatype_when_no_accept_header export;
  dcl-ds mediaType likeds(mediaType_t) inz(*likeds);

  mediaType = il_mediatype_getPreferredAcceptedMediaType(request);

  aEqual('*' : mediaType.type);
  aEqual('*' : mediaType.subtype);
end-proc;

dcl-proc test_should_return_mediatype_for_single_accept_value export;
  dcl-s headerName varchar(1024) inz('Accept');
  dcl-s headerValue varchar(1024) inz('application/json');
  dcl-ds mediaType likeds(mediaType_t) inz(*likeds);
  addRequestHeader(headerName : headerValue);

  mediaType = il_mediatype_getPreferredAcceptedMediaType(request);

  aEqual('application'  : mediaType.type);
  aEqual('json'         : mediaType.subtype);
end-proc;

dcl-proc test_should_return_default_q_of_1 export;
  dcl-s headerName varchar(1024) inz('Accept');
  dcl-s headerValue varchar(1024) inz('application/json');
  dcl-ds mediaType likeds(mediaType_t) inz(*likeds);
  addRequestHeader(headerName : headerValue);

  mediaType = il_mediatype_getPreferredAcceptedMediaType(request);

  nEqual(*on : mediaType.q = 1.0);
end-proc;

dcl-proc test_should_parse_extensions export;
  dcl-s headerName varchar(1024) inz('Accept');
  dcl-s headerValue varchar(1024) inz('application/json;q=0.3;charset=utf-8');
  dcl-ds mediaType likeds(mediaType_t) inz(*likeds);
  dcl-s idx int(10);
  addRequestHeader(headerName : headerValue);

  mediaType = il_mediatype_getPreferredAcceptedMediaType(request);

  aEqual('application'  : mediaType.type);
  aEqual('json'         : mediaType.subtype);
  nEqual(*on            : mediaType.q = 0.3);
  iEqual(1              : mediaType.extensionsLen);
  idx = %lookup(%char('charset':*utf8) : mediaType.extensions(*).name : 1 : mediaType.extensionsLen);
  nEqual(*on            : idx > 0);
  aEqual('utf-8'        : mediaType.extensions(idx).value);

  tearDown();
  setUp();

  headerValue = 'application/json;charset=utf-8;ext1=val1';
  addRequestHeader(headerName : headerValue);

  mediaType = il_mediatype_getPreferredAcceptedMediaType(request);

  aEqual('application'  : mediaType.type);
  aEqual('json'         : mediaType.subtype);
  nEqual(*on            : mediaType.q = 1.0);
  iEqual(2              : mediaType.extensionsLen);
  idx = %lookup(%char('charset':*utf8) : mediaType.extensions(*).name : 1 : mediaType.extensionsLen);
  nEqual(*on            : idx > 0);
  aEqual('utf-8'        : mediaType.extensions(idx).value);
  idx = %lookup(%char('ext1':*utf8) : mediaType.extensions(*).name : 1 : mediaType.extensionsLen);
  nEqual(*on            : idx > 0);
  aEqual('val1'         : mediaType.extensions(idx).value);

  tearDown();
  setUp();

  headerValue = 'application/json;charset=utf-8;ext1=val1;';
  addRequestHeader(headerName : headerValue);

  mediaType = il_mediatype_getPreferredAcceptedMediaType(request);

  aEqual('application'  : mediaType.type);
  aEqual('json'         : mediaType.subtype);
  nEqual(*on            : mediaType.q = 1.0);
  iEqual(2              : mediaType.extensionsLen);
  idx = %lookup(%char('charset':*utf8) : mediaType.extensions(*).name : 1 : mediaType.extensionsLen);
  nEqual(*on            : idx > 0);
  aEqual('utf-8'        : mediaType.extensions(idx).value);
  idx = %lookup(%char('ext1':*utf8) : mediaType.extensions(*).name : 1 : mediaType.extensionsLen);
  nEqual(*on            : idx > 0);
  aEqual('val1'         : mediaType.extensions(idx).value);

  tearDown();
  setUp();

  headerValue = 'application/json;q=0.5;charset=utf-8;ext1=val1;';
  addRequestHeader(headerName : headerValue);

  mediaType = il_mediatype_getPreferredAcceptedMediaType(request);

  aEqual('application'  : mediaType.type);
  aEqual('json'         : mediaType.subtype);
  nEqual(*on            : mediaType.q = 0.5);
  iEqual(2              : mediaType.extensionsLen);
  idx = %lookup(%char('charset':*utf8) : mediaType.extensions(*).name : 1 : mediaType.extensionsLen);
  nEqual(*on            : idx > 0);
  aEqual('utf-8'        : mediaType.extensions(idx).value);
  idx = %lookup(%char('ext1':*utf8) : mediaType.extensions(*).name : 1 : mediaType.extensionsLen);
  nEqual(*on            : idx > 0);
  aEqual('val1'         : mediaType.extensions(idx).value);
end-proc;

// dcl-proc test_should_parse_extensions2 export;
//   dcl-s headerName varchar(1024) inz('Accept');
//   dcl-s headerValue varchar(1024) inz('application/json;charset=utf-8;ext1=val1');
//   dcl-ds mediaType likeds(mediaType_t) inz(*likeds);
//   dcl-s idx int(10);
//   addRequestHeader(headerName : headerValue);

//   mediaType = il_mediatype_getPreferredAcceptedMediaType(request);

//   aEqual('application'  : mediaType.type);
//   aEqual('json'         : mediaType.subtype);
//   nEqual(*on            : mediaType.q = 1.0);
//   iEqual(2              : mediaType.extensionsLen);
//   idx = %lookup(%char('charset':*utf8) : mediaType.extensions(*).name : 1 : mediaType.extensionsLen);
//   nEqual(*on            : idx > 0);
//   aEqual('utf-8'        : mediaType.extensions(idx).value);
//   idx = %lookup(%char('ext1':*utf8) : mediaType.extensions(*).name : 1 : mediaType.extensionsLen);
//   nEqual(*on            : idx > 0);
//   aEqual('val1'        : mediaType.extensions(idx).value);
// end-proc;

// dcl-proc test_should_parse_extensions3 export;
//   dcl-s headerName varchar(1024) inz('Accept');
//   dcl-s headerValue varchar(1024) inz('application/json;charset=utf-8;ext1=val1;');
//   dcl-ds mediaType likeds(mediaType_t) inz(*likeds);
//   dcl-s idx int(10);
//   addRequestHeader(headerName : headerValue);

//   mediaType = il_mediatype_getPreferredAcceptedMediaType(request);

//   aEqual('application'  : mediaType.type);
//   aEqual('json'         : mediaType.subtype);
//   nEqual(*on            : mediaType.q = 1.0);
//   iEqual(2              : mediaType.extensionsLen);
//   idx = %lookup(%char('charset':*utf8) : mediaType.extensions(*).name : 1 : mediaType.extensionsLen);
//   nEqual(*on            : idx > 0);
//   aEqual('utf-8'        : mediaType.extensions(idx).value);
//   idx = %lookup(%char('ext1':*utf8) : mediaType.extensions(*).name : 1 : mediaType.extensionsLen);
//   nEqual(*on            : idx > 0);
//   aEqual('val1'        : mediaType.extensions(idx).value);
// end-proc;

// dcl-proc test_should_parse_extensions4 export;
//   dcl-s headerName varchar(1024) inz('Accept');
//   dcl-s headerValue varchar(1024) inz('application/json;q=0.5;charset=utf-8;ext1=val1;');
//   dcl-ds mediaType likeds(mediaType_t) inz(*likeds);
//   dcl-s idx int(10);
//   addRequestHeader(headerName : headerValue);

//   mediaType = il_mediatype_getPreferredAcceptedMediaType(request);

//   aEqual('application'  : mediaType.type);
//   aEqual('json'         : mediaType.subtype);
//   nEqual(*on            : mediaType.q = 0.5);
//   iEqual(2              : mediaType.extensionsLen);
//   idx = %lookup(%char('charset':*utf8) : mediaType.extensions(*).name : 1 : mediaType.extensionsLen);
//   nEqual(*on            : idx > 0);
//   aEqual('utf-8'        : mediaType.extensions(idx).value);
//   idx = %lookup(%char('ext1':*utf8) : mediaType.extensions(*).name : 1 : mediaType.extensionsLen);
//   nEqual(*on            : idx > 0);
//   aEqual('val1'        : mediaType.extensions(idx).value);
// end-proc;

dcl-proc test_should_select_xml_as_preferred export;
  dcl-s headerName varchar(1024) inz('Accept');
  dcl-s headerValue varchar(1024) inz('application/json;q=0.5,application/xml;q=0.9');
  dcl-ds mediaType likeds(mediaType_t) inz(*likeds);
  addRequestHeader(headerName : headerValue);

  mediaType = il_mediatype_getPreferredAcceptedMediaType(request);

  aEqual('application'  : mediaType.type);
  aEqual('xml'          : mediaType.subtype);
  nEqual(*on            : mediaType.q = 0.9);
end-proc;

dcl-proc test_should_select_xml_as_preferred_with_default_q export;
  dcl-s headerName varchar(1024) inz('Accept');
  dcl-s headerValue varchar(1024) inz('application/json;q=0.5,application/xml');
  dcl-ds mediaType likeds(mediaType_t) inz(*likeds);
  addRequestHeader(headerName : headerValue);

  mediaType = il_mediatype_getPreferredAcceptedMediaType(request);

  aEqual('application'  : mediaType.type);
  aEqual('xml'          : mediaType.subtype);
  nEqual(*on            : mediaType.q = 1.0);
end-proc;

dcl-proc test_order_descending_by_quality_factor export;
  dcl-s headerName varchar(1024) inz('Accept');
  dcl-s headerValue varchar(1024) inz('application/json;q=0.5,application/xml;q=0.7,text/plain;q=0.3');
  dcl-ds typeList likeds(mediaType_t) dim(IL_MAX_MEDIA_TYPE_LIST_LENGTH);
  dcl-s typeListLen uns(10);

  addRequestHeader(headerName : headerValue);

  il_mediatype_getAcceptedMediaTypes(request : typeList : typeListLen);

  iEqual(3              : typeListLen);
  aEqual('application'  : typeList(1).type);
  aEqual('xml'          : typeList(1).subtype);
  nEqual(*on            : typeList(1).q = 0.7);
  aEqual('application'  : typeList(2).type);
  aEqual('json'         : typeList(2).subtype);
  nEqual(*on            : typeList(2).q = 0.5);
  aEqual('text'         : typeList(3).type);
  aEqual('plain'        : typeList(3).subtype);
  nEqual(*on            : typeList(3).q = 0.3);
end-proc;

dcl-proc test_given_same_quality_factor_should_prioritize_less_generic export;
  dcl-s headerName varchar(1024) inz('Accept');
  dcl-s headerValue varchar(1024) inz('application/json;q=0.5,application/*;q=0.5');
  dcl-ds mediaType likeds(mediaType_t) inz(*likeds);
  addRequestHeader(headerName : headerValue);

  mediaType = il_mediatype_getPreferredAcceptedMediaType(request);

  aEqual('application'  : mediaType.type);
  aEqual('json'          : mediaType.subtype);
  nEqual(*on            : mediaType.q = 0.5);
end-proc;

dcl-proc test_given_same_quality_factor_should_return_most_generic_as_last export;
  dcl-s headerName varchar(1024) inz('Accept');
  dcl-s headerValue varchar(1024) inz('application/json;q=0.5,application/*;q=0.5,*/*;q=0.5');
  dcl-ds typeList likeds(mediaType_t) dim(IL_MAX_MEDIA_TYPE_LIST_LENGTH);
  dcl-s typeListLen uns(10);

  addRequestHeader(headerName : headerValue);

  il_mediatype_getAcceptedMediaTypes(request : typeList : typeListLen);

  iEqual(3              : typeListLen);
  aEqual('application'  : typeList(1).type);
  aEqual('json'         : typeList(1).subtype);
  nEqual(*on            : typeList(1).q = 0.5);
  aEqual('application'  : typeList(2).type);
  aEqual('*'            : typeList(2).subtype);
  nEqual(*on            : typeList(2).q = 0.5);
  aEqual('*'            : typeList(3).type);
  aEqual('*'            : typeList(3).subtype);
  nEqual(*on            : typeList(3).q = 0.5);
end-proc;

dcl-proc test_should_return_media_type_ranking_highest export;
  dcl-s headerName varchar(1024) inz('Accept');
  dcl-s headerValue varchar(1024) inz('application/json;q=0.5,application/xml;q=0.3');
  dcl-ds mediaType likeds(mediaType_t);

  addRequestHeader(headerName : headerValue);

  mediaType = il_mediatype_isMediaTypeAccepted(request : 'application/json' : 'application/xml');

  aEqual('application'  : mediaType.type);
  aEqual('json'         : mediaType.subtype);
end-proc;

dcl-proc test_should_return_matching_media_type export;
  dcl-s headerName varchar(1024) inz('Accept');
  dcl-s headerValue varchar(1024) inz('text/plain;q=0.5,application/xml;q=0.3,text/xml;q=0.6');
  dcl-ds mediaType likeds(mediaType_t);

  addRequestHeader(headerName : headerValue);

  mediaType = il_mediatype_isMediaTypeAccepted(request : 'application/json' : 'application/xml');

  aEqual('application'  : mediaType.type);
  aEqual('xml'          : mediaType.subtype);
end-proc;

dcl-proc test_should_return_first_matching_less_generic_media_type_when_q_are_equal export;
  dcl-s headerName varchar(1024) inz('Accept');
  dcl-s headerValue varchar(1024) inz('application/json;q=0.5,application/*;q=0.5,text/xml;q=0.6');
  dcl-ds mediaType likeds(mediaType_t);

  addRequestHeader(headerName : headerValue);

  mediaType = il_mediatype_isMediaTypeAccepted(request : 'application/json' : 'application/xml');

  aEqual('application'  : mediaType.type);
  aEqual('json'         : mediaType.subtype);
end-proc;

dcl-proc test_should_return_first_generic_subtype_matching_media_type export;
  dcl-s headerName varchar(1024) inz('Accept');
  dcl-s headerValue varchar(1024) inz('application/*;q=0.6,text/xml');
  dcl-ds mediaType likeds(mediaType_t);

  addRequestHeader(headerName : headerValue);

  mediaType = il_mediatype_isMediaTypeAccepted(request : 'application/json' : 'application/xml');

  aEqual('application'  : mediaType.type);
  aEqual('json'         : mediaType.subtype);
end-proc;

dcl-proc test_should_return_subtype_generic_matching_highest_ranking_media_type export;
  dcl-s headerName varchar(1024) inz('Accept');
  dcl-s headerValue varchar(1024) inz('application/*;q=0.6,text/*;q=0.7');
  dcl-ds mediaType likeds(mediaType_t);

  addRequestHeader(headerName : headerValue);

  mediaType = il_mediatype_isMediaTypeAccepted(request : 'application/json' : 'application/xml' : 'text/xml');

  aEqual('text'  : mediaType.type);
  aEqual('xml'   : mediaType.subtype);
end-proc;

dcl-proc test_should_return_first_generic_type_matching_generic_media_type export;
  dcl-s headerName varchar(1024) inz('Accept');
  dcl-s headerValue varchar(1024) inz('*/*;q=0.6,text/xml');
  dcl-ds mediaType likeds(mediaType_t);

  addRequestHeader(headerName : headerValue);

  mediaType = il_mediatype_isMediaTypeAccepted(request : 'application/json' : 'application/xml');

  aEqual('application'  : mediaType.type);
  aEqual('json'         : mediaType.subtype);
end-proc;

dcl-proc test_should_log_message_for_corrupted_quality_factor export;
  dcl-s headerName varchar(1024) inz('Accept');
  dcl-s headerValue varchar(1024) inz('application/json;q=0.a6,text/xml');
  dcl-ds mediaType likeds(mediaType_t);
  dcl-s tstmp timestamp(6);


  addRequestHeader(headerName : headerValue);

  tstmp = getFullTimestamp();
  mediaType = il_mediatype_isMediaTypeAccepted(request : 'application/json' : 'application/xml');

  aEqual('application'  : mediaType.type);
  aEqual('json'         : mediaType.subtype);
end-proc;

dcl-proc test_should_log_message_for_corrupted_extension export;
  dcl-s headerName varchar(1024) inz('Accept');
  dcl-s headerValue varchar(1024) inz('application/json;corruptedext');
  dcl-ds mediaType likeds(mediaType_t);
  dcl-s tstmp timestamp(6);


  addRequestHeader(headerName : headerValue);

  tstmp = getFullTimestamp();
  mediaType = il_mediatype_isMediaTypeAccepted(request : 'application/json' : 'application/xml');

  aEqual('application'  : mediaType.type);
  aEqual('json'         : mediaType.subtype);
end-proc;

dcl-proc getResponseHeader;
  dcl-pi *n char(100);
    headerName varchar(100) value;
  end-pi;

  dcl-s header varchar(100) dim(2);
  dcl-ds hSimpleList likeds(SLIST_t) based(responseWithHeaders.headerList);
  dcl-ds hListIterator likeds(SLISTITERATOR_t);
  dcl-ds listOfNodeIterator likeds(SLISTNODE_t) based(hListIterator.pThis);
  dcl-s dataOfIterator char(512) based(listOfNodeIterator.payloadData);
  dcl-s pos int(10);

  hListIterator = sList_setIterator(hSimpleList);

  dow (sList_foreach(hListIterator));
    pos = %scan(':' : dataOfIterator : 1 : listOfNodeIterator.payLoadLength);
    if headerName = %subst(dataOfIterator: 1 : pos - 1);
      header(1) = %triml(%subst(dataOfIterator: pos + 1: listOfNodeIterator.payLoadLength - 1 - pos));
      return %triml(%subst(dataOfIterator: pos + 1: listOfNodeIterator.payLoadLength - 1 - pos));
    endif;
  enddo;

  return *blanks;
end-proc;

dcl-proc createRequest;
  dcl-pi *n likeds(il_request) end-pi;

  dcl-ds request likeds(il_request) inz;
  dcl-ds methodvc likeds(il_varchar);

  setRequestMethod(getMethod);

  request.config = %alloc(%size(il_config));
  request.headerList = sList_new();
  
  return request;
end-proc;

dcl-proc setRequestMethod;
  dcl-pi *n;
    requestMethod varchar(8) options(*varsize) ccsid(*utf8);
  end-pi;

  dcl-ds methodvc likeds(il_varchar);
  methodvc.length = %len(requestMethod);
  methodvc.string = %addr(requestMethod:*data);

  request.method = methodvc;
end-proc;

dcl-proc addRequestHeader;
  dcl-pi *n;
    headerName varchar(1024) value;
    headerValue varchar(1024) value;
  end-pi;

  dcl-s aHeaderName varchar(1024) static;
  dcl-s aHeaderValue varchar(1024) static;

  dcl-pr meme2a extproc(*dclcase);
    pout pointer value;
    pin pointer value options(*string);
    length uns(10) value;
  end-pr;

  dcl-s ptr pointer;
  dcl-s res VARCHAR(1024:4);
  dcl-ds hSimpleList likeds(SLIST_t) based(ptr);

  ptr = request.headerList;
  %len(aHeaderName) = %len(headerName);
  %len(aHeaderValue) = %len(headerValue);
  meme2a(%addr(aHeaderName:*data) : headerName : %len(aHeaderName));
  meme2a(%addr(aHeaderValue:*data) : headerValue : %len(aHeaderValue));
  sList_pushLVPC(hSimpleList : lvpc(aHeaderName) : lvpc(aHeaderValue));
end-proc;

dcl-proc setUp export;
  request = createRequest();
  reset responseWithHeaders;
  responseWithHeaders.headerList = sList_new();
end-proc;

dcl-proc tearDown export;
  dcl-s ptr pointer;
  dcl-ds hSimpleList likeds(SLIST_t) based(ptr);
  ptr = responseWithHeaders.headerList;
  sList_free(hSimpleList);
  ptr = request.headerList;
  sList_free(hSimpleList);
  clear marker;
end-proc;

dcl-proc lvpc;
  dcl-pi *n likeds(LVARPUCHAR_t);
    string varchar(1024) options(*varsize);
  end-pi;

  dcl-ds lVarChar likeds(LVARPUCHAR_t) inz;

  lVarChar.length = %len(string);
  lVarChar.string = %addr(string: *data);

  return lVarChar;

end-proc;