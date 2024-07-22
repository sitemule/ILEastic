**FREE

///
// ILEastic : Kong Registration
//
// This example shows how an ILEastic web service can be automatically added
// to a Kong API Gateway instance for load balancing.
//
// The web service will be added as a target to the configured upstream and will
// remove itself from the upstream on ending of the program.
//
// This examples does not run out of the box as it needs to be adjusted to your
// environment.
//
// @author Mihael Schmidt
///
 
ctl-opt main(main) dftactgrp(*no) actgrp(*caller);
ctl-opt bnddir('ILEASTIC/ILEASTIC' : 'ILEASTIC/JSONXML' : 'ILEVATOR/ILEVATOR');
 
/define RPG_HAS_OVERLOAD
/include 'jsonxml.rpgle'
/include 'ileastic.rpgle'
/include 'ilevator.rpgle'
/include 'kong.rpginc'
 
dcl-proc main;
    dcl-ds config likeds(il_config);
    dcl-s ilevator pointer;
    dcl-s authIlevator pointer;
    dcl-ds authProvider likeds(il_kong_oauth2AuthProvider_t) inz;
 
    //
    // We need 2 HTTP client instances, one with an auth provider and one without!
    //
   
    ilevator = iv_newHttpClient();
    iv_setCertificate(ilevator : '/usr/local/etc/certs/ilevator.kdb' : 'ilevator');
   
    authIlevator = iv_newHttpClient();
    iv_setCertificate(ilevator : '/usr/local/etc/certs/ilevator.kdb' : 'ilevator');
   
    authProvider = il_kong_getOauth2AuthProvider(
        authIlevator :
        'https://iam.company.com/realms/YOUR_REALM/protocol/openid-connect/token' :
        'your_client_id' :
        'your_client_secret'
    );
 
    iv_setAuthProvider(ilevator : %addr(authProvider));
    il_kong_register(ilevator : 'https://kong.company.com' : 'ileastic-upstream' : 'test:35897');
 
 
    config.port = 44100;
    config.host = '*ANY';
 
    il_addRoute(config : %paddr(sayHello) : IL_GET);
    il_listen(config);
   
    on-exit;
        il_kong_deregister(ilevator : 'https://kong.company.com' : 'ileastic-upstream' : 'test:35897');
        iv_free(ilevator);
        iv_free(authIlevator);
end-proc;
 
 
dcl-proc sayHello;
  dcl-pi *n;
    request  likeds(IL_REQUEST);
    response likeds(IL_RESPONSE);
  end-pi;
 
  response.status = 200;
  il_responseWrite(response : 'Hello World');
end-proc;
