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


OBJECTS = REQUEST

all: clean compile

compile: $(OBJECTS)

REQUEST:
	system "CRTRPGMOD MODULE($(BIN_LIB)/REQUEST) SRCSTMF('request.rpgle') INCDIR('$(RUINCDIR)') dbgview(*source) stgmdl(*teraspace)"
	system "CRTSRVPGM $(BIN_LIB)/REQUEST MODULE(($(BIN_LIB)/REQUEST) ($(ILEASTIC_LIB)/*ALL)) STGMDL(*TERASPACE) BNDSRVPGM(ASSERT) EXPORT(*ALL) OPTION(*DUPPROC)"

clean:
	-system "DLTMOD $(BIN_LIB)/REQUEST"
	-system "DLTSRVPGM $(BIN_LIB)/REQUEST"

