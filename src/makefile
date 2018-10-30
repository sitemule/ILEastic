#-------------------------------------------------------------------------------
# User-defined part start
#

# note: ILE RPG compilers don't support UTF-8, so we use win-1252; However ILE C supports UTF-8

# BIN_LIB is the destination library for the service program.
# The rpg modules and the binder source file are also created in BIN_LIB.
# Binder source file and rpg module can be remove with the clean step 
# (make clean).
BIN_LIB=ILEASTIC

#
# User-defined part end
#-------------------------------------------------------------------------------


# system and application include folder
INCLUDE='/QIBM/include' '../headers/'

# CCFLAGS = C compiler parameter
CCFLAGS=OPTIMIZE(10) ENUM(*INT) TERASPACE(*YES) STGMDL(*INHERIT) SYSIFCOPT(*IFSIO) INCDIR($(INCLUDE)) DBGVIEW(*ALL)

MODULES = stream ileastic varchar api sndpgmmsg strutil e2aa2e xlate simpleList serialize

.SUFFIXES: .c

.c:
	system "CHGATR OBJ('$<') ATR(*CCSID) VALUE(1208)"
	system "CRTCMOD MODULE($(BIN_LIB)/$@) SRCSTMF('$<') $(CCFLAGS)"
	
all: compile

compile: $(MODULES)

