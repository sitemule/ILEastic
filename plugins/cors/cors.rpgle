**FREE

///
// ILEastic : CORS Plugin
//
// This plugin adds CORS-Headers to a Request.
//
// @author Paul Siefke
// @date 2020-07-31
///


ctl-opt nomain thread(*concurrent) 
/IF DEFINED(*V7R3M0)
  debug(*constants)
/ENDIF
;


/include 'headers/ileastic.rpgle'
/include 'cors_h.rpginc'

// regcomp() cflags
dcl-c REG_BASIC          0;
dcl-c REG_EXTENDED       1;
dcl-c REG_ICASE          2;
dcl-c REG_NEWLINE        4;
dcl-c REG_NOSUB          8;
dcl-c REG_ALT_N         16;
// regexec() eflags
dcl-c REG_NOTBOL       256; 
dcl-c REG_NOTEOL       512;
// Regular Expression error codes
dcl-c REG_NOMATCH        1;
dcl-c REG_BADPAT         2;
dcl-c REG_ECOLLATE       3;
dcl-c REG_ECTYPE         4;
dcl-c REG_EESCAPE        5;
dcl-c REG_ESUBREG        6;
dcl-c REG_EBRACK         7;
dcl-c REG_EPAREN         8;
dcl-c REG_EBRACE         9;
dcl-c REG_BADBR         10;
dcl-c REG_ERANGE        11;
dcl-c REG_ESPACE        12;
dcl-c REG_BADRPT        13;
dcl-c REG_ECHAR         14;
dcl-c REG_EBOL          15;
dcl-c REG_EEOL          16;
dcl-c REG_ECOMP         17;
dcl-c REG_EEXEC         18;
dcl-c REG_LAST          18;

dcl-pr regcomp int(10) extproc('regcomp');
  cregex   likeds(t_regex);
  //pattern  pointer value options(*string);
  pattern  pointer value;
  cflags   int(10) value;
end-pr;     

dcl-pr regexec int(10) extproc('regexec');
  preg      likeds(t_regex) const;
  string    pointer value  options(*string);
  nmatch    uns(10) value;
  pmatch    likeds(t_regmatch) dim(100) options(*varsize);
  eflags    int(10) value;
end-pr;

dcl-pr regerror uns(10) extproc('regerror');
  errcode     int(10) value;
  preg        likeds(t_regex) const;
  errbuf      char(65535) options(*varsize) ccsid(37);
  errbuf_size int(10) value;
end-pr;  

dcl-pr regfree extproc('regfree');
  cregex   likeds(t_regex);
end-pr;

dcl-ds t_regmatch qualified template align;
  rm_so       int(10);
  rm_ss       int(5);
  rm_eo       int(10);
  rm_es       int(5);
end-ds;

dcl-ds t_regex qualified template;
  re_nsub     uns(10);
//  *n          char(10);
  re_comp     pointer;
  re_cflags   int(10);
  re_erroff   uns(10);
  re_len      uns(10);
  re_ucoll    int(10) dim(2);
//  *n          char(12);
  re_lsub     pointer;
  lsub_ar     uns(10) dim(16);
  esub_ar     uns(10) dim(16);
  *n          pointer;
  re_esub     pointer;
  re_specchar pointer;
  re_phdl     pointer;
  comp_spc    char(112);
  re_map      char(256);
  re_shift    int(5);
  re_dbcs     int(5);
  *n          char(12);
end-ds;

dcl-ds t_corsConfiguration qualified template;
  regex varchar(1000);
  cregex likeds(t_regex);
  allowedMethods varchar(100);
  allowedExposeHeaders varchar(1000);
  allowedRequestHeaders varchar(1000);
  allowCredentials ind;
  customHandler pointer(*proc);
end-ds;

dcl-ds corsConfigurations likeds(t_corsConfiguration) dim(100) static(*allthread);
dcl-s corsConfigurationsSize int(10) static(*allthread);

dcl-s handler pointer(*proc);
dcl-pr customHandler ind extproc(handler);
  request  likeds(il_request);
  response likeds(il_response);
end-pr;

///
// CORS support
// 
// @param ILEastic requesthandle
// @param ILEastic responsehandle
///
dcl-proc il_addCorsHeaders export;
  dcl-pi *n ind;
    request  likeds(il_request);
    response likeds(il_response);
  end-pi;
//---
  dcl-s result ind inz(*off);
  dcl-s originHeader varchar(1000);
  dcl-ds corsMapping likeds(t_corsConfiguration);
  dcl-s retcode int(10);
  dcl-s nmatch uns(10) inz(1);
  dcl-ds pmatch likeds(t_regmatch);
  dcl-s eflags int(10);
  dcl-s it int(10);
  dcl-s allowedRequestHeaders like(corsMapping.allowedRequestHeaders);

  monitor;

    if corsConfigurationsSize = 0;
      il_addHeader(response: IL_HEADERS_CORS_ALLOW_HEADERS: '*, Authorization');
      il_addHeader(response: IL_HEADERS_CORS_ALLOW_METHODS: '*');
      il_addHeader(response: IL_HEADERS_CORS_ALLOW_ORIGIN: '*');
      il_addHeader(response: IL_HEADERS_CORS_EXPOSE_HEADERS: '*');
      il_addHeader(response: IL_HEADERS_CORS_ALLOW_CREDENTIALS : 'true');
    else;
      originHeader = il_getRequestHeader(request : 'Origin');
      if originHeader <> *blanks;
        for it = 1 to corsConfigurationsSize;
          corsMapping = corsConfigurations(it);
          retcode = regexec(corsMapping.cregex:originHeader:nmatch:pmatch:eflags);
          if retcode = 0;
            if corsMapping.customHandler <> *null;
              handler = corsMapping.customHandler;
              return customHandler(request:response);
            else;
              il_addHeader(response: IL_HEADERS_CORS_ALLOW_ORIGIN: %subst(originHeader : 1 : pmatch.rm_eo));
              il_addHeader(response: IL_HEADERS_CORS_EXPOSE_HEADERS: corsMapping.allowedExposeHeaders);
              il_addHeader(response: IL_HEADERS_CORS_ALLOW_METHODS: corsMapping.allowedMethods);
              allowedRequestHeaders = corsMapping.allowedRequestHeaders;
              if corsMapping.allowCredentials;
                il_addHeader(response: IL_HEADERS_CORS_ALLOW_CREDENTIALS: 'true');
                allowedRequestHeaders += ', Authorization';
              endif;
              il_addHeader(response: IL_HEADERS_CORS_ALLOW_HEADERS: allowedRequestHeaders);
            endif;
            leave;
          endif;
        endfor;
      endif;
    endif;

    if il_cors_isPreflight(request);
      response.status = IL_HTTP_OK;
      result = *off;
    else;
      result = *on;
    endif;
  on-error;
      response.status = IL_HTTP_INTERNAL_SERVER_ERROR;
      result = *off;
  endMon;

  return result;
//---
end-proc; 

dcl-proc addCorsConfiguration;
  dcl-pi *n int(10);
    pattern pointer value options(*string);
    methods pointer value options(*string);
    exposeHeaders pointer value options(*string);
    allowHeaders pointer value options(*string);
    customHandler pointer(*proc) value;
    allowCredentials ind value;
  end-pi;

  dcl-ds corsMapping likeds(t_corsConfiguration);
  dcl-ds cregex likeds(t_regex);
  dcl-s errbuf char(65535) ccsid(37);
  dcl-s retcode int(10);
  dcl-s idx int(10);
  dcl-s message varchar(1000);

  retcode = regcomp(cregex:pattern:REG_EXTENDED + REG_ICASE);
  if retcode <> 0;
    regerror(retcode:cregex:errbuf:%size(errbuf));
    message = 'Regular expression compilation failure: RC=' + %char(retcode) + ', MESSAGE=' + %trim(errbuf);
    il_Joblog(message);
    return 1;
  endif;

  corsMapping.regex = %str(pattern);
  if methods <> *null;
    corsMapping.allowedMethods = %str(methods);
  endif;
  if exposeHeaders <> *null;
    corsMapping.allowedExposeHeaders = %str(exposeHeaders);
  endif;
  if allowHeaders <> *null;
    corsMapping.allowedRequestHeaders = %str(allowHeaders);
  endif;
  corsMapping.allowCredentials = allowCredentials;
  corsMapping.cregex = cregex;
  corsMapping.customHandler = customHandler;

  idx = %lookup(%str(pattern) : corsConfigurations(*).regex);
  if idx = 0;
    corsConfigurationsSize += 1;
    corsConfigurations(corsConfigurationsSize) = corsMapping;
  else;
    regfree(corsConfigurations(idx).cregex);
    corsConfigurations(idx) = corsMapping;
  endif;

  return 0;
end-proc;

dcl-proc il_cors_resetCorsConfiguration export;
  dcl-pi *n extproc(*dclcase) end-pi;
  clear corsConfigurations;
  corsConfigurationsSize = 0;
end-proc;

dcl-proc il_cors_addCorsConfigurationCustomHandler export;
  dcl-pi *n int(10);
    pattern pointer value options(*string);
    handler pointer(*proc) value;
  end-pi;

  return addCorsConfiguration(pattern:*null:*null:*null:handler:*off);
end-proc;

dcl-proc il_cors_addCorsConfigurationValues export;
  dcl-pi *n int(10);
    pattern pointer value options(*string);
    methods pointer value options(*string);
    exposeHeaders pointer value options(*string);
    allowHeaders pointer value options(*string);
    allowCredentials ind value options(*nopass);
  end-pi;

  dcl-s l_allowCredentials ind;

  if %parms() >= %parmnum(allowCredentials);
    l_allowCredentials = allowCredentials;
  endif;

  return addCorsConfiguration(pattern:methods:exposeHeaders:allowHeaders:*null:l_allowCredentials);
end-proc;

dcl-proc il_cors_isPreflight export;
  dcl-pi *n ind;
    request likeds(il_request);
  end-pi;

  return il_getRequestMethod(request) = 'OPTIONS' 
          and il_getRequestHeader(request : IL_HEADERS_CORS_REQUEST_METHOD) <> *blanks;
end-proc;