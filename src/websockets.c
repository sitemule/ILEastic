
/* SYSIFCOPT(*IFSIO) TERASPACE(*YES *NOTSIFC) STGMDL(*SNGLVL)    */
/* ------------------------------------------------------------- */
/* Program . . . : websockets                                    */
/* Design  . . . : Niels Liisberg                                */
/* Function  . . : SSL/ socket wrapper                           */
/*                                                               */
/* By     Date       Task    Description                         */
/* NL     15.05.2005 0000000 New program                         */
/* NL     25.02.2007     510 Ignore namespace for WS parameters  */
/* ------------------------------------------------------------- */
/* SYSIFCOPT(*IFSIO) TERASPACE(*YES *NOTSIFC) STGMDL(*SNGLVL)    */
/* SYSIFCOPT(*IFSIO) TERASPACE(*YES *NOTSIFC) STGMDL(*SNGLVL)    */
/* ------------------------------------------------------------- */
/* SYSIFCOPT(*IFSIO) OPTION(*EXPMAC *SHOWINC)                    */
/* Program . . . : SVC200                                        */
/* Date  . . . . : 01.04.2019                                    */
/* Design  . . . : Niels Liisberg                                */
/* Function  . . : Web Sockets                                   */
/*                                                               */
/*By    Date      Task   Description                         */
/* NL     01.04.2019         New program                         */
/* ------------------------------------------------------------- */
#define _MULTI_THREADED

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <qsysinc/h/QC3HASH>
#include "ostypes.h"
#include "varchar.h"
#include "utl100.h"
#include "ServerCall.h"

// Implementation at:
// https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API/Writing_WebSocket_servers

typedef _Packed struct  _WEBSOCKETFRAME {
   int    fin            : 1;
   int    fsv1           : 1;
   int    fsv2           : 1;
   int    fsv3           : 1;
   int    opcode         : 4;
   int    mask           : 1;
   int    payloadlen     : 7;
} WEBSOCKETFRAME, * PWEBSOCKETFRAME;

/* ------------------------------------------------------------- */
void webSocketWrite(PHTTP pHttp, PUCHAR buf , ULONG len , BOOL binary)
{

   WEBSOCKETFRAME wsframe;
   USHORT   len16;
   UINT64   len64;

   memset ( &wsframe , 0 , sizeof(wsframe));
   wsframe.fin = true;
   wsframe.opcode = binary ? 2:1; // 0=continue, 1=text, 2=Bin

   if ( len <= 125) {
      wsframe.payloadlen = len;
      WriteSock(pHttp, (PUCHAR) &wsframe , sizeof(wsframe));
   } else if ( len <= 65535) {
      wsframe.payloadlen = 126;
      WriteSock(pHttp, (PUCHAR) &wsframe , sizeof(wsframe));
      len16 = len;
      WriteSock(pHttp, (PUCHAR) &len16 , sizeof(len16));
   } else  {
      wsframe.payloadlen = 127;
      WriteSock(pHttp, (PUCHAR) &wsframe , sizeof(wsframe));
      len64 = len;
      WriteSock(pHttp, (PUCHAR) &len64 , sizeof(len64));
   }

   WriteSock(pHttp, buf, len);
}
/* ------------------------------------------------------------- */
LONG webSocketRead(PHTTP pHttp, PUCHAR buf, LONG size, LONG timeout)
{
   WEBSOCKETFRAME wsframe;
   LONG     len;
   USHORT   len16;
   UINT64   len64;
   LONG     tempbuflen;
   LONG     buflen = 0;
   PUCHAR   ptempbuf = buf;
   LONG     i;
   UCHAR    mask [4];

   pHttp->svr00r.SVCOTO = timeout < 1 ? 1 :timeout;

   // TODO !! handle size and pHttp->InContentsLen

   do {
      len = tGetBinBlock(pHttp, (PUCHAR) &wsframe  , sizeof(wsframe));
      if ( len <= 0) return len;
      if (wsframe.payloadlen <= 125) {
         tempbuflen = wsframe.payloadlen;
      } else if (wsframe.payloadlen == 126) {
         len = tGetBinBlock(pHttp, (PUCHAR) &len16  , sizeof(len16));
         if ( len <= 0) return len;
         tempbuflen = len16;
      } else if (wsframe.payloadlen == 127) {
         len = tGetBinBlock(pHttp, (PUCHAR) &len64  , sizeof(len64));
         if ( len <= 0) return len;
         tempbuflen = len64;
      }
      if ( wsframe.mask) {
         len = tGetBinBlock(pHttp, mask , sizeof(mask));
         if ( len <= 0) return len;
      }
      len  = tGetBinBlock(pHttp, ptempbuf , tempbuflen);
      if ( len <= 0) return len;
      ptempbuf += len;
      buflen   += len;

   } while ( ! wsframe.fin);

   // Do unmasking - mask loaded seperatly
   for (i=0,ptempbuf=buf; i< buflen; i++) {
      *(ptempbuf++) ^= mask[i % 4];
   }
   return buflen;
}
/* ------------------------------------------------------------- */
/* TEST IMPLEMENTATION  !!!!
BOOL webSocketHandler (PHTTP pHttp)
{
   UCHAR    buf[32000];
   LONG     buflen;

   pHttp->svr00r.SVCOTO   = 1;

   for(;;) {

      buflen = webSocketRead(pHttp, buf , sizeof(buf) , 10);
      if (buflen < 0) return true;		
      if (buflen > 0) {		

         #pragma convert(1252)
         PUCHAR text = "OK";
         #pragma convert(0)

         webSocketWrite(pHttp, text , strlen(text), false);
      }
   }
}
*************/
/* ------------------------------------------------------------- */
BOOL webSocketHandshake (PHTTP pHttp)
{
   UCHAR temp [256];
   UCHAR cleanKey  [256];
   ULONG cleanKeyLen;
   UCHAR hash [20];
   static BOOL first =1;
   static UCHAR algContext [8];
   UCHAR challenge  [256];
   ULONG challengeLen;
   APIRTN apiRtn;
   UCHAR algDesc [8];
   UCHAR anyCSP = '0';
   int hashCleanKeyLen;

   // Initialize
   apiRtn.ApiSize = sizeof(apiRtn);
   memset( algDesc , 0 , sizeof(algDesc));
   algDesc [3] = Qc3_SHA1;


   // Pull the key out of the http header, convert it to ascii and convert from base 64 to binary
   // note: the base64 key mys NOT be decoded before conatenation with the GUID
   tRequestParm(pHttp->InHead , "Sec-WebSocket-Key:", cleanKey);
   cleanKeyLen =  strlen(cleanKey);
   e2a(cleanKey , cleanKey , cleanKeyLen);

   // append the GUID in ASCII
   #pragma convert(1252)
   strcat (cleanKey , "258EAFA5-E914-47DA-95CA-C5AB0DC85B11");
   #pragma convert(0)

   hashCleanKeyLen = cleanKeyLen = strlen(cleanKey);

   Qc3CalculateHash (
        cleanKey           , /* Input data                   */
        &hashCleanKeyLen   , /* Length of input data         */
        "DATA0100"         , /* Input data format name       */
        algDesc            , /* Algorithm description        */
        "ALGD0500"         , /* Algorithm desc format name   */
        &anyCSP            , /* Crypto Service Provider      */
        NULL               , /* Crypto Device Name           */
        hash               , /* Hash                         */
        &apiRtn              /* Error Code                   */
   );

   base64encode ( challenge , &challengeLen , hash , sizeof(hash));
   challenge[challengeLen] =0;
   a2e(challenge , challenge , challengeLen);

   pHttp->OutBufLen = sprintf(pHttp->OutBuf ,
      "HTTP/1.1 101 Switching Protocols\r\n"
      "Upgrade: websocket\r\n"
      "Connection: Upgrade\r\n"
      "Sec-WebSocket-Accept: %s\r\n\r\n",
      challenge
   );
   e2a(pHttp->OutBuf , pHttp->OutBuf , pHttp->OutBufLen);
   tPutBuf(pHttp , pHttp->OutBufLen, pHttp->OutBuf, PUT_HEAD);
   return true;
}
/* ------------------------------------------------------------- */
/* ------------------------------------------------------------- */
WEBSOCKETHANDLER webSocketLoadHandler( PHTTP pHttp)
{

   UCHAR pgmName  [256];
   UCHAR procName [256];
   WEBSOCKETHANDLER webSocketHandler;

   subword(pgmName , pHttp->FilePath ,0,"/?#" );
   subword(procName, pHttp->FilePath ,1,"/?#" );
   webSocketHandler = (WEBSOCKETHANDLER) loadServlet ("*LIBL     ", pgmName , procName);
   return webSocketHandler;
}
/* ------------------------------------------------------------- */
BOOL webSockets (PHTTP pHttp)
{
   UCHAR temp [256];
   WEBSOCKETHANDLER webSocketHandler;


   // if not a websocket request - then simply return
   if (! BeginsWith(tRequestParm(pHttp->InHead , "Upgrade:", temp) , "websocket")) {
      return false;
   }
   pHttp->connectionClose = false;
   webSocketHandshake(pHttp);
   webSocketHandler = webSocketLoadHandler(pHttp);
   if (webSocketHandler) {
      webSocketHandler( pHttp );
   }
   return true;
}
/* ------------------------------------------------------------- */
// RPG wrappers
/* ------------------------------------------------------------- */
LGL socket_connected (PHTTP pHttp)
{
    return  pHttp->SocketError ? OFF:ON;
}
/* ------------------------------------------------------------- */
LGL socket_read (PHTTP pHttp, PVARCHAR buf, LONG size, LONG timeout)
{
    PUCHAR tempbuf = malloc(size);
    LONG  templen  = webSocketRead(pHttp, tempbuf , size , timeout);
    templen = templen < 0 ? 0: templen;
    templen = XlateXdBuf(&pHttp->a2e_1208_cd , buf->String , tempbuf ,  templen);
    buf->Length = templen < 0 ? 0: templen;
    free (tempbuf);
    return  pHttp->SocketError ? OFF:ON;
}
/* ------------------------------------------------------------- */
LGL socket_readBin (PHTTP pHttp, PVARCHAR buf , LONG size, LONG timeout)
{
    LONG  buflen = webSocketRead(pHttp, buf->String , size, timeout);
    buf->Length = buflen < 0 ? 0: buflen;
    return  pHttp->SocketError ? OFF:ON;
}
/* ------------------------------------------------------------- */
LGL socket_writeBin (PHTTP pHttp, PVARCHAR buf)
{
    webSocketWrite(pHttp, buf->String , buf->Length, true);
    return  pHttp->SocketError ? OFF:ON;
}
/* ------------------------------------------------------------- */
LGL socket_write  (PHTTP pHttp, PVARCHAR buf)
{
    PUCHAR tempbuf = malloc (buf->Length * 2);  // When all is ÆØÅ then double size
    LONG  templen = XlateXdBuf(&pHttp->e2a_1208_cd , tempbuf , buf->String , buf->Length);
    templen = templen < 0 ? 0 : templen;
    webSocketWrite(pHttp, tempbuf , templen , false);

    free (tempbuf);
    return  pHttp->SocketError ? OFF:ON;
} 