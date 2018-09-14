/* SYSIFCOPT(*IFSIO) TERASPACE(*YES *TSIFC) STGMDL(*SNGLVL) */
/* ------------------------------------------------------------- *
 * Company . . . : System & Method A/S                           *
 * Design  . . . : Niels Liisberg                                *
 * Function  . . : Stream chunk callback for buffered I/O        *
 *                                                               *
 * By     Date     Task    Description                           *
 * NL     20.11.16 0000000 New program                           *
 * ------------------------------------------------------------- */
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <stdlib.h>
#include "ostypes.h"
#include "streamer.h"

// ----------------------------------------------------------------------------
PSTREAM stream_new(ULONG size)
{
    PSTREAM pStream = malloc(sizeof(STREAM));
    memset( pStream , 0,   sizeof(STREAM));
    pStream->buffer = malloc(size);
    pStream->pos = pStream->buffer;
    pStream->size = size;
    pStream->end = pStream->pos + size;
    return pStream;
}
// ----------------------------------------------------------------------------
void stream_delete(PSTREAM pStream)
{
    stream_flush(pStream);
    free (pStream->buffer);
    free (pStream);
}
// ----------------------------------------------------------------------------
LONG stream_write(PSTREAM pStream, PUCHAR buf , ULONG len)
{
    ULONG  remain;
    ULONG  cpylen;
    PUCHAR newend;
    LONG   retlen = len;

    while ( len > 0) {
       remain = pStream->end - pStream->pos;
       cpylen = len < remain ? len : remain;
       memcpy ( pStream->pos , buf , cpylen);
       newend  = pStream->pos + cpylen;

       if ( newend == pStream->end) {
          LONG rc = pStream->writer(pStream, pStream->buffer , pStream->size);
          if (rc < 0) return rc;
          pStream->pos = pStream->buffer;
       } else {
          pStream->pos = newend;
       }
       buf += cpylen;
       len -= cpylen;
    }
    pStream->totalSize += retlen;
    return retlen;
}
// ----------------------------------------------------------------------------
LONG stream_flush(PSTREAM pStream)
{
    int len = pStream->pos - pStream->buffer;
    if  ( len > 0) {
       pStream->writer(pStream, pStream->buffer , len);
       pStream->pos = pStream->buffer;
    }
    return len;
}
// ----------------------------------------------------------------------------
LONG stream_putc(PSTREAM pStream, UCHAR c)
{
    return stream_write(pStream , &c , 1);
}
// ----------------------------------------------------------------------------
LONG stream_printf (PSTREAM pStream , const char * ctlstr, ...)
{
   va_list arg_ptr;
   UCHAR   buf[65535];
   LONG    len;

   // Build a temp string with the formated data
   va_start(arg_ptr, ctlstr);
   len = vsprintf(buf, ctlstr, arg_ptr);
   va_end(arg_ptr);
   return  stream_write (pStream , buf, len );
}
// ----------------------------------------------------------------------------
LONG stream_puts  (PSTREAM pStream , PUCHAR s)
{
   LONG len = strlen(s);
   return  stream_write (pStream , s , len );
}
// ----------------------------------------------------------------------------
// Test case:
// ----------------------------------------------------------------------------
/******
LONG  myWriter  (PSTREAM pStream , PUCHAR buf , ULONG len)
{
    int rc = fwrite ( buf , 1, len , pStream->handle);
    fputc('\n' , pStream->handle);
    return rc;
}
void main()
{
     LONG i;
     PUCHAR text = "ABCDEFGHIJKLMN";
     PSTREAM pStream = stream_new (5);

     pStream->writer  = myWriter;
     pStream->handle   = fopen ("/www/test.txt" , "w");

     stream_write(pStream , text, strlen(text));

     for ( i = 0; i < 100; i ++) {
        stream_putc (pStream , 'a' + i);
     }

     stream_printf(pStream , "Livet er en gave");
     stream_flush  (pStream); // Dont need the flushm the delete will flush the last buffer
     fclose(pStream->handle);
     stream_delete (pStream);
}
 *****/
