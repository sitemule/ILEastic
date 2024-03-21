/* SYSIFCOPT(*IFSIO) TERASPACE(*YES *TSIFC)   STGMDL(*SNGLVL) */
/* ------------------------------------------------------------- */
/* SYSIFCOPT(*IFSIO) OPTION(*EXPMAC *SHOWINC)                    */
/* Program . . . : CALLSRVPGM                                    */
/* Date  . . . . : 14.06.2012                                    */
/* Design  . . . : Niels Liisberg                                */
/* Function  . . : Load service program and procedures           */
/*                                                               */
/*By    Date      Task   Description                         */
/* NL     14.06.2012         New module                          */
/* ------------------------------------------------------------- */
#include <QLEAWI.h>
#include <signal.h>
#include <mih/stsppo.h>
#include <mih/setsppo.h>
#include <qwtsetp.h>
#include <miptrnam.h>
#include <qsygetph.h>
#include <errno.h>
#include <stdio.h>

#include "ostypes.h"
#include "apierr.h"
#include "trycatch.h"

/* ------------------------------------------------------------- */
_SYSPTR loadServiceProgram (PUCHAR Lib , PUCHAR SrvPgm)
{
   UCHAR SrvPgm_  [11];
   UCHAR Lib_     [11];
   _SYSPTR pgm;

   sprintf(SrvPgm_ , "%-10.10s" , SrvPgm);
   sprintf(Lib_    , "%-10.10s" , Lib);

   try {
      pgm = rslvsp(WLI_SRVPGM , SrvPgm_  , Lib_  , _AUTH_OBJ_MGMT);
   }
   catch (NULL) {
      pgm = NULL;
   }
   return pgm;
}
/* ------------------------------------------------------------- */
PVOID loadProc (_SYSPTR srvpgm ,  PUCHAR procName)
{
   _SYSPTR proc;
   int type;
   APIERR  apierr;
   UINT64 Mark;
   int expNo = 0;
   int expLen = 0;
   int i;
   int acinfolen;
   Qle_ABP_Info_t acinfo;
   Qus_EC_t       ec;

   if (srvpgm == NULL) return NULL;

   ec.Bytes_Provided = sizeof(ec);
   apierr.size = sizeof(apierr);
   acinfolen = sizeof(acinfo);
   QleActBndPgmLong(&srvpgm, &Mark , &acinfo , &acinfolen , &ec);
   proc = QleGetExpLong(&Mark , &expNo  , &expLen , procName , &proc , &type , &ec);
   return(proc);
}
/* ------------------------------------------------------------- */
PVOID loadServiceProgramProc (PUCHAR Lib , PUCHAR SrvPgm, PUCHAR procName , LGL cache)
{
    _SYSPTR pgm = loadServiceProgram (Lib , SrvPgm);
    return loadProc (pgm, procName);
}
/* ------------------------------------------------------------- */
_SYSPTR loadProgram (PUCHAR Lib , PUCHAR Pgm)
{
   UCHAR Pgm_  [11];
   UCHAR Lib_  [11];
   _SYSPTR pgm;

   sprintf(Pgm_ , "%-10.10s" , Pgm);
   sprintf(Lib_ , "%-10.10s" , Lib);

   try {
      pgm = rslvsp(WLI_PGM , Pgm_  , Lib_  , _AUTH_OBJ_MGMT);
   }
   catch (NULL) {
      pgm = NULL;
   }
   return pgm;
} 
