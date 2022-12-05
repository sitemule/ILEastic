**FREE
/// ------------------------------------------------------------------------------------
// TESTPARMS - REST API Driver
//
// Start it:
// SBMJOB CMD(CALL PGM(TESTPARMS3)) JOB(TESTPARMS3) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES) ccsid(37)
//
// @info: It requires your RPG code to be reentrant and compiled for
// multithreading. Each client request is handled by a seperate thread.
// http://my_ibm_i:1302/100
/// ------------------------------------------------------------------------------------

ctl-opt decEdit('0,') datEdit(*YMD.) main(main);
ctl-opt debug(*yes) bndDir('ILEASTIC');
ctl-opt thread(*CONCURRENT);

/include QSYSINC/QRPGLESRC,UNISTD

dcl-f perflog
      extdesc('PERFLOG')
      extfile(*extdesc)
      usage(*output )
      rename(PERFLOGR:perflogout);

/include ./headers/ILEastic.rpgle
/include ./noxdb/headers/jsonParser.rpgle
// --------------------------------------------------------------------------------------
// Program Entry Point
// --------------------------------------------------------------------------------------
dcl-proc main;

    // ILEastic Configuration Data Structure
    dcl-ds config likeds(il_config);

    // Set port and host values
    config.port = 13002;
    config.host = '*ANY';

    il_listen (config : %paddr(myservlet));
    close perflog;

end-proc;
// --------------------------------------------------------------------------------------
dcl-proc myservlet;

    // Procedure Interface
    dcl-pi *n;
        request     likeds(IL_REQUEST);
        response    likeds(IL_RESPONSE);
    end-pi;

    // Local variable declarations
    dcl-s tempI        Packed(8:2);
    dcl-s tempO        Packed(8:2);
    dcl-s tempS        varchar(32);
    
    // Assume everything is OK
    response.status = 200;
    response.contentType = 'application/json';

    // Simulate workload 0.5 sec
    usleep (500000);

    // Write the log
    plTime = %timestamp();
    write perflogOut;
    
    // Calc a temperature
    tempS = il_getRequestSegmentByIndex(request : 1);
    tempI = %DEC(tempS: 7:2);
    tempO = (5/9)*(tempI / 32);

    il_responseWrite(response : '{"tempout":' + %char(tempO) +'}');

end-proc;
