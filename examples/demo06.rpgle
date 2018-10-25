**FREE
// -----------------------------------------------------------------------------
// Yet more advanced, using the router and plugin 
// Note: It requires your RPG code to be reentrant and compiled
// for multithreading. Each client request is handled by a seperate thread.
// Start it:
// SBMJOB CMD(CALL PGM(DEMO05)) JOB(ILEASTIC5) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)        
// -----------------------------------------------------------------------------     
ctl-opt copyright('Sitemule.com  (C), 2018');
ctl-opt decEdit('0,') datEdit(*YMD.) main(main);
ctl-opt debug(*yes) DFTACTGRP(*NO) ACTGRP('QILE');

// -----------------------------------------------------------------------------
// Main, using router
// -----------------------------------------------------------------------------     
dcl-proc main;

    dcl-s t varchar(32);

    t = pack(1  : 1 :0);
    t = pack(-1 : 1 :0);
    t = pack(1.2 : 2 :1);
    t = pack(-1.2: 2 :1);
   
    t = pack(123.45 : 5 :2);
    t = pack(12.345 : 5 :3);
    t = pack(1234.56: 6 :2);
    t = pack(123.456: 6 :3);
    
    t = pack(-123.45 : 5 :2);
    t = pack(-12.345 : 5 :3);
    t = pack(-1234.56: 6 :2);
    t = pack(-123.456: 6 :3);
    

end-proc;
// -----------------------------------------------------------------------------
// It is a servlet called for each request
// -----------------------------------------------------------------------------     
dcl-proc pack;

    dcl-pi *N varchar(32);
        value       packed(15:5) value;
        digits      int(10) value;
        decPos      int(10) value;
    end-pi;

    dcl-ds packds;
        bufDecUneven    packed(32:9 ) pos(1);
        bufDecEven      packed(32:10) pos(1);
        bufChar         char(32)     pos(1);
    end-ds;

    dcl-s returnValue       varchar(32);
    dcl-s sign              char(1) based(pSign);
    dcl-s pSign             pointer;
    dcl-s bytes             int(10);
    dcl-s bytesAfterDec     int(10);
    dcl-s pos               int(10);
    
    if %rem(decPos:2) =0;
        bufDecEven = value;   
    else; 
        bufDecUneven = value;   
    endif;

    bytes = digits / 2 + 1;
    bytesAfterDec = ( decpos + 1 ) / 2  ;
    pos = (32 - 9) / 2 + 1  - (bytes - 1)  + bytesAfterDec;
    returnValue = %subst(BufChar:pos:bytes);
    pSign = %addr(returnValue:*data) + %len(returnValue) -1;
    sign = %bitor (sign : x'0f');
    
    if value < 0;
        sign = %bitand (sign : x'FD');
    endif;

    return returnValue;

end-proc;
