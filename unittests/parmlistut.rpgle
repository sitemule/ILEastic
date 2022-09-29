**FREE

///
// Parameter List Test
//
// The usage of operational description between RPG and C calls is tested.
//
// @author Mihael Schmidt
// @date   29.09.2022
///


ctl-opt nomain;


//
// Includes
//
/include assert

dcl-pr il_parmList int(20) extproc(*dclcase);
  p1 pointer const options(*omit : *nopass);
  p2 pointer const options(*omit : *nopass);
  p3 pointer const options(*omit : *nopass);
  p4 pointer const options(*omit : *nopass);
  p5 pointer const options(*omit : *nopass);
  p6 pointer const options(*nopass);
end-pr;


//
// Prototypes
//
dcl-pr test_noParametersPassed end-pr;
dcl-pr test_twoParametersPassed end-pr;
dcl-pr test_allParametersPassed end-pr;
dcl-pr test_parameterOmitted end-pr;


dcl-proc test_noParametersPassed export;
  dcl-s returnValue int(20);
  dcl-s addr pointer;
  
  addr = %addr(returnValue);
  
  returnValue = il_parmList(addr : addr : addr : addr : addr : addr);
  iEqual(6 : returnValue);
  returnValue = il_parmList();
  iEqual(0 : returnValue);
end-proc;


dcl-proc test_twoParametersPassed export;
  dcl-s returnValue int(20);
  dcl-s addr pointer;
  
  addr = %addr(returnValue);
  
  returnValue = il_parmList(addr : addr : addr : addr : addr : addr);
  iEqual(6 : returnValue);
  returnValue = il_parmList(addr : addr);
  iEqual(2 : returnValue);
end-proc;


dcl-proc test_allParametersPassed export;
  dcl-s returnValue int(20);
  dcl-s addr pointer;
  
  addr = %addr(returnValue);
  
  returnValue = il_parmList(addr : addr : addr : addr : addr : addr);
  iEqual(6 : returnValue);
  returnValue = il_parmList(addr : addr : addr : addr : addr : addr);
  iEqual(6 : returnValue);
end-proc;


dcl-proc test_parameterOmitted export;
  dcl-s returnValue int(20);
  dcl-s addr pointer;
  
  addr = %addr(returnValue);
  
  returnValue = il_parmList(addr : addr : addr : addr : *omit : addr);
  iEqual(6 : returnValue);
  returnValue = il_parmList(*omit : *omit : *omit : addr);
  iEqual(4 : returnValue);
end-proc;
