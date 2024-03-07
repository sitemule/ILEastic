#-------------------------------------------------------------------------------
# User-defined part start
#

# BIN_LIB is the destination library for the service program.
# The rpg modules and the binder source file are also created in BIN_LIB.
# Binder source file and rpg module can be remove with the clean step 
# (make clean).
BIN_LIB=ILEASTIC

DBGVIEW=*ALL
TARGET_CCSID=*JOB
TARGET_RLS=*CURRENT
OUTPUT=*NONE

#
# User-defined part end
#-------------------------------------------------------------------------------

TGTCCSID = $(if $(filter V7R3M0,$(TARGET_RLS)), "" , TGTCCSID($(TARGET_CCSID)))


# CFLAGS = compiler parameter
RCFLAGS=OUTPUT($(OUTPUT)) OPTION(*NOUNREF *SRCSTMT) STGMDL(*INHERIT) INCDIR('../../headers') DBGVIEW($(DBGVIEW)) TGTRLS($(TARGET_RLS)) $(TGTCCSID)

# CCFLAGS = C/C++ compiler parameter
CCFLAGS=OUTPUT($(OUTPUT)) OPTIMIZE(10) TGTCCSID(37) TGTRLS($(TGT_RLS)) ENUM(*INT) TERASPACE(*YES) STGMDL(*INHERIT) SYSIFCOPT(*IFSIO) DBGVIEW(*LIST)

MODULES = openapi openapiini oapimodgen


.SUFFIXES: .cpp .rpgmod

.rpgmod:
	system -q "CHGATR OBJ('$<') ATR(*CCSID) VALUE(1252)"
	system -i "CRTRPGMOD MODULE($(BIN_LIB)/$*) SRCSTMF('$<') $(RCFLAGS)"

.cpp:
	system -i "CHGATR OBJ('$<') ATR(*CCSID) VALUE(1208)"
	system -k "CRTCPPMOD MODULE($(BIN_LIB)/$@) SRCSTMF('$<') $(CCFLAGS)"



all: env compile bind

env:

compile: $(MODULES)

bind:
	system -k "CRTPGM PGM($(BIN_LIB)/OAPIMODGEN)"
	
commands:
	system -iK "CRTCMD $(BIN_LIB)/OAPIMODGEN PGM(*LIBL/OAPIMODGEN) SRCSTMF('oapimodgen.cmd')"

clean:
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/OPENAPI) OBJTYPE(*MODULE)"

.PHONY:

