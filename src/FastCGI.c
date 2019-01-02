/* ------------------------------------------------------------- */
/* Program . . . : ILEastic - Fast CGI interface                 */
/* Date  . . . . : 31.12.2018                                    */
/* Design  . . . : Niels Liisberg                                */
/* Function  . . : Fast-CGI interface                            */
/*                                                               */
/* By     Date       PTF     Description                         */
/* NL     30.12.2018         New program                         */
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
#pragma convert(1252)
BOOL fcgiReceiveHeader (PREQUEST pRequest)
{

   FCGX_Stream *in, *out, *error;
   FCGX_ParamArray envp;
   BOOL ok = FCGX_Accept(&in, &out, &error, &envp) >= 0;
   if (!ok) return (true); // Error

   pRequest->pConfig->fcgi.in  = in;
   pRequest->pConfig->fcgi.out = out;
   pRequest->pConfig->fcgi.err = error;
   pRequest->pConfig->fcgi.envp = envp; 
   
   pRequest->headerList = sList_new ();

   for ( ; *envp != NULL; envp++) {
      PUCHAR parm  = *envp;
      UCHAR  key [64];
      PUCHAR val;
      val = strchr(parm , '=');
      substr(key ,parm , val - parm);
      val ++; // Skip after =

      if (strcmp (key , "SERVER_PROTOCOL") ==0) {
         lvpcSetFromStr (&pRequest->protocol , val);
      } 
      else if (strcmp(key,"REQUEST_URI")==0) {
         lvpcSetFromStr (&pRequest->url, val);
      }
      else if (strcmp(key,"DOCUMENT_URI")==0) {
         lvpcSetFromStr (&pRequest->resource, val);
      }
      else if (strcmp(key,"REQUEST_METHOD")==0) {
         lvpcSetFromStr (&pRequest->method, val);
      }
      else if (strcmp(key,"QUERY_STRING")==0) {
         lvpcSetFromStr (&pRequest->queryString, val);
      }
      else if (strcmp(key,"CONTENT_LENGTH")==0) {
         pRequest->contentLength = a2i(val);
      } 
      else if (memcmp(key, "HTTP_" , 5)==0) { // Akk http headers are prfixed with HTTP_ ( five chars) 

         LVARPUCHAR lkey;
         LVARPUCHAR lvalue;

         lkey.String = parm+5; // Must be the "real" array not the temp value in "key" 
         lkey.Length = strlen(key+5);

         lvpcSetFromStr (&lvalue , val);

         // The key / value pair are ready
         sList_pushLVPC (pRequest->headerList , &lkey , &lvalue);
      }
   }
   pRequest->parmList = parseParms  (pRequest->queryString);

   // Payload:
   if (pRequest->contentLength > 0) {
      int rem = pRequest->contentLength;
      int len; 
      PUCHAR buf = malloc (pRequest->contentLength +1); // Add a zero terniation

      // Build up the previous and the rest
      buf [pRequest->contentLength] = '\0';  // Enshure It will always be a zeroterminted string if used that way
      pRequest->content.String = buf;
      pRequest->content.Length = pRequest->contentLength;

      while (rem > 0) {
         len = FCGX_GetStr(buf , rem, in);
         if (len < 0) break;
         buf += len;
         rem -= len;
      }
   }
   return false;
}
#pragma convert(0)