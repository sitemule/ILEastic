#
# Build script for ILEastic Unit Tests
#


#-------------------------------------------------------------------------------
# User-defined part start
#

# BIN_LIB is the destination library for the unit tests.
BIN_LIB=ILEASTIC

# This folder contains the ASSERT copybook of the unit testing framework.
RUINCDIR=/usr/local/include/irpgunit

# Library which contains RUTESTCASE service program
RU_LIB=*LIBL

# This library contains the ILEASTIC modules.

TARGET_RLS=*CURRENT

DEFINE=RPG_HAS_OVERLOAD
#
# User-defined part end
#-------------------------------------------------------------------------------

# system and application include folder
INCLUDE='/QIBM/include' '../' '../../../'

# CCFLAGS = C compiler parameter
CCFLAGS=OUTPUT(*NONE) OPTIMIZE(10) TGTCCSID(37) TGTRLS($(TARGET_RLS)) ENUM(*INT) TERASPACE(*YES) STGMDL(*INHERIT) SYSIFCOPT(*IFSIO) INCDIR($(INCLUDE)) DBGVIEW(*ALL)

.SUFFIXES: .rpgmod

.rpgmod:
	system -i "CHGATR OBJ('$<') ATR(*CCSID) VALUE(1252)"

ILEASTIC_MODULES=($(BIN_LIB)/XLATE) ($(BIN_LIB)/STRUTIL) ($(BIN_LIB)/TERAMEM) ($(BIN_LIB)/SIMPLELIST) ($(BIN_LIB)/VARCHAR) ($(BIN_LIB)/E2AA2E)

OBJECTS = CORSUT
SRVPGMS = $(RU_LIB)/RUTESTCASE $(BIN_LIB)/ILEASTIC

all: clean compile

main:
	cd ../../../ && $(MAKE) KEEP_MODULES=true

plugin:
	cd ../ && $(MAKE) KEEP_MODULES=true

compile: $(OBJECTS)

CORSUT: corsut
	system -ik "CRTRPGMOD MODULE($(BIN_LIB)/CORSUT) SRCSTMF('corsut.rpgmod') INCDIR('$(RUINCDIR)' $(INCLUDE)) define($(DEFINE)) dbgview(*source) output(*print) stgmdl(*SNGLVL) TGTRLS($(TARGET_RLS)) OPTION(*EVENTF)"
	system -i "CRTSRVPGM $(BIN_LIB)/CORSUT MODULE(($(BIN_LIB)/CORSUT) ($(BIN_LIB)/CORS) $(ILEASTIC_MODULES)) STGMDL(*SNGLVL) BNDSRVPGM($(SRVPGMS)) EXPORT(*ALL) OPTION(*DUPPROC) TGTRLS($(TARGET_RLS)) TEXT('iRPGUnit - $@')"

clean:
	-system -i "DLTMOD $(BIN_LIB)/CORSUT"
	-system -i "DLTSRVPGM $(BIN_LIB)/CORSUT"
	