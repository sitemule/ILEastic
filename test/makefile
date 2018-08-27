#
# Build test cases for Node.rpg
#
BIN_LIB=NODE.RPG

# to this folder the header files (prototypes) are copied in the install step
RPG_OPT=DBGVIEW(*LIST) INCDIR('./..')

 
    
all: compile
.ONESHELL:
compile: 
	qsh <<EOF 
	export QIBM_CCSID=277
	liblist -a $(BIN_LIB) 
	system -i "CRTBNDRPG  PGM($(BIN_LIB)/demo01) SRCSTMF('demo01.rpgle') $(RPG_OPT)" 
	system -i "CRTBNDRPG  PGM($(BIN_LIB)/demo02) SRCSTMF('demo02.rpgle') $(RPG_OPT)" 
	EOF
       
.PHONY: compile