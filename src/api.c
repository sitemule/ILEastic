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
#include <regex.h>



#include "ostypes.h"
#include "varchar.h"
#include "sysdef.h"
#include "strUtil.h"
#include "streamer.h"
#include "simpleList.h"
#include "sndpgmmsg.h"
#include "parms.h"
#include "e2aa2e.h"


/* --------------------------------------------------------------------------- */
// Getters - curtesy procedures 
/* --------------------------------------------------------------------------- */
void il_getRequestResource (PLVARCHAR out , PREQUEST pRequest)
{
    lvpc2lvc (out, &pRequest->resource);
}         
void il_getRequestMethod (PVARCHAR out , PREQUEST pRequest)
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
void il_getRequestHeader (PLVARCHAR out , PREQUEST pRequest, PUCHAR header)
{
    getHeaderValue(out->String , pRequest->headerList ,  header);
    out->Length = strlen(out->String);
}         
void il_getRequestContent (PLVARCHAR out , PREQUEST pRequest)
{
    lvpc2lvc (out, &pRequest->content);
}         
/* --------------------------------------------------------------------------- */
static UCHAR hex2bin (UCHAR c)
{
    if (c >= 0x30 && c <= 0x39) return (c - 0x30);
    if (c >= 0x41 && c <= 0x46) return (c - 0x41 + 10);
    if (c >= 0x61 && c <= 0x66) return (c - 0x61 + 10);
    return 0;
}
/* --------------------------------------------------------------------------- */
static int urldecodeBuf (PUCHAR out , PUCHAR in , int inLen) 
{
    PUCHAR outBegin = out;
    PUCHAR end = in + inLen;
    for (;in < end; in ++) {
        // % escape? 
        if (*in == 0x25) {
            UCHAR c = hex2bin(*(++in)) * 16+
                      hex2bin(*(++in));
            *(out ++) = c;
        } else {
            *(out ++) = *in;
        } 

    }
    return out - outBegin;
}
/* --------------------------------------------------------------------------- */
void il_getParmStr  (PLVARCHAR out , PREQUEST pRequest , PUCHAR parmName , PLVARCHAR dft)
{
 	PSLISTNODE pNode;
    int  keyLen= strlen(parmName);
    UCHAR aKey [256];
    UCHAR temp [256];
    int len;
    
    PSLIST pParmList = pRequest->parmList; 

	if (pParmList != NULL) {
		for (pNode = pParmList->pHead; pNode; pNode=pNode->pNext) {
			PSLISTKEYVAL parm = pNode->payloadData;
			if (keyLen == parm->key.Length) {
				len = urldecodeBuf( temp  , parm->key.String , keyLen);
				mema2e(aKey , temp, len ); // The parms are in ASCII
				if (memicmp (parmName , aKey , keyLen) == 0) {
					out->Length = urldecodeBuf( out->String, parm->value.String ,  parm->value.Length);
					return ;
				}
			}
		}
	}
	
    out->Length = dft->Length;
    substr(out->String , dft->String , dft->Length); 
}
/* --------------------------------------------------------------------------- */
void il_responseWrite (PRESPONSE pResponse, PLVARCHAR buf)
{
    putChunk (pResponse, buf->String, buf->Length);         
}
/* --------------------------------------------------------------------------- */
static LONG streamWriter (PSTREAM pStream , PUCHAR buf , ULONG len)
{
    PRESPONSE pResponse = pStream->output;
    putChunkXlate (pResponse, buf, len);         
    return len;
}
/* --------------------------------------------------------------------------- */
void il_responseWriteStream (PRESPONSE pResponse, PSTREAM pStream)
{
    pStream->writer = streamWriter;
    pStream->output = pResponse;
    pStream->runner(pStream);
    stream_delete (pStream);
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
/* --------------------------------------------------------------------------- *\
    Handle :
    il_addPlugin  (config : myServives: IL_PREREQUEST + IL_POSTRESPONSE)
\* --------------------------------------------------------------------------- */
void il_addPlugin (PCONFIG pConfig, SERVLET servlet, PLUGINTYPE pluginType)
{
    PLUGIN plugin;

    if (pluginType & IL_PREREQUEST) {
        if (pConfig->pluginPreRequest == NULL) {
            pConfig->pluginPreRequest = sList_new();
        }
        plugin.servlet = servlet;
        plugin.pluginType = IL_PREREQUEST;
        sList_push (pConfig->pluginPreRequest   , sizeof(PLUGIN), &plugin, false);
    } 
    if (pluginType & IL_POSTRESPONSE) {
        if (pConfig->pluginPostResponse == NULL) {
            pConfig->pluginPostResponse = sList_new();
        }
        plugin.servlet = servlet;
        plugin.pluginType = IL_POSTRESPONSE;
        sList_push (pConfig->pluginPostResponse , sizeof(PLUGIN), &plugin, false);
    } 
}
/* --------------------------------------------------------------------------- *\
\* --------------------------------------------------------------------------- */
PVOID il_allocThreadMem  (PREQUEST pRequest , ULONG size)
{
    pRequest->threadMem = calloc(1, size);
    return pRequest->threadMem;
}
/* --------------------------------------------------------------------------- *\
\* --------------------------------------------------------------------------- */
PVOID il_getThreadMem  (PREQUEST pRequest)
{
    return pRequest->threadMem;
}
/* --------------------------------------------------------------------------- *\
    Handle :
    il_addRoute  (config : myServives: IL_ANY : '^/services/' : '(application/json)|(text/json)');
\* --------------------------------------------------------------------------- */
void il_addRoute (PCONFIG pConfig, SERVLET servlet, ROUTETYPE routeType , PVARCHAR routeReg , PVARCHAR contentReg )
{
    PNPMPARMLISTADDRP pParms = _NPMPARMLISTADDR();
    LONG rc;
    UCHAR msg  [100];
    ULONG options =  REG_NOSUB + REG_EXTENDED;
    ROUTING routing;

    if (pConfig->router == NULL) {
        pConfig->router = sList_new ();
    }

    routing.routeReg   = NULL;
    routing.contentReg = NULL;
    routing.servlet    = servlet;
    routing.routeType  = pParms->OpDescList->NbrOfParms >= 3 ? routeType : IL_ANY;

    if (pParms->OpDescList->NbrOfParms >= 4) {
        routing.routeReg   = malloc(sizeof(regex_t));
        rc = regcomp(routing.routeReg, vc2str(routeReg) , options );
        if (rc) {
            regerror(rc, routing.routeReg  , msg , 100);
            joblog( "Could not compile regex %s for routing. reason : %s " , vc2str(routeReg) , msg);
            exit(0);
        }
    }
    
    if (pParms->OpDescList->NbrOfParms >= 5) {
        routing.contentReg = malloc(sizeof(regex_t));
        rc = regcomp(routing.contentReg, vc2str(contentReg) , options );
        if (rc) {
            regerror(rc, routing.contentReg  , msg , 100);
            joblog( "Could not compile regex %s for content type. reason : %s " , vc2str(contentReg) , msg);
            exit(0);
        }
    }

    sList_push (pConfig->router , sizeof(ROUTING), &routing, false);
}        
