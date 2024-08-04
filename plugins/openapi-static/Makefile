#-------------------------------------------------------------------------------
# User-defined part start
#

# BIN_LIB is the destination library for the service program.
# The rpg modules and the binder source file are also created in BIN_LIB.
# Binder source file and rpg module can be remove with the clean step 
# (make clean).
export BIN_LIB=ILEASTIC

export DBGVIEW=*ALL
export TARGET_CCSID=*JOB
export TARGET_RLS=*CURRENT
export OUTPUT=*NONE

#
# User-defined part end
#-------------------------------------------------------------------------------

TGTCCSID = $(if $(filter V7R3M0,$(TARGET_RLS)), "" , TGTCCSID($(TARGET_CCSID)))


# CFLAGS = compiler parameter
RCFLAGS=OUTPUT($(OUTPUT)) OPTION(*NOUNREF *SRCSTMT) STGMDL(*INHERIT) INCDIR('../../headers' 'ext/llist') DBGVIEW($(DBGVIEW)) TGTRLS($(TARGET_RLS)) $(TGTCCSID)

# CCFLAGS = C/C++ compiler parameter
CCFLAGS=OUTPUT($(OUTPUT)) OPTIMIZE(10) TGTCCSID(37) TGTRLS($(TARGET_RLS)) ENUM(*INT) TERASPACE(*YES) STGMDL(*INHERIT) SYSIFCOPT(*IFSIO) DBGVIEW(*LIST)

MODULES = message openapi openapiini oapimodgen oapisrcgen
COMMANDS = oapimodgen.cmd oapisrcgen.cmd 
PROGRAMS = oapimodgen.pgm oapisrcgen.pgm

.SUFFIXES: .cpp .rpgmod

.rpgmod:
	system -q "CHGATR OBJ('$<') ATR(*CCSID) VALUE(1252)"
	system -i "CRTRPGMOD MODULE($(BIN_LIB)/$*) SRCSTMF('$<') $(RCFLAGS)"

.cpp:
	system -i "CHGATR OBJ('$<') ATR(*CCSID) VALUE(1208)"
	system -k "CRTCPPMOD MODULE($(BIN_LIB)/$@) SRCSTMF('$<') $(CCFLAGS)"


all: env compile bind commands

env:

compile: $(MODULES)
	$(MAKE) -C ext/llist/ compile

bind: $(PROGRAMS)

oapisrcgen.pgm: .PHONY
	system -k "CRTPGM PGM($(BIN_LIB)/OAPISRCGEN) MODULE($(BIN_LIB)/OAPISRCGEN $(BIN_LIB)/MESSAGE $(BIN_LIB)/LLIST $(BIN_LIB)/LLIST_SORT) TGTRLS($(TARGET_RLS))"

oapimodgen.pgm: .PHONY
	system -k "CRTPGM PGM($(BIN_LIB)/OAPIMODGEN) MODULE($(BIN_LIB)/OAPIMODGEN $(BIN_LIB)/MESSAGE) TGTRLS($(TARGET_RLS))"
	
commands: $(COMMANDS)

oapisrcgen.cmd: .PHONY
	system -iK "CRTCMD $(BIN_LIB)/OAPISRCGEN PGM(*LIBL/OAPISRCGEN) SRCSTMF('oapisrcgen.cmd')"

oapimodgen.cmd: .PHONY
	system -iK "CRTCMD $(BIN_LIB)/OAPIMODGEN PGM(*LIBL/OAPIMODGEN) SRCSTMF('oapimodgen.cmd')"

clean:
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/OPENAPI) OBJTYPE(*MODULE)"
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/OPENAPIINI) OBJTYPE(*MODULE)"
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/OAPIMODGEN) OBJTYPE(*MODULE)"
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/OAPIMODGEN) OBJTYPE(*PGM)"
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/OAPIMODGEN) OBJTYPE(*CMD)"
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/OAPISRCGEN) OBJTYPE(*MODULE)"
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/OAPISRCGEN) OBJTYPE(*PGM)"
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/OAPISRCGEN) OBJTYPE(*CMD)"
	$(MAKE) -C ext/llist/ clean $*

install:

.PHONY:

