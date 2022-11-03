#ifndef SYSDEF_H
#define  SYSDEF_H

#include <regex.h>
#include "ostypes.h"
#include "xlate.h"
#include "simpleList.h"
#include "fcgi_stdio.h"


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

#pragma enum     (2)
typedef enum _PROTOCOL  {
    PROT_HTTP       = 0,
    PROT_HTTPS      = 1,
    PROT_FASTCGI    = 2,
    PROT_SECFASTCGI = 3,
    PROT_DEFAULT    = 0x4040 // When set to blank
} PROTOCOL , *PPROTOCOL ;
#pragma enum     (pop)

typedef _Packed struct  {
    FCGX_Stream * out;
    FCGX_Stream * in;
    FCGX_Stream * err;
    PUCHAR * envp ;
} FCGI , * PFCGI;

// function pointer to scheduler
typedef  LGL (* SCHEDULER) (PVOID pConfig);

typedef _Packed struct _CONFIG  {
    VARCHAR64   interface;
    int         port;
    PROTOCOL    protocol;
    VARCHAR256  certificateFile;
    VARCHAR64   certificatePassword;
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
    FCGI        fcgi;
    SCHEDULER   scheduler;
    ULONG       schedulerTimer;
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
    PSLIST      resourceSegments;
    PVOID       threadMem;
    PVOID       pRouting; // Not able to make cyclic defentions :(   
    PUCHAR      parmValue [256];
    VARCHAR256  routeId; 
} REQUEST , *PREQUEST;

typedef _Packed struct _RESPONSE  {
    PCONFIG     pConfig;
    SHORT       status;
    VARCHAR256  statusText;
    VARCHAR256  contentType ;
    VARCHAR32   charset;
    // private
    PSLIST      headerList;
    UCHAR   filler      [496];
    BOOL    firstWrite;
} RESPONSE , *PRESPONSE;

// function pointer to servlet
typedef  LGL (* SERVLET)   (PREQUEST pRequest, PRESPONSE pResponse);


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
    IL_HEAD     = 32,
    IL_PATCH    = 64,
    IL_ANY      = 0xffff
} ROUTETYPE , *PROUTETYPE ;
#pragma enum     (pop)


typedef struct _ROUTING  {
    ROUTETYPE  routeType;
    regex_t *  routeReg;
    regex_t *  contentReg;
    SERVLET servlet;
    int    parmNumbers;
    PUCHAR parmNames [256];
    VARCHAR256 routeId;
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
PROUTING findRoute(PCONFIG pConfig, PREQUEST pRequest);
BOOL httpMethodMatchesEndPoint(PLVARPUCHAR requestMethod, ROUTETYPE endPointRouteType);
void handleServletException(_INTRPT_Hndlr_Parms_T * __ptr128 parms);
BOOL fcgiReceiveHeader (PREQUEST pRequest);
LONG fcgiWriter(PRESPONSE pResponse, PUCHAR buf , LONG len);
PSLIST parseParms(LVARPUCHAR parmString);
PSLIST parseResource(LVARPUCHAR resource); 

#endif
