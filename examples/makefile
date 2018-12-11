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

# The shell we use
SHELL=/QOpenSys/usr/bin/qsh

#
# add this after CRTBNDRPG for build in vsCode:
# | grep '*RNF' | grep -v '*RNF7031' | sed  "s!*!$<: &!"
# NOTE that OUTPUT are overridden by the make in the vsCode task.json 
# to compile a single file and get erros to the editor
# User-defined part end
#-------------------------------------------------------------------------------
OUTPUT=*NONE
RCFLAGS=OPTION(*NOUNREF) DBGVIEW(*LIST)  OUTPUT($(OUTPUT)) INCDIR('./..')
SQLRPGCFLAGS=OPTION(*NOUNREF) DBGVIEW(*LIST)  OUTPUT($(OUTPUT)) INCDIR(''./..'')

.SUFFIXES: .rpgle .sqlrpgle
 
# suffix rules
.rpgle:
	liblist -a $(BIN_LIB);\
	system -iK "CRTBNDRPG PGM($(BIN_LIB)/$@) SRCSTMF('$<') $(RCFLAGS)" | grep '*RNF' | grep -v '*RNF7031' | sed  "s!*!$<: &!"
	
.sqlrpgle:
	liblist -a $(BIN_LIB);\
	system -iK "CRTSQLRPGI OBJ($(BIN_LIB)/$@) SRCSTMF('$<') RPGPPOPT(*LVL2) COMPILEOPT('$(SQLRPGCFLAGS)')"

OBJECTS = helloworld staticfile datachunks jsonp invalidreq querystr multroutes plugin

all: compile

compile: $(OBJECTS)

.PHONY:
