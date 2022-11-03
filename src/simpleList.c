/* ------------------------------------------------------------- */
/* Program . . . : ILEastic - toolsmain interface                */
/* Date  . . . . : 02.06.2018                                    */
/* Design  . . . : Niels Liisberg                                */
/* Function  . . : Simple list                                   */
/*                                                               */
/* By     Date       PTF     Description                         */
/* NL     02.06.2018         New program                         */
/* ------------------------------------------------------------- */
#define _MULTI_THREADED

/* in qsysinc library */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "ostypes.h" 
#include "teramem.h"
#include "varchar.h" 
#include "simpleList.h"


/* --------------------------------------------------------------------------- *\
    Initialise an list iterator
\* --------------------------------------------------------------------------- */
SLISTITERATOR sList_setIterator( PSLIST pSlist)
{
    SLISTITERATOR iterator;
    memset(&iterator , 0, sizeof(SLISTITERATOR));
    iterator.this = null; // set by sList_foreach()
    iterator.next = pSlist->pHead ? pSlist->pHead : null;
    iterator.hasNext = pSlist->pHead ? ON : OFF;
    return iterator;
}
/* --------------------------------------------------------------------------- *\
    Iterator Usecase in RPG:

    dcl-ds list like(SLIST_DS);
    list = sList_setIterator;
    dow sList_foreach (list);
        mysStr = slist_getNodeStr ( list.this);
        slist_getNodeBuf ( list.this, len , buf);
    enddo;

\* --------------------------------------------------------------------------- */
LGL sList_foreach ( PSLISTITERATOR pIterator)
{
    if (pIterator->hasNext == OFF) return OFF;
    pIterator->this = pIterator->next;
    pIterator->next = pIterator->this ? pIterator->this->pNext : null;
    pIterator->hasNext = pIterator->this ? ON : OFF;
    return pIterator->hasNext;
}
/* --------------------------------------------------------------------------- *\
    Simple list
\* --------------------------------------------------------------------------- */
PSLIST sList_new ()
{
    return  memCalloc (sizeof(SLIST));
}
/* --------------------------------------------------------------------------- *\
    This copies the data into a new node: If 'head' is ON it will be 
    added at the head else it will be added at the tail
\* --------------------------------------------------------------------------- */
PSLISTNODE sList_push (PSLIST pSlist , LONG len , PVOID data, LGL head)
{
    PSLISTNODE pNode = memCalloc (sizeof(SLISTNODE));
    pNode->payLoadLength = len;
    pNode->payloadData = memAlloc(len);
    memcpy(pNode->payloadData , data ,len);
    pSlist->length ++;
    if (head == ON) {
        pNode->pNext = pSlist->pHead;
        pSlist->pHead = pNode; 
    } else {
        if (!pSlist->pHead) {
            pSlist->pHead = pNode;
        }
        if (pSlist->pTail) {
            pSlist->pTail->pNext = pNode;
        }
        pSlist->pTail = pNode; 
    }
    return pNode;
}
/* --------------------------------------------------------------------------- */
VOID sList_free (PSLIST pSlist)
{
    PSLISTNODE pNode;
    PSLISTNODE pNextNode;

    if (pSlist == null) return;
    for (pNode = pSlist->pHead; pNode; pNode = pNextNode) {
        pNextNode = pNode->pNext;
        memFree ( &pNode->payloadData);
        memFree ( &pNode);
    }
    memFree (&pSlist);
}
/* --------------------------------------------------------------------------- *\
    Keyed list of immutable LONGVARCHAR 
\* --------------------------------------------------------------------------- */
PSLISTNODE sList_pushLVPC (PSLIST pSlist , PLVARPUCHAR key , PLVARPUCHAR value)
{
   
    SLISTKEYVAL keyandvalue;
    keyandvalue.key   = *key;
    keyandvalue.value = *value;
    return sList_push (pSlist , sizeof(SLISTKEYVAL) , &keyandvalue, OFF);
}
/* --------------------------------------------------------------------------- *\
    Keyed list lookup 
\* --------------------------------------------------------------------------- */
void sList_lookupLVPC (PLVARCHAR pRetVal , PSLIST pSlist , PLVARCHAR key)
{
    PSLISTNODE pNode;
    LVARPUCHAR vkey = {key->Length , key->String};

    if ( ! pSlist ) {
        pRetVal->Length = 0;
        return;
    }

    for (pNode = pSlist->pHead; pNode; pNode = pNode->pNext) {
        PSLISTKEYVAL pKeyAndValue = pNode->payloadData;
        if (lvpcIsEqual(&pKeyAndValue->key, &vkey)) {
            lvpc2lvc (pRetVal ,&pKeyAndValue->value);
            return;
        }
    }
    pRetVal->Length = 0;
    return;

}