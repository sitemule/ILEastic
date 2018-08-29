
#-----------------------------------------------------------
# User-defined part start
#

# BIN_LIB is the destination library for the service program.
# the rpg modules and the binder source file are also created in BIN_LIB.
# binder source file and rpg module can be remove with the clean step (make clean)
BIN_LIB=ILEASTIC

# to this folder the header files (prototypes) are copied in the install step
INCLUDE=/QIBM/include


# CCFLAGS = C compiler parameter
##CCFLAGS=OPTION(*EXPMAC *SHOWINC) OUTPUT(*PRINT *NOSHOWSRC) OPTIMIZE(10) ENUM(*INT) TERASPACE(*YES) STGMDL(*INHERIT) DEFINE(NOCRYPT USE_STANDARD_TMPFILE USE_BIG_ENDIAN LXW_HAS_SNPRINTF) SYSIFCOPT(*IFS64IO) INCDIR('/QIBM/include' '../include' '$(ZLIB_INC)' '../third_party/minizip')
##CCFLAGS=OUTPUT(*PRINT *NOSHOWSRC) OPTIMIZE(10) ENUM(*INT) TERASPACE(*YES) STGMDL(*INHERIT) SYSIFCOPT(*IFSIO) INCDIR('$(INCLUDE)')
CCFLAGS=OPTIMIZE(10) ENUM(*INT) TERASPACE(*YES) STGMDL(*INHERIT) SYSIFCOPT(*IFSIO) INCDIR('$(INCLUDE)') DBGVIEW(*ALL)

CCFLAGS2=OPTION(*STDLOGMSG) OUTPUT(*NONE) OPTIMIZE(10) ENUM(*INT) TERASPACE(*YES) STGMDL(*INHERIT) SYSIFCOPT(*IFSIO) DBGVIEW(*ALL) INCDIR('$(INCLUDE)') 

#
# User-defined part end
#-----------------------------------------------------------
 
 
.SUFFIXES: .rpgle .c .cpp
 
# suffix rules
.rpgle:
	system "CRTRPGMOD $(BIN_LIB)/$@ SRCSTMF('$<') $(RCFLAGS)"
	touch filename.o
.c:
	system "CRTCMOD MODULE($(BIN_LIB)/$@ SRCSTMF('$<' $(CCFLAGS)
               
current: env

	system "CRTCMOD MODULE($(BIN_LIB)/$(SRC)) SRCSTMF('$(SRC).c') $(CCFLAGS2) "

all: env compile bind 

env:
	system "CHGATR OBJ('*') ATR(*CCSID) VALUE(1208)"
	system "CHGATR OBJ('ILEastic.bnd') ATR(*CCSID) VALUE(1252)"
	-system -q "CRTLIB $(BIN_LIB) TYPE(*TEST) TEXT('ILEastic: Programmable applications server for ILE')                                          
	-system -q "CRTBNDDIR BNDDIR($(BIN_LIB)/ILEASTIC)"
	-system -q "ADDBNDDIRE BNDDIR($(BIN_LIB)/ILEASTIC) OBJ((ILEASTIC))"


compile: 
	system "CRTCMOD MODULE($(BIN_LIB)/ileastic) SRCSTMF('ileastic.c') $(CCFLAGS) "
	system "CRTCMOD MODULE($(BIN_LIB)/varchar) SRCSTMF('varchar.c') $(CCFLAGS) "
	system "CRTCMOD MODULE($(BIN_LIB)/callbacks) SRCSTMF('callbacks.c') $(CCFLAGS)"
	system "CRTCMOD MODULE($(BIN_LIB)/sndpgmmsg) SRCSTMF('sndpgmmsg.c') $(CCFLAGS)"
	system "CRTCMOD MODULE($(BIN_LIB)/strUtil) SRCSTMF('strUtil.c') $(CCFLAGS)"
	system "CRTCMOD MODULE($(BIN_LIB)/e2aa2e) SRCSTMF('e2aa2e.c') $(CCFLAGS)"

bind: 
	system -kpieb "CRTSRVPGM SRVPGM($(BIN_LIB)/ILEASTIC) MODULE($(BIN_LIB)/*ALL) DETAIL(*BASIC) STGMDL(*INHERIT) EXPORT(*SRCFILE) SRCSTMF(ILEASTIC.bnd) TEXT('Node.RPG')"
 
.PHONY:
