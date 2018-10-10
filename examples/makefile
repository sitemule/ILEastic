#
# Build test cases for ILEastic
# This works for:
#  gmake                  compiles all RPGLE file 
#  gmake   demo01.rpgle   only compiles this single file
BIN_LIB=ILEASTIC
RPG_OPT=DBGVIEW(*LIST) INCDIR('./..' '/prj/noxdb')

pgm := $(wildcard *.rpgle) 

.ONESHELL:
.PHONY: compile
compile: $(pgm)

$(pgm): always
	@echo "---- Compiling program $(basename $@) from source $@ ---- Look for errors in 'error.txt' if needed"
	qsh <<EOF 
	export QIBM_CCSID=277
	liblist -a noxdb
	liblist -a $(BIN_LIB)
	system -i "CRTBNDRPG  PGM($(BIN_LIB)/$(basename $@)) SRCSTMF('$@') $(RPG_OPT)" > error.txt
	EOF

# The trick is 'always' is empty and trigger target to run always since we dont have an output object
always:
