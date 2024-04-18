#include <stdio.h>
#include <stdarg.h>
#include <string.h>

#include "ostypes.h"
#include "varchar.h"
#include "message.h"

void message_send(PUCHAR msgId,PUCHAR msgFile, PUCHAR type ,PUCHAR msgData, ... )
{
   APIERR apierr = APIERR_INIT;
   va_list arg_ptr;
   char temp[4096];
   char msgkey [10];
   long stackcount=1;
   int  len;
   va_start(arg_ptr,  msgData);
   len = vsprintf(temp, msgData , arg_ptr);
   va_end(arg_ptr);
   QMHSNDPM (msgId, msgFile, temp , len , type , "message_send" ,
             stackcount, msgkey , &apierr, 12, "*NONE     *NONE     ", -1);
   if (apierr.avail) {
      printf ("Api error: %7s - %s" ,apierr.msgid, apierr.msgdta);
   }
}

void message_sendPastControlBoundary(PUCHAR msgId,PUCHAR msgFile, PUCHAR type ,PUCHAR msgData, ... )
{
   APIERR apierr = APIERR_INIT;
   va_list arg_ptr;
   char temp[4096];
   char msgkey [10];
   long stackcount=1;
   int  len;
   va_start(arg_ptr,  msgData);
   len = vsprintf(temp, msgData , arg_ptr);
   va_end(arg_ptr);
   QMHSNDPM (msgId, msgFile, temp , len , type , "*CTLBDY" ,
             stackcount, msgkey , &apierr, 7, "*NONE     *NONE     ", -1);
   if (apierr.avail) {
      printf ("Api error: %7s - %s" ,apierr.msgid, apierr.msgdta);
   }
}

void message_info(PUCHAR message, ... )
{
   APIERR apierr = APIERR_INIT;
   va_list arg_ptr;
   char temp[4096];
   char msgkey [10];
   long stackcount=1;
   int  len;
   va_start(arg_ptr, message);
   len = vsprintf(temp, message, arg_ptr);
   va_end(arg_ptr);
   QMHSNDPM ("CPF9898", MESSAGE_QCPFMSG , temp , len , MESSAGE_INFO , 
             "message_info" , stackcount, msgkey , &apierr, 12, "*NONE     *NONE     ", -1);
   if (apierr.avail) {
      printf ("Api error: %7s - %s" ,apierr.msgid, apierr.msgdta);
   }
}

void message_escape(PUCHAR message, ... )
{
   APIERR apierr = APIERR_INIT;
   va_list arg_ptr;
   char temp[4096];
   char msgkey [10];
   long stackcount=1;
   int  len;
   va_start(arg_ptr, message);
   len = vsprintf(temp, message, arg_ptr);
   va_end(arg_ptr);
   QMHSNDPM ("CPF9898", MESSAGE_QCPFMSG ,  temp , len , MESSAGE_ESCAPE , 
             "message_escape" , stackcount, msgkey , &apierr, 14, "*NONE     *NONE     ", -1);
   if (apierr.avail) {
      printf ("Api error: %7s - %s" ,apierr.msgid, apierr.msgdta);
   }
}
