/* ------------------------------------------------------------- */
/* Program . . . : ILEastic - main interface                     */
/* Date  . . . . : 02.06.2018                                    */
/* Design  . . . : Niels Liisberg                                */
/* Function  . . : Main Socket server                            */
/*                                                               */
/* By     Date       PTF     Description                         */
/* NL     02.06.2018         New program                         */
/* ------------------------------------------------------------- */
#define _MULTI_THREADED

// max number of concurrent threads
#define FD_SETSIZE 4096

#include <os2.h>
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


#include "ostypes.h"
#include "varchar.h"
#include "sysdef.h"
#include "strUtil.h"

/* --------------------------------------------------------------------------- */
// Getters - curtesy procedures 
/* --------------------------------------------------------------------------- */
void il_getRequestResource (PLVARCHAR out , PREQUEST pRequest)
{
    lvpc2lvc (out, &pRequest->resource);
}         
void il_getRequestMethod
 (PVARCHAR out , PREQUEST pRequest)
{
    lvpc2vc (out, &pRequest->method);
}         
void il_getRequestUrl (PLVARCHAR out , PREQUEST pRequest)
{
    lvpc2lvc (out, &pRequest->url);
}         
void il_getRequestQueryString (PLVARCHAR out , PREQUEST pRequest)
{
    lvpc2lvc (out, &pRequest->queryString);
}         
void il_getRequestProtocol (PVARCHAR out , PREQUEST pRequest)
{
    lvpc2vc (out, &pRequest->protocol);
}         
void il_getRequestHeaders (PLVARCHAR out , PREQUEST pRequest)
{
    lvpc2lvc (out, &pRequest->headers);
}         

/* --------------------------------------------------------------------------- */
void il_responseWrite (PRESPONSE pResponse, PLVARCHAR buf)
{
    putChunk (pResponse, buf->String, buf->Length);         
}

/* --------------------------------------------------------------------------- */
PUCHAR il_getFileExtension  (PVARCHAR256 extension, PVARCHAR fileName)
{
    PUCHAR f = vc2str(fileName);
    PUCHAR temp, ext = f;
    
    for(;;) {
        temp = strchr ( ext  , '.');
        if (temp == NULL) break;
        ext = temp +1;
    }
    if (ext == f) {
        str2vc(extension , "");
        return;
    }
    str2vc(extension , ext);
    return extension->String;
}


/* --------------------------------------------------------------------------- */
PUCHAR il_getFileMimeType (PVARCHAR256  pMimeType , PVARCHAR fileName)
{
    PUCHAR f = vc2str(fileName);
    VARCHAR256 ext;
    PUCHAR extension = il_getFileExtension (&ext , fileName);

    if (*extension == '\0' 
    || 0 == stricmp (extension, "html")
    || 0 == stricmp (extension, "htm")) {
        str2vc(pMimeType , "text/html");
        return;
    }

    if ( 0 == stricmp (extension, "gif")
    ||   0 == stricmp (extension, "png")
    ||   0 == stricmp (extension, "jpg")
    ||   0 == stricmp (extension, "jpeg")) {
        vcprintf (pMimeType , "image/%s", extension);
        return;
    }
    if ( 0 == stricmp (extension, "css")) {
        vcprintf (pMimeType , "text/%s", extension);
        return;
    }
    vcprintf (pMimeType , "application/%s", extension);
}
/* --------------------------------------------------------------------------- */
LGL il_serveStatic (PRESPONSE pResponse, PVARCHAR fileName)         
{        
    UCHAR buf [4096];
    LONG len;
    FILE * fp;
    PUCHAR pFile = vc2str(fileName);
    fp = fopen(pFile, "rb");
    if (fp == NULL) return ON; // Error;
    
    il_getFileMimeType (&pResponse->contentType ,  fileName);
    
    len = fread (buf, 1 , sizeof(buf) , fp);
    while (len > 0 ) {
        putChunk (pResponse, buf, len);         
        len = fread (buf, 1 , sizeof(buf) , fp);
    }
    fclose (fp);   
    return OFF;
}


