#
# Build script for BASE64
#

#-----------------------------------------------------------
# User-defined part start
#

# BIN_LIB is the destination library for the service program and modules.
# The module can be removed with the clean step (make clean).
BIN_LIB=ILEASTIC

# CFLAGS = compile parameter
CFLAGS=DBGVIEW(*LIST) TERASPACE(*YES) STGMDL(*INHERIT) ENUM(*INT) OPTIMIZE(30)

#
# User-defined part end
#-----------------------------------------------------------


OBJECTS = base64
 
 
.SUFFIXES: .c
 
# suffix rules
.c:
	system -i "CRTCMOD $(BIN_LIB)/$@ SRCSTMF('$<') $(CFLAGS)"
        
all: clean compile
 
base64:

compile: $(OBJECTS)
	
clean:
	-system "DLTMOD $(BIN_LIB)/BASE64"

.PHONY:
