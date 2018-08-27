#ifndef SYSDEF_H
#define  SYSDEF_H

#include "ostypes.h"

typedef void(OS_CALL) ();
#pragma linkage (OS_CALL, OS)


#pragma enum     (1)
typedef enum _IPC_TYPE  {
    IPC_INPUT         = 'I',
    IPC_OUTPUT        = 'O'
} IPC_TYPE , *PIPC_TYPE ;
#pragma enum     (pop)



typedef _Packed struct _APIRTN  {
    LONG    ApiSize;
    LONG    ApiAvail;
    UCHAR   ApiMsgId[8];
    UCHAR   ApiMsgData[512];
} APIRTN   , *PAPIRTN;



typedef _Packed struct _CONFIG  {
    UCHAR interface [64];
    int   port;
    UCHAR filler[1024];
    int   mainSocket;
    int   clientSocket;
    UCHAR rmtHost [32];
    ULONG rmtTcpIp;
    int   rmtPort;
    
} CONFIG,  *PCONFIG;


typedef _Packed struct _REQUEST  {
    PCONFIG pConfig;
    UCHAR   contentType  [128];
} REQUEST , *PREQUEST;

typedef _Packed struct _RESPONSE  {
    PCONFIG pConfig;
    SHORT   status;
    UCHAR   statusText  [128];
    UCHAR   contentType [128];
    UCHAR   charset     [32];
    // private
    UCHAR   filler      [512];
    BOOL    firstWrite;  
} RESPONSE , *PRESPONSE;

/* function pointers */
typedef  void (* SERVLET) (PREQUEST pRequest, PRESPONSE pResponse);

typedef _Packed struct _INSTANCE  {
   CONFIG  config;
   SERVLET servlet;
} INSTANCE,  *PINSTANCE;



/* ------------------------------------------------------------- */
/* Prototypes -------------------------------------------------- */
/* ------------------------------------------------------------- */
void putChunk (PRESPONSE pResponse, PUCHAR buf, int len);   
void putHeader (PRESPONSE pResponse);
      

#endif
