**FREE

ctl-opt nomain;

/include assert
/include '../plugins/jwt/jwt_h.rpgle'


dcl-pr test_signing end-pr;
dcl-pr test_signing_jwtio_default end-pr;


dcl-proc test_signing_jwtio_default export;
  dcl-s signKey like(jwt_signKey_t);
  dcl-s payload varchar(1000);
  dcl-s token like(jwt_token_t);
  
  signKey = 'eW91ci0yNTYtYml0LXNlY3JldA======';
  payload = '{"sub":"1234567890","name":"John Doe","iat":1516239022}';
  token = jwt_sign(JWT_HS256 : payload : signKey);
  
  aEqual('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.YddUykUDlYG-S6QrIkcQGJea-Rq6bH6gSg2serstLdU' :token);
end-proc;

dcl-proc test_signing export;
  dcl-s signKey like(jwt_signKey_t);
  dcl-s payload varchar(1000);
  dcl-s token like(jwt_token_t);
  
  signKey = 'eW91ci0yNTYtYml0LXNlY3JldA======';
  payload = '{"sub":"public","user":"mihael","role":"admin","exp":1556991264}';
  token = jwt_sign(JWT_HS256 : payload : signKey);
  
  aEqual('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJwdWJsaWMiLCJ1c2VyIjoibWloYWVsIiwicm9sZSI6ImFkbWluIiwiZXhwIjoxNTU2OTkxMjY0fQ.H-aSZZQ1uEVDwdGGiGZHf1grgNkAYZRVWhJOe_rqz88' :token);
end-proc;