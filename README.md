# ILEastic
It is a self contained web application server for the ILE environment on IBM i running microservices. 

ILEastic is a service program that provides a simple, blazing fast programmable HTTP server for your application so you easy can plug your RPG code into a services infrastructure or make simple web applications without the need of any third party webserver products.

Basically it is a HTTP application server you can bind into your own ILE RPG projects, 
to give you a easy deploy mechanism, that fits into DevOps and microservices alike environments.

The self contained web application server makes it so much easier to develop web application. 

Simply compile and submit. Yes - You don't need GCI, Apache, nginx or IceBreak - simply compile and submit.

The design paradigm is the same as found in Node.JS - so project was initially called node.RPG but the name was subject to some discussion, so ILEastic it is.
Where Node.JS uses JavaScript, ILEastic aims for any ILE language where RPG are the most popular.

Except for initialization, It only requires two lines of code:
```
 il_listen ( config : pServletCallback); 
 il_responseWrite ( pResponse);
```

The `il_listen` are listening on the TCP/IP port and interface you define in the 
config structure. For each http request it will call your "servlet" which is a 
callback procedure that takes a request and a response parameter
   
![](image.png)


The idea is that you deploy your (open source of cause) RPG packages at NPM so the RPG community can benefit from each others work. The NPM ecosystem is the same for Node.JS and ILEastic.    


Example: 
```
        // -----------------------------------------------------------------------------
        // This example runs a simple servlet using ILEastic
        // Note: It requires your RPG code to be reentrant and compiled
        // for multithreading. Each client request is handled by a seperate thread.
        // Start it:
        // SBMJOB CMD(CALL PGM(DEMO01)) JOB(ILEASTIC) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)        
        // -----------------------------------------------------------------------------     
        ctl-opt copyright('Sitemule.com  (C), 2018');
        ctl-opt decEdit('0,') datEdit(*YMD.) main(main);
        ctl-opt debug(*yes) bndDir('ILEASTIC');
        ctl-opt thread(*CONCURRENT);
        /include include/ileastic.rpgle
        // -----------------------------------------------------------------------------
        // Main
        // -----------------------------------------------------------------------------     
        dcl-proc main;

            dcl-ds config likeds(configDS);

            config.port = 44001;
            config.host = '*ANY';

            il_listen (config : %paddr(myservlet));

        end-proc;
        // -----------------------------------------------------------------------------
        // Servlet call back implementation
        // -----------------------------------------------------------------------------     
        dcl-proc myservlet;

            dcl-pi *n;
                request  likeds(REQUESTDS);
                response likeds(RESPONSEDS);
            end-pi;
  
            il_responseWrite(response:'Hello world');

        end-proc;
```

 
# Installation
What you need before you start:

* IBMI 7.3 TR3 ( obove or alike)
* git and gmake ( 5733OPS or YUM)
* ILE C 
* ILE RPG compiler.


From a IBMi menu prompt start the SSH deamon:`===> STRTCPSVR *SSHD`
Or start ssh from win/mac

```
mkdir /prj
cd /prj 
git -c http.sslVerify=false clone https://github.com/NielsLiisberg/ILEastic.git
cd ILEastic
gmake 
cd test 
gmake
```

# Test it:
Log on to your IBMi.
from a IBMi menu prompt 
````
CALL QCMD
ADDLIBLE ILEASTIC
SBMJOB CMD(CALL PGM(DEMO01)) ALWMLTTHD(*YES) JOB(ILEASTIC1) JOBQ(QSYSNOMAX) 
SBMJOB CMD(CALL PGM(DEMO02)) ALWMLTTHD(*YES) JOB(ILEASTIC2) JOBQ(QSYSNOMAX) 
````
Now test it in a browser:

* http://myibmi:44998
* http://myibmi:44999

A simple hello and list with a counter. Please note that the job requires `ALWMLTTHD(*YES)`


# Develop:
You compile the project with gmake, and I have also included a 
setup folder for vsCode so you can compile any changes 
with `Ctrl-shift-B` You need however to 
change .vsCode/task.json file to point 
to your IBMi address. The compile feature requires that you have SSH stated: `STRTCPSVR *SSHD` 

# Moving on
In this first commit we have only implemented the `il_listen` and `il_responseWrite`, so there is not much use for real world application, however - all the plumbing around with git / compile / deploy are working. We at Sitemule.com are striving to move the core of the IceBreak server into the ILEastic project over the next couple of months. So stay tuned.


# Note
This project was initially call Node.RPG, however people could not find the node.js code :) so obvously it was a bad name. Thanks for the feedback pointing me into a better direction.

Happy ILEastic coding

