**FREE

///
// BASE64 Unit Test
//
//
// @author Mihael Schmidt
// @date   12.11.2018
///


ctl-opt nomain;


//
// Includes
//
/include '../headers/ileastic.rpgle'
/include assert

dcl-pr memcpy pointer extproc('memcpy');
  dest   pointer value;
  source pointer value;
  count  uns(10) value;
end-pr;

//
// Prototypes
//
dcl-pr test_il_encode end-pr;
dcl-pr test_il_decode end-pr;


//
// Procedures
//
dcl-proc test_il_encode export;
  aEqual(utf8('bXlfdXNlcm5hbWU6bXlfcGFzc3dv') : il_encodeBase64('my_username:my_passwo'));
end-proc;

dcl-proc test_il_decode export;
  dcl-s encoded varchar(100) ccsid(*utf8);
  
  encoded = 'bXlfdXNlcm5hbWU6bXlfcGFzc3dv';
  
  aEqual(utf8('my_username:my_passwo') : il_decodeBase64(encoded));
end-proc;

dcl-proc utf8;
  dcl-pi *n varchar(1024) ccsid(*utf8);
    string varchar(1024) const;
  end-pi;
  
  return string;
end-proc;
