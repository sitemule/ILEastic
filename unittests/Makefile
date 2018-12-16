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

# This library contains the ILEASTIC modules.
ILEASTIC_LIB=ILEASTIC

#
# User-defined part end
#-------------------------------------------------------------------------------


ILEASTIC_MODULES=($(ILEASTIC_LIB)/ILEASTIC) ($(ILEASTIC_LIB)/API) ($(ILEASTIC_LIB)/SIMPLELIST) ($(ILEASTIC_LIB)/VARCHAR) ($(ILEASTIC_LIB)/STREAM) ($(ILEASTIC_LIB)/XLATE) ($(ILEASTIC_LIB)/E2AA2E) ($(ILEASTIC_LIB)/STRUTIL) ($(ILEASTIC_LIB)/SNDPGMMSG) ($(ILEASTIC_LIB)/SERIALIZE) ($(ILEASTIC_LIB)/BASE64)

OBJECTS = REQUEST ROUTING PLUGIN BASE64UT

all: clean compile

compile: $(OBJECTS)

REQUEST:
	system -i "CRTRPGMOD MODULE($(BIN_LIB)/REQUEST) SRCSTMF('request.rpgle') INCDIR('$(RUINCDIR)') dbgview(*source) stgmdl(*teraspace)"
	system -i "CRTSRVPGM $(BIN_LIB)/REQUEST MODULE(($(BIN_LIB)/REQUEST) $(ILEASTIC_MODULES)) STGMDL(*TERASPACE) BNDSRVPGM(ASSERT) EXPORT(*ALL) OPTION(*DUPPROC)"

ROUTING:
	system -i "CRTRPGMOD MODULE($(BIN_LIB)/ROUTING) SRCSTMF('routing.rpgle') INCDIR('$(RUINCDIR)') dbgview(*source) output(*print) stgmdl(*teraspace)"
	system -i "CRTSRVPGM $(BIN_LIB)/ROUTING MODULE(($(BIN_LIB)/ROUTING) $(ILEASTIC_MODULES)) STGMDL(*TERASPACE) BNDSRVPGM(ASSERT) EXPORT(*ALL) OPTION(*DUPPROC)"

PLUGIN:
	system -i "CRTRPGMOD MODULE($(BIN_LIB)/PLUGIN) SRCSTMF('plugin.rpgle') INCDIR('$(RUINCDIR)') dbgview(*source) output(*print) stgmdl(*teraspace)"
	system -i "CRTSRVPGM $(BIN_LIB)/PLUGIN MODULE(($(BIN_LIB)/PLUGIN) $(ILEASTIC_MODULES)) STGMDL(*TERASPACE) BNDSRVPGM(ASSERT) EXPORT(*ALL) OPTION(*DUPPROC)"

BASE64UT:
	system -i "CRTRPGMOD MODULE($(BIN_LIB)/BASE64UT) SRCSTMF('base64ut.rpgle') INCDIR('$(RUINCDIR)') dbgview(*source) output(*print) stgmdl(*teraspace)"
	system -i "CRTSRVPGM $(BIN_LIB)/BASE64UT MODULE(($(BIN_LIB)/BASE64UT) $(ILEASTIC_MODULES)) STGMDL(*TERASPACE) BNDSRVPGM(ASSERT) EXPORT(*ALL) OPTION(*DUPPROC)"

clean:
	-system -i "DLTMOD $(BIN_LIB)/REQUEST"
	-system -i "DLTSRVPGM $(BIN_LIB)/REQUEST"
	-system -i "DLTMOD $(BIN_LIB)/ROUTING"
	-system -i "DLTSRVPGM $(BIN_LIB)/ROUTING"
	-system -i "DLTMOD $(BIN_LIB)/PLUGIN"
	-system -i "DLTSRVPGM $(BIN_LIB)/PLUGIN"
