/* ------------------------------------------------------------- */
/* Program . . . : ILEastic - main interface                     */
/* Date  . . . . : 02.06.2018                                    */
/* Design  . . . : Niels Liisberg                                */
/* Function  . . : Main Socket server                            */
/*                                                               */
/* By     Date       PTF     Description                         */
/* NL     02.06.2018         New program                         */
/* ------------------------------------------------------------- */
#define _MULTI_THREADED

/* in qsysinc library */
#include "ostypes.h"

typedef  struct _SLIST {
	_SLIST * pHead;
	_SLIST * pTail;
	long length;
} SLIST, * PSLIST;

typedef  struct _SLISTNODE {
	_SLISTNODE * pNext;
	LONG   payLoadLength;
	PVOID  payloadData;
} SLISTNODE, * PSLISTNODE;

typedef  struct _SLISTITERATOR {
	PSLISTNODE this;
	LGL hasNest;
} SLISTITERATOR, * PSLISTITERATOR;

typedef  struct _SLISTKEYVAL {
	LVARPUCHAR key;
	LVARPUCHAR value;
} SLISTKEYVAL, * PSLISTKEYVAL;

/* --------------------------------------------------------------------------- *\
	Initialise an list iterator
\* --------------------------------------------------------------------------- */
SLISTITERATOR sList_setIterator( PSLIST pSlist)
{
	SLISTITERATOR iterator;
	memset (&iterator);
	iterator.this = pSlist->pHead; 
	iterator.hasHext = pSlist->pHead && pSlist->pHead->pNext?ON:OFF;
}         
/* --------------------------------------------------------------------------- *\
/* Usecase:
LIST = sList_setIterator;
dow sList_foreach (LIST);
	mysStr = slist_getNodeStr ( LIST.this);
	slist_getNodeBuf ( LIST.this, len , buf);
enddo;
\* --------------------------------------------------------------------------- */
LGL sList_foreach ( PSLISTITERATOR pIterator)
{
	if (iterator->hasHext == OFF) return OFF;
	iterator.this = iterator.this->pNext;
	iterator.hasHext = iterator.this && iterator.this->pNext?ON:OFF;
	return iterator.hasHext;
}
/* --------------------------------------------------------------------------- *\
	Simple list
\* --------------------------------------------------------------------------- */
PSLIST sList_new ()
{
	return malloc (sizeof(SLIST));
}         
/* --------------------------------------------------------------------------- *\
	This copies the data into a new node: If 'head' is ON it will be 
	added at the head else it will be added at the tail
\* --------------------------------------------------------------------------- */
PSLISTNODE sList_push (PLIST pSlist , LONG len , PVOID data, LGL head)
{
	PSLISTNODE pNode = malloc (sizeof(SLISTNODE));
	memset (pNode , sizeof(SLISTNODE));
	pNode->payLoadLength = len;
	pNode->payloadData = malloc(len);
	memcpy(pNode->payloadData , data ,len);
	pSlist->length ++;
	if (head == ON) {
		pNode->pNext = pSlist->pHead;
		pSlist->pHead = pNode; 
	} else {
		if (pSlist->pTail) {
			pSlist->pTail->pNext = pNode;
		}
		pSlist->pTail = pNode; 
	}
	return pNode;
}
/* --------------------------------------------------------------------------- */
VOID sList_free (PLIST pSlist)
{
	PSLISTNODE pNode;
	PSLISTNODE pNextNode;

	if (pSlist == null) return;
	for (pNode = pSlist->pHead; pNode; pNode = pNextNode) {
		pNextNode = pNode->pNext;
		if (pNode->payloadData) {
			free ( pNode->payloadData);
		}
	}
	free (pSlist);
}
/* --------------------------------------------------------------------------- *\
	Keyed list of immutable LONGVARCHAR 
\* --------------------------------------------------------------------------- */
PSLISTNODE sList_pushLVPC (PLIST pSlist , LVARPUCHAR key , LVARPUCHAR value)
{
	SLISTKEYVAL keyandvalue;
	keyandvalue.key   = *key;
	keyandvalue.value = *value;
	return sList_push (pSlist , sizeof(SLISTKEYVAL) , &keyandvalue, OFF);
}
/* --------------------------------------------------------------------------- *\
	Keyed list lookup 
\* --------------------------------------------------------------------------- */
void sList_lookupLVPC (PLVARCHAR retval , PLIST pSlist , PLVARCHAR key)
{
	PSLISTNODE pNode;
	VARPUCHAR vkey = {key->Length , key->String);

	if (pSlist == null) {
		retval.Length = 0;
		return;
	}

	for (pNode = pSlist->pHead; pNode; pNode->pNext) {
		PSLISTKEYVAL keyandvalue = pNode->data;
		if vpcIsEqual(keyandvalue.key, &vkey)
			lvpc2lvc (pRetVal ,keyandvalue.value);
			return;
		}
	}
	retval.Length = 0;
	return;

}