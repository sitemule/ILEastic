#-------------------------------------------------------------------------------
# User-defined part start
#

# BIN_LIB is the destination library for the service program.
# The rpg modules and the binder source file are also created in BIN_LIB.
# Binder source file and rpg module can be remove with the clean step 
# (make clean).
BIN_LIB=ILEASTIC

DBGVIEW=*ALL
TARGET_RLS=*CURRENT
OUTPUT=*NONE

#
# User-defined part end
#-------------------------------------------------------------------------------

OS_VERSION=$(shell echo "$$(uname -v)$$(uname -r)")
HAS_TGTCCSID=$(shell if [ $(OS_VERSION) -ge 74 ]; then echo yes; else echo no; fi)
ifeq ($(HAS_TGTCCSID),yes)
RPG_TGTCCSID=TGTCCSID(37)
endif

# CFLAGS = compiler parameter
RCFLAGS=OUTPUT($(OUTPUT)) OPTION(*NOUNREF *SRCSTMT) STGMDL(*INHERIT) INCDIR('.') DBGVIEW($(DBGVIEW)) TGTRLS($(TARGET_RLS)) $(RPG_TGTCCSID)

MODULES = llist llist_sort


.SUFFIXES: .rpgmod

.rpgmod:
	system -q "CHGATR OBJ('$<') ATR(*CCSID) VALUE(1252)"
	system -i "CRTRPGMOD MODULE($(BIN_LIB)/$*) SRCSTMF('$<') $(RCFLAGS)"


all: compile

env:

compile: $(MODULES)

clean:
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/LLIST) OBJTYPE(*MODULE)"
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/LLIST_SORT) OBJTYPE(*MODULE)"

.PHONY:

