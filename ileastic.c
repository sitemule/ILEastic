/* ------------------------------------------------------------- */
/* Program . . . : Node.RPG - main interface                     */
/* Date  . . . . : 02.06.2018                                    */
/* Design  . . . : Niels Liisberg                                */
/* Function  . . : Main Socket server                            */
/*                                                               */
/* By     Date       PTF     Description                         */
/* NL     02.06.2018         New program                         */
/* ------------------------------------------------------------- */
#define _MULTI_THREADED

// max number of concurrent users
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
#include "sndpgmmsg.h"
#include "strUtil.h"
#include "e2aa2e.h"


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
void putChunk (PRESPONSE pResponse, PUCHAR buf, int len)         
{        
    int rc;                                                 
    LONG   lenleni;                                        
    PUCHAR tempBuf = malloc ( len + 16);                   
    PUCHAR wrkBuf = tempBuf;                               
                                                            
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
void putHeader (PRESPONSE pResponse)
{
    size_t rc;
    UCHAR  header [1024];
    UCHAR  w1 [256];
    UCHAR  w2 [256];
    UCHAR  w3 [256];
    PUCHAR p = header;
    LONG len;

    if (!pResponse->firstWrite) return;

    p += sprintf(p ,
        "HTTP/1.1 %d %s\r\n"
        "Date: Tue, 05 Jun 2018 22:45:51 GMT\r\n"
        "Transfer-Encoding: chunked\r\n"
        "Content-type: %s;charset=%s\r\n"
        "\r\n",
        pResponse->status,
        strrighttrimncpy(w1,pResponse->statusText, sizeof(pResponse->statusText)),
        strrighttrimncpy(w2,pResponse->contentType, sizeof(pResponse->contentType)),
        strrighttrimncpy(w3,pResponse->charset, sizeof(pResponse->charset))
    );

    len = p - header;
    meme2a( header , header , len);
    rc = write(pResponse->pConfig->clientSocket, header , len);
    
    pResponse->firstWrite = false;
             
}
/* --------------------------------------------------------------------------- */
static void * serverThread (PINSTANCE pInstance)
{
    REQUEST  request;
    RESPONSE response;

    memset(&request  , 0, sizeof(REQUEST));
    memset(&response , 0, sizeof(RESPONSE));
    request.pConfig = &pInstance->config;
    response.pConfig = &pInstance->config;

    while (pInstance->config.clientSocket > 0) {
        response.firstWrite = true;
        response.status = 200;
        strcpy(response.contentType , "text/html");
        strcpy(response.charset     , "UTF-8");
        strcpy(response.statusText  , "OK");
        pInstance->servlet (&request , &response);
        putChunkEnd (&response);
        // for now !! TODO 
        close(response.pConfig->clientSocket);
        response.pConfig->clientSocket = 0;

    }
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
    strtrimncpy(interface , pConfig->interface, sizeof(pConfig->interface));

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

    // Up to 512 clients can be queued 
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
void node_listen (PCONFIG pConfig, SERVLET servlet)
{
    BOOL     resetSocket = TRUE;

    setMaxSockets();

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
        pInstance->servlet = servlet;
        rc = pthread_create(&pServerThread , NULL, serverThread , pInstance);
        if (rc) {
            joblog("Thread not started");
            exit(0);
        }

    }
}

