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

#include "os2.h"
#include <pthread.h>

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <decimal.h>
#include <fcntl.h>
#include <time.h>       /* time_t, struct tm, time, localtime, strftime */


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
#include "sndpgmmsg.h"
#include "strUtil.h"
#include "e2aa2e.h"
#include "xlate.h"
#include "simplelist.h"
#include "parms.h"

/* --------------------------------------------------------------------------- */
// TOOLS - TODO move to own files:
/* --------------------------------------------------------------------------- */
// atoi - real ascii version - the stdlib is running in EBCDIC
LONG a2i (PUCHAR s)
{
    LONG res = 0;
    for (;*s;s++) {
        // Is real ascii number?
        if (*s >= 0x30 && *s <= 0x39) {
            res = 10*res + (*s - 0x30);
        }
    }
    return res;
}
/* --------------------------------------------------------------------------- */
// end of chunks                                               
void putChunkEnd (PRESPONSE pResponse)
{                                                         
    int     rc;                                                 
    LONG    lenleni;                                        
    UCHAR   lenbuf [32];     
    lenleni = sprintf (lenbuf , "0\r\n\r\n" );  // end of chunks   
    meme2a(lenbuf,lenbuf, lenleni);
    rc = write(pResponse->pConfig->clientSocket, lenbuf, lenleni );
}
/* --------------------------------------------------------------------------- */
void putChunk (PRESPONSE pResponse, PUCHAR buf, LONG len)         
{        
    int rc;                                                 
    LONG   lenleni;                                        
    PUCHAR tempBuf = malloc ( len + 16);                   
    PUCHAR wrkBuf = tempBuf;                               

    putHeader (pResponse); // if not put yet

    lenleni = sprintf (wrkBuf , "%x\r\n" , len);           
    meme2a( wrkBuf , wrkBuf , lenleni);              
    wrkBuf += lenleni;                                     
                                                            
    memcpy (wrkBuf , buf, len);                            
    wrkBuf += len;                                         
                                                            
    *(wrkBuf++) =  0x0d;                                   
    *(wrkBuf++) =  0x0a;                                   
    rc = write(pResponse->pConfig->clientSocket, tempBuf , wrkBuf - tempBuf);
    free (tempBuf);                                        
                                                            
}
/* --------------------------------------------------------------------------- */
void putChunkXlate (PRESPONSE pResponse, PUCHAR buf, LONG len)         
{        
    int rc;                                                 
    LONG   lenleni;     
    int outlen = len * 4;                                   
    PUCHAR tempBuf = malloc ( outlen + 16);                   
    PUCHAR wrkBuf = tempBuf; 
    PUCHAR input;
    size_t inbytesleft, outbytesleft;
                              

    putHeader (pResponse); // if not put yet

    lenleni = sprintf (wrkBuf , "%x\r\n" , len);           
    meme2a( wrkBuf , wrkBuf , lenleni);              
    wrkBuf += lenleni;                                     

    input = buf;
	inbytesleft = len;
	outbytesleft = outlen;
                                                        
    rc = iconv ( pResponse->pConfig->e2a->Iconv , &input , &inbytesleft, &wrkBuf , &outbytesleft);
	                                                        
    *(wrkBuf++) =  0x0d;                                   
    *(wrkBuf++) =  0x0a;                                   
    rc = write(pResponse->pConfig->clientSocket, tempBuf , wrkBuf - tempBuf);
    free (tempBuf);                                        
                                                            
}               
/* --------------------------------------------------------------------------- */
/*  Sun, 06 Nov 1994 08:49:37 GMT    ; IMF-fixdate */
/* --------------------------------------------------------------------------- */
PUCHAR imfTimeString(PUCHAR buf)
{
    time_t rawtime;
    struct tm * timeinfo;
    static const UCHAR * dayname   [] = {"Sun","Mon","Tue","Wed","Thu","Fri","Sat"};
    static const UCHAR * monthname [] = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov","Dec"};

    time (&rawtime);
    timeinfo = gmtime (&rawtime);

    sprintf( 
        buf,"%s, %02d %s %4d %02d:%02d:%02d GMT",
        dayname[timeinfo->tm_wday],
        timeinfo->tm_mday,
        monthname[timeinfo->tm_mon],
        timeinfo->tm_year + 1900,
        timeinfo->tm_hour,
        timeinfo->tm_min,
        timeinfo->tm_sec
    );
    return buf;
}                                          
/* --------------------------------------------------------------------------- */
void putHeader (PRESPONSE pResponse)
{
    size_t rc;
    UCHAR  header [1024];
    UCHAR  w1 [256];
    UCHAR  w2 [256];
    UCHAR  w3 [256];
    PUCHAR p = header;
    LONG len;
    UCHAR timeBuffer [128];


    if (!pResponse->firstWrite) return;

    p += sprintf(p ,
        "HTTP/1.1 %d %s\r\n"
        "Date: %s\r\n" // Todo !!! Real timestamp
        "Transfer-Encoding: chunked\r\n"
        "Content-type: %s;charset=%s\r\n"
        "\r\n",
        pResponse->status,
        vc2str(&pResponse->statusText),
        imfTimeString(timeBuffer),
        vc2str(&pResponse->contentType),
        vc2str(&pResponse->charset)
    );

    len = p - header;
    meme2a( header , header , len);
    rc = write(pResponse->pConfig->clientSocket, header , len);
    
    pResponse->firstWrite = false;
             
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
        pRequest->resource.Length = pRequest->queryString.String - pRequest->url.String;
    } else {
        pRequest->resource.Length = pRequest->url.Length;
    }
}
/* --------------------------------------------------------------------------- 
   Produce a key/value list of the request headers
   --------------------------------------------------------------------------- */
static void parseHeaders (PREQUEST pRequest)
{
    char eol [2]  = { 0x0d , 0x0a};
    
    HEADERLIST headerList   [MAXHEADERS];
    PUCHAR headend , begin, end, split;
    SHORT  hIx =0;

    begin =  pRequest->headers.String;
    headend = begin + pRequest->headers.Length; 
    while (begin < headend) {
        for (;*begin == 0x20; begin ++); // Skip blank(s)
        end  = memmem(begin, headend - begin , eol , 2); // Find end of line
        if (end == null) { // end of line not found => end of headers
          end = headend;
        }
        split= memchr(begin, 0x3A, end - begin ); // Split at the : colon
        if (split == null) break;

        // Got the components, now store in the array
        headerList[hIx].key.String = begin;
        headerList[hIx].key.Length = split - begin;
 
        split++;
        for (;*split == 0x20; split++); // Skip blank(s)
        headerList[hIx].value.String = split;
        headerList[hIx].value.Length = end - split;

        // Next iteration
        begin = end + 2; // After the eol mark
        hIx++;
    }
    // Store the header list in the request structure
    pRequest->headerList = malloc((hIx +1) * sizeof(HEADERLIST)); // plus room for the termination zero
    memcpy ( pRequest->headerList , headerList , hIx * sizeof(HEADERLIST));
    memset ( &pRequest->headerList[hIx], 0 , sizeof(HEADERLIST)); 
}
/* --------------------------------------------------------------------------- 
   Return string of header values
   Note - the keys are in ASCII so we have to convert. memicmp only works on EBCDIC 
   --------------------------------------------------------------------------- */
PUCHAR getHeaderValue(PUCHAR  value, PHEADERLIST headerList ,  PUCHAR key)
{
    PHEADERLIST header = headerList;
    UCHAR aKey [256];
    int keyLen = strlen(key);
    for (;;) {
        if (header == null || header->key.Length == 0) {
            *value = '\0';
            return value;
        }

        if (keyLen == header->key.Length) {
            mema2e(aKey , header->key.String , keyLen); // The headers are in ASCII
            if (memicmp (key , aKey , keyLen) == 0) {
                substr(value , header->value.String ,  header->value.Length);
                return value;
            }
        }
        // Get next
        header += 1;
    }
} 
/* --------------------------------------------------------------------------- 
   Parse this: 
   GET / HTTP/1.1██Host: dksrv133:44001██Con
   --------------------------------------------------------------------------- */
BOOL lookForHeaders ( PREQUEST pRequest, PUCHAR buf , ULONG bufLen)
{

    ULONG beforeHeadersLen;
    PUCHAR begin , next;
    char eol [4]  = { 0x0d , 0x0a , 0x0d , 0x0a};
    UCHAR temp [256];
    PUCHAR eoh = memmem ( buf ,bufLen , eol , 4);

    // No end-of-headers in this buffer, the just continue
    if (eoh == NULL)      return false;

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
    PUCHAR buf = malloc (pRequest->contentLength +1); // Add a zero terniation
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
        socketWait (pRequest->pConfig->clientSocket, 60);
        rc = read(pRequest->pConfig->clientSocket , bufwin , end - bufwin);
        if (rc <= 0) {
            return true;
        }
        bufwin += rc;
    }

    return false;
}

/* --------------------------------------------------------------------------- */
static BOOL receiveHeader (PREQUEST pRequest)
{
    PUCHAR buf = malloc (SOCMAXREAD);
    PUCHAR bufWin = buf;
    ULONG  bufLen = 0;
    LONG   rc;
    BOOL   isLookingForHeaders = true;

    // Load the complete request data
    for(;;) {
        socketWait (pRequest->pConfig->clientSocket, 10);
        rc = read(pRequest->pConfig->clientSocket , bufWin , SOCMAXREAD - bufLen);
        if (rc <= 0) {
            free(buf);
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
                return false; // TODO - Now only GET - no payload 
            }
        }
    }
}

/* --------------------------------------------------------------------------- *\
    Handle :
    il_addRoute  (config : myServives: IL_ANY : '^/services/' : '(application/json)|(text/json)');
\* --------------------------------------------------------------------------- */
void runServletByRouting (PREQUEST pRequest, PRESPONSE pResponse)
{
    int rc;
    UCHAR msgbuf[100];
    PSLIST pRouts;
	PSLISTNODE pRouteNode;
    PUCHAR resource = malloc(pRequest->resource.Length +1);

    if (pRequest->pConfig->router == NULL) return;

    // get the ebcdic version of the resource
    mema2e(resource ,  pRequest->resource.String , pRequest->resource.Length); // The headers are in ASCII
    resource[pRequest->resource.Length] = '\0';  // Need it as a string

    pRouts    =  pRequest->pConfig->router;
	for (pRouteNode = pRouts->pHead; pRouteNode ; pRouteNode = pRouteNode->pNext) {
    
        PROUTING pRouting = pRouteNode->payloadData;

        // Execute regular expression
        // If non is given then it is a match as well. That counts for a "match all"
        rc = pRouting->routeReg == NULL ? 0 :regexec(pRouting->routeReg, resource, 0, NULL, 0);
        if (rc == 0) { // Match found
            if  (ON == pRouting->servlet ( pRequest, pResponse)) {
                free (resource);
                return;
            };
        }
    }

    joblog( "No routing found for request:  %s " , resource);
    free (resource);

}
/* --------------------------------------------------------------------------- */
static void * serverThread (PINSTANCE pInstance)
{
    REQUEST  request;
    RESPONSE response;

    while (pInstance->config.clientSocket > 0) {
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
        if (pInstance->servlet) {
            pInstance->servlet (&request , &response);
        } else {
            runServletByRouting (&request , &response);
        }
        putChunkEnd (&response);

        // Clean up this transaction 
        if (request.headerList) {
            free(request.headerList);
        } 
        if (request.completeHeader.String) {
            free(request.completeHeader.String);
        } 
        if (request.content.String) {
            free(request.content.String);
        }
    }
    close(response.pConfig->clientSocket);
    free(pInstance);
    pthread_exit(NULL);
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
        joblog( "socket error: %d - %s" , (int) errcde, strerror((int) errcde));
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
        joblog( "setsockop error: %d - %s" ,(int) errcde, strerror((int) errcde));
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
      joblog( "bind error : %d - %s" ,(int) errcde, strerror((int) errcde));
      close(pConfig->mainSocket);
        return false;
   }

    // Up to XXX clients can be queued 
    rc = listen(pConfig->mainSocket, SOMAXCONN);
    if (rc < 0)  {
        errcde = montcp(errno);
        close(pConfig->mainSocket);
        joblog( "Listen error: %d - %s" ,(int) errcde, strerror((int) errcde));
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
        joblog ("select() failed :%s\r\n", strerror(errno));
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
/* ------------------------------------------------------------- */
void il_listen (PCONFIG pConfig, SERVLET servlet)
{
    PNPMPARMLISTADDRP pParms = _NPMPARMLISTADDR();
    BOOL     resetSocket = TRUE;

    setMaxSockets();
    pConfig->a2e = XlateXdOpen (1208, 0);
    pConfig->e2a = XlateXdOpen (0 , 1208);

    // tInitSSL(pConfig);

    // Infinit loop
    for (;;) {
        pthread_t  pServerThread;
        PINSTANCE pInstance;
        int clientSocket;
        struct sockaddr_in serveraddr, client; 
        int clientSize;
        int errcde;
        int rc;

        // Initialize connection
        if (resetSocket) {
            if ( ! getSocket(pConfig) ) {
                sleep(5);
                continue;
            }
            resetSocket = false;
        }


        // accept() the incoming connection request.
        clientSize = sizeof(client);
        clientSocket = accept(pConfig->mainSocket,  (struct sockaddr *)   &client, &clientSize);

        if (clientSocket < 0 ) {
            errcde = montcp(errno);
            resetSocket = TRUE;
            close(pConfig->mainSocket);
            joblog( "Accept error: %d - %s" ,(int) errcde, strerror((int) errcde));
            continue;
        }

        // virker ikke:    sprintf(RemoteIp   , "%s" , inet_ntoa(client.sin_addr));
        pConfig->rmtTcpIp = client.sin_addr.s_addr;
        FormatIp(pConfig->rmtHost , client.sin_addr.s_addr);
        pConfig->rmtPort = client.sin_port;

        // Setup arguments to pass
        pInstance = malloc(sizeof(INSTANCE));
        memcpy(&pInstance->config , pConfig , sizeof(CONFIG));
        pInstance->config.clientSocket   = clientSocket;
        pInstance->servlet = pParms->OpDescList->NbrOfParms >= 2 ? servlet : NULL;

        rc = pthread_create(&pServerThread , NULL, serverThread , pInstance);
        if (rc) {
            joblog("Thread not started");
            exit(0);
        }

    }
}

