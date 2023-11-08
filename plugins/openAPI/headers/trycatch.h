#ifndef TRYCATCH_H
#define TRYCATCH_H
#include <signal.h>
typedef _INTRPT_Hndlr_Parms_T  EXCEPTION , *PEXCEPTION;
void _try (void);
BOOL _catch  (PEXCEPTION pmsg);
#define try _try();
#define catch(a)  if(_catch(a))
void _try_serialized (void);
BOOL _catch_serialized      (PEXCEPTION pmsg);
#define try_serialized         _try_serialized ();
#define catch_serialized  (a)  if(_catch_serialized (a))
#endif