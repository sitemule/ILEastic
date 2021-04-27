#-------------------------------------------------------------------------------
# User-defined part start
#

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
CFLAGS=OUTPUT(*PRINT) OPTION(*NOUNREF *SRCSTMT) STGMDL(*INHERIT) INCDIR('../..') DBGVIEW(*ALL) TGTRLS($(TARGET_RLS))

MODULES = jwt jwtplugin

.SUFFIXES: .rpgle

.rpgle:
	system -i "CHGATR OBJ('$<') ATR(*CCSID) VALUE(819)"
	-system -i "RMVM FILE($(BIN_LIB)/JWTSRC) MBR($@)"
	system -i "CPYFRMSTMF FROMSTMF('$<') TOMBR('/QSYS.LIB/$(BIN_LIB).LIB/JWTSRC.FILE/$@.MBR') MBROPT(*ADD)"
	system -ikK "CRTRPGMOD MODULE($(BIN_LIB)/$@) SRCFILE($(BIN_LIB)/JWTSRC) SRCMBR($@) $(CFLAGS)"
	
all: env compile bind

env:
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/JWTSRC) OBJTYPE(*FILE)"
	system -i "CRTSRCPF FILE($(BIN_LIB)/JWTSRC) RCDLEN(200)"
	-system -qi "ADDBNDDIRE BNDDIR($(BIN_LIB)/ILEASTIC) OBJ(($(BIND_LIB)/JWT))"
	-system -qi "ADDBNDDIRE BNDDIR($(BIN_LIB)/ILEASTIC) OBJ(($(BIND_LIB)/ILJWTPLUG))"

compile: $(MODULES)

bind:
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/QSRVSRC) OBJTYPE(*FILE)"
	system -i "CRTSRCPF FILE($(BIN_LIB)/QSRVSRC) RCDLEN(112)"
	system -i "CPYFRMSTMF FROMSTMF('jwt.bnd') TOMBR('/QSYS.LIB/$(BIN_LIB).LIB/QSRVSRC.FILE/JWT.MBR') MBROPT(*ADD)"
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/JWT) OBJTYPE(*SRVPGM)"
	system -pieb "CRTSRVPGM SRVPGM($(BIN_LIB)/JWT) MODULE($(BIN_LIB)/JWT) BNDSRVPGM(($(BIN_LIB)/ILEASTIC) ($(BIN_LIB)/JSONXML)) OPTION(*DUPPROC) DETAIL(*BASIC) STGMDL(*INHERIT) SRCFILE($(BIN_LIB)/QSRVSRC) TGTRLS($(TARGET_RLS)) TEXT('ILEastic - JWT')"
	system -i "CPYFRMSTMF FROMSTMF('jwtplugin.bnd') TOMBR('/QSYS.LIB/$(BIN_LIB).LIB/QSRVSRC.FILE/ILJWTPLUG.MBR') MBROPT(*ADD)"
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/ILJWTPLUG) OBJTYPE(*SRVPGM)"
	system -pieb "CRTSRVPGM SRVPGM($(BIN_LIB)/ILJWTPLUG) MODULE($(BIN_LIB)/JWTPLUGIN) BNDSRVPGM(($(BIND_LIB)/ILEASTIC) ($(BIND_LIB)/JSONXML) ($(BIND_LIB)/JWT)) OPTION(*DUPPROC) DETAIL(*BASIC) STGMDL(*INHERIT) SRCFILE($(BIN_LIB)/QSRVSRC) TEXT('ILEastic - JWT Plugin')"

clean:
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/QSRVSRC) OBJTYPE(*FILE)"
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/JWTSRC) OBJTYPE(*FILE)"
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/JWT) OBJTYPE(*MODULE)"
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/JWTPLUGIN) OBJTYPE(*MODULE)"
