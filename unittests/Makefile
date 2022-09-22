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

#
# User-defined part end
#-------------------------------------------------------------------------------


ILEASTIC_MODULES=($(ILEASTIC_LIB)/ILEASTIC) ($(ILEASTIC_LIB)/API) ($(ILEASTIC_LIB)/SIMPLELIST) ($(ILEASTIC_LIB)/VARCHAR) ($(ILEASTIC_LIB)/STREAM) ($(ILEASTIC_LIB)/XLATE) ($(ILEASTIC_LIB)/E2AA2E) ($(ILEASTIC_LIB)/STRUTIL) ($(ILEASTIC_LIB)/SNDPGMMSG) ($(ILEASTIC_LIB)/SERIALIZE) ($(ILEASTIC_LIB)/BASE64) ($(ILEASTIC_LIB)/FASTCGI)

OBJECTS = REQUEST ROUTING PLUGIN BASE64UT SMPLELSTUT JWT_UT RESOURCE ROUTEID
SRVPGMS = $(RU_LIB)/RUTESTCASE $(ILEASTIC_LIB)/ILEFASTCGI $(ILEASTIC_LIB)/JWT $(ILEASTIC_LIB)/JSONXML

all: clean compile

compile: $(OBJECTS)

ROUTEID:
	system -i "CRTRPGMOD MODULE($(BIN_LIB)/ROUTEID) SRCSTMF('routeid.rpgle') INCDIR('$(RUINCDIR)') dbgview(*source) output(*print) stgmdl(*SNGLVL)"
	system -i "CRTSRVPGM $(BIN_LIB)/ROUTEID MODULE(($(BIN_LIB)/ROUTEID) $(ILEASTIC_MODULES)) STGMDL(*SNGLVL) BNDSRVPGM($(SRVPGMS)) EXPORT(*ALL) OPTION(*DUPPROC)"

REQUEST:
	system -i "CRTRPGMOD MODULE($(BIN_LIB)/REQUEST) SRCSTMF('request.rpgle') INCDIR('$(RUINCDIR)') dbgview(*source) stgmdl(*SNGLVL)"
	system -i "CRTSRVPGM $(BIN_LIB)/REQUEST MODULE(($(BIN_LIB)/REQUEST) $(ILEASTIC_MODULES)) STGMDL(*SNGLVL) BNDSRVPGM($(SRVPGMS)) EXPORT(*ALL) OPTION(*DUPPROC)"

ROUTING:
	system -i "CRTRPGMOD MODULE($(BIN_LIB)/ROUTING) SRCSTMF('routing.rpgle') INCDIR('$(RUINCDIR)') dbgview(*source) output(*print) stgmdl(*SNGLVL)"
	system -i "CRTSRVPGM $(BIN_LIB)/ROUTING MODULE(($(BIN_LIB)/ROUTING) $(ILEASTIC_MODULES)) STGMDL(*SNGLVL) BNDSRVPGM($(SRVPGMS)) EXPORT(*ALL) OPTION(*DUPPROC)"

PLUGIN:
	system -i "CRTRPGMOD MODULE($(BIN_LIB)/PLUGIN) SRCSTMF('plugin.rpgle') INCDIR('$(RUINCDIR)') dbgview(*source) output(*print) stgmdl(*SNGLVL)"
	system -i "CRTSRVPGM $(BIN_LIB)/PLUGIN MODULE(($(BIN_LIB)/PLUGIN) $(ILEASTIC_MODULES)) STGMDL(*SNGLVL) BNDSRVPGM($(SRVPGMS)) EXPORT(*ALL) OPTION(*DUPPROC)"

BASE64UT:
	system -ik "CRTRPGMOD MODULE($(BIN_LIB)/BASE64UT) SRCSTMF('base64ut.rpgle') INCDIR('$(RUINCDIR)') dbgview(*source) output(*print) stgmdl(*SNGLVL)"
	system -i "CRTSRVPGM $(BIN_LIB)/BASE64UT MODULE(($(BIN_LIB)/BASE64UT) $(ILEASTIC_MODULES)) STGMDL(*SNGLVL) BNDSRVPGM($(SRVPGMS)) EXPORT(*ALL) OPTION(*DUPPROC)"

SMPLELSTUT:
	system -i "CRTRPGMOD MODULE($(BIN_LIB)/SMPLLSTUT) SRCSTMF('smpllstut.rpgle') INCDIR('$(RUINCDIR)') dbgview(*source) output(*print) stgmdl(*SNGLVL)"
	system -i "CRTSRVPGM $(BIN_LIB)/SMPLLSTUT MODULE(($(BIN_LIB)/SMPLLSTUT) $(ILEASTIC_MODULES)) STGMDL(*SNGLVL) BNDSRVPGM($(SRVPGMS)) EXPORT(*ALL) OPTION(*DUPPROC)"

JWT_UT:
	system -i "CRTRPGMOD MODULE($(BIN_LIB)/JWT_UT) SRCSTMF('jwt_ut.rpgle') INCDIR('$(RUINCDIR)') dbgview(*source) output(*print) stgmdl(*SNGLVL)"
	system -i "CRTSRVPGM $(BIN_LIB)/JWT_UT MODULE( ($(BIN_LIB)/JWT_UT) ) STGMDL(*SNGLVL) BNDSRVPGM($(SRVPGMS)) EXPORT(*ALL) OPTION(*DUPPROC)"

RESOURCE:
	system -ik "CRTRPGMOD MODULE($(BIN_LIB)/RESOURCE) SRCSTMF('resource.rpgle') INCDIR('$(RUINCDIR)') dbgview(*source) output(*print) stgmdl(*SNGLVL)"
	system -ik "CRTSRVPGM $(BIN_LIB)/RESOURCE MODULE(($(BIN_LIB)/RESOURCE) $(ILEASTIC_MODULES)) STGMDL(*SNGLVL) BNDSRVPGM($(SRVPGMS)) EXPORT(*ALL) OPTION(*DUPPROC)"


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
	-system -i "DLTMOD $(BIN_LIB)/JWT_UT"
	-system -i "DLTSRVPGM $(BIN_LIB)/JWT_UT"
	-system -i "DLTMOD $(BIN_LIB)/RESOURCE"
	-system -i "DLTSRVPGM $(BIN_LIB)/RESOURCE"
	