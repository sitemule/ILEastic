
#-----------------------------------------------------------
# User-defined part start
#

# BIN_LIB is the destination library for the service program.
# the rpg modules and the binder source file are also created in BIN_LIB.
# binder source file and rpg module can be remove with the clean step (make clean)
BIN_LIB=NODE.RPG

# to this folder the header files (prototypes) are copied in the install step
INCLUDE=/QIBM/include


# CCFLAGS = C compiler parameter
##CCFLAGS=OPTION(*EXPMAC *SHOWINC) OUTPUT(*PRINT *NOSHOWSRC) OPTIMIZE(10) ENUM(*INT) TERASPACE(*YES) STGMDL(*INHERIT) DEFINE(NOCRYPT USE_STANDARD_TMPFILE USE_BIG_ENDIAN LXW_HAS_SNPRINTF) SYSIFCOPT(*IFS64IO) INCDIR('/QIBM/include' '../include' '$(ZLIB_INC)' '../third_party/minizip')
##CCFLAGS=OUTPUT(*PRINT *NOSHOWSRC) OPTIMIZE(10) ENUM(*INT) TERASPACE(*YES) STGMDL(*INHERIT) SYSIFCOPT(*IFSIO) INCDIR('$(INCLUDE)')
CCFLAGS=OPTIMIZE(10) ENUM(*INT) TERASPACE(*YES) STGMDL(*INHERIT) SYSIFCOPT(*IFSIO) INCDIR('$(INCLUDE)') DBGVIEW(*ALL)

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
               
all: env compile bind 

env:
	system "CHGATR OBJ('*') ATR(*CCSID) VALUE(1208)"
	system "CHGATR OBJ('noderpg.bnd') ATR(*CCSID) VALUE(1252)"
	-system -q "CRTLIB $(BIN_LIB) TYPE(*TEST) TEXT('Node.RPG: Programmable applications server for RPG')                                          
	-system -q "CRTBNDDIR BNDDIR($(BIN_LIB)/NODERPG)"
	-system -q "ADDBNDDIRE BNDDIR($(BIN_LIB)/NODERPG) OBJ((NODERPG))"


compile: 
	system "CRTCMOD MODULE($(BIN_LIB)/node) SRCSTMF('node.c') $(CCFLAGS) "
	system "CRTCMOD MODULE($(BIN_LIB)/callbacks) SRCSTMF('callbacks.c') $(CCFLAGS)"
	system "CRTCMOD MODULE($(BIN_LIB)/sndpgmmsg) SRCSTMF('sndpgmmsg.c') $(CCFLAGS)"
	system "CRTCMOD MODULE($(BIN_LIB)/strUtil) SRCSTMF('strUtil.c') $(CCFLAGS)"
	system "CRTCMOD MODULE($(BIN_LIB)/e2aa2e) SRCSTMF('e2aa2e.c') $(CCFLAGS)"

bind: 
	system -kpieb "CRTSRVPGM SRVPGM($(BIN_LIB)/noderpg) MODULE($(BIN_LIB)/*ALL) DETAIL(*BASIC) STGMDL(*INHERIT) EXPORT(*SRCFILE) SRCSTMF(noderpg.bnd) TEXT('Node.RPG')"
 
.PHONY:
