/* ------------------------------------------------------------- */
/* Program . . . : ILEastic - main interface                     */
/* Date  . . . . : 02.06.2018                                    */
/* Design  . . . : Niels Liisberg                                */
/* Function  . . : serialize calls fro non-thread applications   */
/*                                                               */
/* By     Date       PTF     Description                         */
/* NL     02.06.2018         New program                         */
/* ------------------------------------------------------------- */
#include <mih/milckcom.h>     /* Lock types           */ 
#include <mih/lock.h>       /* LOCKSL instruction   */   
#include <mih/unlocksl.h>     /* UNLOCKSL instruction */ 
#include <mih/locksl.h>     /* UNLOCKSL instruction */ 

static char threadLock; 
/* --------------------------------------------------------------------------- */
// lock memory for serialization
/* --------------------------------------------------------------------------- */
void il_enterThreadSerialize (void)
{
    locksl(&threadLock , _LENR_LOCK);           
}
/* --------------------------------------------------------------------------- */
// lock memory for serialization
/* --------------------------------------------------------------------------- */
void il_exitThreadSerialize (void)
{
    unlocksl(&threadLock , _LENR_LOCK);         
}
