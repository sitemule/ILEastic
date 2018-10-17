#ifndef SYSDEF_H
#define  SYSDEF_H

#include <regex.h>
#include "ostypes.h"
#include "xlate.h"
#include "simplelist.h"


#define  SOCMAXREAD 650000

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
    VARCHAR64   interface;
    int         port;
    UCHAR       filler[1024];
    // Private:
    int         mainSocket;
    int         clientSocket;
    UCHAR       rmtHost [32];
    ULONG       rmtTcpIp;
    int         rmtPort;
    PXLATEDESC  e2a;
    PXLATEDESC  a2e;
    PSLIST      router;
    PSLIST      pluginPreRequest;
    PSLIST      pluginPostResponse;

} CONFIG,  *PCONFIG;

typedef _Packed struct _HEADERLIST  {
    LVARPUCHAR  key;     
    LVARPUCHAR  value;
} HEADERLIST , *PHEADERLIST;

typedef _Packed struct _REQUEST  {
    PCONFIG     pConfig;
    LVARPUCHAR  method;     
    LVARPUCHAR  url;
    LVARPUCHAR  resource;
    LVARPUCHAR  queryString;
    LVARPUCHAR  protocol;
    LVARPUCHAR  headers;
    LVARPUCHAR  content;
    VARCHAR256  contentType;
    ULONG       contentLength;
    LVARPUCHAR  completeHeader;
    PSLIST      headerList;
    PSLIST      parmList;
    PVOID       threadMem;
} REQUEST , *PREQUEST;

typedef _Packed struct _RESPONSE  {
    PCONFIG     pConfig;
    SHORT       status;
    VARCHAR256  statusText;
    VARCHAR256  contentType ;
    VARCHAR32   charset;
    // private
    UCHAR   filler      [512];
    BOOL    firstWrite;  
} RESPONSE , *PRESPONSE;

// function pointers
typedef  LGL (* SERVLET) (PREQUEST pRequest, PRESPONSE pResponse);

typedef _Packed struct _INSTANCE  {
   CONFIG  config;
   SERVLET servlet;
} INSTANCE,  *PINSTANCE;

#pragma enum     (2)
typedef enum _ROUTETYPE  {
    IL_GET      = 1,
    IL_POST     = 2,
    IL_DELETE   = 4,
    IL_PUT      = 8,
    IL_OPTIONS  = 16,
    IL_ANY      = 0xffff
} ROUTETYPE , *PROUTETYPE ;
#pragma enum     (pop)


typedef struct _ROUTING  {
    ROUTETYPE  routeType; 
    regex_t *  routeReg;
    regex_t *  contentReg;
    SERVLET servlet; 
} ROUTING, * PROUTING;

#pragma enum     (2)
typedef enum _PLUGINTYPE  {
    IL_PREREQUEST   = 1, 
    IL_POSTRESPONSE = 2
} PLUGINTYPE , *PPLUGINTYPE ;
#pragma enum     (pop)

typedef struct _PLUGIN  {
    PLUGINTYPE  pluginType; 
    SERVLET     servlet; 
} PLUGIN, * PPLUGIN;


/* ------------------------------------------------------------- */
/* Prototypes -------------------------------------------------- */
/* ------------------------------------------------------------- */
void putChunk (PRESPONSE pResponse, PUCHAR buf, LONG len);   
void putHeader (PRESPONSE pResponse);
void putChunkXlate (PRESPONSE pResponse, PUCHAR buf, LONG len);         
int socketWait (int sd , int sec);
PUCHAR getHeaderValue(PUCHAR  value, PSLIST headerList ,  PUCHAR key);
SERVLET findRoute(PCONFIG pConfig, LVARPUCHAR resource);

#endif
