#-------------------------------------------------------------------------------
# User-defined part start
#

# BIN_LIB is the destination library for the service program.
# The rpg modules and the binder source file are also created in BIN_LIB.
# Binder source file and rpg module can be remove with the clean step 
# (make clean).
BIN_LIB=ILEASTIC

BIND_LIB=*LIBL
DBGVIEW=*ALL
TARGET_CCSID=*JOB
TARGET_RLS=*CURRENT
OUTPUT=*NONE
ILEVATOR_INCDIR=/usr/local/include/ilevator
ILEVATOR_LIB=*LIBL

#
# User-defined part end
#-------------------------------------------------------------------------------

TGTCCSID = $(if $(filter V7R3M0,$(TARGET_RLS)), "" , TGTCCSID($(TARGET_CCSID)))

# RCFLAGS = RPG compiler parameter
RCFLAGS=OUTPUT($(OUTPUT)) OPTION(*NOUNREF *SRCSTMT) STGMDL(*INHERIT) INCDIR('../../headers' '../..' '$(ILEVATOR_INCDIR)') DBGVIEW($(DBGVIEW)) TGTRLS($(TARGET_RLS)) DEFINE($(DEFINE)) $(TGTCCSID)

# Do not touch below
INCLUDE='/QIBM/include' '.' '../../headers/'  

# C compile flags
CCFLAGS=OUTPUT($(OUTPUT)) OPTION(*NOSHOWINC) OPTIMIZE(10) ENUM(*INT) TERASPACE(*YES) STGMDL(*INHERIT) SYSIFCOPT(*IFSIO) INCDIR($(INCLUDE)) DBGVIEW(*ALL) DEFINE($(DEFINE)) TGTCCSID($(TARGET_CCSID)) TGTRLS($(TARGET_RLS))

MODULES = kong.rpgmod message.c

# remove all default suffix rules
.SUFFIXES:

%.rpgmod: .PHONY
	system -q "CHGATR OBJ('$*.rpgmod') ATR(*CCSID) VALUE(819)"
	system -i "CRTRPGMOD MODULE($(BIN_LIB)/$*) SRCSTMF('$*.rpgmod') $(RCFLAGS)"

%.c: .PHONY
	system -q "CHGATR OBJ('$*.c') ATR(*CCSID) VALUE(1252)"
	system "CRTCMOD MODULE($(BIN_LIB)/$(notdir $*)) SRCSTMF('$*.c') $(CCFLAGS)"

all: env compile bind

env:

compile: $(MODULES)

bind:
	system -pieb "CRTSRVPGM SRVPGM($(BIN_LIB)/ILKONG) MODULE($(BIN_LIB)/KONG $(BIN_LIB)/MESSAGE) BNDSRVPGM(($(ILEVATOR_LIB)/ILEVATOR) ($(BIND_LIB)/JSONXML)) OPTION(*DUPPROC) DETAIL(*BASIC) STGMDL(*INHERIT) SRCSTMF('kong.bnd') TGTRLS($(TARGET_RLS)) TEXT('ILEastic - Kong Registrar')"

clean:
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/KONG) OBJTYPE(*MODULE)"

purge: clean
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/ILKONG) OBJTYPE(*SRVPGM)"

.PHONY:
