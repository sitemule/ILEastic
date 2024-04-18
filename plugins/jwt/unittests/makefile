#-------------------------------------------------------------------------------
# User-defined part start
#

# BIN_LIB is the destination library for the service program.
# The rpg modules and the binder source file are also created in BIN_LIB.
# Binder source file and rpg module can be remove with the clean step 
# (make clean).
BIN_LIB=ILEASTIC

BIND_LIB=*LIBL

TARGET_CCSID=*JOB
TARGET_RLS=*CURRENT
OUTPUT=*NONE

# Library which contains RUTESTCASE service program
RU_LIB=*LIBL

#
# User-defined part end
#-------------------------------------------------------------------------------

TGTCCSID = $(if $(filter V7R3M0,$(TARGET_RLS)), "" , TGTCCSID($(TARGET_CCSID)))

# RCFLAGS = RPG compiler parameter
RCFLAGS=OUTPUT($(OUTPUT)) OPTION(*NOUNREF *SRCSTMT) STGMDL(*INHERIT) INCDIR('../../../headers' '../.') DBGVIEW(*ALL) TGTRLS($(TARGET_RLS)) DEFINE($(DEFINE)) $(TGTCCSID)

# Bind options
BINDFLAGS=STGMDL(*SNGLVL) BNDSRVPGM($(SRVPGMS)) EXPORT(*ALL) OPTION(*DUPPROC)

OBJECTS = HMACUT
SRVPGMS = ($(RU_LIB)/RUTESTCASE)

all: compile

%.rpgmod: .PHONY
	system -q "CHGATR OBJ('$*.rpgmod') ATR(*CCSID) VALUE(819)"
	system -i "CRTRPGMOD MODULE($(BIN_LIB)/$*) SRCSTMF('$*.rpgmod') $(RCFLAGS)"

HMACUT:
	system -i "CHGATR OBJ('hmacut.rpgmod') ATR(*CCSID) VALUE(1252)"
	system -ik "CRTRPGMOD MODULE($(BIN_LIB)/HMACUT) SRCSTMF('hmacut.rpgmod') $(RCFLAGS)"
	system -i "CRTSRVPGM $(BIN_LIB)/HMACUT MODULE(($(BIN_LIB)/HMACUT) ($(BIN_LIB)/HMAC) ($(BIN_LIB)/BASE64) ($(BIN_LIB)/BASE64URL) ($(BIN_LIB)/MESSAGE)) $(BINDFLAGS)"

compile: $(OBJECTS)

clean:
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/HMACUT) OBJTYPE(*MODULE)"

.PHONY:
