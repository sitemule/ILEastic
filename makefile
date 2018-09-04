#-----------------------------------------------------------
# User-defined part start
#

# BIN_LIB is the destination library for the modules and service program.
# The RPG modules and the binder source file are also created in BIN_LIB.
# Binder source file and RPG modules can be remove with the clean step 
# (make clean).
BIN_LIB=ILEASTIC

# directory where the copybooks are copied to on the install step
DSTINCDIR=/usr/local/include

# CCFLAGS = C compiler parameter
CCFLAGS=OPTIMIZE(10) ENUM(*INT) TERASPACE(*YES) STGMDL(*INHERIT) SYSIFCOPT(*IFSIO) INCDIR($(INCLUDE)) DBGVIEW(*ALL)

#
# User-defined part end
#-----------------------------------------------------------


# include path(s) for header files, see INCDIR compile command parameter
INCLUDE='/QIBM/include' 'headers/'


all: env compile bind 

env:
	-system -q "CRTLIB $(BIN_LIB) TYPE(*TEST) TEXT('ILEastic: Programmable applications server for ILE')                                          
	-system -q "CRTBNDDIR BNDDIR($(BIN_LIB)/ILEASTIC)"
	-system -q "ADDBNDDIRE BNDDIR($(BIN_LIB)/ILEASTIC) OBJ(($(BIN_LIB)/ILEASTIC))"

compile: 
	system "CHGATR OBJ('src/*') ATR(*CCSID) VALUE(1208)"
	system "CHGATR OBJ('headers/*') ATR(*CCSID) VALUE(1208)"
	system "CRTCMOD MODULE($(BIN_LIB)/ILEASTIC) SRCSTMF('src/ileastic.c') $(CCFLAGS) "
	system "CRTCMOD MODULE($(BIN_LIB)/VARCHAR) SRCSTMF('src/varchar.c') $(CCFLAGS) "
	system "CRTCMOD MODULE($(BIN_LIB)/CALLBACKS) SRCSTMF('src/callbacks.c') $(CCFLAGS)"
	system "CRTCMOD MODULE($(BIN_LIB)/SNDPGMMSG) SRCSTMF('src/sndpgmmsg.c') $(CCFLAGS)"
	system "CRTCMOD MODULE($(BIN_LIB)/STRUTIL) SRCSTMF('src/strUtil.c') $(CCFLAGS)"
	system "CRTCMOD MODULE($(BIN_LIB)/E2AA2E) SRCSTMF('src/e2aa2e.c') $(CCFLAGS)"

bind:
	-system "DLTF FILE($(BIN_LIB)/QSRVSRC)"
	system "CRTSRCPF FILE($(BIN_LIB)/QSRVSRC) RCDLEN(112)"
	system "CPYFRMSTMF FROMSTMF('headers/ileastic.bnd') TOMBR('/QSYS.lib/$(BIN_LIB).lib/QSRVSRC.file/ILEASTIC.mbr') MBROPT(*ADD)"
	system -kpieb "CRTSRVPGM SRVPGM($(BIN_LIB)/ILEASTIC) MODULE($(BIN_LIB)/*ALL) DETAIL(*BASIC) STGMDL(*INHERIT) SRCFILE($(BIN_LIB)/QSRVSRC) TEXT('ILEastic - programable applicationserver for ILE')"

clean:
	-system -q "DLTOBJ OBJ($(BIN_LIB)/QSRVSRC) OBJTYPE(*FILE)"
	-system -q "DLTOBJ OBJ($(BIN_LIB)/ILEASTIC) OBJTYPE(*MODULE)"
	-system -q "DLTOBJ OBJ($(BIN_LIB)/VARCHAR) OBJTYPE(*MODULE)"
	-system -q "DLTOBJ OBJ($(BIN_LIB)/CALLBACKS) OBJTYPE(*MODULE)"
	-system -q "DLTOBJ OBJ($(BIN_LIB)/SNDPGMMSG) OBJTYPE(*MODULE)"
	-system -q "DLTOBJ OBJ($(BIN_LIB)/STRUTIL) OBJTYPE(*MODULE)"
	-system -q "DLTOBJ OBJ($(BIN_LIB)/E2AA2E) OBJTYPE(*MODULE)"

install:
	-rm -rf $(DSTINCDIR)/ILEastic
	-mkdir -p $(DSTINCDIR)/ILEastic
	-cp headers/ileastic.rpgle $(DSTINCDIR)/ILEastic
