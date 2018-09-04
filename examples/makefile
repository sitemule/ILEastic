#
# Build examples for ILEastic
#
BIN_LIB=ILEASTIC

# to this folder the header files (prototypes) are copied in the install step
RPG_OPT=DBGVIEW(*LIST) INCDIR('./..')
    
all: compile

compile: 
	system -i "CRTBNDRPG  PGM($(BIN_LIB)/demo01) SRCSTMF('demo01.rpgle') $(RPG_OPT)" 
	system -i "CRTBNDRPG  PGM($(BIN_LIB)/demo02) SRCSTMF('demo02.rpgle') $(RPG_OPT)" 
       
.PHONY: compile