/* SYSIFCOPT(*IFSIO) TERASPACE(*YES *TSIFC) STGMDL(*INHERIT) */
/* ------------------------------------------------------------- */
/* Date  . . . . : 14.12.3005                                    */
/* Design  . . . : Niels Liisberg                                */
/* Function  . . : Base utilies                                  */
/*                                                               */
/* By     Date       PTF     Description                         */
/* NL     09.03.2005         New program                         */
/* ------------------------------------------------------------- */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <decimal.h>
#include <mih/milckcom.h>     /* Lock types           */
#include <mih/locksl.h>       /* LOCKSL instruction   */
#include <mih/unlocksl.h>     /* UNLOCKSL instruction */
#include <mih/setspfp.h>
#include <mih/setsppfp.h>

#include "ostypes.h"
#include "strUtil.h"

/* ------------------------------------------------------------- *\
   copy a string and return number of bytes copied
\* ------------------------------------------------------------- */
int cpy  (PUCHAR out , PUCHAR in)
{
   int l = strlen(in);
   memcpy (out , in , l+1);
   return (l);
}
/* ------------------------------------------------------------- *\
   strIcmp  is stricmp in ccsid 277
\* ------------------------------------------------------------- */
int strIcmp (PUCHAR s1, PUCHAR s2)
{
    int c =0;
    do {
      c = toUpper(*(s1++)) - toUpper(*(s2++));
    } while (c == 0 && *s1 && *s2);

    return c;
}
/* ------------------------------------------------------------- *\
   memIcmp  is memicmp in ccsid 277
\* ------------------------------------------------------------- */
int memIcmp (PUCHAR s1, PUCHAR s2 , int len)
{
    int c =0;
    while (len-- > 0 && c==0) {
      c = toUpper(*(s1++)) - toUpper(*(s2++));
    }
    return c;
}
/* ------------------------------------------------------------- *\
   toUpper and toLower in ccsid 277
\* ------------------------------------------------------------- */
UCHAR toUpper(UCHAR c)
{
   switch(c) {
      case 'æ' : return 'Æ';
      case 'ø' : return 'Ø';
      case 'å' : return 'Å';
      default  : return toupper(c);
   }
}
UCHAR toLower(UCHAR c)
{
   switch(c) {
      case 'Æ' : return 'æ';
      case 'Ø' : return 'ø';
      case 'Å' : return 'å';
      default  : return tolower(c);
   }
}
/* ------------------------------------------------------------- */
UCHAR toupperascii (UCHAR c)
{
#pragma convert(1252)
   if (c >= 'a' && c <= 'z') return c - ( 'a' - 'A');
   return c;
#pragma convert(0)
}
/* ------------------------------------------------------------- *\
\* ------------------------------------------------------------- */
UCHAR tolowerascii (UCHAR c)
{
#pragma convert(1252)
   if (c >= 'A' && c <= 'Z') return c + ( 'a' - 'A');
   return c;
#pragma convert(0)
}
/* ------------------------------------------------------------- *\
   stristr is strstr that ignores the case
   is trturns the pointer to "key" with in base
\* ------------------------------------------------------------- */
PUCHAR stristr(PUCHAR base, PUCHAR key )
{
   UCHAR k = toUpper(key[0]) ;
   SHORT keylen = strlen (key);

   while (*base) {
     if  (toUpper(*base) == k) {
        if (memIcmp (base , key , keylen) == 0) {  /* Found !! */
           return base;
        }
     }
     base ++;
   }
   return NULL;
}
/* ------------------------------------------------------------- *\
   strchrreplace returns a string, where chars are replaced one by one if byte match
\* ------------------------------------------------------------- */
PUCHAR strchrreplace(PUCHAR out , PUCHAR in , PUCHAR from , PUCHAR to )
{
   PUCHAR pf, pt, res = out;

   for (;*in; in++, out++) {
     *out = *in;
     for   (pf=from, pt=to ;*pf;pf++, pt++)  {
       if (*in == *pf) {
         *out = *pt;
         break;
       }
     }
   }
   *out = '\0';
   return res;
}
/* ------------------------------------------------------------- *\
   memstrreplace returns new lengt of the buffer where replaced with a string
\* ------------------------------------------------------------- */
LONG  memstrreplace(PUCHAR buf , LONG len , PUCHAR from , PUCHAR to )
{
   PUCHAR in , out = buf, inbuf, end;
   int lFrom = strlen(from), lTo = strlen(to);

   in = inbuf = malloc(len);
   memcpy(in, buf, len);
   end = in + len;

   while (in<end) {
     if (*in == *from
     &&  memcmp (in , from  , lFrom) ==0) {
       memcpy(out , to , lTo);
       out += lTo;
       in += lFrom;
     } else {
       *(out++) = *(in++);
     }
   }
   free(inbuf);
   return out - buf;
}
/* ------------------------------------------------------------- *\
   "memstr" returns a pointer to the first occurrence of a substring within another string.

   base: points to the string to be scanned.
   key: points to the (sub)string to scan for. This string should end in the usual '\0'.
   len:  is the length of "base".
   returns:
   points to the first occurrence of the substring in the given string. If the substring is not found, this will be a nu
   ll pointer.
\* ------------------------------------------------------------- */
PUCHAR memstr(PUCHAR base, PUCHAR key, LONG len )
{
   UCHAR k = key[0] ;
   SHORT keylen = strlen (key);

   while (len>0) {
     if  (*base == k) {
        if (memcmp (base , key , keylen) == 0) {  /* Found !! */
           return base;
        }
     }
     base ++;
     len --;
   }
   return NULL;
}
PUCHAR memIstr(PUCHAR base, PUCHAR key, LONG len )
{
   UCHAR k = toUpper(key[0]) ;
   SHORT keylen = strlen (key);

   while (len>0) {
     if  (toUpper(*base) == k) {
        if (memIcmp (base , key , keylen) == 0) {  /* Found !! */
           return base;
        }
     }
     base ++;
     len --;
   }
   return NULL;
}
SHORT memicmpascii (PUCHAR m1 , PUCHAR m2 , LONG len)
{
   while (len) {
     UCHAR c1 = toupperascii(*m1);
     UCHAR c2 = toupperascii(*m2);
     if (c1 > c2) return 1;
     if (c1 < c2) return -1;
     len --;
     m1++;m2++;
   }
   return 0;
}
PUCHAR memistrascii(PUCHAR base, PUCHAR key, LONG len )
{
   SHORT keylen = strlen (key);
   UCHAR k = toupperascii(key[0]);

   while (len>0) {
     if  (toupperascii(*base) == k) {
       if (memicmpascii (base , key , keylen) == 0) {  /* Found !! */
          return base;
       }
     }
     base ++;
     len --;
   }
   return NULL;
}
/* ------------------------------------------------------------- *\
   firstnonblank returns pointer to the string > ' '
\* ------------------------------------------------------------- */
PUCHAR firstnonblank(PUCHAR in)
{
// Find first non blank
   for (;;){
      if (*in == '\0') return (in);
      if (*in > ' ')   return (in);
      in ++;
   }
}
/* ------------------------------------------------------------- *\
   lastnonblank returns pointer to the last char > ' '
\* ------------------------------------------------------------- */
PUCHAR lastnonblank(PUCHAR in)
{
   LONG   len;
   PUCHAR end = in + strlen(in);

// Find last  non blank
   while (end > in) {
      if (*end  > ' ') return (end);
      end--;
   }
   return in;
}
/* ------------------------------------------------------------- *\
   righttrim - just set string termination after the last non blank
\* ------------------------------------------------------------- */
PUCHAR righttrim(PUCHAR in)
{
  PUCHAR p = lastnonblank(in);
  * (p+1) = '\0';
  return in;
}
/* ------------------------------------------------------------- *\
   trim both
\* ------------------------------------------------------------- */
PUCHAR trim(PUCHAR in)
{
  PUCHAR out, end, begin, ret;
  BOOL   docopy = false;
  ret = begin = end = out = in;
  while (*in) {
     if (*in > ' ') {
        docopy = true;
     }
     if (docopy) {
       *(out++) = *in;
       if (*in > ' ') end = out;  // Store that address just after the nonblank char
     }
     in++;
  }
  *end = '\0';
  return ret;
}
/* ------------------------------------------------------------- *\
   righttrimlen - start from length
\* ------------------------------------------------------------- */
PUCHAR righttrimlen(PUCHAR in , LONG size)
{
  PUCHAR p = in + size -1 ;
  for   (;p >= in && * p <= ' ' ; p--);
  * (p+1) = '\0';
  return in;
}
/* ------------------------------------------------------------- *\
   righttrimlen - start from length
\* ------------------------------------------------------------- */
LONG lenrighttrimlen(PUCHAR in , LONG size)
{
  PUCHAR p = in + size -1 ;
  if (size <= 0) return 0;
  for   (;p >= in && * p <= ' ' ; p--, size --);
  return size;
}
/* ------------------------------------------------------------- *\
   lastnonblank returns pointer to the last char > ' '
\* ------------------------------------------------------------- */
PUCHAR lastnonblankfrom(PUCHAR in, LONG from)
{
   PUCHAR end = in;
   PUCHAR p = in;
   while  (from --) {
      if (*p  > ' ') {
        end = p;
      } else if (*p == '\0') {
        break;
      }
      p++;
   }
   return end;
}
/* ------------------------------------------------------------- *\
   strtrimcpy copys and remows blanks before and after
\* ------------------------------------------------------------- */
PUCHAR strtrimncpy(PUCHAR out , PUCHAR in , LONG maxlen)
{
   PUCHAR end = out;
   PUCHAR ret = out;
   BOOL   findfirst = TRUE;

   for  (; maxlen > 0 ; maxlen --) {
      if (findfirst ) {
         if (*in > ' ') {
            findfirst = FALSE;
         }
      }
      if (! findfirst) {
        *out = *in;
        if (*out > ' ') {
          end = out + 1; // Where the zero termination will be
        }
        out++;
      }
      in++;
   }
   *(end) = '\0';
   return ret;
}
/* ------------------------------------------------------------- *\
   strtrimcpy copys and remows blanks before and after
\* ------------------------------------------------------------- */
PUCHAR strtrimcpy(PUCHAR out , PUCHAR in)
{
   PUCHAR end = out;
   PUCHAR ret = out;
   BOOL   findfirst = TRUE;
   int maxlen = strlen(in);

   for  (; maxlen > 0 ; maxlen --) {
      if (findfirst ) {
         if (*in > ' ') {
            findfirst = FALSE;
         }
      }
      if (! findfirst) {
        *out = *in;
        if (*out > ' ') {
          end = out + 1; // Where the zero termination will be
        }
        out++;
      }
      in++;
   }
   *(end) = '\0';
   return ret;
}
/* ------------------------------------------------------------- *\
   substr  copys and from and up to len
\* ------------------------------------------------------------- */
PUCHAR substr(PUCHAR out , PUCHAR in , LONG len)
{
   if (len < 0) len =0;

   if (in == NULL) {
      out[0] = '\0';
      return (out);
   }

   if (out == NULL) {
     system("DSPJOB OUTPUT(*PRINT) OPTION(*PGMSTK)");
   }

   memcpy(out, in , len);
   out[len] = '\0';
   return (out);
}
/* ------------------------------------------------------------- *\
   copys a subword from at list seperated by the delimiter list
   wordindex start at 0
\* ------------------------------------------------------------- */
PUCHAR subword (PUCHAR out , PUCHAR in , LONG ix, PUCHAR delimiters)
{
   PUCHAR res = out;
   PUCHAR pi  = in;
   LONG cx  =0;
   PUCHAR p;
   LONG i;

   *out = '\0';
   if (*in == '\0' ) return res; // Not found

   // Find the first occurens
   for (; *in > '\0' && cx <ix; in++) {
      p = strchr(delimiters , *in);
      if (p) cx ++;
   }
   if (cx != ix) return res; // Not found

   // Find the first occurens
   while(*in > '\0') {
      p = strchr(delimiters , *in);
      if (p) break;
      *(out++) = *(in++);
   }
   *(out) = '\0';
   return res;
}
/* ------------------------------------------------------------- */
LONG subwords (PUCHAR in , PUCHAR  delimiters)
{
   LONG res =1;
   PUCHAR p;

   if (!*in) return 0;

   for (; *in ; in++) {
      p = strchr(delimiters , *in);
      if (p) res++;
   }
   return res;
}
/* ------------------------------------------------------------- */
/* -----------------------------------------------------------------
   Copy a C-string to fixed char according to its length
   padding it right with blanks
   ----------------------------------------------------------------- */
PUCHAR padncpy(PUCHAR dst, PUCHAR src, SHORT dstlen)
{
   PUCHAR ret = dst;
   SHORT i;
   for (i=0;i< dstlen ; i++) {
      if (*src) {
         *dst = *src;
         src++;
      } else {
         *dst = ' ';
      }
      dst++;
   }
   return ret;
}
/* -----------------------------------------------------------------
   ----------------------------------------------------------------- */
PUCHAR pad(PUCHAR s , LONG l)
{
  BOOL   dopad = FALSE;
  PUCHAR r = s;
  LONG   i;
  for (i = 0; i< l; i++,s++) {
    if (*s  < ' ') dopad = TRUE;
    if (dopad) *s = ' ';

  }
  return r;
}
/* -----------------------------------------------------------------
   ----------------------------------------------------------------- */
PUCHAR strrighttrimcpy(PUCHAR dst, PUCHAR src)
{
   PUCHAR end = dst;
   PUCHAR ret = dst;
   SHORT i;
   while (*src) {
      *dst = *src;
      if (*dst > ' ') {
        end = dst;
      }
      dst ++;
      src ++;
   }
   *(end+1) = '\0';
   return ret;
}
/* -----------------------------------------------------------------
   ----------------------------------------------------------------- */
PUCHAR strrighttrimncpy(PUCHAR dst, PUCHAR src, LONG len)
{
   PUCHAR end = dst;
   PUCHAR ret = dst;
   SHORT i;
   while (*src && len-- > 0) {
      *dst = *src;
      if (*dst > ' ') {
        end = dst;
      }
      dst ++;
      src ++;
   }
   *(end+1) = '\0';
   return ret;
}
/* -----------------------------------------------------------------
   ----------------------------------------------------------------- */
PUCHAR UpperString(PUCHAR str)
{
   PUCHAR r = str;
   if (str == NULL) return NULL;
   while (*str) {
      *str = toUpper(*str);
      str++;
   }
   return r;
}
/* -----------------------------------------------------------------
   ----------------------------------------------------------------- */
PUCHAR str2upper (PUCHAR out, PUCHAR in )
{
   PUCHAR r = out;
   if (in) {
     while (*in ) {
        *(r++)   = toUpper(*(in++));
     }
   }
   *r= '\0';
   return out;
}
/* -----------------------------------------------------------------
   ----------------------------------------------------------------- */
PUCHAR str2lower (PUCHAR out, PUCHAR in )
{
   PUCHAR r = out;
   if (in) {
     while (*in ) {
        *(r++)   = toLower(*(in++));
     }
   }
   *r= '\0';
   return out;
}
/* --------------------------------------------------------------------------- */
UCHAR hexchar2int (UCHAR c)
{
   if (c >= '0' && c <= '9') {
     return (c - '0');
   }
   if (c >= 'A' && c <= 'F') {
     return (c - 'A' + 10);
   }
   if (c >= 'a' && c <= 'f') {
     return (c - 'a' + 10);
   }
}
PUCHAR binMem2Hex (PUCHAR out , PUCHAR in , LONG len)
{
   PUCHAR  res = out;
   PUCHAR h = "0123456789ABCDEF";
   UCHAR c;
   SHORT i;

   for (i=0; i < len  ; i++) {
     c = in[i] ;
     *(res++) = h[c / 16];
     *(res++) = h[c % 16];
   }
    *(res++) = '\0';   // Can be a string
   return out;
}
PUCHAR hex2BinMem (PUCHAR out , PUCHAR in , LONG len)
{
   PUCHAR  res = out;

   while (len-- > 0) {
     *(out++) = (16 * hexchar2int(*(in++)) + hexchar2int(*(in++)));
   }
   return res;
}
/* --------------------------------------------------------------------------- */
ULONG hexstr2int (PUCHAR s)
{
   LONG res = 0;
   while (*s) {
      res = (res * 256) + (16 * hexchar2int(*(s++)) + hexchar2int(*(s++)));
   }
   return res;
}
/* ------------------------------------------------------------- */
FIXEDDEC str2dec(PUCHAR str , UCHAR decPoint)
{
   PUCHAR p;
   FIXEDDEC        Res   = 0D;
   decimal(17,16)  Temp  = 0D;
   decimal(17)     Decs  = 1D;
   BOOL  DecFound = FALSE;
   UCHAR c = '0';
   PUCHAR firstDigit = NULL;
   PUCHAR lastDigit  = NULL;
   int   Dec=0;
   int   Prec=0;

   for (p=str; (c = *p) > '\0' ; p ++) {
      if (c >= '0' && c <= '9' ) {
         if (!firstDigit) firstDigit = p;
         lastDigit = p;
         if (DecFound) {
           if (++Prec <= 15) {
              Decs  *= 10D;
              Temp = (c - '0');
              Temp /= Decs;
              Res += Temp;
           }
         } else {
           if (Dec < 15) {
             Res = Res * 10D + (c - '0');
             if (Res > 0D) Dec++;
           }
         }
      } else if (c == decPoint) {
         DecFound = TRUE;
      }
   }
   if ((firstDigit > str && *(firstDigit-1) == '-')
   ||  (lastDigit        && *(lastDigit+1)  == '-')) {
      Res = - Res;
   }
   return (Res );
}
/* ------------------------------------------------------------- */
LONG packedMem2Int(PUCHAR buf, SHORT bytes)
{
    SHORT i;
    LONG  res  = 0;
    for(i=0;i<bytes-1; i++,buf++) {
       res = 10 * res + (*buf >> 4);
       res = 10 * res + (*buf & 0x0f);
    }
    res = 10 * res + (*buf >> 4);
    if ((*buf & 0x0F) != 0x0F) {
      res = - res;
    }
    return res;
}
/* ------------------------------------------------------------- */
PUCHAR stripLeadingZeros(PUCHAR out, PUCHAR s)
{
   PUCHAR p = s;
   BOOL   Neg = FALSE;

   if (*p == '-') {
     p++;
     Neg = TRUE;
   }

   // NULL returns 0. Also it could be a single '-' from the abowe
   if (*p == '\0') {
      strcpy(out , "0");
      return out;
   }

   while (*p == '0') {
     p ++;
   }
   if (p > s && ! isdigit(*p)) p --;

   if (Neg) {
     p--;
     *p = '-';
   }
   strcpy(out , p);
   return (out);
}
/* ------------------------------------------------------------- */
PUCHAR fmtPacked(PUCHAR out , PUCHAR in , SHORT len , SHORT prec, UCHAR decPoint)
{
   UCHAR  temp [64];
   PUCHAR pOut = temp;
   SHORT  ByteLen = len / 2 + 1;  /* Bytes required */
   SHORT  HighNibbel = len % 2;
   SHORT  j;

   // Negative when not xF in last lo nibble */
   if ((in[ByteLen-1] & 0x0F)  != 0x0F) {
      *pOut++ = '-';
   }
   for (j=0;j<len;j++) {
      if (j == (len - prec)) {
         *pOut++ = decPoint;
      }
      if (HighNibbel) {
          *pOut++ = '0' + (*in >> 4);
          HighNibbel = FALSE;
      } else {
          *pOut++ = '0' + (*in++ & 0x0f);
          HighNibbel = TRUE;
      }
   }
   *pOut = '\0';
   return(stripLeadingZeros(out, temp));
}
PUCHAR fmtZoned(PUCHAR out , PUCHAR in , SHORT len , SHORT prec, UCHAR decPoint)
{
   UCHAR  temp [64];
   PUCHAR pOut = temp;
   SHORT  ByteLen = len ;  // Bytes required
   SHORT  j;

   // Negative when not xF in last lo nibble
   if ((in[ByteLen-1] & 0xF0)  != 0xF0) {
      *pOut++ = '-';
   }
   for (j=0;j<len;j++) {
      if (j == (len - prec)) {
         *pOut++ = decPoint;
      }
      *pOut++ = '0' + (*in++ & 0x0f);
   }
   *pOut = '\0';
   return(stripLeadingZeros(out , temp));
}
// -------------------------------------------------------------
/*
PUCHAR strDup(PUCHAR s)
{
    PUCHAR p;
    LONG len = strlen(s);
    p = memAlloc (len);
    return p;
}
*/
/* ------------------------------------------------------------- */
LGL isOn (int boolExpr)
{
    return ( boolExpr ? ON : OFF);
}
/* ------------------------------------------------------------- */
PUCHAR strlastchr(PUCHAR str , UCHAR c)
{
     PUCHAR p, found = NULL;
     while ( p = strchr(str , c )) {
        found = p;
        str = p +1;
     }
     return found;
}
PUCHAR blob2str  (PBLOB pb)
{
    pb->String[pb->Length] = '\0';
    return  pb->String;
}
/* ---------------------------------------------------------------------------------------- */
LONG strTrimLen(PUCHAR str)
{
    PUCHAR end = str;
    LONG l=0,len=0;
    while (*end) {
       l++;
       if (*end > ' ') {
         len = l ;
       }
       end++;
    }
    return len;
}
