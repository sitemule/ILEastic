**FREE

ctl-opt main(main);

/copy qsysinc/qrpglesrc,qusec

dcl-pr QLICOBJD extpgm('QLICOBJD');
  oLib    char(10);                
  iObjLib char(20) const;      
  iType   char(10) const;      
  iData   like(inf_t) const;      
  iErr    likeds(QUSEC);
end-pr;

dcl-ds inf_t qualified;                    
  num int(10) inz(1);              
  key int(10) inz(9);              
  len int(10) inz(10);            
  data char(10);                  
end-ds; 

dcl-proc main;
  dcl-pi *n;
    obj char(10);
    lib char(10);
  end-pi;

  dcl-ds inf likeds(inf_t) inz;
  dcl-ds errDS likeds(QUSEC) inz;
  dcl-s oLib char(10);

  inf.num = 1;
  inf.key = 9; // User-defined attribute
  inf.len = 10;
  inf.data = 'iRPGUnit';

  QLICOBJD(oLib : obj + lib : '*SRVPGM' : inf : errDS);

  return;
end-proc;