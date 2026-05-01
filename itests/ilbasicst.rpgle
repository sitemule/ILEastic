**FREE

///
// Integration Test Suite
//
// This test suite tests the different parts of ILEastic.
//
// @author Mihael Schmidt
// @date   09.04.2026
///


ctl-opt nomain;


/include assert
/include ilevator
/include jsonxml
/include '../headers/ileastic.rpgle'

dcl-pr getenv pointer extproc('getenv');
  envvar pointer value options(*string : *trim);
end-pr;

dcl-c REGEX_START u'005E';
dcl-c BRACKET_OPEN u'005B';
dcl-c BRACKET_CLOSE u'005D';
dcl-c CURLY_OPEN u'007B';
dcl-c CURLY_CLOSE u'007D';
dcl-c REGEX_END u'0024';

dcl-pr setup end-pr;
dcl-pr teardown end-pr;
dcl-pr test_getWithQuery end-pr;
dcl-pr test_getWithJsonAccept end-pr;
dcl-pr test_getWithCustomAccept end-pr;
dcl-pr test_getResponeHttpHeader end-pr;
dcl-pr test_getEmptySearchResult end-pr;
dcl-pr test_delete end-pr;
dcl-pr test_patchAccepted end-pr;
dcl-pr test_patchPathParameterValidation end-pr;
dcl-pr test_patchNotFound end-pr;
dcl-pr test_head end-pr;
dcl-pr test_headNotFound end-pr;
dcl-pr test_headErrorMessageBody end-pr;
dcl-pr test_options end-pr;
dcl-pr test_post end-pr;
dcl-pr test_routeNotFound end-pr;


dcl-s httpClient pointer;
dcl-s keyFilePath varchar(1000);
dcl-s keyFileSecret varchar(100);
dcl-s baseUrl varchar(100);
dcl-s buffer varchar(65000:4) ccsid(1208);
dcl-s book varchar(1000);

dcl-proc setup export;
    dcl-s value pointer;

    value = getenv('ILEASTIC_ITEST_KEYFILE_PATH');
    if (value <> *null);
        keyFilePath = %str(value);
    endif;

    value = getenv('ILEASTIC_ITEST_KEYFILE_SECRET');
    if (value <> *null);
        keyFileSecret = %str(value);
    endif;

    value = getenv('ILEASTIC_ITEST_BASE_URL');
    if (value <> *null);
        baseUrl = %str(value);
    else;
        baseUrl = 'http://localhost:44000';
    endif;


    httpClient = iv_newHttpClient();
    iv_setTimeout(httpClient : 5);
    iv_setRetries(httpClient : 1);
    iv_setCertificate(httpClient : '/home/mschmidt/cert/rpgnextgen/server.kdb' : 'changeit');

    book = BRACKET_OPEN;
    book += CURLY_OPEN;
    book += '"id" : 358 , +
        "title" : "The Vampire Lestat", +
        "subtitle" : "Vampire Chronicles Book 2", +
        "publisher" : "Random House Publishing Group", +
        "language" : "english", +
        "format" : "tradepaperback", +
        "isbn" : "0345419642", +
        "isbn13" : "978-0345419644", +
        "relaseDate" : "1997-11-29" ';
    book += CURLY_CLOSE;
    book += BRACKET_CLOSE;
end-proc;


dcl-proc teardown export;
    iv_free(httpClient);
end-proc;


dcl-proc test_getWithQuery export;
    clear buffer;
    iv_setResponseDataBuffer (httpClient : %addr(buffer) : %size(buffer) : IV_VARCHAR4 : IV_CCSID_UTF8);

    iv_execute(httpClient : 'GET' : baseUrl + '/book/excerpt?q=vampire%20lestat');
    iEqual(IV_HTTP_OK : iv_getStatus(httpClient));
    aEqual('We kissed tenderly amid the laughter and the reek of wine. Ah, the smell of innocent blood.' : buffer);
end-proc;


dcl-proc test_getWithJsonAccept export;
    dcl-s headers pointer;

    headers = iv_buildList(
        'accept' : 'application/json'
    );

    clear buffer;
    iv_setResponseDataBuffer (httpClient : %addr(buffer) : %size(buffer) : IV_VARCHAR4 : IV_CCSID_UTF8);

    iv_execute(httpClient : 'GET' : baseUrl + '/book?q=vampire%20lestat' : headers);
    iEqual(IV_HTTP_OK : iv_getStatus(httpClient));
    aEqual(book : buffer);

    on-exit;
        iv_freeList(headers);
end-proc;


dcl-proc test_getResponeHttpHeader export;
    dcl-s headers pointer;

    headers = iv_buildList(
        'accept' : 'application/json'
    );

    clear buffer;
    iv_setResponseDataBuffer (httpClient : %addr(buffer) : %size(buffer) : IV_VARCHAR4 : IV_CCSID_UTF8);

    iv_execute(httpClient : 'GET' : baseUrl + '/book?q=vampire%20lestat' : headers);
    iEqual(IV_HTTP_OK : iv_getStatus(httpClient));
    aEqual('358' : iv_getHeader(httpClient : 'IL_BOOKS_COUNT'));

    on-exit;
        iv_freeList(headers);
end-proc;


dcl-proc test_getWithCustomAccept export;
    dcl-s headers pointer;

    headers = iv_buildList(
        'accept' : 'application/vnd.rpgnextgen.isbn'
    );

    clear buffer;
    iv_setResponseDataBuffer (httpClient : %addr(buffer) : %size(buffer) : IV_VARCHAR4 : IV_CCSID_UTF8);

    iv_execute(httpClient : 'GET' : baseUrl + '/book?q=vampire%20lestat' : headers);
    iEqual(IV_HTTP_OK : iv_getStatus(httpClient));
    aEqual('0345419642' : buffer);

    on-exit;
        iv_freeList(headers);
end-proc;


dcl-proc test_getEmptySearchResult export;
    dcl-s headers pointer;

    headers = iv_buildList(
        'accept' : 'application/json'
    );

    clear buffer;
    iv_setResponseDataBuffer (httpClient : %addr(buffer) : %size(buffer) : IV_VARCHAR4 : IV_CCSID_UTF8);

    iv_execute(httpClient : 'GET' : baseUrl + '/book?q=arman' : headers);
    iEqual(IV_HTTP_OK : iv_getStatus(httpClient));
    aEqual(BRACKET_OPEN + BRACKET_CLOSE : buffer);

    on-exit;
        iv_freeList(headers);
end-proc;


dcl-proc test_delete export;
    clear buffer;
    iv_setResponseDataBuffer (httpClient : %addr(buffer) : %size(buffer) : IV_VARCHAR4 : IV_CCSID_UTF8);

    iv_execute(httpClient : 'DELETE' : baseUrl + '/book/123');
    iEqual(IV_HTTP_NO_CONTENT : iv_getStatus(httpClient));
    iEqual(0 : %len(buffer));
end-proc;


dcl-proc test_patchAccepted export;
    dcl-s headers pointer;
    dcl-s messageBody varchar(1000:4) ccsid(1208);
    dcl-s json pointer;

    messageBody = '128';
    iv_setRequestDataBuffer(httpClient : %addr(messageBody) : %size(messageBody) : IV_VARCHAR4 : IV_CCSID_UTF8);

    headers = iv_buildList(
        'Content-Type' : 'text/plain'
    );

    clear buffer;
    iv_setResponseDataBuffer (httpClient : %addr(buffer) : %size(buffer) : IV_VARCHAR4 : IV_CCSID_UTF8);

    iv_execute(httpClient : 'PATCH' : baseUrl + '/book/978-0345419644/rating' : headers);
    iEqual(IV_HTTP_OK : iv_getStatus(httpClient));
    
    json = jx_parseStringCcsid(%addr(buffer : *data) : 1208);
    iEqual(128 : jx_getInt(json : 'rating'));

    on-exit;
        iv_freeList(headers);
        jx_close(json);
end-proc;


dcl-proc test_patchPathParameterValidation export;
    dcl-s headers pointer;
    dcl-s messageBody varchar(1000:4) ccsid(1208);
    dcl-s json pointer;

    messageBody = '128';
    iv_setRequestDataBuffer(httpClient : %addr(messageBody) : %size(messageBody) : IV_VARCHAR4 : IV_CCSID_UTF8);

    headers = iv_buildList(
        'Content-Type' : 'text/plain'
    );

    clear buffer;
    iv_setResponseDataBuffer (httpClient : %addr(buffer) : %size(buffer) : IV_VARCHAR4 : IV_CCSID_UTF8);

    iv_execute(httpClient : 'PATCH' : baseUrl + '/book/978-0345419644-invalid/rating' : headers);
    iEqual(IV_HTTP_BAD_REQUEST : iv_getStatus(httpClient));

    on-exit;
        iv_freeList(headers);
end-proc;


dcl-proc test_patchNotFound export;
    dcl-s headers pointer;
    dcl-s messageBody varchar(1000:4) ccsid(1208);
    dcl-s json pointer;

    messageBody = '128';
    iv_setRequestDataBuffer(httpClient : %addr(messageBody) : %size(messageBody) : IV_VARCHAR4 : IV_CCSID_UTF8);

    headers = iv_buildList(
        'Content-Type' : 'text/plain'
    );

    clear buffer;
    iv_setResponseDataBuffer (httpClient : %addr(buffer) : %size(buffer) : IV_VARCHAR4 : IV_CCSID_UTF8);

    iv_execute(httpClient : 'PATCH' : baseUrl + '/book/978-0345419646/rating' : headers);
    iEqual(IV_HTTP_NOT_FOUND : iv_getStatus(httpClient));

    on-exit;
        iv_freeList(headers);
end-proc;


dcl-proc test_head export;
    clear buffer;
    iv_setResponseDataBuffer (httpClient : %addr(buffer) : %size(buffer) : IV_VARCHAR4 : IV_CCSID_UTF8);

    iv_execute(httpClient : 'HEAD' : baseUrl + '/book/978-0345419644');
    iEqual(IV_HTTP_NO_CONTENT : iv_getStatus(httpClient));
    assert(%len(buffer) = 0 : 'Message body should be ignored on HEAD request.');
end-proc;


dcl-proc test_headNotFound export;
    clear buffer;
    iv_setResponseDataBuffer (httpClient : %addr(buffer) : %size(buffer) : IV_VARCHAR4 : IV_CCSID_UTF8);

    iv_execute(httpClient : 'HEAD' : baseUrl + '/book/978-0345419690');
    iEqual(IV_HTTP_NOT_FOUND : iv_getStatus(httpClient));
    assert(%len(buffer) = 0 : 'Message body should be ignored on HEAD request.');
end-proc;


dcl-proc test_headInvalidPathParameter export;
    clear buffer;
    iv_setResponseDataBuffer (httpClient : %addr(buffer) : %size(buffer) : IV_VARCHAR4 : IV_CCSID_UTF8);

    iv_execute(httpClient : 'HEAD' : baseUrl + '/book/978-034541964xx');
    iEqual(IV_HTTP_BAD_REQUEST : iv_getStatus(httpClient));
    assert(%len(buffer) = 0 : 'Message body should be ignored on HEAD request.');
end-proc;


dcl-proc test_options export;
    clear buffer;
    iv_setResponseDataBuffer (httpClient : %addr(buffer) : %size(buffer) : IV_VARCHAR4 : IV_CCSID_UTF8);

    iv_execute(httpClient : 'OPTIONS' : baseUrl + '/book');
    iEqual(IV_HTTP_NO_CONTENT : iv_getStatus(httpClient));
    aEqual('GET,POST' : iv_getHeader(httpClient : 'Allow'));
end-proc;


dcl-proc test_post export;
    dcl-s messageBody varchar(1000:4) ccsid(1208);
    dcl-s json pointer;
    dcl-s headers pointer;

    messageBody = CURLY_OPEN;
    messageBody += '"title": "The Queen of the Damned", +
		"subtitle": "Vampire Chronicles Book 2", +
		"publisher": "Random House Publishing Group", +
		"language": "english", +
		"format": "tradepaperback", +
		"isbn": "0345419626", +
		"isbn13": "978-0345419620", +
		"relaseDate": "1997-11-29"';
    messageBody += CURLY_CLOSE;
    iv_setRequestDataBuffer(httpClient : %addr(messageBody) : %size(messageBody) : IV_VARCHAR4 : IV_CCSID_UTF8);

    headers = iv_buildList(
        'Content-Type' : 'application/json' :
        'Accept' : 'application/json'
    );

    clear buffer;
    iv_setResponseDataBuffer (httpClient : %addr(buffer) : %size(buffer) : IV_VARCHAR4 : IV_CCSID_UTF8);

    iv_execute(httpClient : 'POST' : baseUrl + '/book' : headers);
    iEqual(IV_HTTP_CREATED : iv_getStatus(httpClient));

    json = jx_parseStringCcsid(%addr(buffer : *data) : 1208);
    aEqual('0345419626' : jx_getStr(json : 'isbn'));
    iEqual(359 : jx_getInt(json : 'id'));
    assert(jx_isNull(json : 'rating') : 'There should not be a rating on a new book.');

    on-exit;
        jx_close(json);
        iv_freeList(headers);
end-proc;


dcl-proc test_routeNotFound export;
    clear buffer;
    iv_setResponseDataBuffer (httpClient : %addr(buffer) : %size(buffer) : IV_VARCHAR4 : IV_CCSID_UTF8);

    iv_execute(httpClient : 'GET' : baseUrl + '/not_valid_route');
    iEqual(IV_HTTP_NOT_FOUND : iv_getStatus(httpClient));
end-proc;