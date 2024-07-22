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
#define MAXHEADERS 4096
#define MAX_HEADER_WAIT 120
#define MAX_PAYLOAD_WAIT 120

#include "os2.h"
#include <pthread.h>

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
//#include <decimal.h>
#include <fcntl.h>
#include <time.h>       /* time_t, struct tm, time, localtime, strftime */
#include <regex.h>


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
#include <sys/signal.h>


#include "ostypes.h"
#include "teramem.h"
#include "varchar.h"
#include "streamer.h"
#include "sysdef.h"
#include "sndpgmmsg.h"
#include "strUtil.h"
#include "e2aa2e.h"
#include "xlate.h"
#include "simpleList.h"
#include "parms.h"
#include "fcgi_stdio.h"
#include "jsonxml.h"


// callback function pointers
BOOL (*receiveHeader)  (PREQUEST pRequest);
BOOL shutdownFlag = false;


/* --------------------------------------------------------------------------- */
void prepareResponse  (PRESPONSE pResponse)
{
    // if not put yet
    if (pResponse->firstWrite) {
        putHeader (pResponse); 
        pResponse->firstWrite = false;
    }
}
/* --------------------------------------------------------------------------- */
// end of chunks
void putChunkEnd (PRESPONSE pResponse)
{
    int     rc;
    LONG    lenleni;
    UCHAR   lenbuf [32];

    if (pResponse->pConfig->protocol == PROT_FASTCGI
    ||  pResponse->pConfig->protocol == PROT_SECFASTCGI) {
        return;
    }

    prepareResponse  (pResponse);

    lenleni = sprintf (lenbuf , "0\r\n\r\n" );  // end of chunks
    meme2a(lenbuf,lenbuf, lenleni);
    rc = write(pResponse->pConfig->clientSocket,lenbuf, lenleni);
}
/* --------------------------------------------------------------------------- */
void putChunk (PRESPONSE pResponse, PUCHAR buf, LONG len)
{
    int rc;
    LONG   lenleni;
    PUCHAR tempBuf;
    PUCHAR wrkBuf;

    if (len == 0) {
        return;
    }

    tempBuf = memAlloc ( len + 16);
    wrkBuf = tempBuf;

    prepareResponse  (pResponse);

    if (pResponse->pConfig->protocol == PROT_FASTCGI
    ||  pResponse->pConfig->protocol == PROT_SECFASTCGI) {
        rc = FCGX_PutStr( buf , len , pResponse->pConfig->fcgi.out);
        memFree (&tempBuf);
        return;
    }

    lenleni = sprintf (wrkBuf , "%x\r\n" , len);
    meme2a( wrkBuf , wrkBuf , lenleni);
    wrkBuf += lenleni;

    memcpy (wrkBuf , buf, len);
    wrkBuf += len;

    *(wrkBuf++) =  0x0d;
    *(wrkBuf++) =  0x0a;
    rc = write(pResponse->pConfig->clientSocket, tempBuf , wrkBuf - tempBuf);
    memFree (&tempBuf);

}
/* --------------------------------------------------------------------------- */
void putChunkXlate (PRESPONSE pResponse, PUCHAR buf, LONG len)
{
    int rc;
    LONG   lenleni;
    int outlen = len * 4;
    UCHAR lenBuf [16];
    PUCHAR tempBuf;
    PUCHAR wrkBuf;
    PUCHAR totBuf;
    PUCHAR input;
    size_t inbytesleft, outbytesleft, totalWriteLen ;

    if (len == 0) {
        return;
    }

    prepareResponse  (pResponse);

    input = buf;
    inbytesleft = len;
    outbytesleft = outlen;
    totBuf = memAlloc ( 16 + (outlen));     // The Chunk header + the max size which twice the byte size
    wrkBuf = tempBuf = totBuf + 16;       // Make room for the chunk header ( max 16 bytes)

    rc = iconv ( pResponse->pConfig->e2a->Iconv , &input , &inbytesleft, &wrkBuf , &outbytesleft);

    totalWriteLen = wrkBuf - tempBuf;

    if (pResponse->pConfig->protocol == PROT_FASTCGI
    ||  pResponse->pConfig->protocol == PROT_SECFASTCGI) {
        rc = FCGX_PutStr( tempBuf , totalWriteLen , pResponse->pConfig->fcgi.out);
        memFree (&totBuf);
        return;
    }

    // Build the Chunk header
    lenleni = sprintf (lenBuf , "%x\r\n" , totalWriteLen);
    tempBuf -= lenleni;
    meme2a( tempBuf , lenBuf  , lenleni);

    *(wrkBuf++) =  0x0d;
    *(wrkBuf++) =  0x0a;
    totalWriteLen = wrkBuf - tempBuf;
    rc = write(pResponse->pConfig->clientSocket, tempBuf , totalWriteLen);
    memFree (&totBuf);

}
/* --------------------------------------------------------------------------- */
/*  Sun, 06 Nov 1994 08:49:37 GMT    ; IMF-fixdate */
/* --------------------------------------------------------------------------- */
PUCHAR imfTimeString(PUCHAR buf)
{
    time_t rawtime;
    struct tm timeinfo;
    static const UCHAR * dayname   [] = {"Sun","Mon","Tue","Wed","Thu","Fri","Sat"};
    static const UCHAR * monthname [] = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov","Dec"};

    time (&rawtime);
    gmtime_r (&rawtime , &timeinfo);

    sprintf(
        buf,"%s, %02d %s %4d %02d:%02d:%02d GMT",
        dayname[timeinfo.tm_wday],
        timeinfo.tm_mday,
        monthname[timeinfo.tm_mon],
        timeinfo.tm_year + 1900,
        timeinfo.tm_hour,
        timeinfo.tm_min,
        timeinfo.tm_sec
    );
    return buf;
}
/* --------------------------------------------------------------------------- */
void putHeader (PRESPONSE pResponse)
{
    const int HEADER_SIZE = 4096;

    size_t rc;
    UCHAR  header [HEADER_SIZE];
    PUCHAR p = header;
    LONG len;
    LONG newLen;
    LONG hdrLen;
    UCHAR timeBuffer [128];
    SLISTITERATOR headers;
    PSLISTNODE pNode;


    p += sprintf(p ,
        "HTTP/1.1 %d %s\r\n"
        "Date: %s\r\n"
        "Transfer-Encoding: chunked\r\n"
        "Content-type: %s;charset=%s\r\n",
        pResponse->status,
        vc2str(&pResponse->statusText),
        imfTimeString(timeBuffer),
        vc2str(&pResponse->contentType),
        vc2str(&pResponse->charset)
    );

    headers = sList_setIterator(pResponse->headerList);
    while (sList_foreach (&headers) == ON) {
        pNode = headers.this;
        hdrLen = strlen(pNode->payloadData) + 4; // two more bytes for the CRLF
        newLen = p - header + hdrLen;            // delimiter before POST section
        if (newLen <= HEADER_SIZE) {
            p += sprintf(p, "%s\r\n", pNode->payloadData);
        }
    }

    // TODO: Handle "buffer to small to hold all headers" error

    // Add CRLF delimiter before POST data section
    hdrLen = 2;
    newLen = p - header + hdrLen;
    if (newLen <= HEADER_SIZE) {
        p += sprintf(p, "%s", "\r\n");
    }

    len = p - header;
    meme2a( header , header , len);

    if (pResponse->pConfig->protocol == PROT_FASTCGI
    ||  pResponse->pConfig->protocol == PROT_SECFASTCGI) {
        rc = FCGX_PutStr( header , len , pResponse->pConfig->fcgi.out);
    } else {
        rc = write(pResponse->pConfig->clientSocket, header , len);
    }

}
/* ---------------------------------------------------------------------------
   Split the url at "?" into resource, and queryString
   --------------------------------------------------------------------------- */
static void parseQueryString (PREQUEST pRequest)
{
    pRequest->resource.String = pRequest->url.String;
    pRequest->queryString.String = memchr(pRequest->url.String, 0x3F, pRequest->url.Length);
    if (pRequest->queryString.String) {
        // don't need the query string delimiter ? in the query string value
        pRequest->queryString.String++;
        pRequest->queryString.Length = pRequest->protocol.String - pRequest->queryString.String;
        // -1 because we don't want the delimiter (?) in the resource url
        pRequest->resource.Length = pRequest->queryString.String - pRequest->url.String - 1;
    } else {
        pRequest->resource.Length = pRequest->url.Length;
    }
}

/* ---------------------------------------------------------------------------
   Produce a key/value list of form or query string

   --------------------------------------------------------------------------- */
PSLIST parseParms ( LVARPUCHAR parmString)
{
    PSLIST pParmList;
    PUCHAR parmEnd, begin, end, split;
    if (parmString.String == NULL) {
        return NULL;
    }

    pParmList = sList_new ();

    begin =  parmString.String;
    end    = begin + parmString.Length;
    while (begin < end) {

        LVARPUCHAR key;
        LVARPUCHAR value;

        parmEnd = memchr(begin, 0x26, end - begin ); // Split at the &

        // last parameter?
        if (parmEnd == NULL) {
            parmEnd = *end == '\0' ? end : end - 1 ; // Omit the "blank" separator !!TODO Adjust the parm string
        }

        split= memchr(begin, 0x3D, parmEnd - begin ); // Split at the =
        if (split == null) break;

        // Got the components, now store in the list
        key.String = begin;
        key.Length = split - begin;

        split++;
        value.String = split;
        value.Length = parmEnd - split;

        // The key / value pair are ready
        sList_pushLVPC (pParmList , &key , &value);

        // Next iteration
        begin = parmEnd + 1; // After the ? mark
    }

    return pParmList;
}

PSLIST parseResource(LVARPUCHAR resource)
{
    if (resource.String == NULL) {
        return NULL;
    }

    PSLIST pResourceSegments = sList_new();
    char * SLASH = "\x2f"; // "/" = 0x2f in UTF-8
    
    int segmentStart = -1;
  
    int i = 0;
  
    LVARPUCHAR segment;
  
    for (i = 0; i <= resource.Length; i++) {
        if (resource.String[i] == *SLASH || i == resource.Length) {
            if (segmentStart == -1) {
                segmentStart = i;
            }
            else if (segmentStart >= 0) {
                segment.Length = i - segmentStart - 1;
                segment.String = resource.String + segmentStart + 1;
                segmentStart = i;
                sList_push(pResourceSegments, sizeof(LVARPUCHAR), &segment, OFF);
                
            }
        }
    }
    
    return pResourceSegments;
}

/* ---------------------------------------------------------------------------
   Produce a key/value list of the request headers
   --------------------------------------------------------------------------- */
static void parseHeaders (PREQUEST pRequest)
{
    static char eol [2]  = { 0x0d , 0x0a};

    PUCHAR headend , begin, end, split;

    pRequest->headerList = sList_new ();

    begin =  pRequest->headers.String;
    headend = begin + pRequest->headers.Length;
    while (begin < headend) {
        LVARPUCHAR key;
        LVARPUCHAR value;

        for (;*begin == 0x20; begin ++); // Skip blank(s)
        end  = memmem(begin, headend - begin , eol , 2); // Find end of line
        if (end == null) { // end of line not found => end of headers
            end = headend;
        }
        split= memchr(begin, 0x3A, end - begin ); // Split at the : colon
        if (split == null) break;

        // Got the components, now store in the list
        key.String = begin;
        key.Length = split - begin;

        split++;
        for (;*split == 0x20; split++); // Skip blank(s)
        value.String = split;
        value.Length = end - split;

        // The key / value pair are ready
        sList_pushLVPC (pRequest->headerList , &key , &value);

        // Next iteration
        begin = end + 2; // After the eol mark
    }
}
/* ---------------------------------------------------------------------------
   Return string of header values
   Note - the keys are in ASCII so we have to convert. memicmp only works on EBCDIC
   --------------------------------------------------------------------------- */
PUCHAR getHeaderValue(PUCHAR  value, PSLIST headerList ,  PUCHAR key)
{
     PSLISTNODE pNode;
    int  keyLen= strlen(key);
    UCHAR aKey [256];

    for (pNode = headerList->pHead; pNode; pNode=pNode->pNext) {
        PSLISTKEYVAL header = pNode->payloadData;
        if (keyLen == header->key.Length) {
            mema2e(aKey , header->key.String , keyLen); // The headers are in ASCII
            if (memicmp (key , aKey , keyLen) == 0) {
                substr(value , header->value.String ,  header->value.Length);
                return value;
            }
        }
    }
    *value = '\0';
    return value;
}
/* ---------------------------------------------------------------------------
   Parse this:
   GET / HTTP/1.1??Host: dksrv133:44001??Con
   --------------------------------------------------------------------------- */
BOOL lookForHeaders ( PREQUEST pRequest, PUCHAR buf , ULONG bufLen)
{

    ULONG beforeHeadersLen;
    PUCHAR begin , next;
    static char eol [4]  = { 0x0d , 0x0a , 0x0d , 0x0a};
    UCHAR temp [256];
    PUCHAR eoh = memmem ( buf ,bufLen , eol , 4);

    // No end-of-headers in this buffer, the just continue
    if (eoh == NULL)      return false;

    // Skip all CRLF from the begining of buffer
    for (;*buf == 0x0d || *buf == 0x0a; buf ++, bufLen --);

    // got the end of header; Now parse the HTTP header
    pRequest->completeHeader.String = buf;
    pRequest->completeHeader.Length = eoh - buf;

    beforeHeadersLen = pRequest->completeHeader.Length;

    // Headers
    pRequest->headers.String = memmem ( buf ,bufLen , eol , 2) + 2;
    pRequest->headers.Length = eoh - pRequest->headers.String;

    // Method
    begin = buf;
    for (;*begin== 0x20; begin ++); // Skip blank(s)
    pRequest->method.String = begin;
    next = memchr(begin, 0x20, beforeHeadersLen);
    pRequest->method.Length = next - begin;

    // url
    begin = next;
    for (;*begin== 0x20; begin ++); // Skip blank(s)
    pRequest->url.String = begin;
    next = memchr(begin, 0x20, beforeHeadersLen);
    pRequest->url.Length = next - begin;

    // Protocol
    begin = next;
    for (;*begin== 0x20; begin ++); // Skip blank(s)
    pRequest->protocol.String = begin;
    next  = memmem ( begin  , beforeHeadersLen , eol , 2);
    pRequest->protocol.Length = next - begin;


    // The request is now parsed into raw components:
    parseQueryString (pRequest);
    parseHeaders (pRequest);
    pRequest->parmList = parseParms(pRequest->queryString);
    pRequest->resourceSegments = parseResource(pRequest->resource);


    pRequest->contentLength = a2i(getHeaderValue (temp , pRequest->headerList, "content-length"));

    // Only what is recived so far - the rest is returned in "receivePayload"
    if (pRequest->contentLength > 0) {
        pRequest->content.String = eoh + 4;
        pRequest->content.Length = bufLen - ( pRequest->content.String - buf );
    }

    return true;

}
/* --------------------------------------------------------------------------- */
static BOOL receivePayload (PREQUEST pRequest)
{
    PUCHAR buf = memAlloc (pRequest->contentLength +1); // Add a zero terniation
    PUCHAR bufwin , end;
    LONG   rc;

    // What is already receved:
    memcpy ( buf , pRequest->content.String , pRequest->content.Length);
    bufwin = buf + pRequest->content.Length;

    // Build up the previous and the rest
    buf [pRequest->contentLength] = '\0';  // Enshure It will always be a zeroterminted string if used that way
    pRequest->content.String = buf;
    pRequest->content.Length = pRequest->contentLength;

    end = buf + pRequest->contentLength;
    while (bufwin < end) {
        rc = socketWait (pRequest->pConfig->clientSocket, MAX_PAYLOAD_WAIT);
        if (rc <= 0) {
            return true;
        }

        rc = read(pRequest->pConfig->clientSocket , bufwin , end - bufwin);
        if (rc <= 0) {
            return true;
        }
        bufwin += rc;
    }

    return false;
}

/* --------------------------------------------------------------------------- */
static BOOL receiveHeaderHTTP (PREQUEST pRequest)
{
    PUCHAR buf = memAlloc (SOCMAXREAD);
    PUCHAR bufWin = buf;
    ULONG  bufLen = 0;
    LONG   rc;
    BOOL   isLookingForHeaders = true;

    // Load the complete request data
    for(;;) {
        rc = socketWait (pRequest->pConfig->clientSocket, MAX_HEADER_WAIT);
        if (rc <= 0) {
            memFree(&buf);
            return true;
        }
        rc = read(pRequest->pConfig->clientSocket , bufWin , SOCMAXREAD - bufLen);
        if (rc <= 0) {
            memFree(&buf);
            return true;
        }

        bufLen += rc;
        bufWin += rc;
        if (isLookingForHeaders) {
            if (lookForHeaders ( pRequest , buf, bufLen)) {
                if (pRequest->contentLength) {
                    receivePayload (pRequest);
                }
                isLookingForHeaders = false;
                // memFree(&buf); !! Dont !! this is now pRequest->completeHeader.String
                return false; // TODO - Now only GET - no payload
            }
        }
    }
}

/* --------------------------------------------------------------------------- */
// Depending of the protocol, we have to set lo-level I/O
/* --------------------------------------------------------------------------- */
static void setCallbacks (PCONFIG pConfig)
{
    switch (pConfig->protocol) {
        case PROT_DEFAULT:
        case PROT_HTTP:
        case PROT_HTTPS:
            receiveHeader = receiveHeaderHTTP;
            break;
        case PROT_FASTCGI:
        case PROT_SECFASTCGI:
            receiveHeader =  fcgiReceiveHeader;
            break;
        default:
            il_joblog ("Invalid protocol types %d" , pConfig->protocol);
            exit(-1);
    }
}
/* --------------------------------------------------------------------------- *\
    Handle :
    il_addRoute  (config : myServives: IL_ANY : '^/services/' : '(application/json)|(text/json)');
\* --------------------------------------------------------------------------- */
void runServletByRouting (PREQUEST pRequest, PRESPONSE pResponse, SERVLET servlet)
{
    UCHAR msgbuf[100];

    if (pRequest->pConfig->router == NULL) return;

    if (servlet) {
        servlet(pRequest, pResponse);
    }
    else {
        il_joblog( "No routing found for request"); // TODO add resource to output
        pResponse->status = 404;
        putChunk(pResponse, "", 0); // TODO add not found message
    }
}

PROUTING findRoute(PCONFIG pConfig, PREQUEST pRequest) {
    PROUTING matchingRouting = NULL;
    PSLIST pRouts;
    PSLISTNODE pRouteNode;
    PUCHAR end;
    PUCHAR l_resource;

    // No routing  - simple direct servlet
    if (pConfig->router == NULL) {
        return null;
    }

    pRouts = pConfig->router;
    pRequest->pRouting = NULL;
    
    // get the ebcdic version of the resource
    l_resource = memAlloc(pRequest->resource.Length +1);
    mema2e(l_resource ,  pRequest->resource.String , pRequest->resource.Length); // The headers are in ASCII
    l_resource[pRequest->resource.Length] = '\0';  // Need it as a string

    // Terminate at parameters ( if any)
    end = strchr(l_resource , '?');
    if (end) {
        *end = '\0';
    }

    for (pRouteNode = pRouts->pHead; pRouteNode ; pRouteNode = pRouteNode->pNext) {

        PROUTING pRouting = pRouteNode->payloadData;

        if (httpMethodMatchesEndPoint(&pRequest->method, pRouting->routeType)) {
            regmatch_t groupArray[pRouting->parmNumbers+1];
            int g;
            PUCHAR value;
            // Execute regular expression
            // If non is given then it is a match as well. That counts for a "match all"
            int rc = pRouting->routeReg == NULL ? 0 : regexec(pRouting->routeReg, l_resource, pRouting->parmNumbers+1 , groupArray, 0);
            if (rc == 0) { // Match found
                for (g = 1; g <= pRouting->parmNumbers; g++) {
                    if (groupArray[g].rm_so == (size_t)-1)
                        break;  // No more groups
                    // Now make space for the UTF-8 version of the data    
                    value = memAlloc (groupArray[g].rm_eo - groupArray[g].rm_so + 1);
                    substr( value, pRequest->resource.String + groupArray[g].rm_so, groupArray[g].rm_eo - groupArray[g].rm_so) ;  
                    pRequest->parmValue[g-1] = value;
                }
                matchingRouting = pRouting;
                break;
            }
        }
    }

    memFree (&l_resource);

    return matchingRouting;
}
#pragma convert(1252)
BOOL httpMethodMatchesEndPoint(PLVARPUCHAR requestMethod, ROUTETYPE endPointRouteType)
{
    ROUTETYPE requestRouteType;

    if (endPointRouteType == IL_ANY) {
        return true;
    }
    else if (lvpcIsEqualStr (requestMethod, "GET")) {
        requestRouteType = IL_GET;
    }
    else if (lvpcIsEqualStr (requestMethod, "HEAD")) {
        requestRouteType = IL_HEAD;
    }
    else if (lvpcIsEqualStr (requestMethod, "PUT")) {
        requestRouteType = IL_PUT;
    }
    else if (lvpcIsEqualStr (requestMethod, "POST")) {
        requestRouteType = IL_POST;
    }
    else if (lvpcIsEqualStr (requestMethod, "DELETE")) {
        requestRouteType = IL_DELETE;
    }
    else if (lvpcIsEqualStr (requestMethod, "PATCH")) {
        requestRouteType = IL_PATCH;
    }
    else if (lvpcIsEqualStr (requestMethod, "OPTIONS")) {
        requestRouteType = IL_OPTIONS;
    }
    else {
      return false;
    }

    return endPointRouteType & requestRouteType;
}
#pragma convert(0)

/* --------------------------------------------------------------------------- */
BOOL runPlugins (PSLIST plugins , PREQUEST pRequest, PRESPONSE pResponse)
{
    PSLISTNODE pPluginNode;

    if (plugins) {
        for (pPluginNode = plugins->pHead; pPluginNode ; pPluginNode = pPluginNode->pNext) {
            PPLUGIN  pPlugin =  pPluginNode->payloadData;
            if  (OFF == pPlugin->servlet ( pRequest, pResponse)) {
                return false;
            }
        }
    }
    return true;
}
/* --------------------------------------------------------------------------- */
static void cleanupTransaction (PREQUEST pRequest , PRESPONSE pResponse)
{
    int i;
    PROUTING pRoute = pRequest->pRouting;                 
    if (pRoute) {                                         
        for (i = 0 ; i < pRoute->parmNumbers ; i++ ) {    
            memFree(&pRequest->parmValue[i]);             
        }                                                 
    }                                                     

    sList_free (pRequest->headerList);
    sList_free (pRequest->parmList);
    sList_free (pRequest->resourceSegments);
    sList_free (pResponse->headerList);

    if (pRequest->threadMem) {
        jx_NodeDelete(pRequest->threadMem);
        pRequest->threadMem = NULL;
    }
    memFree(&pRequest->completeHeader.String);
    memFree(&pRequest->content.String);
}

/* --------------------------------------------------------------------------- */
static void * serverThread (PINSTANCE pInstance)
{
    REQUEST  request;
    RESPONSE response;
    BOOL     allSaysGo;
    volatile PRESPONSE pResponse;
    PROUTING matchingRouting;
    BOOL     connected = true; 
    UCHAR    temp [256]; 
    
    pthread_detach(pthread_self());


    while (pInstance->config.clientSocket > 0 && connected) {
        memset(&request  , 0, sizeof(REQUEST));
        memset(&response , 0, sizeof(RESPONSE));
        request.pConfig = &pInstance->config;
        response.pConfig = &pInstance->config;
        if (receiveHeader(&request)) {
            break;
        }
        response.firstWrite = true;
        response.status = 200;
        str2vc(&response.contentType , "text/html");
        str2vc(&response.charset     , "UTF-8");
        str2vc(&response.statusText  , "OK");
        response.headerList = sList_new();

        pResponse = &response;
        
        request.threadMem = (PVOID) jx_NewObject(NULL);

        #pragma exception_handler(handleServletException, pResponse, _C1_ALL, _C2_MH_ESCAPE, _CTLA_HANDLE)
        matchingRouting = findRoute(request.pConfig, &request);
        if (matchingRouting) {
            request.routeId.Length = matchingRouting->routeId.Length;
            memcpy(request.routeId.String, matchingRouting->routeId.String, matchingRouting->routeId.Length); 
            request.pRouting = matchingRouting;
        }
        
        allSaysGo = runPlugins (request.pConfig->pluginPreRequest , &request , &response);
        if (allSaysGo) {
            if (pInstance->servlet) {
                pInstance->servlet (&request , &response);
            } else {
                runServletByRouting (&request , &response, matchingRouting ? matchingRouting->servlet:null);
            }
            runPlugins (request.pConfig->pluginPostResponse , &request , &response);
        }
        #pragma disable_handler

        putChunkEnd (&response);

        if ( 0 == memicmpascii (getHeaderValue (temp , request.headerList, "connection") , "close" , 5)) {
            connected = false;
        } 

        // Clean up this roundtrip 
        cleanupTransaction (&request , &response);
    }
    close(response.pConfig->clientSocket);
    memFree(&pInstance);
    pthread_exit(NULL);
    return NULL;
}
/* --------------------------------------------------------------------------- */
static void * schedulerThread (PCONFIG pConfig)
{
    ULONG sec =0;
    for(;;) {
        sleep(1);
        // The config structure uninitialized default to BLANK 0404040 :(
        if (pConfig->schedulerTimer < 100000 && pConfig->scheduler
        && (shutdownFlag || sec ++ > pConfig->schedulerTimer)) {
            LGL run = pConfig->scheduler(pConfig);
            if (run == OFF) exit(0);
            sec =0;
        }
        if (shutdownFlag) exit(0);
    }
}
/* --------------------------------------------------------------------------- */
void handleServletException(_INTRPT_Hndlr_Parms_T * __ptr128 parms) {
    PRESPONSE * pResponse = parms->Com_Area;
    PRESPONSE response = *pResponse;
    response->status = 500;
    putChunkXlate(response, "Internal Server Error", 21);
}

/* --------------------------------------------------------------------------- */
static int montcp(int errcde)
{
   if (errcde == 3448) { // TCP/IP is not running yet
      sleep(60);
   }
   return errcde;
}
/* --------------------------------------------------------------------------- */
static void FormatIp(PUCHAR out, ULONG in)
{
   PUCHAR p = (PUCHAR) &in;
   USHORT t[4];
   UCHAR str[16];
   int i;
   for (i=0; i<4 ;i++) {
     t[i] = p[i];
   }
   sprintf(out, "%d.%d.%d.%d" , t[0], t[1],t[2] ,t[3]);
}

/* --------------------------------------------------------------------------- */
/* Set up a new connection                                                     */
/* --------------------------------------------------------------------------- */
static BOOL getSocket(PCONFIG pConfig)
{
    static struct sockaddr_in serveraddr, client;
    int on = 1;
    int errcde;
    int rc;

    UCHAR interface  [32];
    vc2strcpy(interface , &pConfig->interface);

    // Get a socket descriptor
    if ((pConfig->mainSocket = socket(AF_INET, SOCK_STREAM, 0)) < 0)  {
        errcde = montcp(errno);
        il_joblog( "socket error: %d - %s" , (int) errcde, strerror((int) errcde));
        return false;
    }

    // Allow socket descriptor to be reuseable
    rc = setsockopt(
        pConfig->mainSocket, SOL_SOCKET,
        SO_REUSEADDR,
        (char *)&on,
        sizeof(on)
    );

    if (rc < 0) {
        errcde = montcp(errno);
        il_joblog( "setsockop error: %d - %s" ,(int) errcde, strerror((int) errcde));
        close(pConfig->mainSocket);
        return false;
    }

    // bind to interface / port
    memset(&serveraddr, 0x00, sizeof(struct sockaddr_in));
    serveraddr.sin_family        = AF_INET;
    serveraddr.sin_port          = htons(pConfig->port);

    if (strspn (interface , "0123456789.") == strlen(interface)) {
        serveraddr.sin_addr.s_addr   = inet_addr(interface);
    } else {
        serveraddr.sin_addr.s_addr   = htonl(INADDR_ANY);
    }


   rc = bind(pConfig->mainSocket,  (struct sockaddr *)&serveraddr, sizeof(serveraddr));
   if (rc < 0) {
      errcde = montcp(errno);
      il_joblog( "bind error : %d - %s" ,(int) errcde, strerror((int) errcde));
      close(pConfig->mainSocket);
        return false;
   }

    // Up to XXX clients can be queued
    rc = listen(pConfig->mainSocket, SOMAXCONN);
    if (rc < 0)  {
        errcde = montcp(errno);
        close(pConfig->mainSocket);
        il_joblog( "Listen error: %d - %s" ,(int) errcde, strerror((int) errcde));
        return false;
    }

    // So fare we are ready
    return true;
}

/* ------------------------------------------------------------- *\
   returns:
      0=Time out
      >0 : OK data ready
      <0 :Error
\* ------------------------------------------------------------- */
int socketWait (int sd , int sec)
{
    int rc;
    fd_set fd;
    struct timeval timeout;
    timeout.tv_sec  = sec;
    timeout.tv_usec = 0;

    // select()  - wait for data to be read.
    FD_ZERO(&fd);
    FD_SET(sd,&fd);
    rc = select(sd+1,&fd,NULL,NULL,&timeout);
    if (rc < 0) {
        il_joblog ("select() failed :%s\r\n", strerror(errno));
    }
    return rc;
}
/* ------------------------------------------------------------- */
void setMaxSockets(void)
{
    int     maxFiles;
    APIRET   apiret;
    LONG     pcbReqCount = 0;
    ULONG    pcbCurMaxFH = 0;

    // Setup max number of sockes
    maxFiles = sysconf(_SC_OPEN_MAX);
    apiret = DosSetRelMaxFH(&pcbReqCount,  &pcbCurMaxFH);
    pcbReqCount = FD_SETSIZE  - pcbCurMaxFH;
    apiret = DosSetRelMaxFH(&pcbReqCount,  &pcbCurMaxFH);
    maxFiles = sysconf(_SC_OPEN_MAX);

}
/* ------------------------------------------------------------- *\
    Set up a signal handling procedure to handle the
    asynchronous signal SIGTERM being generated by
    ENDJOB, ENBSBS, or PWRDWNSYS when the *CNTRLD option is
    specified for the OPTION keyword
\* ------------------------------------------------------------- */
void catcher( int sig) {
    shutdownFlag = true;
}
void setShutdownHandler (void)
{
    struct sigaction sigact, osigact;

    sigemptyset( &sigact.sa_mask );
    sigact.sa_flags = 0;
    sigact.sa_handler = catcher;
    sigaction( SIGTERM, &sigact, &osigact );
}
/* ------------------------------------------------------------- *\
    Load this from environment if set, overidding values;
    VARCHAR64   interface;
    int         port;
    PROTOCOL    protocol;
    VARCHAR256  certificateFile;
    VARCHAR64   certificatePassword;
\* ------------------------------------------------------------- */
static void loadConfigFromEnvironment (PCONFIG pConfig)
{
    PUCHAR pEnvVal;

    pEnvVal = getenv("I_INTERFACE");
    if (pEnvVal) {
        str2vc (&pConfig->interface , pEnvVal );
    } 

    pEnvVal = getenv("I_PORT");
    if (pEnvVal) {
        pConfig->port = atoi(pEnvVal);
    } 

    pEnvVal = getenv("I_PROTOCOL");
    if (pEnvVal) {
        if        (0==strcmp(pEnvVal, "HTTP")) {
            pConfig->protocol = PROT_HTTP;
        } else if (0==strcmp(pEnvVal, "HTTPS")) {
            pConfig->protocol = PROT_HTTPS;
        } else if (0==strcmp(pEnvVal, "FASTCGI")) {
            pConfig->protocol = PROT_FASTCGI;
        } else if (0==strcmp(pEnvVal, "SECFASTCGI")) {
            pConfig->protocol = PROT_SECFASTCGI;
        }
    }

    pEnvVal = getenv("I_CERTIFICATE");
    if (pEnvVal) {
        str2vc (&pConfig->certificateFile , pEnvVal );
    } 

    pEnvVal = getenv("I_CERTIFICATE_PASSWORD");
    if (pEnvVal) {
        str2vc (&pConfig->certificatePassword , pEnvVal );
    } 

}
/* ------------------------------------------------------------- */
void il_listen (PCONFIG pConfig, SERVLET servlet)
{
    PNPMPARMLISTADDRP pParms = _NPMPARMLISTADDR();
    BOOL     resetSocket = TRUE;
    pthread_attr_t attr;
    pthread_t  pSchedulerThread;
    int rc;

    loadConfigFromEnvironment ( pConfig);

    rc = pthread_attr_init(&attr);
    if (rc == -1) {
        perror("error in pthread_attr_init");
        exit(1);
    }

    rc = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
    if (rc == -1) {
        perror("error in pthread_attr_setdetachstate");
        exit(2);
    }

    rc = pthread_create(&pSchedulerThread , &attr, schedulerThread , pConfig);
    setShutdownHandler ();
    setMaxSockets();
    pConfig->a2e = XlateXdOpen (1208, 0);
    pConfig->e2a = XlateXdOpen (0 , 1208);

    setCallbacks (pConfig);


    // tInitSSL(pConfig);

    // Infinit loop
    for (;;) {
        pthread_t  pServerThread;

        PINSTANCE pInstance;
        int clientSocket;
        struct sockaddr_in serveraddr, client;
        int clientSize;
        int errcde;

        // Initialize connection
        if (resetSocket) {
            if ( ! getSocket(pConfig) ) {
                sleep(5);
                continue;
            }
            resetSocket = false;
        }

        if (pConfig->protocol == PROT_FASTCGI
        ||  pConfig->protocol == PROT_SECFASTCGI) {
            // Setup arguments to pass
            PINSTANCE pInstance = memAlloc(sizeof(INSTANCE));
            memcpy(&pInstance->config , pConfig , sizeof(CONFIG));
            pInstance->config.clientSocket = 32760;
            pInstance->servlet = pParms->OpDescList->NbrOfParms >= 2 ? servlet : NULL;
            serverThread (pInstance);
            return ;
        }


        // accept() the incoming connection request.
        clientSize = sizeof(client);
        clientSocket = accept(pConfig->mainSocket,  (struct sockaddr *)   &client, &clientSize);

        if (clientSocket < 0 ) {
            errcde = montcp(errno);
            resetSocket = TRUE;
            close(pConfig->mainSocket);
            il_joblog( "Accept error: %d - %s" ,(int) errcde, strerror((int) errcde));
            continue;
        }

        // virker ikke:    sprintf(RemoteIp   , "%s" , inet_ntoa(client.sin_addr));
        pConfig->rmtTcpIp = client.sin_addr.s_addr;
        FormatIp(pConfig->rmtHost , client.sin_addr.s_addr);
        pConfig->rmtPort = client.sin_port;

        // Setup arguments to pass
        pInstance = memAlloc(sizeof(INSTANCE));
        memcpy(&pInstance->config , pConfig , sizeof(CONFIG));
        pInstance->config.clientSocket   = clientSocket;
        pInstance->servlet = pParms->OpDescList->NbrOfParms >= 2 ? servlet : NULL;

        rc = pthread_create(&pServerThread , &attr, serverThread , pInstance);
        if (rc) {
            errcde = rc;
            il_joblog( "Thread not started - ensure ALWMLTTHD(*YES) on job: %d - %s" , (int) errcde, strerror((int) errcde));
            exit(0);
        }

    }
}

