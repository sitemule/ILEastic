**FREE

///
// Request Test
//
// The parsing of the HTTP request resource into a list of path segments is
// tested here.
//
// @author Mihael Schmidt
// @date   28.06.2020
///


ctl-opt nomain;


//
// Includes
//
/include '../headers/ileastic.rpgle'
/include assert

dcl-pr memcpy pointer extproc('memcpy');
  dest pointer value;
  source pointer value;
  count uns(10) value;
end-pr;    

dcl-pr memcmp int(10) extproc('memcmp');
  buffer1 pointer value;
  buffer2 pointer value;
  count uns(10) value;
end-pr;
     
dcl-ds SLISTNODE_t qualified template;
   pNext pointer; // struct SLISTNODE_t
   payLoadLength int(10);
   payloadData pointer;
end-ds;

dcl-ds SLIST_t qualified template;
   pHead pointer;
   pTail pointer;
   length int(10);
end-ds;

dcl-ds SLISTITERATOR_t qualified align(*full) template;
   pThis pointer; // pointer of type SLISTNODE_t
   pNext pointer; // pointer of type SLISTNODE_t
   hasNext ind;
end-ds;

dcl-pr sList_new pointer extproc('sList_new') end-pr;

dcl-pr sList_free extproc('sList_free');
   hSlist likeds(SLIST_t) const; // simpleList.c: PSLIST
end-pr;

dcl-pr sList_setIterator likeds(SLISTITERATOR_t) extproc('sList_setIterator');
   hSlist likeds(SLIST_t) const; // PSLIST
end-pr;

dcl-pr sList_foreach ind extproc('sList_foreach');
   iterator likeds(SLISTITERATOR_t) const; // simpleList.c: PSLISTITERATOR
end-pr;


dcl-ds LVARPUCHAR qualified template;
  length uns(10);
  string pointer;
end-ds;

// PSLIST parseResource(LVARPUCHAR resource)
dcl-pr parseResource pointer extproc(*CWIDEN:*dclcase);
  resource likeds(LVARPUCHAR) value;
end-pr;

// BOOL lookForHeaders ( PREQUEST pRequest, PUCHAR buf , ULONG bufLen)
dcl-pr lookForHeaders extproc(*CWIDEN:*dclcase);
  request pointer value;
  buffer pointer value;
  bufferLength uns(10) value;
end-pr;

dcl-s CRLF char(2) inz(x'0d0a') ccsid(819); 

dcl-ds request likeds(il_request);

dcl-ds SLIST likeds(SLIST_t) based(request.headerList);

dcl-s g_path1 varchar(1024) ccsid(*utf8) inz('/');
dcl-s g_result1 char(10) dim(1) ctdata;
dcl-s g_path2 varchar(1024) ccsid(*utf8) inz('//');
dcl-s g_result2 char(10) dim(2) ctdata;
dcl-s g_path3 varchar(1024) ccsid(*utf8) inz('/api');
dcl-s g_result3 char(10) dim(1) ctdata;
dcl-s g_path4 varchar(1024) ccsid(*utf8) inz('/api/users');
dcl-s g_result4 char(10) dim(2) ctdata;
dcl-s g_path5 varchar(1024) ccsid(*utf8) inz('/api/users/:email');
dcl-s g_result5 char(10) dim(3) ctdata;
dcl-s g_path6 varchar(1024) ccsid(*utf8) inz('/api/users/:email/');
dcl-s g_result6 char(10) dim(4) ctdata;


//
// Prototypes
//
dcl-pr setup end-pr;
dcl-pr teardown end-pr;
dcl-pr test_internal_rootOnly end-pr;
dcl-pr test_internal_singleSegment end-pr;
dcl-pr test_internal_multipleSegments end-pr;
dcl-pr test_internal_emptySegments end-pr;
dcl-pr test_internal_emptyEndingSegment end-pr;
dcl-pr test_rootOnly end-pr;
dcl-pr test_singleSegment end-pr;
dcl-pr test_multipleSegments end-pr;
dcl-pr test_emptySegments end-pr;
dcl-pr test_emptyEndingSegment end-pr;
dcl-pr test_outOfRange end-pr;


dcl-proc test_internal_rootOnly export;
  compareResults(g_path1 : g_result1 : %elem(g_result1));
end-proc;


dcl-proc test_internal_emptySegment export;
  compareResults(g_path2 : g_result2 : %elem(g_result2));
end-proc;


dcl-proc test_internal_singleSegment export;
  compareResults(g_path3 : g_result3 : %elem(g_result3));
end-proc;


dcl-proc test_internal_multipleSegment export;
  compareResults(g_path4 : g_result4 : %elem(g_result4));
end-proc;


dcl-proc test_internal_emptyEndingSegment export;
  compareResults(g_path6 : g_result6 : %elem(g_result6));
end-proc;


dcl-proc compareResults;
  dcl-pi *n;
    path varchar(1024) ccsid(*utf8);
    result char(10) dim(10) const;
    elements int(10) const;
  end-pi;

  dcl-ds resource likeds(LVARPUCHAR);
  dcl-ds segments likeds(slist_t) based(pSegments);
  dcl-ds iterator likeds(slistiterator_t);
  dcl-ds node likeds(SLISTNODE_t) based(pNode);
  dcl-ds value LIKEDS(LVARPUCHAR) based(pValue);
  dcl-s expected char(100) ccsid(1208);
  dcl-s i int(10);
    
  resource.string = %addr(path : *DATA);
  resource.length = %len(path);
  
  pSegments = parseResource(resource);
  
  iterator = sList_setIterator(segments);
  dow (sList_foreach(iterator));
    pNode = iterator.pThis;
    pValue = node.payloadData;
    i += 1;
    if (value.length = 0);
      aEqual(result(i) : '');
    else;
      expected = result(i);
      assert(memcmp(%addr(expected) : value.string : value.length) = 0 : '');
    endif;
  enddo;
  
  iEqual(elements : i);
  
  sList_free(segments);
end-proc;


dcl-proc test_rootOnly export;
  dcl-s httpMessage varchar(1000) ccsid(819);
  
  httpMessage = 'GET / HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + CRLF;
  lookForHeaders(%addr(request) : %addr(httpMessage : *data) : %len(httpMessage));
  
  aEqual(utf8('/') : il_getRequestResource(request));
  aEqual(utf8('') : il_getRequestSegmentByIndex(request : 0));
end-proc;

dcl-proc test_singleSegment export;
  dcl-s httpMessage varchar(1000) ccsid(819);
  
  httpMessage = 'GET /api HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + CRLF;
  lookForHeaders(%addr(request) : %addr(httpMessage : *data) : %len(httpMessage));
  
  aEqual(utf8('api') : il_getRequestSegmentByIndex(request : 0));
end-proc;

dcl-proc test_multipleSegments export;
  dcl-s httpMessage varchar(1000) ccsid(819);
  
  httpMessage = 'GET /api/users HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + CRLF;
  lookForHeaders(%addr(request) : %addr(httpMessage : *data) : %len(httpMessage));
  
  aEqual(utf8('api') : il_getRequestSegmentByIndex(request : 0));
  aEqual(utf8('users') : il_getRequestSegmentByIndex(request : 1));
end-proc;

dcl-proc test_emptySegments export;
  dcl-s httpMessage varchar(1000) ccsid(819);
  
  httpMessage = 'GET /api//users HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + CRLF;
  lookForHeaders(%addr(request) : %addr(httpMessage : *data) : %len(httpMessage));
  
  aEqual(utf8('api') : il_getRequestSegmentByIndex(request : 0));
  aEqual(utf8('') : il_getRequestSegmentByIndex(request : 1));
  aEqual(utf8('users') : il_getRequestSegmentByIndex(request : 2));
end-proc;

dcl-proc test_emptyEndingSegment export;
  dcl-s httpMessage varchar(1000) ccsid(819);
  
  httpMessage = 'GET /api/users/ HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + CRLF;
  lookForHeaders(%addr(request) : %addr(httpMessage : *data) : %len(httpMessage));
  
  aEqual(utf8('api') : il_getRequestSegmentByIndex(request : 0));
  aEqual(utf8('users') : il_getRequestSegmentByIndex(request : 1));
  aEqual(utf8('') : il_getRequestSegmentByIndex(request : 2));
end-proc;

dcl-proc test_outOfRange export;
  dcl-s httpMessage varchar(1000) ccsid(819);
  
  httpMessage = 'GET /api/users HTTP/1.1' + CRLF + 'Host: localhost' + CRLF + CRLF;
  lookForHeaders(%addr(request) : %addr(httpMessage : *data) : %len(httpMessage));
  
  aEqual(utf8('') : il_getRequestSegmentByIndex(request : 10));
end-proc;


dcl-proc setup export;
  request = createRequest();
end-proc;

dcl-proc teardown export;
  disposeRequest(request);
end-proc;

dcl-proc utf8;
  dcl-pi *n varchar(1024) ccsid(*utf8);
    string varchar(1024) const;
  end-pi;
  
  return string;
end-proc;


dcl-proc createRequest;
  dcl-pi *n likeds(il_request) end-pi;

  dcl-ds request likeds(il_request) inz;
  dcl-ds headerList likeds(il_varchar) based(headerListPtr);
  
  request.config = %alloc(%size(il_config));

  return request;
end-proc;


dcl-proc disposeRequest;
  dcl-pi *n;
    request likeds(il_request);
  end-pi;
  
  dealloc request.config;
  sList_free(SLIST);
end-proc;


**CTDATA g_result1
 
**CTDATA g_result2
 
 
**CTDATA g_result3
api
**CTDATA g_result4
api
users
**CTDATA g_result5
api
users
:email
**CTDATA g_result6
api
users
:email
 
