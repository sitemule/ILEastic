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
ILEASTIC_LIB=ILEASTIC

TARGET_RLS=*CURRENT
#
# User-defined part end
#-------------------------------------------------------------------------------

# system and application include folder
INCLUDE='/QIBM/include' '../headers/' '../ILEfastCGI/include' '../noxDB/headers'

# CCFLAGS = C compiler parameter
CCFLAGS=OUTPUT(*NONE) OPTIMIZE(10) TGTCCSID(37) TGTRLS($(TARGET_RLS)) ENUM(*INT) TERASPACE(*YES) STGMDL(*INHERIT) SYSIFCOPT(*IFSIO) INCDIR($(INCLUDE)) DBGVIEW(*ALL)

.SUFFIXES: .c .rpgle

.c:
	system -i "CHGATR OBJ('$<') ATR(*CCSID) VALUE(1208)"
	system -ik "CRTCMOD MODULE($(BIN_LIB)/$@) SRCSTMF('$<') $(CCFLAGS)"

.rpgle:
	system -i "CHGATR OBJ('$<') ATR(*CCSID) VALUE(1252)"

ILEASTIC_MODULES=($(ILEASTIC_LIB)/ILEASTIC) ($(ILEASTIC_LIB)/API) ($(ILEASTIC_LIB)/SIMPLELIST) ($(ILEASTIC_LIB)/VARCHAR) ($(ILEASTIC_LIB)/STREAM) ($(ILEASTIC_LIB)/XLATE) ($(ILEASTIC_LIB)/E2AA2E) ($(ILEASTIC_LIB)/STRUTIL) ($(ILEASTIC_LIB)/SNDPGMMSG) ($(ILEASTIC_LIB)/SERIALIZE) ($(ILEASTIC_LIB)/BASE64) ($(ILEASTIC_LIB)/FASTCGI) ($(ILEASTIC_LIB)/TERAMEM) 

OBJECTS = REQUEST ROUTING PLUGIN BASE64UT SMPLLSTUT RESOURCE ROUTEID PARMLISTUT
SRVPGMS = $(RU_LIB)/RUTESTCASE $(ILEASTIC_LIB)/ILEFASTCGI $(ILEASTIC_LIB)/JSONXML

all: clean compile TAG

main:
	cd .. && $(MAKE) KEEP_MODULES=true

compile: $(OBJECTS)

PARMLISTUT: parmlistut parmlist
	system -i "CRTSRVPGM $(BIN_LIB)/PARMLIST MODULE(($(BIN_LIB)/PARMLIST)) STGMDL(*SNGLVL) EXPORT(*ALL) OPTION(*DUPPROC) TGTRLS($(TARGET_RLS))"
	system -i "CRTRPGMOD MODULE($(BIN_LIB)/PARMLISTUT) SRCSTMF('parmlistut.rpgle') INCDIR('$(RUINCDIR)') dbgview(*source) output(*print) stgmdl(*SNGLVL) TGTRLS($(TARGET_RLS))"
	system -i "CRTSRVPGM $(BIN_LIB)/PARMLISTUT MODULE(($(BIN_LIB)/PARMLISTUT)) STGMDL(*SNGLVL) BNDSRVPGM($(BIN_LIB)/PARMLIST $(RU_LIB)/RUTESTCASE) EXPORT(*ALL) OPTION(*DUPPROC) TGTRLS($(TARGET_RLS)) TEXT('iRPGUnit - $@')"

ROUTEID: routeid
	system -i "CRTRPGMOD MODULE($(BIN_LIB)/ROUTEID) SRCSTMF('routeid.rpgle') INCDIR('$(RUINCDIR)') dbgview(*source) output(*print) stgmdl(*SNGLVL) TGTRLS($(TARGET_RLS))"
	system -i "CRTSRVPGM $(BIN_LIB)/ROUTEID MODULE(($(BIN_LIB)/ROUTEID) $(ILEASTIC_MODULES)) STGMDL(*SNGLVL) BNDSRVPGM($(SRVPGMS)) EXPORT(*ALL) OPTION(*DUPPROC) TGTRLS($(TARGET_RLS)) TEXT('iRPGUnit - $@')"

REQUEST: request
	system -i "CRTRPGMOD MODULE($(BIN_LIB)/REQUEST) SRCSTMF('request.rpgle') INCDIR('$(RUINCDIR)') dbgview(*source) stgmdl(*SNGLVL) TGTRLS($(TARGET_RLS))"
	system -i "CRTSRVPGM $(BIN_LIB)/REQUEST MODULE(($(BIN_LIB)/REQUEST) $(ILEASTIC_MODULES)) STGMDL(*SNGLVL) BNDSRVPGM($(SRVPGMS)) EXPORT(*ALL) OPTION(*DUPPROC) TGTRLS($(TARGET_RLS)) TEXT('iRPGUnit - $@')"

ROUTING: routing
	system -i "CRTRPGMOD MODULE($(BIN_LIB)/ROUTING) SRCSTMF('routing.rpgle') INCDIR('$(RUINCDIR)') dbgview(*source) output(*print) stgmdl(*SNGLVL) TGTRLS($(TARGET_RLS))"
	system -i "CRTSRVPGM $(BIN_LIB)/ROUTING MODULE(($(BIN_LIB)/ROUTING) $(ILEASTIC_MODULES)) STGMDL(*SNGLVL) BNDSRVPGM($(SRVPGMS)) EXPORT(*ALL) OPTION(*DUPPROC) TGTRLS($(TARGET_RLS)) TEXT('iRPGUnit - $@')"

PLUGIN: plugin
	system -i "CRTRPGMOD MODULE($(BIN_LIB)/PLUGIN) SRCSTMF('plugin.rpgle') INCDIR('$(RUINCDIR)') dbgview(*source) output(*print) stgmdl(*SNGLVL) TGTRLS($(TARGET_RLS))"
	system -i "CRTSRVPGM $(BIN_LIB)/PLUGIN MODULE(($(BIN_LIB)/PLUGIN) $(ILEASTIC_MODULES)) STGMDL(*SNGLVL) BNDSRVPGM($(SRVPGMS)) EXPORT(*ALL) OPTION(*DUPPROC) TGTRLS($(TARGET_RLS)) TEXT('iRPGUnit - $@')"

BASE64UT: base64ut
	system -ik "CRTRPGMOD MODULE($(BIN_LIB)/BASE64UT) SRCSTMF('base64ut.rpgle') INCDIR('$(RUINCDIR)') dbgview(*source) output(*print) stgmdl(*SNGLVL) TGTRLS($(TARGET_RLS))"
	system -i "CRTSRVPGM $(BIN_LIB)/BASE64UT MODULE(($(BIN_LIB)/BASE64UT) $(ILEASTIC_MODULES)) STGMDL(*SNGLVL) BNDSRVPGM($(SRVPGMS)) EXPORT(*ALL) OPTION(*DUPPROC) TGTRLS($(TARGET_RLS)) TEXT('iRPGUnit - $@')"

SMPLLSTUT: smpllstut
	system -i "CRTRPGMOD MODULE($(BIN_LIB)/SMPLLSTUT) SRCSTMF('smpllstut.rpgle') INCDIR('$(RUINCDIR)') dbgview(*source) output(*print) stgmdl(*SNGLVL) TGTRLS($(TARGET_RLS))"
	system -i "CRTSRVPGM $(BIN_LIB)/SMPLLSTUT MODULE(($(BIN_LIB)/SMPLLSTUT) $(ILEASTIC_MODULES)) STGMDL(*SNGLVL) BNDSRVPGM($(SRVPGMS)) EXPORT(*ALL) OPTION(*DUPPROC) TGTRLS($(TARGET_RLS)) TEXT('iRPGUnit - $@')"

RESOURCE: resource
	system -ik "CRTRPGMOD MODULE($(BIN_LIB)/RESOURCE) SRCSTMF('resource.rpgle') INCDIR('$(RUINCDIR)') dbgview(*source) output(*print) stgmdl(*SNGLVL) TGTRLS($(TARGET_RLS))"
	system -ik "CRTSRVPGM $(BIN_LIB)/RESOURCE MODULE(($(BIN_LIB)/RESOURCE) $(ILEASTIC_MODULES)) STGMDL(*SNGLVL) BNDSRVPGM($(SRVPGMS)) EXPORT(*ALL) OPTION(*DUPPROC) TGTRLS($(TARGET_RLS)) TEXT('iRPGUnit - $@')"

TAG:
	system -i "CHGATR OBJ('../utils/userattr.rpgle') ATR(*CCSID) VALUE(1252)"
	system -ik "CRTBNDRPG PGM($(BIN_LIB)/USERATTR) SRCSTMF('../utils/userattr.rpgle') OPTION(*EVENTF) DBGVIEW(*SOURCE) TGTRLS($(TARGET_RLS))"
	@for module in $(OBJECTS); do \
		system -iq "CALL PGM($(BIN_LIB)/USERATTR) PARM(($$module (*CHAR 10)) ($(BIN_LIB) (*CHAR 10)))" ; \
	done

clean:
	-system -i "DLTMOD $(BIN_LIB)/REQUEST"
	-system -i "DLTSRVPGM $(BIN_LIB)/REQUEST"
	-system -i "DLTMOD $(BIN_LIB)/ROUTING"
	-system -i "DLTSRVPGM $(BIN_LIB)/ROUTING"
	-system -i "DLTMOD $(BIN_LIB)/PLUGIN"
	-system -i "DLTSRVPGM $(BIN_LIB)/PLUGIN"
	-system -i "DLTMOD $(BIN_LIB)/BASE64UT"
	-system -i "DLTSRVPGM $(BIN_LIB)/BASE64UT"
	-system -i "DLTMOD $(BIN_LIB)/SMPLLSTUT"
	-system -i "DLTSRVPGM $(BIN_LIB)/SMPLLSTUT"
	-system -i "DLTMOD $(BIN_LIB)/RESOURCE"
	-system -i "DLTSRVPGM $(BIN_LIB)/RESOURCE"
	