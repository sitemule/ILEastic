#-------------------------------------------------------------------------------
# User-defined part start
#

# note: ILE RPG compilers don't support UTF-8, so we use win-1252; However ILE C supports UTF-8

# BIN_LIB is the destination library for the service program.
# The rpg modules and the binder source file are also created in BIN_LIB.
# Binder source file and rpg module can be remove with the clean step 
# (make clean).
BIN_LIB=ILEASTIC

BIND_LIB=*LIBL
DBGVIEW=*ALL
TARGET_CCSID=*JOB
TARGET_RLS=*CURRENT
OUTPUT=*NONE
SHELL=/QOpenSys/usr/bin/qsh

#
# User-defined part end
#-------------------------------------------------------------------------------

TGTCCSID = $(if $(filter V7R3M0,$(TARGET_RLS)), "" , TGTCCSID($(TARGET_CCSID)))

# CFLAGS = compiler parameter
CFLAGS=OUTPUT($(OUTPUT)) OPTION(*NOUNREF *SRCSTMT) STGMDL(*INHERIT) INCDIR('../..') DBGVIEW($(DBGVIEW)) TGTRLS($(TARGET_RLS)) $(TGTCCSID)

MODULES = authsystem

.SUFFIXES: .rpgle

.rpgle:
	system -ik "CHGATR OBJ('$<') ATR(*CCSID) VALUE(1252)"
	system -ik "CRTRPGMOD MODULE($(BIN_LIB)/$@) SRCSTMF('$<') $(CFLAGS)"
	
all: env compile bind

env:
	-system -qi "ADDBNDDIRE BNDDIR($(BIN_LIB)/ILEASTIC) OBJ(($(BIND_LIB)/ILAUTHSYS))"
	
compile: $(MODULES)

bind:
	-system -q "DLTOBJ OBJ($(BIN_LIB)/QSRVSRC) OBJTYPE(*FILE)"
	system "CRTSRCPF FILE($(BIN_LIB)/QSRVSRC) RCDLEN(112)"
	system "CPYFRMSTMF FROMSTMF('authsystem.bnd') TOMBR('/QSYS.lib/$(BIN_LIB).lib/QSRVSRC.file/ILAUTHSYS.mbr') MBROPT(*replace)"
	-system -q "DLTOBJ OBJ($(BIN_LIB)/ILAUTHSYS) OBJTYPE(*SRVPGM)"
	liblist -a $(BIN_LIB); \
	system -kpieb "CRTSRVPGM SRVPGM($(BIN_LIB)/ILAUTHSYS) MODULE($(BIN_LIB)/AUTHSYSTEM) BNDSRVPGM(($(BIND_LIB)/ILEASTIC) ($(BIND_LIB)/JSONXML)) OPTION(*DUPPROC) DETAIL(*BASIC) STGMDL(*INHERIT) SRCFILE($(BIN_LIB)/QSRVSRC) TGTRLS($(TARGET_RLS)) TEXT('ILEastic - Auth System Plugin')"

clean:
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/AUTHSYSTEM) OBJTYPE(*MODULE)"

purge: clean
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/ILAUTHSYS) OBJTYPE(*SRVPGM)"

install:
	cp authsystem_h.rpgle $(USRINCDIR)/ILEastic/