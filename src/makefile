#-------------------------------------------------------------------------------
# User-defined part start
#

# note: ILE RPG compilers don't support UTF-8, so we use win-1252; However ILE C supports UTF-8

# BIN_LIB is the destination library for the service program.
# The rpg modules and the binder source file are also created in BIN_LIB.
# Binder source file and rpg module can be remove with the clean step 
# (make clean).
BIN_LIB=ILEASTIC
TARGET_RLS=*CURRENT
OUTPUT=*PRINT
OS_VERSION=$(shell echo "$(uname -v)$(uname -r)")
HAS_TGTCCSID=$(shell if [ $(OS_VERSION) -ge 74 ]; then echo yes; else echo no; fi)
ifeq ($(HAS_TGTCCSID),yes)
	TGTCCSID=TGTCCSID(37)
endif 
#
# User-defined part end
#-------------------------------------------------------------------------------


# system and application include folder
INCLUDE='/QIBM/include' '../headers/' '../' '../ILEfastCGI/include' '../noxDB/headers'

# CCFLAGS = C compiler parameter
CCFLAGS=OUTPUT($(OUTPUT)) OPTIMIZE(10) TGTCCSID(37) TGTRLS($(TARGET_RLS)) ENUM(*INT) TERASPACE(*YES) STGMDL(*INHERIT) SYSIFCOPT(*IFSIO) INCDIR($(INCLUDE)) DBGVIEW(*ALL)
RPGFLAGS=OUTPUT($(OUTPUT)) $(TGTCCSID) TGTRLS($(TARGET_RLS)) INCDIR($(INCLUDE)) DBGVIEW(*ALL)

MODULES = githash stream ileastic varchar api sndpgmmsg strUtil e2aa2e xlate simpleList serialize base64 fastCGI teramem ileasticr mediatype

.SUFFIXES: .c .rpgmod .sqlrpgmod

.c:
	system -i "CHGATR OBJ('$<') ATR(*CCSID) VALUE(1208)"
	system -ik "CRTCMOD MODULE($(BIN_LIB)/$@) SRCSTMF('$<') $(CCFLAGS)"

.rpgmod:
	system -i "CHGATR OBJ('$<') ATR(*CCSID) VALUE(1252)"
	system -ik "CRTRPGMOD MODULE($(BIN_LIB)/$@) SRCSTMF('$<') $(RPGFLAGS)"

.sqlrpgmod:
	system -i "CHGATR OBJ('$<') ATR(*CCSID) VALUE(1252)"
	system -ik "CRTSQLRPGI OBJ($(BIN_LIB)/$@) SRCSTMF('$<') OBJTYPE(*MODULE) RPGPPOPT(*LVL2) COMMIT(*NONE) DBGVIEW(*SOURCE) TGTRLS($(TARGET_RLS)) COMPILEOPT('INCDIR($(subst ','',$(INCLUDE)))')"

all: compile

compile: $(MODULES) 

