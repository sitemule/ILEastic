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
void il_responseWrite (PRESPONSE pResponse, PLVARCHAR buf)
{
    putChunk (pResponse, buf->String, buf->Length);         
}
/* --------------------------------------------------------------------------- */
void setContentTypeForFileType (PRESPONSE pResponse , PVARCHAR fileName)
{
    PUCHAR f = vc2str(fileName);
    PUCHAR temp, extension = f;
    for(;;) {
        temp = strchr ( extension  , '.');
        if (temp == NULL) break;
        extension = temp +1;
    }
    if (extension == f 
    || 0 == stricmp (extension, "html")
    || 0 == stricmp (extension, "htm")) {
        str2vc(&pResponse->contentType , "text/html");
        return;
    }

    if ( 0 == stricmp (extension, "gif")
    ||   0 == stricmp (extension, "png")
    ||   0 == stricmp (extension, "jpg")
    ||   0 == stricmp (extension, "jpeg")) {
        vcprintf (&pResponse->contentType , "image/%s", extension);
        return;
    }
    if ( 0 == stricmp (extension, "css")) {
        vcprintf (&pResponse->contentType , "text/%s", extension);
        return;
    }
    vcprintf (&pResponse->contentType , "application/%s", extension);
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
    
    setContentTypeForFileType (pResponse , fileName);

    len = fread (buf, 1 , sizeof(buf) , fp);
    while (len > 0 ) {
        putChunk (pResponse, buf, len);         
        len = fread (buf, 1 , sizeof(buf) , fp);
    }
    fclose (fp);   
    return OFF;
}


