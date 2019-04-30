#ifndef APIERR_H
#define APIERR_H
typedef  struct _APIERR {
      long size;
      long avail;
      char msgid [7];
      char filler;
      char msgdta  [256];
} APIERR, * PAPIERR;
#define APIERR_INIT  { sizeof(APIERR) , 0 , "" , ' ' , ""}
#endif