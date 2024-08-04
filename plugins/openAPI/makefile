#-------------------------------------------------------------------------------
# User-defined part start
#

# BIN_LIB is the destination library for the service program.
# The rpg modules and the binder source file are also created in BIN_LIB.
# Binder source file and rpg module can be remove with the clean step 
# (make clean).
BIN_LIB=ILEASTIC

BIND_LIB=*LIBL
OUTPUT=*NONE

TARGET_RLS=*CURRENT
INCLUDE='/QIBM/include' './headers/' '../../headers/' '../' '../../ILEfastCGI/include' '../../noxDB/headers' '../../noxDB/headers/ext'
SHELL=/QOpenSys/usr/bin/qsh

#
# User-defined part end
#-------------------------------------------------------------------------------

# RPGFLAGS = RPG compiler parameter
RPGFLAGS=OUTPUT(*PRINT) OPTION(*NOUNREF *SRCSTMT) STGMDL(*INHERIT) INCDIR('../..') DBGVIEW(*ALL) TGTRLS($(TARGET_RLS))

# CFLAGS = C compiler parameter
CFLAGS=OPTION(*STDLOGMSG) OUTPUT($(OUTPUT)) OPTIMIZE(10) TGTCCSID(37) TGTRLS($(TARGET_RLS)) ENUM(*INT) TERASPACE(*YES) STGMDL(*INHERIT) SYSIFCOPT(*IFSIO) INCDIR($(INCLUDE)) DBGVIEW(*ALL)

MODULES = loadpgm trycatch addpgmrte teramem e2aa2e strutil

.SUFFIXES: .c

.c:
	system -i "CHGATR OBJ('$<') ATR(*CCSID) VALUE(819)"
	system -ik "CRTCMOD MODULE($(BIN_LIB)/$@) SRCSTMF('$<') $(CFLAGS)"

.rpgle:
	system -i "CHGATR OBJ('$<') ATR(*CCSID) VALUE(819)"
	-system -i "RMVM FILE($(BIN_LIB)/JWTSRC) MBR($@)"
	system -i "CPYFRMSTMF FROMSTMF('$<') TOMBR('/QSYS.LIB/$(BIN_LIB).LIB/JWTSRC.FILE/$@.MBR') MBROPT(*ADD)"
	system -ikK "CRTRPGMOD MODULE($(BIN_LIB)/$@) SRCFILE($(BIN_LIB)/JWTSRC) SRCMBR($@) $(CFLAGS)"
	
all: compile srvpgm bnddir

compile: $(MODULES)


%.csss:
	system -i "CHGATR OBJ('$*.c') ATR(*CCSID) VALUE(1208)"
	system -ik "CRTCMOD MODULE($(BIN_LIB)/$(notdir $*)) SRCSTMF('src/$*.c') $(CFLAGS)"


srvpgm:
	@# You may be wondering what this ugly string is. It's a list of objects created from the dep list that end with .c or .clle.
	@$(eval modules := $(patsubst %,$(BIN_LIB)/%,$(MODULES)))

	-system -qi "DLTOBJ OBJ($(BIN_LIB)/QSRVSRC) OBJTYPE(*FILE)"
	system -i "CRTSRCPF FILE($(BIN_LIB)/QSRVSRC) RCDLEN(112)"
	system -i "CPYFRMSTMF FROMSTMF('openapi.bnd') TOMBR('/QSYS.LIB/$(BIN_LIB).LIB/QSRVSRC.FILE/OPENAPI.MBR') MBROPT(*ADD)"
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/OPENAPI) OBJTYPE(*SRVPGM)"
	liblist -a $(BIN_LIB); \
	system -pieb "CRTSRVPGM SRVPGM($(BIN_LIB)/OPENAPI) MODULE($(modules)) BNDSRVPGM(($(BIND_LIB)/ILEASTIC) ($(BIND_LIB)/JSONXML)) OPTION(*DUPPROC) DETAIL(*BASIC) STGMDL(*INHERIT) SRCFILE($(BIN_LIB)/QSRVSRC) TGTRLS($(TARGET_RLS)) TEXT('ILEastic - openAPI')"

bnddir:
	@-system -q "DLTBNDDIR BNDDIR($(BIN_LIB)/OPENAPI)"
	@system -q "CRTBNDDIR BNDDIR($(BIN_LIB)/OPENAPI)"
	system -q "ADDBNDDIRE BNDDIR($(BIN_LIB)/OPENAPI) OBJ((*LIBL/OPENAPI *SRVPGM *IMMED))"


clean:
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/QSRVSRC) OBJTYPE(*FILE)"
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/OPENAPISRC) OBJTYPE(*FILE)"
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/OPENAPI) OBJTYPE(*MODULE)"

install: