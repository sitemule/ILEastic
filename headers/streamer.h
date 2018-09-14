#ifndef STREAM_H
#define STREAM_H

typedef  LONG   (* PWRITE)  (PVOID pb, PUCHAR buf , ULONG len);
typedef  VOID   (* PRUNNER) (PVOID pStream);

typedef  struct  _STREAM {
    PVOID    handle ;
    PWRITE   writer;
    PUCHAR   buffer;
    ULONG    size;
    PUCHAR   pos;
    PUCHAR   end;
    ULONG    totalSize;
    PVOID    context;
    PRUNNER  runner;
    PVOID    output;
    UCHAR    filler[1024];
} STREAM,* PSTREAM;

PSTREAM stream_new(ULONG size);
void stream_delete(PSTREAM stream);
LONG stream_write(PSTREAM stream, PUCHAR buf , ULONG len);
LONG stream_flush(PSTREAM stream);
LONG stream_putc(PSTREAM stream, UCHAR c);
LONG stream_puts(PSTREAM stream, PUCHAR s);
LONG stream_printf (PSTREAM stream , const char * ctlstr, ...);
#endif