#ifndef XLATE_H
#define XLATE_H
#include <iconv.h>
#include <QTQICONV.h>
typedef _Packed struct _XLATEDESC   {
   iconv_t Iconv;
   BOOL    Open;
   int     FromCCSID;
   int     ToCCSID;
} XLATEDESC , * PXLATEDESC;
PXLATEDESC XlateXdOpen ( int FromCCSID, int ToCCSID);
ULONG      XlateXdBuf(PXLATEDESC xd , PUCHAR OutBuf, PUCHAR InBuf , ULONG Len);
VARCHAR    XlateXdStr(PXLATEDESC xd , PVARCHAR InBuf);
LONG       XlateXdSprintf (PXLATEDESC pxd, PUCHAR out , PUCHAR Ctlstr,...);
VOID       XlateXdClose( PXLATEDESC xd);
ULONG      XlateBuf(PUCHAR OutBuf, PUCHAR InBuf , ULONG Len, int FromCCSID, int ToCCSID);
VARCHAR    XlateStr (PVARCHAR In ,  int FromCCSID, int ToCCSID);
PUCHAR     Xlatestr (PUCHAR out, PUCHAR in , int FromCCSID, int ToCCSID);
PUCHAR     XlateFromAnyAscii2ebcdic (PUCHAR outStr, PUCHAR inStr);
#endif
