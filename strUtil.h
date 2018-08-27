#ifndef STRUTIL_H
#define STRUTIL_H

int     strIcmp (PUCHAR s1, PUCHAR s2);
int     memIcmp (PUCHAR s1, PUCHAR s2 , int len);
SHORT  memicmpascii(PUCHAR m1  , PUCHAR m2 , LONG len );
UCHAR  toLower(UCHAR c);
UCHAR  toUpper(UCHAR c);
UCHAR  toupperascii(UCHAR c);
UCHAR  tolowerascii(UCHAR c);
LONG   strTrimLen(PUCHAR str);
LONG   strtrim(PUCHAR str);
PUCHAR strchrreplace(PUCHAR out , PUCHAR in , PUCHAR from , PUCHAR to );
LONG   memstrreplace(PUCHAR buf , LONG len , PUCHAR from , PUCHAR to );
PUCHAR fmtPacked(PUCHAR out , PUCHAR in , SHORT len , SHORT prec, UCHAR decPoint);
PUCHAR fmtZoned(PUCHAR out , PUCHAR in , SHORT len , SHORT prec, UCHAR decPoint);
PUCHAR stripLeadingZeros(PUCHAR out, PUCHAR input);
PUCHAR str2lower(PUCHAR out , PUCHAR in);
PUCHAR str2upper(PUCHAR out , PUCHAR in);
PUCHAR subword (PUCHAR out , PUCHAR in , LONG ix, PUCHAR delimiters);
LONG   subwords (PUCHAR in , PUCHAR  delimiters);
// LONG   subwords (PVARCHAR inputStr, PUCHAR  delimiters);
PUCHAR stristr(PUCHAR base, PUCHAR key );
PUCHAR strlastchr(PUCHAR base, UCHAR c );
PUCHAR memstr(PUCHAR base, PUCHAR key , LONG len);
PUCHAR memistr(PUCHAR base, PUCHAR key , LONG len);
PUCHAR strtrimncpy(PUCHAR out , PUCHAR in , LONG maxlen);
PUCHAR strtrimcpy(PUCHAR out , PUCHAR in);
PUCHAR strrighttrimcpy(PUCHAR dst, PUCHAR src);
PUCHAR strrighttrimncpy(PUCHAR dst, PUCHAR src, LONG len);

int cpy  (PUCHAR out , PUCHAR in);
PUCHAR trim(PUCHAR in);
PUCHAR firstnonblank(PUCHAR in);
PUCHAR lastnonblank(PUCHAR in);
PUCHAR righttrim(PUCHAR in);
PUCHAR righttrimlen(PUCHAR in , LONG size);
LONG   lenrighttrimlen(PUCHAR in , LONG size);
PUCHAR substr(PUCHAR out , PUCHAR in , LONG len);
PUCHAR padncpy(PUCHAR dst, PUCHAR src, SHORT dstlen);
#define padcpy(a,b) padncpy(a,b,sizeof(a))
PUCHAR pad(PUCHAR s , LONG l);
PUCHAR blob2str   (PBLOB blob);
ULONG hexstr2int (PUCHAR s);
UCHAR hexchar2int (UCHAR c);
PUCHAR binMem2Hex (PUCHAR out , PUCHAR in , LONG len);
PUCHAR hex2BinMem (PUCHAR out , PUCHAR in , LONG len);
FIXEDDEC str2dec(PUCHAR str, UCHAR decPoint);
LONG packedMem2Int(PUCHAR buf, SHORT bytes);


#endif
