/* SYSIFCOPT(*IFSIO) TERASPACE(*YES *NOTSIFC) STGMDL(*SNGLVL)    */
/* ------------------------------------------------------------- */
/* Program . . . : SOCKETS                                       */
/* Design  . . . : Niels Liisberg                                */
/* Function  . . : SSL/ socket wrapper                           */
/*                                                               */
/* By     Date       Task    Description                         */
/* NL     15.05.2005 0000000 New program                         */
/* NL     25.02.2007     510 Ignore namespace for WS parameters  */
/* ------------------------------------------------------------- */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <fcntl.h>
#include <xxdtaa.h>
#include <gskssl.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>
// #include <ssl.h>
#include <errno.h>
#include <qsyrgap1.h>


/* own standart includes */
#include "ostypes.h"
#include "apierr.h"
#include "varchar.h"
#include "utl100.h"
#include "MinMax.h"
#include "parms.h"
#include "sockets.h"
#include "sndpgmmsg.h"
#include "e2aa2e.h"
#include "xlate.h"


/* --------------------------------------------------------------------------- */
PSOCKETS sockets_new(void)
{
   // Get mem and set to zero
   PSOCKETS ps = calloc(1,sizeof(SOCKETS));
   return ps;
}

/* --------------------------------------------------------------------------- */
void  sockets_free(PSOCKETS ps)
{
   sockets_close(ps);
   free(ps);
}
/* --------------------------------------------------------------------------- *\
   Define if SSL is used
\* --------------------------------------------------------------------------- */
void sockets_setSSL(PSOCKETS ps,BOOL asSSL, PUCHAR certificateFile , PUCHAR keyringPassword)
{
    strcpy(ps->certificateFile, certificateFile);
    strcpy(ps->keyringPassword, keyringPassword);
    ps->asSSL = asSSL;
}
/* --------------------------------------------------------------------------- *\
   Open the trace file / default file if requestet on server
\* --------------------------------------------------------------------------- */
void sockets_setTrace(PSOCKETS ps,PUCHAR tracefilename)
{
   if (tracefilename && *tracefilename > ' ') {
      strcpy(ps->tracefilename, tracefilename);
      ps->trace = fopen(tracefilename ,"ab,codepage=1252");
      sockets_putTrace(ps, "\r\n---  Start of Communcation ---\r\n");
   } else {
      strcpy(ps->tracefilename,"");
      ps->trace = NULL;
   }
}
/* --------------------------------------------------------------------------- *\
  wrapper for the message and trace to  the message log
\* --------------------------------------------------------------------------- */
void sockets_putTrace(PSOCKETS ps,PUCHAR Ctlstr, ...)
{
   va_list arg_ptr;
   UCHAR   temp[1024];
   UCHAR   temp2[1024];
   LONG    len;
   SHORT   l,i;
   if (ps->trace == NULL) return;

   va_start(arg_ptr, Ctlstr);
   len = vsprintf( temp , Ctlstr, arg_ptr);
   va_end(arg_ptr);
   e2aMem(temp2 , temp , len);
   fputs (temp2 , ps->trace);
}

/* --------------------------------------------------------------------------- *\
  wrapper for the message and trace to  the message log
\* --------------------------------------------------------------------------- */
static void xsetmsg(PSOCKETS ps,PUCHAR msgid , PUCHAR Ctlstr, ...)
{
   va_list arg_ptr;
   UCHAR   temp[1024];
   LONG    len;
   SHORT   l,i;
   PUCHAR  msgf = BeginsWith(msgid , "CPF") ? QCPFMSG : USRMSG ;
   va_start(arg_ptr, Ctlstr);
   len = vsprintf( temp , Ctlstr, arg_ptr);
   va_end(arg_ptr);

   sockets_putTrace(ps ,"%s" , temp);
   //strcpy (ps->msgid  , msgid);
   //strcpy (ps->msgtxt  , temp);
   sndpgmmsg (msgid, msgf , DIAG  , temp);

}
/* --------------------------------------------------------------------------- *\
   Clean up
\* --------------------------------------------------------------------------- */
static void sockets_close(PSOCKETS ps)
{
  if (ps->trace) {
    sockets_putTrace(ps, "\r\n---  End of Communcation ---\r\n");
    fclose(ps->trace);
    ps->trace = NULL;
  }
  // disable SSL support for the socket
  if (ps->my_session_handle != NULL) {
    gsk_secure_soc_close(&ps->my_session_handle);
    ps->my_session_handle = NULL;
  }

  // disable the SSL environment
  if (ps->my_env_handle != NULL) {
    gsk_environment_close(&ps->my_env_handle);
    ps->my_env_handle = NULL;
  }

  // close the connection
  if (ps->hasSocket) {
    close(ps->socket);
    ps->hasSocket = false;
  }
  ps->isInitialized = FALSE;
}

/* --------------------------------------------------------------------------- */
static void sockets_setSSLmsg(PSOCKETS ps,int rc, PUCHAR txt)
{
   xsetmsg(ps,"CPF9898", "%s: %d: %s, %s", txt, rc, gsk_strerror(rc), strerror(errno));
}
/* --------------------------------------------------------------------------- */
static int sockets_sslCallBack(PUCHAR certChain, int valStatus)
{
  // sockets_putTrace( "\nCallBack: %s\n", gsk_strerror(valStatus));
  return GSK_OK;
}
// ----------------------------------------------------------------------------------------
static PUCHAR addKeyVal(PUCHAR pVarRecCount, PUCHAR pVarRec, LONG key  , LONG len , PUCHAR value)
{
  LONG totLen;
  PUCHAR pNext;

  (* (PLONG) pVarRecCount) ++;

  // Ajust for 4-byte allignment
  totLen = (sizeof(LONG) * 3) + len;
  totLen += totLen % sizeof(LONG);
  pNext = pVarRec + totLen;

  * ((PLONG) pVarRec) = totLen;
  pVarRec += sizeof(LONG);

  * ((PLONG) pVarRec) = key;
  pVarRec += sizeof(LONG);

  * ((PLONG) pVarRec) = len;
  pVarRec += sizeof(LONG);

  memcpy(pVarRec , value , len);

  return ( pNext);
}

// ----------------------------------------------------------------------------------------
static BOOL set_attr (PSOCKETS ps, gsk_handle hndl, int attr , int value, PUCHAR msg)
{
   int rc;
   errno=0;

   rc  = gsk_attribute_set_numeric_value(hndl, attr, value);
   if (rc != GSK_OK) {
      sockets_setSSLmsg(ps, rc, msg);
      sockets_close(ps);
      return true; // true fails
   } else {
      return false;
   }
}
// ----------------------------------------------------------------------------------------
BOOL sockets_connect(PSOCKETS ps, PUCHAR ServerIP, LONG ServerPort, SHORT TimeOut)
{
   LONG   rc;
   struct sockaddr_in serveraddr;
   struct hostent * hostp;
   struct sockaddr peeraddr;
   PUCHAR appId = "ICEBREAK_SECURE_CLIENT";
   int    appIdLen = strlen(appId);

   ps->timeOut = TimeOut;

   if (ps->asSSL) {
     if (ps->isInitialized == FALSE) {
       PUCHAR keyringPassword;

       // open a gsk environment
       errno = 0;
       rc = gsk_environment_open(&ps->my_env_handle);
       if (rc != GSK_OK) {
         sockets_setSSLmsg(ps, rc, "gsk_environment_open()");
         sockets_close(ps);
         return FALSE;
       }


       // set the Application ID to use
       /*
       errno = 0;
       rc = gsk_attribute_set_buffer(ps->my_env_handle,
                                     GSK_OS400_APPLICATION_ID,
                                     appId,
                                     appIdLen);
       if (rc != GSK_OK) {
         sockets_setSSLmsg(ps, rc, "set the Application ID");
         sockets_close(ps);
         return FALSE;
       }
       */

       // set the validation callback
       ps->valCallBack.validation_callback = sockets_sslCallBack;
       ps->valCallBack.validateRequired    = GSK_NO_VALIDATION;
       ps->valCallBack.certificateNeeded   = GSK_END_ENTITY_CERTIFICATE;

       errno = 0;
       rc = gsk_attribute_set_callback(ps->my_env_handle,
                                       GSK_CERT_VALIDATION_CALLBACK,
                                       &ps->valCallBack);
       if (rc != GSK_OK) {
         sockets_setSSLmsg(ps, rc, "set the validation callback");
         sockets_close(ps);
         return FALSE;
       }


       // set the Keyring file path
       errno = 0;
       rc = gsk_attribute_set_buffer(ps->my_env_handle,
                                     GSK_KEYRING_FILE,
                                     ps->certificateFile,
                                     strlen(ps->certificateFile));
       if (rc != GSK_OK) {
         sockets_setSSLmsg(ps,rc, "set the Keyring file");
         sockets_close(ps);
         return FALSE;
       }


       // set Password to the keyring
       errno = 0;
       rc = gsk_attribute_set_buffer(ps->my_env_handle,
                                     GSK_KEYRING_PW,
                                     ps->keyringPassword,
                                     strlen(ps->keyringPassword));
       if (rc != GSK_OK) {
         sockets_setSSLmsg(ps,rc, "set Password to the keyring");
         sockets_close(ps);
         return FALSE;
       }

       // If one fails - then return  !!
       if (set_attr (ps,ps->my_env_handle, GSK_HANDSHAKE_TIMEOUT , 30             ,"Set GSK_HANDSHAKE_TIMEOUT  error")
       ||  set_attr (ps,ps->my_env_handle, GSK_OS400_READ_TIMEOUT, TimeOut * 1000L,"Set GSK_OS400_READ_TIMEOUT error")
       ||  set_attr (ps,ps->my_env_handle, GSK_V2_SESSION_TIMEOUT, 60             ,"Set GSK_V2_SESSION_TIMEOUT error")
       ||  set_attr (ps,ps->my_env_handle, GSK_V3_SESSION_TIMEOUT, 60             ,"Set GSK_V3_SESSION_TIMEOUT error")){
          return FALSE;
       }

       // set this side as the client (this is the default)
       errno = 0;
       rc = gsk_attribute_set_enum(ps->my_env_handle,
                                   GSK_SESSION_TYPE,
                                   GSK_CLIENT_SESSION);
       if (rc != GSK_OK) {
         sockets_setSSLmsg(ps,rc, "set this side as the client");
         sockets_close(ps);
         return FALSE;
       }


       // set auth-passthru
       errno = 0;
       rc = gsk_attribute_set_enum(ps->my_env_handle,
                                   GSK_CLIENT_AUTH_TYPE,
                                   GSK_CLIENT_AUTH_PASSTHRU);

       if (rc != GSK_OK) {
         sockets_setSSLmsg(ps,rc, "set auth-passthru");
         sockets_close(ps);
         return FALSE;
       }

       // Initialize the secure environment
       rc = gsk_environment_init(ps->my_env_handle);

       // Not registeret yet - do it
       if (rc == GSK_AS400_ERROR_NOT_REGISTERED) {
         UCHAR  varRec [512];
         PLONG  pVarRecCount = (PLONG) varRec;
         PUCHAR pVarRec = varRec + sizeof(LONG);
         APIERR apiRtn;
         apiRtn.size = sizeof(APIERR);

         memset(varRec , 0 , sizeof(varRec));
         pVarRec = addKeyVal(varRec, pVarRec, 2 , 50 , "IceBreak Secure Client                            ");
         pVarRec = addKeyVal(varRec, pVarRec, 8 , 1  , "2"); // Client type
         pVarRec = addKeyVal(varRec, pVarRec, 10, 1  , "0"); // Client authentication supported. 1=application support
         pVarRec = addKeyVal(varRec, pVarRec, 4 , 1  , "0"); // Limit CA certificates trusted

         QsyRegisterAppForCertUse (
               appId,
               &appIdLen,
               (Qsy_App_Controls_T *) varRec,
               &apiRtn);

         if (apiRtn.avail !=0) {
           sockets_setSSLmsg(ps,rc, "Register App For Cert Use");
           sockets_close(ps);
           return FALSE;
         }

         // re-initialize the secure environment */
         errno = 0;
         rc = gsk_environment_init(ps->my_env_handle);
         if (rc != GSK_OK) {
           sockets_setSSLmsg(ps,rc, "gsk_environment_init");
           sockets_close(ps);
           return FALSE;
         }
       }

       // So far ? - We are ready
       ps->isInitialized = TRUE;  // done - we are initialized

     } else {
       sleep(1);  // Detach the process due to bugg in SSL
     }
   }

   // Get a socket descriptor
   ps->socket = socket(AF_INET, SOCK_STREAM, 0);

   if (ps->socket == JX_INVALID_SOCKET)  {
      xsetmsg(ps,"CPF9898" ,  "Invalid socket %s" , strerror(errno));
      return FALSE;
   }

   ps->hasSocket = true;

   // Connect to an address
   memset(&serveraddr, 0x00, sizeof(struct sockaddr_in));
   serveraddr.sin_family        = AF_INET;
   serveraddr.sin_port          = htons(ServerPort);

   // If a valid ip adress is given (only digitd and dots)
   if (strspn (ServerIP , "0123456789.") == strlen( ServerIP)) {
      serveraddr.sin_addr.s_addr   = inet_addr( ServerIP);
   } else {

     // get host address
     hostp = gethostbyname(ServerIP);
     if (hostp == (struct hostent *)NULL) {
        sockets_close(ps);
        xsetmsg(ps,"CPF9898" ,  "Invalid host <%s> Error: %s", ServerIP , strerror(errno));
        return FALSE;
     }
     memcpy(&serveraddr.sin_addr,  hostp->h_addr, sizeof(serveraddr.sin_addr));
   }

   rc = connect(ps->socket , (struct sockaddr *)&serveraddr , sizeof(serveraddr));
   if (rc < 0) {
      xsetmsg(ps,"CPF9898" ,  "Connection failed: %s %s" , ServerIP, strerror(errno));
      sockets_close(ps);
      return FALSE;
   }

   if (ps->asSSL) {
     // open a secure session
     errno = 0;
     rc = gsk_secure_soc_open(ps->my_env_handle, &ps->my_session_handle);
     if (rc != GSK_OK) {
       sockets_setSSLmsg(ps,rc, "gsk_secure_soc_open");
       sockets_close(ps);
       return FALSE;
     }

     if (set_attr (ps, ps->my_session_handle, GSK_FD , ps->socket
        , "Set GSK_FD associate socket with the secure session")) {
        return FALSE;
     }

     // initiate the SSL handshake
     errno = 0;
     rc = gsk_secure_soc_init(ps->my_session_handle);
     if (rc != GSK_OK) {
       sockets_setSSLmsg(ps,rc, "initiate the SSL handshake");
       sockets_close(ps);
       return FALSE;
     }
   }

   /*
   rc = getpeername (ps->socket , &peeraddr , &peeraddrlen) ;
   if (rc < 0) {
      sndpgmmsg ("CPF9898" ,INFO , "get peer name failed: %s" , strerror(errno));
   }
   */
   return TRUE;
}
/* --------------------------------------------------------------------------- *\
   SockSend puts data to the socket port and test for errors
\* --------------------------------------------------------------------------- */
LONG sockets_send (PSOCKETS ps,PUCHAR Buf, LONG Len)
{
   LONG rc;
   int error;
   int errlen = sizeof(error);
   int amtWritten = 0;

   // Nothing to send?
   if (Len == 0) return(TRUE);

   if (ps->trace) {
     fwrite(Buf , 1 , Len , ps->trace);
   }

// rc = send (ps->socket, Buf , Len ,0);
// rc = SSL_Write(pSsl, Buf , Len);

   if (ps->asSSL) {
     amtWritten = 0;
     rc = gsk_secure_soc_write(ps->my_session_handle, Buf, Len, &amtWritten);
     if (rc != GSK_OK || amtWritten != Len) {
       sockets_setSSLmsg(ps,rc, "gsk_secure_soc_write");
       sockets_close(ps);
       return -1;
     }
   } else {
     errno = 0;
     rc = send (ps->socket, Buf , Len ,0);
     if (rc != Len) {

       // Get the error number.
       rc = getsockopt(ps->socket, SOL_SOCKET, SO_ERROR, (PUCHAR) &error, &errlen);
       if (rc == 0) {
          errno = error;
       }
       xsetmsg(ps,"CPF9898" ,"Send failed: %s" , strerror(errno));
       sockets_close(ps);
       return -1 ;
     }
   }

   return Len;
}
/* --------------------------------------------------------------------------- *\
\* --------------------------------------------------------------------------- */
LONG sockets_receive (PSOCKETS ps, PUCHAR Buf, LONG Len, SHORT TimeOut)
{
   int rc;
   int error;
   int errlen = sizeof(error);
   struct fd_set read_fd;
   struct timeval timeout;
   int amtRead = 0;

   Buf[0] = '\0';

   // read() from client
   // rc = SSL_Read(pSsl, Buf , Len);

   // receive a message from the client using the secure session
   if (ps->asSSL) {

     rc = gsk_secure_soc_read(ps->my_session_handle, Buf, Len, &amtRead);

     /* Not cant do!!
     if (rc != GSK_OK && ! HttpHeader.Chunked &&  HttpHeader.ContentLength ==  0 && rcvTotalLen > 0) {
        return 0; // Fix for Apache Cyote
     }
     */
     if (rc == GSK_OS400_ERROR_TIMED_OUT) {  // Timeout
       xsetmsg(ps,"CPF9898" ,  "Timeout");
       sockets_close(ps);
       return -2;
     }

     if (rc != GSK_OK ) {
       sockets_setSSLmsg(ps,rc, "gsk_secure_soc_read");
       sockets_close(ps);
       return -1;
     }

   } else {
     // Set select timeout
     timeout.tv_sec  = TimeOut;
     timeout.tv_usec = 0;

     // Wait for up to xx seconds on
     // select() for data to be read.
     FD_ZERO(&read_fd);
     FD_SET(ps->socket,&read_fd);

     rc = select(ps->socket +1, &read_fd ,NULL,NULL,&timeout);
     if (rc < 0) {

     /* Get the error number. */
        rc = getsockopt(ps->socket, SOL_SOCKET, SO_ERROR, (PUCHAR) &error, &errlen);
        if (rc == 0) {
           errno = error;
        }
        xsetmsg(ps,"CPF9898" ,  "Socket selcet error : %s" , strerror(errno));
        sockets_close(ps);
        return(-1);
     } else if (rc == 0) {
        xsetmsg(ps,"CPF9898" , "Empty data");
        sockets_close(ps);
        return(-2);
     }
     rc = read(ps->socket, Buf, Len );
     if (rc < 0) {  // error
        xsetmsg(ps,"CPF9898" ,  "Socket read error: %s" , strerror(errno));
        sockets_close(ps);
        return -1;

     } else if (rc == 0) {  // Timeout
        xsetmsg(ps,"CPF9898" ,  "Timeout");
        sockets_close(ps);
        return -2;
     }
     amtRead = rc;
   }

   Buf[amtRead] = '\0';

   if (ps->trace) {
     fwrite(Buf , 1 , amtRead , ps->trace);
   }
   return (amtRead); /* The returned lenght */
}
/* -------------------------------------------------------------------------- */
LONG sockets_receiveXlate (PSOCKETS ps, PUCHAR Buf, LONG Len, SHORT TimeOut)
{
   LONG rc = sockets_receive (ps, Buf, Len, TimeOut);
   if (rc > 0) {
      a2eMem (Buf , Buf , rc);
   }
   return rc;
}

/* -------------------------------------------------------------------------- */
LONG sockets_printf (PSOCKETS ps, PUCHAR Ctlstr , ...)
{
   va_list arg_ptr;
   UCHAR Buf [2048];
   LONG Len;

   // Build a temp string with the formated data
   va_start(arg_ptr, Ctlstr);
   Len = vsprintf( Buf , Ctlstr, arg_ptr);
   va_end(arg_ptr);

   // send it
   sockets_send (ps, Buf, Len);
   return Len;
}
/* -------------------------------------------------------------------------- */
LONG sockets_sendXlate (PSOCKETS ps, PUCHAR buf , LONG len)
{
   e2aMem(buf, buf, len);
   sockets_send  (ps, buf, len);
   return len;
}
/* -------------------------------------------------------------------------- */
LONG sockets_sendCcsXlate (PSOCKETS ps,  int fromCcsId, int toCcsId,  PUCHAR buf , LONG len)
{
   XlateBuf(buf , buf , len, fromCcsId , toCcsId);
   sockets_send  (ps, buf, len);
   return len;
}
/* -------------------------------------------------------------------------- */
LONG sockets_printfXlate (PSOCKETS ps, PUCHAR Ctlstr , ...)
{
   va_list arg_ptr;
   UCHAR Buf [65535];
   LONG Len;
   LONG i;

   // Build a temp string with the formated data
   va_start(arg_ptr, Ctlstr);
   Len = vsprintf( Buf , Ctlstr, arg_ptr);
   va_end(arg_ptr);

   sockets_sendXlate  (ps, Buf, Len);
   return Len;

}
LONG sockets_printfCcsXlate (PSOCKETS ps, int fromCcsId, int toCcsId, PUCHAR Ctlstr , ...)
{
   va_list arg_ptr;
   UCHAR Buf [65535];
   LONG Len;
   LONG i;

   // Build a temp string with the formated data
   va_start(arg_ptr, Ctlstr);
   Len = vsprintf( Buf , Ctlstr, arg_ptr);
   va_end(arg_ptr);

   sockets_sendCcsXlate  (ps, fromCcsId, toCcsId, Buf, Len);
   return Len;

}

