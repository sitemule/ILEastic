**FREE

///
// Return Padded JSON String Example
//
// This example shows how to return a padded JSON value to the caller.
//
// The current date will be returned as parts to the caller padded in the 
// JSON callback function name.
//
// Start it:
// SBMJOB CMD(CALL PGM(QUERYSTR)) JOB(ILEASTIC5) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)        
//
// The web service can be tested with the browser by entering the following URL:
// http://my_ibm_i:44001?callback=angular.callback.123
//
// @info: It requires your RPG code to be reentrant and compiled for 
//        multithreading. Each client request is handled by a seperate thread.
//
// @link https://en.wikipedia.org/wiki/JSONP JSONP at Wikipedia
///

ctl-opt copyright('Sitemule.com  (C), 2018');
ctl-opt decEdit('0,') datEdit(*YMD.) main(main);
ctl-opt debug(*yes) bndDir('ILEASTIC');
ctl-opt thread(*CONCURRENT);

/include ./headers/ileastic.rpgle

dcl-c CURLY_OPEN u'007B';
dcl-c CURLY_CLOSE u'007D';

// -----------------------------------------------------------------------------
// Program Entry Point
// -----------------------------------------------------------------------------     
dcl-proc main;

    dcl-ds config likeds(il_config);
    
    config.port = 44001; 
    config.host = '*ANY';

    il_listen (config : %paddr(myservlet));
 
end-proc;

// -----------------------------------------------------------------------------
// Servlet callback implementation
// -----------------------------------------------------------------------------     
dcl-proc myservlet;

    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;
    
    dcl-s content varchar(1000);
    dcl-s callback varchar(100);
      
    // Get the callback function name from the query string.
    callback = il_getParmStr(request : 'callback');

    content = buildResponseContent();

    if (callback = *blank); 
      // no callback function name given => return the plain JSON object
      il_responseWrite(response : content);
    else;
      // callback function name given => return the JSON object wrapped
      il_responseWrite(response : callback + '(' + content + ')');
    endif;
end-proc;


dcl-proc buildResponseContent;
  dcl-pi *n varchar(1000) end-pi;

  dcl-s content varchar(1000);
  dcl-s currentDate date;
  currentDate = %date();
  
  content = CURLY_OPEN;
  content += '"date" : "' + %char(currentDate) + '" , ';
  content += '"year" : ' + %char(%subdt(currentDate : *years)) + ', ';
  content += '"month" : ' + %char(%subdt(currentDate : *months)) + ', ';
  content += '"day" : ' + %char(%subdt(currentDate : *days));
  content += CURLY_CLOSE;
  
  return content;
end-proc;
