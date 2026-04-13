#
# Build script for ILEastic Integration Test
#


#-------------------------------------------------------------------------------
# User-defined part start
#

# BIN_LIB is the destination library for the unit tests.
BIN_LIB=ILEASTIC

# This library contains the ILEASTIC modules.
ILEASTIC_LIB=ILEASTIC

ILEVATOR_LIB=ILEVATOR
ILEVATOR_INCDIR=/usr/local/include/ilevator

RPGUNIT_LIB=RPGUNIT

OUTPUT=*NONE

TARGET_RLS=*CURRENT
#
# User-defined part end
#-------------------------------------------------------------------------------

# system and application include folder
INCLUDE='.' '/QIBM/include' '../headers/' '../ILEfastCGI/include' '../noxDB/headers' '$(ILEVATOR_INCDIR)'

.SUFFIXES: .rpgle

.rpgle:
	system -i "CHGATR OBJ('$<') ATR(*CCSID) VALUE(1252)"

OBJECTS = ILBASICS ILBASICST
SRVPGMS = $(ILEASTIC_LIB)/ILEFASTCGI $(ILEASTIC_LIB)/JSONXML $(ILEASTIC_LIB)/ILEASTIC $(RPGUNIT_LIB)/RUTESTCASE $(ILEVATOR_LIB)/ILEVATOR

all: clean compile

main:
	cd .. && $(MAKE)

compile: $(OBJECTS)

ILBASICS: ilbasics
	system -i "CRTRPGMOD MODULE($(BIN_LIB)/ILBASICS) SRCSTMF('ilbasics.rpgle') INCDIR($(INCLUDE)) DBGVIEW(*LIST) OUTPUT($(OUTPUT)) STGMDL(*SNGLVL) TGTRLS($(TARGET_RLS))"
	system -i "CRTPGM $(BIN_LIB)/ILBASICS STGMDL(*SNGLVL) BNDSRVPGM($(SRVPGMS)) OPTION(*DUPPROC) TGTRLS($(TARGET_RLS))"

ILBASICST: ilbasicst
	system -i "CRTRPGMOD MODULE($(BIN_LIB)/ILBASICST) SRCSTMF('ilbasicst.rpgle') INCDIR($(INCLUDE)) DBGVIEW(*LIST) OUTPUT($(OUTPUT)) STGMDL(*SNGLVL) TGTRLS($(TARGET_RLS))"
	system -i "CRTSRVPGM $(BIN_LIB)/ILBASICST STGMDL(*SNGLVL) BNDSRVPGM($(SRVPGMS)) OPTION(*DUPPROC) TGTRLS($(TARGET_RLS)) EXPORT(*ALL)"

clean:
	-system -i "DLTMOD $(BIN_LIB)/ILBASICS"
	-system -i "DLTPGM $(BIN_LIB)/ILBASICS"
	-system -i "DLTMOD $(BIN_LIB)/ILBASICST"
	-system -i "DLTSRVPGM $(BIN_LIB)/ILBASICST"
	