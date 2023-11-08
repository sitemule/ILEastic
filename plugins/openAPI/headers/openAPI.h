#ifndef OPENAPI_H
#define OPENAPI_H

typedef struct _OPENAPI  {
    _SYSPTR userMethod;
    BOOL    userMethodIsProgram;
    PJXNODE pcml;
    ULONG   ccsid;
} OPENAPI, * POPENAPI;
#endif
