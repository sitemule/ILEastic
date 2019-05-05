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

#
# User-defined part end
#-------------------------------------------------------------------------------


# CFLAGS = compiler parameter
CFLAGS=OUTPUT(*NONE) OPTION(*NOUNREF *SRCSTMT) DBGVIEW(*LIST) STGMDL(*INHERIT) INCDIR('../..')

MODULES = jwt jwtplugin

.SUFFIXES: .rpgle

.rpgle:
	system -ik "CRTRPGMOD MODULE($(BIN_LIB)/$@) SRCSTMF('$<') $(CFLAGS)"
	
all: env compile bind

env:
	-system -qi "ADDBNDDIRE BNDDIR($(BIN_LIB)/ILEASTIC) OBJ(($(BIND_LIB)/JWT))"
	-system -qi "ADDBNDDIRE BNDDIR($(BIN_LIB)/ILEASTIC) OBJ(($(BIND_LIB)/ILJWTPLUG))"

compile: $(MODULES)

bind:
	system -q "DLTOBJ OBJ($(BIN_LIB)/QSRVSRC) OBJTYPE(*FILE)";\
	system "CRTSRCPF FILE($(BIN_LIB)/QSRVSRC) RCDLEN(112)";\
	system "CPYFRMSTMF FROMSTMF('jwt.bnd') TOMBR('/QSYS.lib/$(BIN_LIB).lib/QSRVSRC.file/JWT.mbr') MBROPT(*replace)";\
	system -q "DLTOBJ OBJ($(BIN_LIB)/JWT) OBJTYPE(*SRVPGM)";\
	system -kpieb "CRTSRVPGM SRVPGM($(BIN_LIB)/JWT) MODULE($(BIN_LIB)/JWT) BNDSRVPGM(($(BIN_LIB)/ILEASTIC) ($(BIN_LIB)/JSONXML)) OPTION(*DUPPROC) DETAIL(*BASIC) STGMDL(*INHERIT) SRCFILE($(BIN_LIB)/QSRVSRC) TEXT('ILEastic - JWT')";\
	system "CPYFRMSTMF FROMSTMF('jwtplugin.bnd') TOMBR('/QSYS.lib/$(BIN_LIB).lib/QSRVSRC.file/ILJWTPLUG.mbr') MBROPT(*replace)";\
	system -q "DLTOBJ OBJ($(BIN_LIB)/ILJWTPLUG) OBJTYPE(*SRVPGM)";\
	system -kpieb "CRTSRVPGM SRVPGM($(BIN_LIB)/ILJWTPLUG) MODULE($(BIN_LIB)/JWTPLUGIN) BNDSRVPGM(($(BIND_LIB)/ILEASTIC) ($(BIND_LIB)/JSONXML) ($(BIND_LIB)/JWT)) OPTION(*DUPPROC) DETAIL(*BASIC) STGMDL(*INHERIT) SRCFILE($(BIN_LIB)/QSRVSRC) TEXT('ILEastic - JWT Plugin')";
