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
#include <mih/callpgmv.h>
#include <qwtsetp.h>
#include <qbnrpii.h>
#include <miptrnam.h>
#include <qsygetph.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>


#include "ostypes.h"
#include "teramem.h"
#include "varchar.h"
#include "parms.h"
#include "streamer.h"
#include "sysdef.h"
#include "jsonxml.h"
#include "loadpgm.h"
#include "openAPI.h"
#include "MinMax.h"
#include "StrUtil.h"
#include "e2aa2e.h"

// Missing prototype in noxDb !! TODO 
PSTREAM jx_Stream  (PJXNODE pNode);


/* --------------------------------------------------------------------------- *\
   parse PCML: 
   <pcml version="7.0">
      <program name="HELLOPGM" path="/QSYS.LIB/ILEASTIC.LIB/HELLOPGM.PGM">
         <data name="NAME" type="char" length="10" usage="input" />
         <data name="TEXT" type="char" length="200" usage="inputoutput" />
      </program>
   </pcml>
\* --------------------------------------------------------------------------- */

/* --------------------------------------------------------------------------- *\
    Call the plain program resolved by the system pointer:
\* --------------------------------------------------------------------------- */
static LGL callBack   (PREQUEST pRequest, PRESPONSE pResponse) 
{
   PROUTING pRouting = pRequest->pRouting;
   POPENAPI pOpenAPI = pRouting->pluginData; 
   PJXNODE pParm = jx_GetNode  (pOpenAPI->pcml , "/pcml/program/data") ;
   PJXNODE pOutParm = pParm;
   PJXNODE pJson; 
   UCHAR parmbuffer [32000];
   PUCHAR pParmBuffer = parmbuffer;
   int parmIx = 0;
   void *argArray[256]; 
   LVARCHAR temp;
   LVARCHAR dft;
   dft.Length = 0;

   while ( pParm) {
      PUCHAR name   = jx_GetAttrValuePtr ( jx_AttributeLookup ( pParm, "NAME"));
      PUCHAR type   = jx_GetAttrValuePtr ( jx_AttributeLookup ( pParm, "TYPE"));
      PUCHAR length = jx_GetAttrValuePtr ( jx_AttributeLookup ( pParm, "LENGTH"));
      PUCHAR usage  = jx_GetAttrValuePtr ( jx_AttributeLookup ( pParm, "USAGE"));
      int len = length ? atoi(length) : 0;
      argArray [parmIx++] = pParmBuffer;
      il_getParmStr  (&temp , pRequest , name  , &dft);
      memset ( pParmBuffer , ' ', len);
      mema2e ( pParmBuffer , temp.String ,  min(temp.Length , len));
      pParmBuffer += len + 1; // room for zeroterm 
      pParm = jx_GetNodeNext(pParm);
   }

   // huxi !!
   argArray [parmIx++] = pParmBuffer;

   _CALLPGMV ( &pOpenAPI->userMethod , argArray , parmIx );

   pJson = jx_NewObject(NULL);
   pParmBuffer = parmbuffer;
   while ( pOutParm) {
      PUCHAR name   = jx_GetAttrValuePtr ( jx_AttributeLookup ( pOutParm, "NAME"));
      PUCHAR type   = jx_GetAttrValuePtr ( jx_AttributeLookup ( pOutParm, "TYPE"));
      PUCHAR length = jx_GetAttrValuePtr ( jx_AttributeLookup ( pOutParm, "LENGTH"));
      PUCHAR usage  = jx_GetAttrValuePtr ( jx_AttributeLookup ( pOutParm, "USAGE"));
      int len = length ? atoi(length) : 0;
      UCHAR temp [256];
      if (0==strcmp(usage , "inputoutput")) {
         jx_SetStrByName (pJson , str2lower (temp, name ) , righttrimlen(pParmBuffer , len ));
      }
      pParmBuffer += len + 1; // room for zero term
      pOutParm = jx_GetNodeNext(pOutParm);
   }

   il_responseWriteStream(pResponse , jx_Stream(pJson));
   jx_NodeDelete(pJson);

   return ON;
}

/* --------------------------------------------------------------------------- *\
    Get the pcml from the program 
\* --------------------------------------------------------------------------- */
static void getProgramPcml ( POPENAPI pOpenAPI ,PUCHAR Library , PUCHAR Program)
{
   Qbn_Interface_Entry_t * pet;
   Qbn_PGII0100_t * ppgi;
   UCHAR buffer [100000];
   long long err = 0;
   long i;
   PUCHAR pcml;
   UCHAR libpgm [20];
   memcpy ( libpgm      , Program , 10 );
   memcpy ( libpgm +10  , Library , 10 );

   QBNRPII (
      buffer ,                   /* Receiver variable                    */
      sizeof(buffer),            /* Length of receiver variable          */
      "RPII0100 ",               /* Format name                          */
      libpgm     ,               /* Qualified object name                */
      "*PGM      ",              /* Object Type                          */
      "*ALLBNDMOD          ",    /* Qualified bound module name          */
      &err                       /* Error code                           */
   );
   ppgi = (Qbn_PGII0100_t *) buffer;
   pet = (Qbn_Interface_Entry_t * ) (buffer + ppgi->Offset_First_Entry);
   for (i=0;i< ppgi->Number_Entries; i++ ) {
      pcml = buffer + pet->Offset_Interface_Info;
      pcml [pet->Interface_Info_Length_Ret] = '\0';
      pOpenAPI->pcml = jx_ParseString(pcml, "");
      pOpenAPI->ccsid = pet->Interface_Info_CCSID;
      /* 
      
      printf ("Module : %10.10s \n" ,  pet->Module_Name);
      printf ("Library: %10.10s \n" ,  pet->Module_Library);
      printf ("ccsid  : %d \n" ,  pet->Interface_Info_CCSID);
      printf ("pcml   : %s \n" ,  pcml);
      */ 
      pet = (Qbn_Interface_Entry_t *) ((char *) pet + pet->Offset_Next_Entry); 
   }
}
/* --------------------------------------------------------------------------- *\
    Handle :
    il_addRoute  (config : myServives: IL_ANY : '^/services/' : '(application/json)|(text/json)');
\* --------------------------------------------------------------------------- */
void il_addProgramRoute (PCONFIG pConfig, PUCHAR library , PUCHAR program, ROUTETYPE routeType , PVARCHAR routeReg , PVARCHAR contentReg , PVARCHAR routeId)
{
   void il_addRoute_vararg (PCONFIG pConfig, SERVLET servlet, ROUTETYPE routeType , ...);
   #pragma descriptor ( void il_addRoute_vararg    (void))
   #pragma map ( il_addRoute_vararg, "il_addRoute")
   
   PNPMPARMLISTADDRP pParms = _NPMPARMLISTADDR();
   PROUTING pRouting;
   POPENAPI pOpenAPI;

   switch (pParms->OpDescList->NbrOfParms) {
      case   6: il_addRoute_vararg ( pConfig,callBack,routeType ,routeReg ,contentReg ,routeId); break;
      case   5: il_addRoute_vararg ( pConfig,callBack,routeType ,routeReg ,contentReg ); break;
      case   4: il_addRoute_vararg ( pConfig,callBack,routeType ,routeReg ); break;
      default : il_addRoute_vararg ( pConfig,callBack,routeType ); break;
   }

   pRouting = pConfig->router->pTail->payloadData;
   pRouting->pluginData =  pOpenAPI = memAlloc ( sizeof(OPENAPI));

   pOpenAPI->userMethod = loadProgram ( library, program);
   pOpenAPI->userMethodIsProgram = TRUE;
   getProgramPcml ( pOpenAPI , library , program);

}
