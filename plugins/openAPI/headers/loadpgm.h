_SYSPTR loadServiceProgram (PUCHAR Lib , PUCHAR SrvPgm);
PVOID loadProc (_SYSPTR srvpgm ,  PUCHAR procName);
PVOID loadServiceProgramProc (PUCHAR Lib , PUCHAR SrvPgm, PUCHAR procName , LGL cache);
_SYSPTR loadProgram (PUCHAR Lib , PUCHAR Pgm);