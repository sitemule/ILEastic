#-------------------------------------------------------------------------------
# User-defined part start
#

# note: ILE RPG compilers don't support UTF-8, so we use win-1252; However ILE C supports UTF-8

# BIN_LIB is the destination library for the service program.
# The rpg modules and the binder source file are also created in BIN_LIB.
# Binder source file and rpg module can be remove with the clean step 
# (make clean).
BIN_LIB=ILEASTIC

BIND_LIB=*LIBL

TARGET_RLS=*CURRENT

#
# User-defined part end
#-------------------------------------------------------------------------------


# CFLAGS = compiler parameter
CFLAGS=OUTPUT(*PRINT) OPTION(*NOUNREF *SRCSTMT) DBGVIEW(*LIST) STGMDL(*INHERIT) INCDIR('../../' './') TGTRLS($(TARGET_RLS))

MODULES = cors

.SUFFIXES: .rpgle

.rpgle:
	system -ik "CHGATR OBJ('$<') ATR(*CCSID) VALUE(923)";\
	system -ik "CRTRPGMOD MODULE($(BIN_LIB)/$@) SRCSTMF('$<') $(CFLAGS)"
	
all: env compile bind

env:
	-system -qi "ADDBNDDIRE BNDDIR($(BIN_LIB)/ILEASTIC) OBJ(($(BIND_LIB)/CORS))"

compile: $(MODULES)

bind:
	-system -q "DLTOBJ OBJ($(BIN_LIB)/QSRVSRC) OBJTYPE(*FILE)"
	system "CRTSRCPF FILE($(BIN_LIB)/QSRVSRC) RCDLEN(112)"
	system "CPYFRMSTMF FROMSTMF('cors.bnd') TOMBR('/QSYS.lib/$(BIN_LIB).lib/QSRVSRC.file/cors.mbr') MBROPT(*replace)"
	-system -q "DLTOBJ OBJ($(BIN_LIB)/cors) OBJTYPE(*SRVPGM)"
	system -kpieb "CRTSRVPGM SRVPGM($(BIN_LIB)/cors) MODULE($(BIN_LIB)/cors) BNDSRVPGM(($(BIN_LIB)/ILEASTIC)) OPTION(*DUPPROC) DETAIL(*BASIC) STGMDL(*INHERIT) SRCFILE($(BIN_LIB)/QSRVSRC) TGTRLS($(TARGET_RLS)) TEXT('ILEastic - CORS Plugin')"
