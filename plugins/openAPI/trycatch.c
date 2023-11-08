/* SYSIFCOPT(*IFSIO) TERASPACE(*YES *TSIFC) STGMDL(*SNGLVL) */
/* ------------------------------------------------------------- *
 * Company . . . : System & Method A/S                           *
 * Design  . . . : Niels Liisberg                                *
 * Function  . . : Simple try / catch monitor for ANSI C         *
 *                                                               *
 *By    Date    Task   Description                           *
 * NL     20.11.16 0000000 New program                           *
 * ------------------------------------------------------------- */
#define _MULTI_THREADED
#include <stdio.h>
#include <signal.h>
#include <QMHCHGEM.h>
#include <mih/milckcom.h>     /* Lock types           */
#include <mih/locksl.h>       /* LOCKSL instruction   */
#include <mih/unlocksl.h>     /* UNLOCKSL instruction */
#include "ostypes.h"
#include "trycatch.h"

// Thread locals dont work on IBMi, so we use "the chritical section" by locking the errorFound
// a "Serialized thread model" with locks / mutex

__thread static  BOOL      errorFound;
__thread static  EXCEPTION excData;
/* -------------------------------------------------------------
   Error Monitor routine
   ------------------------------------------------------------- */
static void callback_monitor (int sig)
{
   locksl  (&errorFound, _LENR_LOCK);    // Lock Exclusive, No Read
   errorFound = TRUE;
   _GetExcData (&excData); // need to be done in the call back monitor :( ... not thread safe
}
// -------------------------------------------------------------
// This is OK to do while not locked, since it will always
// be the same monitor, unless it it in the catch: But there
// we are under lock condition
// -------------------------------------------------------------
void _try    (void)
{
   errorFound = FALSE;
   signal(SIGALL , callback_monitor);
}
// -------------------------------------------------------------
// NOTE: The order of code, is to ensure lock syncronization
// Always leave with the "errorFound" false and unlocked
// -------------------------------------------------------------
BOOL _catch   (PEXCEPTION  pmsg)
{
   // While locked: handle the error
   if (errorFound) {
      EXCEPTION msg;
      INT64 errapi = 0;
      errorFound = FALSE;
      if (pmsg != NULL) {
         memcpy(pmsg , &excData  , sizeof(EXCEPTION));
      }
      signal(SIGALL, SIG_DFL);  // Restore default moitor
      unlocksl  (&errorFound, _LENR_LOCK);    // Unlock Exclusive, No Read
      QMHCHGEM(&(excData.Target), 0, (char*) &excData.Msg_Ref_Key, "*REMOVE   ", "", 0, &errapi);
      return true;
   }
   // If no error occurs, we have no locks
   signal(SIGALL, SIG_DFL);  // Restore default moitor
   return false;
}
// ----------------------------------------------------------------------------
// Test case:
// ----------------------------------------------------------------------------
/***
void main()
{
    int a=1,b=1,c=1;
    EXCEPTION err;

    // Try - no errors
    // NOTE: The catch can have an "else" if no error occurs
    try {
       c = a / b;
    }
    catch(&err) {
       printf ("%s" , err.Msg_Id);
       // break;  will work if we are in loop!!
    }
    else {
       a=b=c=0;
    }

    // Try to dive by zero
    // NOTE: The catch can have an "else" if no error occurs
    // Try - no errors
    a=b=c=0;
    try {
       c = a / b;
    }
    catch(&err) {
       int i;
       printf ("%s" , err.Msg_Id);
       i = 1;
       // break;  will work if we are in loop!!
    }
    else {
       a=b=c=0;
    }
}
****/