#ifndef SNDPGMMSG_I
#define SNDPGMMSG_I

#include "qmhsndpm.h"
#include "ostypes.h"

#define MESSAGE_ESCAPE  "*ESCAPE   "
#define MESSAGE_INFO    "*INFO     "
#define MESSAGE_DIAG    "*DIAG     "
#define MESSAGE_UTLMSG  "UTLMSG    *LIBL     "
#define MESSAGE_USRMSG  "USRMSG    *LIBL     "
#define MESSAGE_QCPFMSG "QCPFMSG   *LIBL     "

void message_send(PUCHAR msgId, PUCHAR msgFile, PUCHAR type, PUCHAR message, ...);
void message_sendPastControlBoundary(PUCHAR msgId, PUCHAR msgFile, PUCHAR type, PUCHAR message, ...);
void message_info(PUCHAR message, ...);
void message_escape(PUCHAR message, ...);

#endif