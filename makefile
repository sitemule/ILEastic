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
# The folder where the copy books for ILEastic will be copied to with the 
# install step (make install).
#
USRINCDIR=/usr/local/include

#
# User-defined part end
#-------------------------------------------------------------------------------


# system and application include folder
INCLUDE='/QIBM/include' 'headers/'

# CCFLAGS = C compiler parameter
CCFLAGS=OPTIMIZE(10) ENUM(*INT) TERASPACE(*YES) STGMDL(*INHERIT) SYSIFCOPT(*IFSIO) INCDIR($(INCLUDE)) DBGVIEW(*ALL)
CCFLAGS2=OPTION(*STDLOGMSG) OUTPUT(*NONE) OPTIMIZE(10) ENUM(*INT) TERASPACE(*YES) STGMDL(*INHERIT) SYSIFCOPT(*IFSIO) DBGVIEW(*ALL) INCDIR($(INCLUDE)) 


all: env compile bind 

env:
	-system -q "CRTLIB $(BIN_LIB) TYPE(*TEST) TEXT('ILEastic: Programmable applications server for ILE')                                          
	-system -q "CRTBNDDIR BNDDIR($(BIN_LIB)/ILEASTIC)"
	-system -q "ADDBNDDIRE BNDDIR($(BIN_LIB)/ILEASTIC) OBJ((ILEASTIC))"

compile: 
	system "CHGATR OBJ('src/*') ATR(*CCSID) VALUE(1208)"
	system "CHGATR OBJ('headers/*') ATR(*CCSID) VALUE(1208)"
	system "CRTCMOD MODULE($(BIN_LIB)/stream) SRCSTMF('src/stream.c') $(CCFLAGS) "
	system "CRTCMOD MODULE($(BIN_LIB)/ileastic) SRCSTMF('src/ileastic.c') $(CCFLAGS) "
	system "CRTCMOD MODULE($(BIN_LIB)/varchar) SRCSTMF('src/varchar.c') $(CCFLAGS) "
	system "CRTCMOD MODULE($(BIN_LIB)/api) SRCSTMF('src/api.c') $(CCFLAGS)"
	system "CRTCMOD MODULE($(BIN_LIB)/sndpgmmsg) SRCSTMF('src/sndpgmmsg.c') $(CCFLAGS)"
	system "CRTCMOD MODULE($(BIN_LIB)/strUtil) SRCSTMF('src/strUtil.c') $(CCFLAGS)"
	system "CRTCMOD MODULE($(BIN_LIB)/e2aa2e) SRCSTMF('src/e2aa2e.c') $(CCFLAGS)"
	system "CRTCMOD MODULE($(BIN_LIB)/xlate) SRCSTMF('src/xlate.c') $(CCFLAGS)"
	system "CRTCMOD MODULE($(BIN_LIB)/simplelist) SRCSTMF('src/simplelist.c') $(CCFLAGS)"

bind:
	-system -q "CRTSRCPF FILE($(BIN_LIB)/QSRVSRC) RCDLEN(112)"
	system "CPYFRMSTMF FROMSTMF('headers/ileastic.bnd') TOMBR('/QSYS.lib/$(BIN_LIB).lib/QSRVSRC.file/ILEASTIC.mbr') MBROPT(*replace)"
	-system -q "DLTOBJ OBJ($(BIN_LIB)/ILEASTIC) OBJTYPE(*SRVPGM)"
	system -kpieb "CRTSRVPGM SRVPGM($(BIN_LIB)/ILEASTIC) MODULE($(BIN_LIB)/*ALL) OPTION(*DUPPROC) DETAIL(*BASIC) STGMDL(*INHERIT) SRCFILE($(BIN_LIB)/QSRVSRC) TEXT('ILEastic - programable applicationserver for ILE')"

clean:
	-system -q "DLTOBJ OBJ($(BIN_LIB)/STREAM) OBJTYPE(*MODULE)"
	-system -q "DLTOBJ OBJ($(BIN_LIB)/ILEASTIC) OBJTYPE(*MODULE)"
	-system -q "DLTOBJ OBJ($(BIN_LIB)/VARCHAR) OBJTYPE(*MODULE)"
	-system -q "DLTOBJ OBJ($(BIN_LIB)/API) OBJTYPE(*MODULE)"
	-system -q "DLTOBJ OBJ($(BIN_LIB)/SNDPGMMSG) OBJTYPE(*MODULE)"
	-system -q "DLTOBJ OBJ($(BIN_LIB)/STRUTIL) OBJTYPE(*MODULE)"
	-system -q "DLTOBJ OBJ($(BIN_LIB)/SIMPLELIST) OBJTYPE(*MODULE)"
	-system -q "DLTOBJ OBJ($(BIN_LIB)/E2AA2E) OBJTYPE(*MODULE)"
	-system -q "DLTOBJ OBJ($(BIN_LIB)/XLATE) OBJTYPE(*MODULE)"
	-system -q "DLTOBJ OBJ($(BIN_LIB)/QSRVSRC) OBJTYPE(*FILE)"

# For vsCode 
current: env
	system "CRTCMOD MODULE($(BIN_LIB)/$(SRC)) SRCSTMF('src/$(SRC).c') $(CCFLAGS2) "

install:
	-mkdir $(USRINCDIR)/ILEastic
	cp headers/ileastic.rpgle $(USRINCDIR)/ILEastic/

.PHONY:
