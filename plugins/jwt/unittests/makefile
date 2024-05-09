#-------------------------------------------------------------------------------
# User-defined part start
#

# BIN_LIB is the destination library for the service program.
# The rpg modules and the binder source file are also created in BIN_LIB.
# Binder source file and rpg module can be remove with the clean step 
# (make clean).
BIN_LIB=ILEASTIC

TARGET_CCSID=*JOB
TARGET_RLS=*CURRENT
OUTPUT=*NONE

# Library which contains RUTESTCASE service program
RU_LIB=*LIBL

#
# User-defined part end
#-------------------------------------------------------------------------------

TGTCCSID = $(if $(filter V7R3M0,$(TARGET_RLS)), "" , TGTCCSID($(TARGET_CCSID)))
SRVPGMS = ($(RU_LIB)/RUTESTCASE) ($(BIN_LIB)/JSONXML)
OBJECTS = HMACUT RSAUT JWTUT JWTPLUGUT

# RCFLAGS = RPG compiler parameter
RCFLAGS=OUTPUT($(OUTPUT)) OPTION(*NOUNREF *SRCSTMT) STGMDL(*INHERIT) INCDIR('../../../headers' '../.' '../../..') DBGVIEW(*ALL) TGTRLS($(TARGET_RLS)) DEFINE($(DEFINE)) $(TGTCCSID)

# Bind options
BINDFLAGS=STGMDL(*SNGLVL) BNDSRVPGM($(SRVPGMS)) EXPORT(*ALL) OPTION(*DUPPROC)


all: compile

%.rpgmod: .PHONY
	system -q "CHGATR OBJ('$*.rpgmod') ATR(*CCSID) VALUE(1252)"
	system -i "CRTRPGMOD MODULE($(BIN_LIB)/$*) SRCSTMF('$*.rpgmod') $(RCFLAGS)"

HMACUT:
	system -i "CHGATR OBJ('hmacut.rpgmod') ATR(*CCSID) VALUE(1252)"
	system -ik "CRTRPGMOD MODULE($(BIN_LIB)/HMACUT) SRCSTMF('hmacut.rpgmod') $(RCFLAGS)"
	system -i "CRTSRVPGM $(BIN_LIB)/HMACUT MODULE(($(BIN_LIB)/HMACUT) ($(BIN_LIB)/HMAC) ($(BIN_LIB)/BASE64) ($(BIN_LIB)/BASE64URL) ($(BIN_LIB)/MESSAGE)) $(BINDFLAGS)"

RSAUT:
	system -i "CHGATR OBJ('rsaut.rpgmod') ATR(*CCSID) VALUE(1252)"
	system -ik "CRTRPGMOD MODULE($(BIN_LIB)/RSAUT) SRCSTMF('rsaut.rpgmod') $(RCFLAGS)"
	system -i "CRTSRVPGM $(BIN_LIB)/RSAUT MODULE(($(BIN_LIB)/RSAUT) ($(BIN_LIB)/RSA) ($(BIN_LIB)/BASE64) ($(BIN_LIB)/BASE64URL) ($(BIN_LIB)/MESSAGE)) $(BINDFLAGS)"

JWTUT:
	system -i "CHGATR OBJ('jwtut.rpgmod') ATR(*CCSID) VALUE(1252)"
	system -ik "CRTRPGMOD MODULE($(BIN_LIB)/JWTUT) SRCSTMF('jwtut.rpgmod') $(RCFLAGS)"
	system -i "CRTSRVPGM $(BIN_LIB)/JWTUT MODULE(($(BIN_LIB)/JWTUT) ($(BIN_LIB)/JWT) ($(BIN_LIB)/HMAC) ($(BIN_LIB)/RSA) ($(BIN_LIB)/BASE64) ($(BIN_LIB)/BASE64URL) ($(BIN_LIB)/MESSAGE)) $(BINDFLAGS)"

JWTPLUGUT:
	system -i "CHGATR OBJ('jwtplugut.rpgmod') ATR(*CCSID) VALUE(1252)"
	system -ik "CRTRPGMOD MODULE($(BIN_LIB)/JWTPLUGUT) SRCSTMF('jwtplugut.rpgmod') $(RCFLAGS)"
	system -i "CRTSRVPGM $(BIN_LIB)/JWTPLUGUT MODULE(($(BIN_LIB)/JWTPLUGUT) ($(BIN_LIB)/JWTPLUGIN) ($(BIN_LIB)/JWT) ($(BIN_LIB)/HMAC) ($(BIN_LIB)/RSA) ($(BIN_LIB)/BASE64) ($(BIN_LIB)/BASE64URL) ($(BIN_LIB)/MESSAGE)) $(BINDFLAGS)"

compile: $(OBJECTS)

clean:
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/HMACUT) OBJTYPE(*MODULE)"
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/HMACUT) OBJTYPE(*SRVPGM)"
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/RSAUT) OBJTYPE(*MODULE)"
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/RSAUT) OBJTYPE(*SRVPGM)"
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/JWTUT) OBJTYPE(*MODULE)"
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/JWTUT) OBJTYPE(*SRVPGM)"
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/JWTPLUGUT) OBJTYPE(*MODULE)"
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/JWTPLUGUT) OBJTYPE(*SRVPGM)"

.PHONY:
