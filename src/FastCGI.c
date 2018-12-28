/* ------------------------------------------------------------- */
/* Program . . . : ILEastic - main interface                     */
/* Date  . . . . : 02.06.2018                                    */
/* Design  . . . : Niels Liisberg                                */
/* Function  . . : Fast-CGI interface                            */
/*                                                               */
/* By     Date       PTF     Description                         */
/* NL     02.06.2018         New program                         */
/* ------------------------------------------------------------- */
#define _MULTI_THREADED
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <decimal.h>
#include <fcntl.h>

/* in qsysinc library */
#include <sys/time.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <ssl.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <errno.h>
#include <unistd.h>
#include <spawn.h>
#include <regex.h>

#include "ostypes.h"
#include "varchar.h"
#include "sysdef.h"
#include "strUtil.h"
#include "streamer.h"
#include "simplelist.h"
#include "sndpgmmsg.h"
#include "parms.h"
#include "e2aa2e.h"
#include "fcgi_stdio.h"

typedef _Packed struct  {
  PHTTP  pHttp;
  FCGX_Stream * out;
  FCGX_Stream * in;
  PUCHAR * envp ;
  BOOL   firstWrite;
} FCGI , * PFCGI;

int getSocket(int port)
{
    int sd, sd2, rc, length = sizeof(int), errcde;
    int addrlen = 0, totalcnt = 0, on = 1;
    struct sockaddr_in serveraddr, client;
    char msg [512];

    if ((sd = socket(AF_INET, SOCK_STREAM, 0)) < 0)  {
        joblog( "socket error: %d - %s" , (int) errcde, strerror((int) errcde));
        exit(-1);
    }

    // Allow socket descriptor to be reuseable */
    rc = setsockopt(sd, SOL_SOCKET,
        SO_REUSEADDR,
        (char *)&on,
        sizeof(on));

    if (rc < 0) {
        joblog( "socket error: %d - %s" ,(int) errcde, strerror((int) errcde));
        close(sd);
        exit(-2);
    }
    //  bind to an address
    memset(&serveraddr, 0x00, sizeof(struct sockaddr_in));
    serveraddr.sin_family        = AF_INET;
    serveraddr.sin_port          = htons(port);
    serveraddr.sin_addr.s_addr   = htonl(INADDR_ANY);
    rc = bind(sd,  (struct sockaddr *)&serveraddr, sizeof(serveraddr));
    if (rc < 0) {
        joblog( "bind error: %d - %s" ,(int) errcde, strerror((int) errcde));
        close(sd);
        exit(-3);
    }


    rc = listen(sd, 10);
    if (rc < 0)  {
        close(sd);
        joblog( "Listen error: %d - %s" ,(int) errcde, strerror((int) errcde));
        exit(-4);
    }

    return sd;
}

static void fcgi_puts(PFCGI pFcgi , PUCHAR s)
{
   FCGX_PutStr(s , strlen(s) , pFcgi->out);
}
static void printEnv(PFCGI pFcgi)
{

    char **envp = pFcgi->envp;

    #pragma convert(1252)
    fcgi_puts (pFcgi, "<pre>");
    for ( ; *envp != NULL; envp++) {
        fcgi_puts (pFcgi , *envp);
        fcgi_puts (pFcgi , "\n");
    }
    fcgi_puts (pFcgi, "</pre>");
    #pragma convert(0)

}
/* ------------------------------------------------------------- */
void init(PHTTP pHttp, int serverId)
{
   static UCHAR  IcePath[128];

   memset(pHttp   , 0 , sizeof(HTTP));
   pHttp->apirtn.ApiSize = sizeof(APIRTN);

   sSetPhttp (pHttp);
   tOpenFiles(pHttp);
   tGetSvr(pHttp, serverId );

   // Ensure SQL is invoked in the right order
   pSqlConnect (pHttp);


   SVC213 (pHttp->DatFmt  ,
           &pHttp->DatSep ,
           &pHttp->TimSep ,
           &pHttp->DecFmt ,
           pHttp->Version ,
           pHttp->IceDbLib,
           pHttp->IcePgmLib,
           &pHttp->svr00r.SVJRPTY,
           pHttp->svr00r.SVJNAM ,
           pHttp->svr00r.SVJUSR ,
           pHttp->svr00r.SVJNUM ,
           IcePath);
   // Not now ..
   // redirectStdout(pHttp->svr00r.SVJNUM);

   pHttp->IcePath = righttrimlen(IcePath, sizeof(IcePath));
   memcpy(pHttp->threadJob , pHttp->svr00r.SVJNAM , sizeof(pHttp->threadJob));

   chdir( pHttp->HomeDir);

   SetTrace(pHttp->svr00r.SVTRAC, vc2str(&pHttp->svr00r.SVTPTH));
   tInitHttpInstance(pHttp);
   tBuildBuffers  (pHttp);
   tLoadWebConfig (pHttp,  vc2str(&pHttp->svr00r.SVPATH), FALSE); // Need a pointer before call to sprintf
   tLoadDirMap    (pHttp, pHttp->svr00r.SVSVTK);
}
/* ------------------------------------------------------------- */
void call (PHTTP pHttp, PUCHAR lib , PUCHAR pgm )
{
   LGL   dummy ;
   LGL   viaHive  = OFF;
   LGL   viaWeb   = ON;
   UCHAR  pgmName [11];

   BuildPgmName (pgmName  , pgm);

   SVC202 (&dummy  , pgmName ,
      pHttp->msg, pHttp->svr00r.SVNAME, pHttp->svr00r.SVDPGM , lib  , &viaHive, &viaWeb
   );
}
/* ------------------------------------------------------------- */
LONG  chunkFcgiWriter  (PSTREAM pStream , PUCHAR buf , ULONG len)
{

    PUCHAR head;
    int  headLen;
    PFCGI pFcgi  = pStream->handle;

    if (pFcgi->firstWrite) {
       PHTTP pHttp = pFcgi->pHttp;
       pFcgi->firstWrite = false;
       head = malloc(32766 + pHttp->ConsoleLog.memUsed);
       headLen = tBuildHttpHead (pHttp, head , true);
       FCGX_PutStr(head  , headLen , pFcgi->out);
       free (head);

    /*    #pragma convert(1252)
        FCGX_PutStr("Content-type: text/html\r\n\r\n" , 27 , pFcgi->out);
        #pragma convert(0)
    */
    }

    FCGX_PutStr(buf , len , pFcgi->out);

    return 0;
}
/* ------------------------------------------------------------- */
static PUCHAR asciicat (PHTTP pHttp, PUCHAR pBuf , PUCHAR s)
{
   long len = strlen(s);
   tA2E (pHttp, pBuf  , s  , len + 1 ); // Include the zero term
   return pBuf + len;
}
/* ------------------------------------------------------------- */
void setparm_urldecode (PJXNODE pReq , PUCHAR key , PUCHAR value)
{

    VARCHAR vcKey;
    VARCHAR vcValue;

    ParseFormData (&vcKey  , key   , strlen(key));
    ParseFormData (&vcValue, value , strlen(value));

    jx_SetValueByName (pReq , vcKey.String  ,  vcValue.String , VALUE);
}
/* ------------------------------------------------------------- */
void tParseRequestStr (PJXNODE pReq , PUCHAR str)
{

   PUCHAR key = str;
   PUCHAR value , end;

   for (;;) {
      value = strchr ( key , '=');
      if (!value) return; // DONE!!

      *value = '\0';
      value++;

      end  = strchr ( value , '&');
      if (!end) { // Last element. and the value is terminated
         setparm_urldecode (pReq , key , value);
         return;
      }

      *end = '\0';
      setparm_urldecode (pReq , key , value);

      key = end +1;

   }
}
/* ------------------------------------------------------------- *\
   unpack from the env array
          FCGI_ROLE=RESPONDER
          DOCUMENT_URI=/hello.aspx
          QUERY_STRING=s
          CONTENT_LENGTH=
          CONTENT_TYPE=
          REQUEST_METHOD=GET
          SERVER_PROTOCOL=HTTP/1.1
          GATEWAY_INTERFACE=CGI/1.1
          SERVER_SOFTWARE=Jetty/9.3.0.v20150612
          HTTP_COOKIE=sys_sesid=s1047AF027A03364D80981FB7309CD47C03971F38B
          HTTP_CACHE_CONTROL=max-age=0
          HTTP_ACCEPT=text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,* / *;q=0.8
          HTTP_UPGRADE_INSECURE_REQUESTS=1
          HTTP_USER_AGENT=Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko)
          HTTP_ACCEPT_ENCODING=gzip, deflate, sdch
          HTTP_ACCEPT_LANGUAGE=da,en-US;q=0.8,en;q=0.6
          HTTP_VIA=http/1.1 nielss-mbp.sysmet.local
          HTTP_X_FORWARDED_FOR=192.168.5.81
          HTTP_X_FORWARDED_PROTO=http
          HTTP_X_FORWARDED_HOST=192.168.5.48:8082
          HTTP_X_FORWARDED_SERVER=192.168.5.48
          HTTP_HOST=192.168.5.48:8082
          DOCUMENT_ROOT=/
          REMOTE_ADDR=192.168.5.81
          REMOTE_PORT=1305
          SERVER_NAME=192.168.5.48
          SERVER_ADDR=192.168.5.48
          SERVER_PORT=8082
          REQUEST_URI=/hello.aspx?s
          SCRIPT_NAME=/hello.aspx
          SCRIPT_FILENAME=//hello.aspx
\* ------------------------------------------------------------- */
void fcgi_unpackParms (PFCGI pFcgi)
{
   PUCHAR * envp = pFcgi->envp;
   PHTTP  pHttp = pFcgi->pHttp;
   PUCHAR method = "GET";
   PUCHAR uri = "";
   PUCHAR qrystr = "";

   PUCHAR pBuf = pHttp->InBufXlate;
   LONG   len;
   LONG   contentlen = 0;

   strcpy( pHttp->OutContentType , "text/html");
   strcpy( pHttp->Charset        , "windows-1252");

   //pHttp->pReqHeaders = jx_newObject();

   #pragma convert(1252)
   for ( ; *envp != NULL; envp++) {
       PUCHAR parm  = *envp;
       if (BeginsWith(parm, "REQUEST_URI")) {
          uri = parm + sizeof("REQUEST_URI");
       }
       else if (BeginsWith(parm, "REQUEST_METHOD")) {
          method = parm + sizeof("REQUEST_METHOD");
       }
       else if (BeginsWith(parm, "QUERY_STRING")) {
          qrystr = parm + sizeof("QUERY_STRING");
       }
       else if (BeginsWith(parm, "CONTENT_LENGTH")) {
          UCHAR temp [32];
          PUCHAR p = parm + sizeof("CONTENT_LENGTH");
          tA2E (pHttp, temp , p  , strlen(p));
          contentlen = atoi(temp);
       }
   }

   pBuf = asciicat (pHttp, pBuf , method);
   pBuf = asciicat (pHttp, pBuf , " ");
   pBuf = asciicat (pHttp, pBuf , uri);

   // TODO !! Simulate empty headerand no payload !!
   pBuf = asciicat (pHttp, pBuf , " .\r\n\r\n");


   #pragma convert(0)

   pHttp->InBufLen =  pBuf - pHttp->InBufXlate;
   tParseUrl(pHttp);

   // Setup env for FCGI
   pHttp->ResponseEncode = RSPENC_CHUNKED;

   jx_NodeDelete(pHttp->pReqParms); // Cleanup previous ( if any: null is allowed )
   pHttp->pReqParms   = jx_NewObject(NULL);
   tA2E (pHttp, qrystr , qrystr  , strlen(qrystr));
   tParseRequestStr (pHttp->pReqParms , qrystr);

   jx_NodeDelete(pHttp->pXmlCom); // Cleanup previous ( if any: null is allowed )
   if (contentlen > 0) {
      int len;
      PUCHAR temp = malloc(contentlen);
      pHttp->pXmlCom   = jx_NewObject(NULL);
      len = FCGX_GetStr(temp , contentlen, pFcgi->in);
      tA2E (pHttp, temp , temp  , contentlen);
      tParseRequestStr (pHttp->pXmlCom , temp);
      free (temp);
   }

}
/* ------------------------------------------------------------- */
/* Main line:                                                    */
/* Interface to the SVC200 service program with all              */
/* the server functionality                                      */
/* ------------------------------------------------------------- */
// #define DEBUG 1
void main (int argc , char * argv[])
{
   HTTP   http;
   PHTTP  pHttp = &http;
   FCGX_Stream *in, *out, *error;
   FCGX_ParamArray envp;
   UCHAR buf [4095 * 2];
   LONG   serverId = atoi(argv[1]);
   int    sd;
   FCGI fcgi;
   PFCGI pFcgi = &fcgi;
   pFcgi->pHttp = pHttp;

   sd = getSocket(atoi(argv[2]));

   init (pHttp , serverId);

   CurrentTimeStamp((PTS) pHttp->Session );
   pHttp->OutBuf = buf;
   pHttp->useFastCGI = true;
   pHttp->pOutChunk = stream_new (128); // pHttp->ChunkSize);
   pHttp->pOutChunk->writer  = chunkFcgiWriter;
   pHttp->pOutChunk->handle  = pFcgi;

   while (FCGX_Accept(&in, &out, &error, &envp) >= 0) {

        pFcgi->out   = out;
        pFcgi->in    = in;
        pFcgi->envp  = envp;
        pFcgi->firstWrite = true;


        fcgi_unpackParms (pFcgi);


        // SwapUserProfile(pHttp); // Change to profile if logged on

        call (pHttp, pHttp->AppLib , pHttp->Resource );

        printEnv(pFcgi);

        stream_flush(pHttp->pOutChunk);

    }

    close(sd);
}

 