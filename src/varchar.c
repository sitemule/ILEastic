/* SYSIFCOPT(*IFSIO) TERASPACE(*YES *TSIFC) STGMDL(*INHERIT) */
/* ------------------------------------------------------------- */
/* Program . . . : varchar                                       */
/* Design  . . . : Niels Liisberg                                */
/* Function  . . : varchar routines                              */
/*                                                               */
/* By     Date     PTF     Description                           */
/* NL     25.02.04 0000000 New program                           */
/* ------------------------------------------------------------- */
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "ostypes.h"
#include "strUtil.h"
#include "varchar.h"

/* ------------------------------------------------------------- */
// LONG (  4 byte length)
/* ------------------------------------------------------------- */ 
void lvpc2lvc (PLVARCHAR out, PLVARPUCHAR in)
{
   out->Length = in->Length;
   memcpy(out->String , in->String, in->Length);
   out->String[in->Length] = '\0'; 
}
/* ------------------------------------------------------------- */
// SHORT (  2 byte length)
/* ------------------------------------------------------------- */
void lvpc2vc (PVARCHAR out, PLVARPUCHAR in)
{
   out->Length = in->Length;
   memcpy(out->String , in->String, in->Length);
   out->String[in->Length] = '\0'; 
}
/* ------------------------------------------------------------- */
VARPUCHAR str2varpuchar(PUCHAR s)
{
   VARPUCHAR res;
   res.Length = strlen(s);
   res.String = s;
   return(res);
}
/* ------------------------------------------------------------- */
VARPUCHAR vc2varpuchar(PVARCHAR in)
{
   VARPUCHAR res;
   res.Length = in->Length;
   if (in->Length  == 32767) { // TODO - lengthe is set to zero if *BLANK is passed
      if  (memcmp( in->String , "          " , 10 ) == 0) {
         res.Length = 0;
      }
   }
   res.String = in->String;
   return(res);
}
/* --------------------------------------------------------------------------- */
PUCHAR vc2str(PVOID pv)
{
   PVARCHAR p = (PVARCHAR) pv;
   p->String[p->Length] = '\0';
   return(p->String);
}
/* --------------------------------------------------------------------------- */
PUCHAR vc2strtrim(PVOID pv)
{
   PVARCHAR p = (PVARCHAR) pv;
   PUCHAR end = p->String + p->Length;
   *end = '\0';
   while (end > p->String && *end <= ' ') {
      *(end--) = '\0';
   }                                       ;
   return(p->String);
}
/* --------------------------------------------------------------------------- */
PUCHAR vc2strcpy(PUCHAR res,  PVOID pv)
{
   PVARCHAR p = (PVARCHAR) pv;
   memcpy (res,  p->String, p->Length );
   res [p->Length] = '\0';
   return res;
}
/* --------------------------------------------------------------------------- */
void  vccatstr (PVARCHAR out , PUCHAR s   )
{
   int l = strlen (s);
   memcpy(out->String + out->Length , s , l );
   out->Length += l;
}
/* --------------------------------------------------------------------------- */
void  vccatc  (PVARCHAR out, UCHAR in)
{
   if (out == NULL) return;
   out->String[out->Length++] = in;
   out->String[out->Length]   = '\0';
}
/* --------------------------------------------------------------------------- */
void  vccatvc    (PVARCHAR out, PVARCHAR in)
{
   if (in == NULL || out == NULL) return;
   memcpy(out->String+out->Length , in->String , in->Length+1);  // Including the zero termination
   out->Length += in->Length;
}
/* --------------------------------------------------------------------------- */
void  vccatmem (PVARCHAR out , PUCHAR s , LONG len)
{
   memcpy(out->String + out->Length , s , len );
   out->Length += len;
}
/* --------------------------------------------------------------------------- */
void  vccpy (PVARCHAR out , PVARCHAR in)
{
   memcpy(out , in , in->Length + 2);
}
/* --------------------------------------------------------------------------- */
void  vcTrimRight (PVARCHAR str)
{
   while (str->Length > 0 && str->String[str->Length -1] <= ' ') {
     str->Length --;
   }
}
/* --------------------------------------------------------------------------- */
void  str2vc (PVOID  out , PUCHAR in)
{
   PVARCHAR pVc = out;
   if (in == NULL) {
      pVc->Length =0;
      return;
   }
   pVc->Length = strlen(in);
   memcpy(pVc->String , in , pVc->Length);
}
/* --------------------------------------------------------------------------- */
void substr2vc (PVOID  out , PUCHAR in , LONG len)
{
   PVARCHAR pVc = out;
   pVc->Length = strlen(in);
   if (pVc->Length > len) pVc->Length = len;
   memcpy(pVc->String , in , pVc->Length);
}
/* --------------------------------------------------------------------------- */
void vcprintf  (PVOID VarChar, PUCHAR Ctlstr , ...)
{
   va_list arg_ptr;
   PVARCHAR pVc = VarChar;

/* Build a temp string with the formated data  */
   va_start(arg_ptr, Ctlstr);
   pVc->Length = vsprintf(pVc->String, Ctlstr, arg_ptr);
   va_end(arg_ptr);
}
/* --------------------------------------------------------------------------- */
void vccatf (PVOID VarChar, PUCHAR Ctlstr , ...)
{
   va_list arg_ptr;
   PVARCHAR pVc = VarChar;

/* Build a temp string with the formated data  */
   va_start(arg_ptr, Ctlstr);
   pVc->Length += vsprintf(pVc->String + pVc->Length , Ctlstr, arg_ptr);
   va_end(arg_ptr);
}
/* --------------------------------------------------------------------------- */
PVARCHARLIST  vcListNew (void)
{
   PVARCHARLIST pVcl = malloc(sizeof(VARCHARLIST));
   memset(pVcl , 0 , sizeof(VARCHARLIST));
   return pVcl;
}
/* --------------------------------------------------------------------------- */
void vcListAdd (PVARCHARLIST pVcl ,PVARCHAR str)
{
   PVARCHAR temp;
   LONG len = pVcl->endOffset + str->Length + 3;  // Len of meta data (the length:2 + the terminaiton:1 = 3)
   if (len >= pVcl->memUsed) {
     len += 1024;
     pVcl->list = realloc(pVcl->list , len);
     pVcl->memUsed = len;
   }
   temp = (PVARCHAR)  (pVcl->list + pVcl->endOffset);
   vccpy (temp , str);
   vc2str(temp);                          // Zero term so we can use the list as normal c-strings
   pVcl->endOffset += str->Length + 3;    // Len of meta data (the length:2 + the terminaiton:1 = 3)
   pVcl->numEntries ++;
}
/* --------------------------------------------------------------------------- */
void vcListFree(PVARCHARLIST pVcl)
{
   if (pVcl == NULL);
   if (pVcl->list) free(pVcl->list);
   memset(pVcl , 0 , sizeof(VARCHARLIST));
}
/* --------------------------------------------------------------------------- */
PVARCHAR  vcListFirst (PVARCHARLIST pVcl)
{
   if (pVcl == NULL) return NULL;
   if (pVcl->numEntries == 0) return NULL;
   return (PVARCHAR) pVcl->list;
}
/* --------------------------------------------------------------------------- */
PVARCHAR  vcListNext  (PVARCHARLIST pVcl, PVARCHAR pVc)
{
   PUCHAR  next;
   if (pVcl == NULL) return NULL;
   if (pVc  == NULL) return NULL;
   next = ((PUCHAR)pVc ) + pVc->Length +3; // Len of meta data (the length:2 + the terminaiton:1 = 3)
   if (next >= pVcl->list + pVcl->endOffset)  return NULL;
   return (PVARCHAR) next;
}
/* ---------------------------------------------------------------------------------------- */
PUCHAR  vpc2string(PUCHAR res, PVARPUCHAR pvpc )
{
  if (pvpc == NULL || pvpc->String == NULL) {
    *res = '\0';
  } else {
    substr(res , pvpc->String  , pvpc->Length);
  }
  return res;
}
/* ---------------------------------------------------------------------------------------- */
VARPUCHAR vpcSetString(PUCHAR s)
{
  VARPUCHAR vpc;
  vpc.String = s;
  vpc.Length = strlen(s);
  return vpc;
}
/* ---------------------------------------------------------------------------------------- */
BOOL vpcIsEqual(PVARPUCHAR p1, PVARPUCHAR p2)
{
   return (
       (p1->Length == p2->Length)
   &&  (memicmp (p1->String , p2->String ,p2->Length) == 0)
   );
}