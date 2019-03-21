# ILEastic
It is a self contained web application server for the ILE environment on IBM i 
to run microservices. 

ILEastic is a service program that provides a simple, blazing fast programmable 
HTTP server for your application. You can easily plug your RPG code into a services 
infrastructure and make simple web applications without the need of any third party 
webserver products.

Basically it is a HTTP application server you can bind into your own ILE RPG 
projects, to give you a easy deploy mechanism, that fits into DevOps and 
microservices alike environments.

The self contained web application server makes it so much easier to develop 
web applications. 

Simply compile and submit. No - You don't need GCI, Apache, nginx or IceBreak - 
simply compile and submit.

The design paradigm is the same as found in Node.JS - the project was initially 
called node.RPG but the name was subject to some discussion, so ILEastic it is.
Where Node.JS uses JavaScript, ILEastic aims for any ILE language where RPG are 
the most popular.

Except for initialization, It only requires two lines of code:
```
 il_listen ( config : pServletCallback); 
 il_responseWrite ( pResponse);
```

The `il_listen` is listening on the TCP/IP port and interface you define in the 
config structure. For each http request it will call your "servlet" which is a 
callback procedure that takes a request and a response parameter
   
![](image.png)


The idea is that you deploy your (open source of course) RPG packages at NPM so 
the RPG community can benefit from each others work. The NPM ecosystem is the 
same for Node.JS and ILEastic.    


Example: 
```
**FREE

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

    dcl-ds config likeds(IL_CONFIG);

    config.port = 44001;
    config.host = '*ANY';

    il_listen (config : %paddr(myservlet));

end-proc;
// -----------------------------------------------------------------------------
// Servlet call back implementation
// -----------------------------------------------------------------------------     
dcl-proc myservlet;

    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;
  
    il_responseWrite(response:'Hello world');

end-proc;
```

 
# Installation
What you need before you start:

* IBM i 7.3 TR3 (or higher)
* Use YUM from ACS to install: git, make and make-gnu (gmake)
* ILE C 
* ILE RPG compiler


From a IBM i menu prompt start the SSH deamon:`===> STRTCPSVR *SSHD`
Or start ssh from win/mac/linux

```
mkdir /prj
cd /prj 
git -c http.sslVerify=false clone --recurse-submodules https://github.com/sitemule/ILEastic.git
cd ILEastic
gmake all 
```
Now you have library ILEastic on your IBM i - and you are good to go. You can simply copy the serivce program
to you own projects libraries along with the binding directory and header files.

If you like to try the examples then you need to build them as well- as simple as:

```
cd examples 
make
```

# Test it:
Log on to your IBM i.
from a IBM i menu prompt 
```
CALL QCMD
ADDLIBLE ILEASTIC
SBMJOB CMD(CALL PGM(helloworld)) ALWMLTTHD(*YES) JOB(helloworld) JOBQ(QSYSNOMAX) 
SBMJOB CMD(CALL PGM(staticfile)) ALWMLTTHD(*YES) JOB(staticfile) JOBQ(QSYSNOMAX) 
```
Look for the complete list in the examples folder - and observe which port they are "listening" at.


Now test it in a browser: 

* http://myibmi:44000  Hello world
* http://myibmi:44001  Simple website demo


Please note that the job requires `ALWMLTTHD(*YES)`


# Develop
You compile the project with gmake, and I have also included a setup folder for
vsCode so you can compile any changes with `Ctrl-Shift-B` You need however to 
change .vsCode/task.json file to point to your IBM i address. The compile feature 
requires that you have SSH started: `STRTCPSVR *SSHD` 

# Unit Tests
For executing the unit tests located in the folder _unittests_ you need to 
previously install either [iRPGUnit][iru] or [RPGUnit][ru].

# Moving on
So far we have implemented the basic features like `il_listen` , `il_responseWrite` and
`il_addRoute` - look at the prototypes in `ILEastic.rpgle` header file for the complete 
list of features. There is still much work to do, however - all the plumbing 
around with git / compile / deploy is working. We at Sitemule.com are striving 
to move the core of the IceBreak server into the ILEastic project over the next 
couple of months. So stay tuned.


# Note
This project was initially call Node.RPG, however people could not find the 
node.js code :) so obvously it was a bad name. Thanks for the feedback pointing 
me into a better direction.

Happy ILEastic coding

[iru]: https://irpgunit.sourceforge.io
[ru]: https://rpgunit.sourceforge.io

