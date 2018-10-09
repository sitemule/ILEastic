/* ------------------------------------------------------------- */
/* Program . . . : ILEastic - tools                              */
/* Date  . . . . : 02.06.2018                                    */
/* Design  . . . : Niels Liisberg                                */
/* Function  . . : Simple list                                   */
/*                                                               */
/* By     Date       PTF     Description                         */
/* NL     02.06.2018         New program                         */
/* ------------------------------------------------------------- */
#ifndef SIMPLELIST_H
#define  SIMPLELIST_H

#define _MULTI_THREADED

/* in qsysinc library */
#include "ostypes.h"
#include "varchar.h"


typedef  struct _SLISTNODE {
	struct _SLISTNODE * pNext;
	LONG   payLoadLength;
	PVOID  payloadData;
} SLISTNODE, * PSLISTNODE;

typedef  struct _SLIST {
	PSLISTNODE pHead;
	PSLISTNODE pTail;
	long length;
} SLIST, * PSLIST;


typedef  struct _SLISTITERATOR {
	PSLISTNODE this;
	PSLISTNODE next;
	LGL hasNext;
} SLISTITERATOR, * PSLISTITERATOR;

typedef  struct _SLISTKEYVAL {
	LVARPUCHAR key;
	LVARPUCHAR value;
} SLISTKEYVAL, * PSLISTKEYVAL;

void sList_lookupLVPC (PLVARCHAR pRetVal , PSLIST pSlist , PLVARCHAR key);
PSLISTNODE sList_pushLVPC (PSLIST pSlist , PLVARPUCHAR key , PLVARPUCHAR value);
VOID sList_free (PSLIST pSlist);
PSLISTNODE sList_push (PSLIST pSlist , LONG len , PVOID data, LGL head);
PSLIST sList_new (void);
LGL sList_foreach ( PSLISTITERATOR pIterator);
SLISTITERATOR sList_setIterator( PSLIST pSlist);
#endif

