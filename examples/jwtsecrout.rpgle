**FREE

///
// ILEastic : JWT Token secured route
//
// This example shows how to secure an route/endpoint. The JWT plugin expects
// a valid JWT token signed with the secret key configured in this example.
//
// The secured route is located at / and will return the current time. For
// generating a valid token see https://jwt.io .
//
// @info: Keep in mind that JWT token verification also checks the expiration 
//        date if it is contained in the token (see claim "exp").
//
// @info: It requires your RPG code to be reentrant and compiled for 
//        multithreading. Each client request is handled by a seperate thread.
//
// @info: This example requires the JWT plugin service program to be installed 
//        before it will compile

ctl-opt copyright('Sitemule.com  (C), 2019');
ctl-opt decEdit('0,') datEdit(*YMD.) main(main);
ctl-opt debug(*yes) bndDir('ILEASTIC');
ctl-opt thread(*CONCURRENT);

/include ./headers/ileastic.rpgle
/include ./plugins/jwt/jwt.rpginc
/include ./plugins/jwt/jwtplugin.rpginc


// -----------------------------------------------------------------------------
// Program Entry Point
// -----------------------------------------------------------------------------
dcl-proc main;
  dcl-ds config likeds(il_config);
  dcl-ds jwtOptions likeds(jwt_options_t) inz;

  // The server will listen on port 44000.
  config.port = 44000;
  config.host = '*ANY';

  // Sets the key which will be used for verifying the JWT token.
  // This key should be kept secure (and not like this =) )!!!
  jwtOptions.alg = JWT_HS256;
  jwtOptions.key = 'eW91ci0yNTYtYml0LXNlY3JldA======';
  il_jwt_addVerifyOptions(jwtOptions);
  
  // Adds the JWT plugin to the chain of plugins
  // This will only check if each request has a valid JWT token.
  // It does not check if the requester is authorized to use this service!
  // It puts the payload of the JWT token in the thread local storage at
  // /ileastic/jwt/payload where it can be retrieve by any other plugin or 
  // servlet in this thread.
  //
  // The plugin will expect to have a HTTP header like
  // Authorization: Bearer <my_token>
  il_addPlugin(config : %paddr('il_jwt_filter') : IL_PREREQUEST);

  // Adds the secured route.
  il_addRoute(config : %paddr(getTime) : IL_GET);

  // Starts the server.
  il_listen(config);
end-proc;


// -----------------------------------------------------------------------------
// Servlet callback implementation
// -----------------------------------------------------------------------------
dcl-proc getTime;
  dcl-pi *n;
      request  likeds(IL_REQUEST);
      response likeds(IL_RESPONSE);
  end-pi;

  il_responseWrite(response : %char(%time()));
end-proc;

