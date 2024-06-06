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

#
# User-defined part end
#-------------------------------------------------------------------------------


# CFLAGS = compiler parameter
CFLAGS=OUTPUT(*PRINT) OPTION(*NOUNREF *SRCSTMT) DBGVIEW(*LIST) STGMDL(*INHERIT) INCDIR('../..')

MODULES = basicauth

.SUFFIXES: .rpgle

.rpgle:
	system -ik "CHGATR OBJ('$<') ATR(*CCSID) VALUE(1252)"
	system -ik "CRTRPGMOD MODULE($(BIN_LIB)/$@) SRCSTMF('$<') $(CFLAGS)"
	
all: env compile bind

env:
	-system -qi "ADDBNDDIRE BNDDIR($(BIN_LIB)/ILEASTIC) OBJ(($(BIND_LIB)/ILBASICAUT))"

compile: $(MODULES)

bind:
	-system -q "DLTOBJ OBJ($(BIN_LIB)/QSRVSRC) OBJTYPE(*FILE)"
	system "CRTSRCPF FILE($(BIN_LIB)/QSRVSRC) RCDLEN(112)"
	system "CPYFRMSTMF FROMSTMF('basicauth.bnd') TOMBR('/QSYS.lib/$(BIN_LIB).lib/QSRVSRC.file/ILBASICAUT.mbr') MBROPT(*replace)"
	-system -q "DLTOBJ OBJ($(BIN_LIB)/ILBASICAUT) OBJTYPE(*SRVPGM)"
	system -kpieb "CRTSRVPGM SRVPGM($(BIN_LIB)/ILBASICAUT) MODULE($(BIN_LIB)/BASICAUTH) BNDSRVPGM(($(BIN_LIB)/ILEASTIC) ($(BIN_LIB)/JSONXML)) OPTION(*DUPPROC) DETAIL(*BASIC) STGMDL(*INHERIT) SRCFILE($(BIN_LIB)/QSRVSRC) TEXT('ILEastic - BasicAuth Plugin')"
