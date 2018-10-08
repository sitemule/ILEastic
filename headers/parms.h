#include "ostypes.h"

typedef _Packed struct _OPDESC {
  SHORT DescType;
  SHORT DataType;
  SHORT DescInf1;
  SHORT DescInf2;
  LONG  DataLen ;
} OPDESC , * POPDESC;

typedef _Packed struct _OPDESCLST {
  LONG NbrOfParms;
  UCHAR filler1[12];
  UCHAR filler2[16];
  POPDESC OpDesc [400];
} OPDESCLST , * POPDESCLST;

typedef _Packed struct _NPMPARMLISTADDRP {
  POPDESCLST OpDescList;
  UCHAR  filler[16];
  PUCHAR Parms;
} NPMPARMLISTADDRP, * PNPMPARMLISTADDRP;

#ifdef __ILEC400__
  #pragma linkage  (_NPMPARMLISTADDR, builtin)
  #pragma argument (_NPMPARMLISTADDR, nowiden)
#else
  extern "builtin"
#endif

PNPMPARMLISTADDRP  _NPMPARMLISTADDR (void);