#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include "ostypes.h"
#include "sndpgmmsg.h"
void sndpgmmsg(PUCHAR Msgid,PUCHAR Msgf, PUCHAR Type ,PUCHAR Msgdta, ... )
{
   APIERR apierr = APIERR_INIT;
   va_list arg_ptr;
   char temp[4096];
   char msgkey [10];
   long stackcount=1;
   int  len;
   va_start(arg_ptr,  Msgdta);
   len = vsprintf(temp, Msgdta , arg_ptr);
   va_end(arg_ptr);
   QMHSNDPM (Msgid, Msgf, temp , len , Type , "sndpgmmsg           " ,
             stackcount, msgkey , &apierr);
   if (apierr.avail) {
      printf ("Api error: %7s - %s" ,apierr.msgid, apierr.msgdta);
   }
}
void joblog(PUCHAR text , ... )
{
   APIERR apierr = APIERR_INIT;
   va_list arg_ptr;
   char temp[4096];
   char msgkey [10];
   long stackcount=1;
   int  len;
   va_start(arg_ptr,  text);
   len = vsprintf(temp, text, arg_ptr);
   va_end(arg_ptr);
   QMHSNDPM ("CPF9898", QCPFMSG ,  temp , len , INFO , "joblog              " ,
             stackcount, msgkey , &apierr);
   if (apierr.avail) {
      printf ("Api error: %7s - %s" ,apierr.msgid, apierr.msgdta);
   }
}
