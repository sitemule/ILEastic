**FREE

///
// ILEastic : System Authentication Provider
//
// This ILEastic plugin retrieves the username and password from the thread
// local storage and tries to validate the user at the system it is running
// on.
//
// The credentials are expected at the following paths:
//
// /ileastic/auth/username and /ileastic/auth/password
//
// If this plugin cannot authenticate the user the plugin chain will be
// interrupted by returning *off from this plugin procedure. Additionally
// an HTTP response will be sent with status 401.
//
// The plugin retrieving the credentials from the HTTP request and putting
// it into the thread local storage must be registered before this plugin
// so that this plugin is called _after_ the other one.
//
// @author Mihael Schmidt
// @date   05.03.2019
///

ctl-opt nomain thread(*concurrent);

/include 'noxDB/headers/JSONXML.rpgle'
/include 'headers/ileastic.rpgle'

dcl-ds qusec_t qualified template;
  bytesProvided int(10);
  bytesAvailable int(10);
  exceptionId char(7);
  reserved char(2);
end-ds;

dcl-pr il_auth_system ind extproc(*dclcase);
  request  likeds(il_request);
  response likeds(il_response);
end-pr;


dcl-proc il_auth_system export;
  dcl-pi *n ind;
    request  likeds(il_request);
    response likeds(il_response);
  end-pi;

  dcl-s json pointer;
  dcl-s username varchar(4094:2);
  dcl-s password varchar(4094:2);
  dcl-s valid ind;

  json = il_getThreadMem(request);
  username = jx_getStr(json : '/ileastic/auth/username');
  password = jx_getStr(json : '/ileastic/auth/password');

  if (username = *blank or password = *blank);
    return *off;
  else;
    if (isValidUser(username : password));
      return *on;
    else;
      response.status = 401;
      response.statusText = 'Unauthorized';
      il_responseWrite(response : 'Invalid credentials.');
      return *off;
    endif;
  endif;
end-proc;


dcl-proc isValidUser;
  dcl-pi *n ind;
    username char(10) const;
    password char(512) const;
  end-pi;

  dcl-pr sys_getProfileHandle extpgm('QSYGETPH');
    username char(10) const;
    password char(512) const;
    profileHandle char(12);
    errorCode likeds(qusec_t);
    passwordLength int(10) const;
    passwordCcsid int(10) const;
  end-pr;

  dcl-pr sys_releaseProfileHandle extpgm('QSYRLSPH');
    profileHandle char(12) const;
  end-pr;

  dcl-s profileHandle char(12);
  dcl-ds errorCode likeds(qusec_t) inz;

  monitor;
    sys_getProfileHandle(username : password : profileHandle : errorCode : %len(%trimr(password)) : 0);
    sys_releaseProfileHandle(profileHandle);
    return *on;
  on-error *all;
    return *off;
  endmon;
end-proc;
