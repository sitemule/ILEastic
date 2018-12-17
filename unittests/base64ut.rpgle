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
/include '../base64/base64_h.rpgle'
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
dcl-pr test_encodingASCII end-pr;
dcl-pr test_decodingASCII end-pr;
dcl-pr test_il_decode end-pr;


//
// Procedures
//
dcl-proc test_encodingASCII export;
  dcl-s string char(50) ccsid(819);
  dcl-s encodedPtr pointer;
  dcl-s encoded char(50);
  dcl-s size int(10);
  
  string = 'my_username:my_passwo';
  encodedPtr = base64_encode(%addr(string) : %len(%trimr(string)) : %addr(size));
  iEqual(29 : size);
  
  encoded = %str(encodedPtr : size -1);
  aEqual('bXlfdXNlcm5hbWU6bXlfcGFzc3dv' : encoded);
  
  dealloc encodedPtr;
end-proc;

dcl-proc test_decodingASCII export;
  dcl-s string char(50) ccsid(819);
  dcl-s decodedPtr pointer;
  dcl-s decoded char(50) based(decodedPtr) ccsid(819);
  dcl-s size int(10);
  
  string = 'bXlfdXNlcm5hbWU6bXlfcGFzc3dv';
  decodedPtr = base64_decode(%addr(string) : %len(%trimr(string)) : %addr(size));
  iEqual(21 : size);
  aEqual('my_username:my_passwo' : %subst(decoded : 1 : size));
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
