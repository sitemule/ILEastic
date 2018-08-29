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
    VARCHAR64 interface;
    int       port;
    UCHAR     filler[1024];
    int       mainSocket;
    int       clientSocket;
    UCHAR     rmtHost [32];
    ULONG     rmtTcpIp;
    int       rmtPort;
    
} CONFIG,  *PCONFIG;


typedef _Packed struct _REQUEST  {
    PCONFIG     pConfig;
    PUCHAR      pUrl;
    PUCHAR      pQueryString;
    PUCHAR      pHeaders;
    PUCHAR      pContent;
    VARCHAR128  contentType;
    VARCHAR32   method;     
} REQUEST , *PREQUEST;

typedef _Packed struct _RESPONSE  {
    PCONFIG     pConfig;
    SHORT       status;
    VARCHAR128  statusText;
    VARCHAR128  contentType ;
    VARCHAR32   charset;
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
void putChunk (PRESPONSE pResponse, PUCHAR buf, LONG len);   
void putHeader (PRESPONSE pResponse);
      

#endif
