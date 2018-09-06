/* SYSIFCOPT(*IFSIO) TERASPACE(*YES *TSIFC) STGMDL(*INHERIT) */
/* ------------------------------------------------------------- */
/* Program . . . : XLATE                                         */
/* Date  . . . . : 24.04.2008                                    */
/* Design  . . . : Niels Liisberg                                */
/* Function  . . : X-alation using iconv                         */
/*                                                               */
/* By     Date       PTF     Description                         */
/* NL     24.04.2008         New program                         */
/* ------------------------------------------------------------- */
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <ctype.h>
#include <iconv.h>
#include <QTQICONV.h>

#include "ostypes.h"
#include "varchar.h"
#include "xlate.h"

/* ------------------------------------------------------------- */
PXLATEDESC XlateXdOpen (int FromCCSID, int ToCCSID)
{
   PXLATEDESC pXd = malloc(sizeof(XLATEDESC));
   QtqCode_T To;
   QtqCode_T From;

   pXd->FromCCSID = FromCCSID ;
   pXd->ToCCSID   = ToCCSID;

   memset(&From , 0, sizeof(From));
   From.CCSID = FromCCSID;
   From.cnv_alternative = 0 ;
   From.subs_alternative = 0 ;
   From.shift_alternative = 0;
   From.length_option = 0;
   From.mx_error_option = 0;

   memset(&To , 0, sizeof(To));
   To.CCSID = ToCCSID;
   To.cnv_alternative = 0;
   To.subs_alternative = 0;
   To.shift_alternative = 0;
   To.length_option = 0;
   To.mx_error_option = 0;

   // Get descriptor
   pXd->Iconv = QtqIconvOpen( &To, &From);
   pXd->Open = (pXd->Iconv.return_value != -1);
   if (! pXd->Open) {
      free (pXd);
      return (NULL); // invalid CCSID
   }
   return (pXd);  // Number of bytes converted
}
/* ------------------------------------------------------------- */
void XlateXdClose  (PXLATEDESC pXd)
{
   if ( pXd == NULL) return;
   iconv_close (pXd->Iconv);
   free (pXd);
}
/* ------------------------------------------------------------- */
ULONG XlateXdBuf(PXLATEDESC pXd, PUCHAR OutBuf, PUCHAR InBuf , ULONG Len)
{
   PUCHAR pOutBuf;
   PUCHAR pInBuf;
   int i;
   size_t OutLen, inbytesleft, outbytesleft;
   size_t before, rc;

   if (Len ==0 ) return 0;

   if (pXd == NULL
   ||  pXd->FromCCSID == pXd->ToCCSID) {
      memcpy(OutBuf, InBuf , Len);
      return Len;
   }

   before = outbytesleft = Len * 4; // Max size of UTF8 expand to 4 times bytes
   inbytesleft  = Len;

   pOutBuf = OutBuf;
   pInBuf  = InBuf;

   // Do Conversion
   rc = iconv (pXd->Iconv, &pInBuf, &inbytesleft, &pOutBuf, &outbytesleft);
   if (rc == -1) return (-1);

   OutLen  = before - outbytesleft;
   return (OutLen);  // Number of bytes converted
}
/* ------------------------------------------------------------- */
VARCHAR XlateXdStr (PXLATEDESC pXd, PVARCHAR In )
{
   VARCHAR Result;
   Result.Length = XlateXdBuf(pXd ,Result.String , In->String , In->Length );
   return (Result);
}
/* ------------------------------------------------------------- */
ULONG XlateBuf(PUCHAR OutBuf, PUCHAR InBuf , ULONG Len, int FromCCSID, int ToCCSID)
{
   PXLATEDESC pXd;
   ULONG OutLen;

   if (Len ==0 ) return 0;

   if (FromCCSID == ToCCSID) {
      memcpy(OutBuf, InBuf , Len);
      return Len;
   }

   pXd = XlateXdOpen (FromCCSID, ToCCSID);
   if  (!pXd) return -1;

   OutLen = XlateXdBuf(pXd, OutBuf, InBuf , Len);
   XlateXdClose  (pXd);

   return (OutLen);  // Number of bytes converted
}
/* ------------------------------------------------------------- */
VARCHAR XlateStr (PVARCHAR In ,  int FromCCSID, int ToCCSID)
{
   VARCHAR Result;

   Result.Length = XlateBuf(Result.String , In->String , In->Length , FromCCSID, ToCCSID);
   return (Result);
}
/* ------------------------------------------------------------- */
PUCHAR Xlatestr (PUCHAR out, PUCHAR in, int FromCCSID, int ToCCSID)
{
   int len = XlateBuf(out, in , strlen(in)  , FromCCSID, ToCCSID);
   out[len] = 0;
   return out;
}
/* ------------------------------------------------------------- */
PUCHAR XlateFromAnyAscii2ebcdic (PUCHAR outStr, PUCHAR inStr)
{
  PXLATEDESC pXd;
  int inLen = strlen (inStr);
  int xLen;
  int isCCSID;
  PUCHAR temp;

  // First guess the input ccssid by converting it to unicode...
  pXd =  XlateXdOpen(1208 , 1200 );
  temp   = malloc(inLen  *2);  // Unicode requires double size
  xLen = XlateXdBuf(pXd , temp   , inStr , inLen  );
  XlateXdClose(pXd);
  free(temp);
  isCCSID = (xLen == -1) ? 1252 : 1208;

  // next convet to current job ccsid
  pXd =  XlateXdOpen(isCCSID, 0 );
  xLen = XlateXdBuf(pXd , outStr , inStr , inLen  );
  XlateXdClose(pXd);
  outStr[xLen] = '\0';
  return outStr;
}
/* ------------------------------------------------------------- */
LONG  XlateXdSprintf (PXLATEDESC pxd, PUCHAR out, PUCHAR Ctlstr,...)
{
   va_list arg_ptr;
   UCHAR   temp1[65535];
   LONG    len1, len2;
   SHORT   l,i;

   // Build a temp string with the formated data
   va_start(arg_ptr, Ctlstr);
   len1 = vsprintf(temp1, Ctlstr, arg_ptr);
   va_end(arg_ptr);

   len2 = XlateXdBuf(pxd , out , temp1  , len1);
   return len2;
}
