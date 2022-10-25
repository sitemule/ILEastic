#define _MULTI_THREADED

// max number of concurrent threads
#define FD_SETSIZE 4096

#include <stdio.h>
#include <stdlib.h>

#include <sys/types.h>

#include "ostypes.h"
#include "parms.h"


LONG il_parmList(PVOID p1, PVOID p2, PVOID p3, PVOID p4, PVOID p5, PVOID p6)
{
    PNPMPARMLISTADDRP pParms = _NPMPARMLISTADDR();
    LONG rc = pParms->OpDescList->NbrOfParms;
    
    return rc;
}

