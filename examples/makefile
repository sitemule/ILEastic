#
# Build examples for ILEastic
#
# This works for:
#  make              compiles all demo programs
#  make helloworld   only compiles this single file
#

#-------------------------------------------------------------------------------
# User-defined part start
#

# BIN_LIB is the destination library for the demo programs.
BIN_LIB=ILEASTIC

# Inclucde directory for the noxDB headers
NOXDBINC='/usr/local/include/noxdb'

#
# User-defined part end
#-------------------------------------------------------------------------------


RCFLAGS=OPTION(*NOUNREF) DBGVIEW(*LIST) INCDIR('./..' $(NOXDBINC))
SQLRPGCFLAGS=OPTION(*NOUNREF) DBGVIEW(*LIST) INCDIR(''./..'')

.SUFFIXES: .rpgle .sqlrpgle
 
# suffix rules
.rpgle:
	system -iK "CRTBNDRPG $(BIN_LIB)/$@ SRCSTMF('$<') $(RCFLAGS)"

.sqlrpgle:
	system -iK "CRTSQLRPGI OBJ($(BIN_LIB)/$@) SRCSTMF('$<') RPGPPOPT(*LVL2) COMPILEOPT('$(SQLRPGCFLAGS)')"

OBJECTS = helloworld staticfile datachunks invalidreq querystr multroutes plugin

all: compile

compile: $(OBJECTS)

.PHONY:
