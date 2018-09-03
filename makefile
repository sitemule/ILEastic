
#-----------------------------------------------------------
# User-defined part start
#

# BIN_LIB is the destination library for the service program.
# the rpg modules and the binder source file are also created in BIN_LIB.
# binder source file and rpg module can be remove with the clean step (make clean)
BIN_LIB=ILEASTIC

# to this folder the header files (prototypes) are copied in the install step
INCLUDE='/QIBM/include' 'headers/'

# CCFLAGS = C compiler parameter
CCFLAGS=OPTIMIZE(10) ENUM(*INT) TERASPACE(*YES) STGMDL(*INHERIT) SYSIFCOPT(*IFSIO) INCDIR('$(INCLUDE)') DBGVIEW(*ALL)

#
# User-defined part end
#-----------------------------------------------------------

all: env compile bind 

env:
	-system -q "CRTLIB $(BIN_LIB) TYPE(*TEST) TEXT('ILEastic: Programmable applications server for ILE')                                          
	-system -q "CRTBNDDIR BNDDIR($(BIN_LIB)/ILEASTIC)"
	-system -q "ADDBNDDIRE BNDDIR($(BIN_LIB)/ILEASTIC) OBJ((ILEASTIC))"


compile: 
	system "CRTCMOD MODULE($(BIN_LIB)/ileastic) SRCSTMF('src/ileastic.c') $(CCFLAGS) "
	system "CRTCMOD MODULE($(BIN_LIB)/varchar) SRCSTMF('src/varchar.c') $(CCFLAGS) "
	system "CRTCMOD MODULE($(BIN_LIB)/callbacks) SRCSTMF('src/callbacks.c') $(CCFLAGS)"
	system "CRTCMOD MODULE($(BIN_LIB)/sndpgmmsg) SRCSTMF('src/sndpgmmsg.c') $(CCFLAGS)"
	system "CRTCMOD MODULE($(BIN_LIB)/strUtil) SRCSTMF('src/strUtil.c') $(CCFLAGS)"
	system "CRTCMOD MODULE($(BIN_LIB)/e2aa2e) SRCSTMF('src/e2aa2e.c') $(CCFLAGS)"

bind:
	system "CRTSRCPF FILE($(BIN_LIB)/QSRVSRC) RCDLEN(112)"
	system "CPYFRMSTMF FROMSTMF('headers/ileastic.bnd') TOMBR('/QSYS.lib/$(BIN_LIB).lib/QSRVSRC.file/ILEASTIC.mbr') MBROPT(*ADD)"
	system -kpieb "CRTSRVPGM SRVPGM($(BIN_LIB)/ILEASTIC) MODULE($(BIN_LIB)/*ALL) DETAIL(*BASIC) STGMDL(*INHERIT) SRCFILE($(BIN_LIB)/QSRVSRC) TEXT('ILEastic - programable applicationserver for ILE')"

clean:
	-system -q "DLTOBJ OBJ($(BIN_LIB)/QSRVSRC) OBJTYPE(*FILE)"