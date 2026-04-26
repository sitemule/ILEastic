**FREE

///
// Integration Test : Basics
//
// This test covers all the basics one would encounter in a CRUD application.
//
// Start it:
//
// ADDLIBLE ILEASTIC
// SBMJOB CMD(CALL PGM(ILBASICS)) JOB(ILEASTIC) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES) CPYENVVAR(*YES)
// 
// @info It requires your RPG code to be reentrant and compiled for 
//       multithreading. Each client request is handled by a seperate thread.
///

ctl-opt main(main) debug(*yes) thread(*CONCURRENT);


/include ileastic
/include jsonxml

dcl-pr getenv pointer extproc('getenv');
  envvar pointer value options(*string : *trim);
end-pr;

dcl-c REGEX_START u'005E';
dcl-c BRACKET_OPEN u'005B';
dcl-c BRACKET_CLOSE u'005D';
dcl-c CURLY_OPEN u'007B';
dcl-c CURLY_CLOSE u'007D';
dcl-c REGEX_END u'0024';

dcl-s book varchar(1000) static(*allthread);
dcl-s port int(10) inz(44000);
dcl-s keyFilePath varchar(1000);
dcl-s keyFileSecret varchar(100);

dcl-proc init;
    dcl-s value pointer;

    value = getenv('ILEASTIC_ITEST_KEYFILE_PATH');
    if (value <> *null);
        keyFilePath = %str(value);
    endif;

    value = getenv('ILEASTIC_ITEST_KEYFILE_SECRET');
    if (value <> *null);
        keyFileSecret = %str(value);
    endif;

    value = getenv('ILEASTIC_ITEST_PORT');
    if (value <> *null);
        port = %int(%str(value));
    endif;

    book = CURLY_OPEN;
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
end-proc;


dcl-proc main;
    dcl-ds config likeds(il_config) inz;
    
    init();

    config.port = port; 
    config.host = '*ANY';

    if (keyFilePath <> *blank);
        il_setKeyfile(config : keyFilePath : keyFileSecret);
    endif;

    il_addRoute(config : %paddr(test_getBookExcerpt) : IL_GET : REGEX_START + '/book/excerpt' + REGEX_END);
    il_addRoute(config : %paddr(test_deleteBook) : IL_DELETE: REGEX_START + '/book/' + CURLY_OPEN + 'isbn' + CURLY_CLOSE + REGEX_END);
    il_addRoute(config : %paddr(test_updateRating) : IL_PATCH : REGEX_START + '/book/' + CURLY_OPEN + 'isbn' + CURLY_CLOSE + '/rating' + REGEX_END);
    il_addRoute(config : %paddr(test_bookExists) : IL_HEAD : REGEX_START + '/book/' + CURLY_OPEN + 'isbn' + CURLY_CLOSE + REGEX_END);
    il_addRoute(config : %paddr(test_createBook) : IL_POST : REGEX_START + '/book' + REGEX_END);
    il_addRoute(config : %paddr(test_search) : IL_GET : REGEX_START + '/book' + REGEX_END);
    il_addRoute(config : %paddr(test_bookOptions) : IL_OPTIONS : REGEX_START + '/book' + REGEX_END);
    il_addRoute(config : %paddr(test_notFound));

    il_listen (config);
end-proc;


dcl-proc test_notFound;
    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;

    response.contentType = 'text/plain';
    response.status = 404;
    il_responseWrite(response: 'Route not found');
end-proc;


dcl-proc test_bookOptions;
    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;

    il_addHeader(response : 'Allow' : 'GET,POST');

    response.status = 204;
    il_responseWrite(response: '');
end-proc;


dcl-proc test_search;
    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;

    dcl-s q varchar(1000);
    dcl-s accept varchar(100);

    accept = il_getRequestHeader(request : 'accept');

    if (not (accept = 'application/json' or accept = 'application/vnd.rpgnextgen.isbn'));
        response.status = 415;
        il_responseWrite(response : 'Only application/json and application/vnd.rpgnextgen.isbn supported');
        return;
    endif;

    response.status = 200;

    q = il_getQueryParameter(request : 'q' : '');
    if (%scan('vampire' : q) > 0 or %scan('lestat' : q)  > 0);

        il_addHeader(response : 'IL_BOOKS_COUNT' : '358');

        if (accept = 'application/json');
            il_responseWrite(response : BRACKET_OPEN + book + BRACKET_CLOSE);
        else;
            il_responseWrite(response : '0345419642');
        endif;

    else;
        il_responseWrite(response : BRACKET_OPEN + BRACKET_CLOSE);
    endif;
end-proc;


dcl-proc test_bookExists;
    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;

    dcl-s isbn varchar(20) ccsid(1208);

    //  ISBN 0345419642 or 978-0345419644 : The Vampire Lestat
    isbn = il_getPathParameter(request : 'isbn' : '');
 
    if (isbn = '0345419642' or isbn = '978-0345419644');
        response.status = 204;
        il_responseWrite(response: '');
    elseif (%len(isbn) = 10 or %len(isbn) = 14);
        response.status = 404;
        response.contentType = 'text/plain';
        il_responseWrite(response : 'ISBN ' + isbn + ' not in store.');
    else;
        response.status = 400;
        response.contentType = 'text/plain';
        il_responseWrite(response: 'Valid length for ISBN is 10 and 13');
    endif;
end-proc;


dcl-proc test_getBookExcerpt;
    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;

    il_responseWrite(response: 'We kissed tenderly amid the laughter and the +
        reek of wine. Ah, the smell of innocent blood.');
end-proc;


dcl-proc test_createBook;
    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;

    dcl-s json pointer;
    dcl-s messageBody varchar(10000);
    dcl-s contentType varchar(100);

    contentType = il_getRequestHeader(request : 'Content-Type');
    if (contentType <> 'application/json');
        response.status = 415;
        il_responseWrite(response : 'Only application/json supported');
        return;
    endif;

    messageBody = il_getRequestContent(request);
    json = jx_parseString(messageBody);
    jx_setInt(json : 'id' : 359);
    jx_setNull(json : 'rating');

    response.status = 201;
    response.contentType = 'application/json';
    il_responseWriteStream(response: jx_stream(json));

    on-exit;
        jx_close(json);
end-proc;


dcl-proc test_deleteBook;
    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;

    response.status = 204;
    il_responseWrite(response: '');
end-proc;


dcl-proc test_updateRating;
    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;

    dcl-s rating int(5);
    dcl-s json pointer;
    dcl-s isbn varchar(20) ccsid(1208);

    if (%len(request.contentType) >= 10 and %subst(request.contentType : 1 : 10) = 'text/plain');
        response.status = 415;
        il_responseWrite(response: 'Only text/plain supported');
        return;
    endif;

    isbn = il_getPathParameter(request : 'isbn' : '');
    if (isbn = '0345419642' or isbn = '978-0345419644');
        monitor;
            rating = %int(il_getRequestContent(request));
        on-error;
            response.status = 400;
            il_responseWrite(response: 'Invalid rating');
            return;
        endmon;

        json = jx_parseString(book);
        jx_setInt(json : 'rating' : rating);
        il_responseWriteStream(response : jx_stream(json));
    elseif (%len(isbn) = 10 or %len(isbn) = 14);
        response.status = 404;
        il_responseWrite(response: 'ISBN ' + isbn + ' not in store.');
    else;
        response.status = 400;
        response.contentType = 'text/plain';
        il_responseWrite(response: 'Valid length for ISBN are 10 and 13');
    endif;

    on-exit;
        jx_close(json);
end-proc;