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
# NOTE: LIBLIST can be overwritten from the commandline, but defaults to the BIN_LIB
BIN_LIB=ILEASTIC
LIBLIST=$(BIN_LIB)

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
FILTER=| grep '*RNF' | grep -v '*RNF7031' | sed  "s!*!$<: &!"
NOFILTER=>errorlist.txt

.SUFFIXES: .rpgle .sqlrpgle
 
# suffix rules
.rpgle:
	touch errorlist.txt ;\
	setccsid 1252 errorlist.txt;\
	liblist -a $(LIBLIST);\
	setccsid 1252 $<;\
	system -iK "CRTBNDRPG PGM($(BIN_LIB)/$@) SRCSTMF('$<') $(RCFLAGS)" $(FILTER) ;\
	
.sqlrpgle:
	liblist -a $(LIBLIST);\
	system -iK "CRTSQLRPGI OBJ($(BIN_LIB)/$@) SRCSTMF('$<') RPGPPOPT(*LVL2) COMPILEOPT('$(SQLRPGCFLAGS)')"

OBJECTS = helloworld staticfile datachunks jsonp invalidreq querystr multroutes plugin jsondata

all: compile

compile: $(OBJECTS)

.PHONY:
