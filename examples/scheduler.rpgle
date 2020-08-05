**FREE

///
// Scheduler Plugin Example
//
// This example shows how to add a scheduler plugin to the server which gets each xx seconds 
// in a seperate thread. This can be used to test for system shutdown / do cleanup / statistics
//
//
// Start it:
// SBMJOB CMD(CALL PGM(SCHEDULER)) JOB(SCHEDULER) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)        
//
// The web service can be tested with the browser by entering the following URL:
// http://my_ibm_i:44004 
// will just say hello world until you do an:
//
// ENDJOB JOB(SCHEDULER)  
//
// Note it by deafult handles gracefull termination and calls the scheduler just before termination
//
// @info: It requires your RPG code to be reentrant and compiled for 
//        multithreading. Each client request is handled by a seperate thread.
///

ctl-opt copyright('Sitemule.com  (C), 2018');
ctl-opt decEdit('0,') datEdit(*YMD.) main(main);
ctl-opt debug(*yes) bndDir('ILEASTIC');
ctl-opt thread(*CONCURRENT);

/include ./headers/ileastic.rpgle

// -----------------------------------------------------------------------------
// Program Entry Point
// -----------------------------------------------------------------------------     
dcl-proc main;

    dcl-ds config likeds(il_config);
    
    config.port = 44004; 
    config.host = '*ANY';

    // Set the scheduler - let it be called each 5 seconds:
    il_setSchedulerPlugin (config : %paddr(myScheduler) : 5);

    // All request will be handled by my simple servlet
    il_listen(config : %paddr(myservlet));
 
end-proc;
// -----------------------------------------------------------------------------
// myScheduler - When i return *OFF the ILEasticserver til terminate gracefully
// -----------------------------------------------------------------------------     
dcl-proc myScheduler;

    dcl-pi *n ind;
        config  likeds(IL_CONFIG);
    end-pi;
    dcl-s countDown int(5) static inz(10); // count from 10 and down 

    // Each 5 sec i count down so the server will stop after 50 sec.
    countDown -= 1;

    if countDown > 0;
      il_Joblog('Keep running ' + %char(countDown));
      return *ON;  
    elseif %SHTDN() = *ON;
      il_Joblog('The job was ended normaly by ENDJOB OPTION(*CNTRLD) at ' + %char(countDown));
      return *OFF;  
    else;
      il_Joblog('Done !! ' + %char(countDown));
      return *OFF; // Dont Run
    endif;

end-proc;
// -----------------------------------------------------------------------------
// Servlet callback implementation
// -----------------------------------------------------------------------------     
dcl-proc myservlet;
    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;
    
    il_responseWrite(response : 'Look in the joblog ... ' + %char(%time()));
end-proc;
