#-------------------------------------------------------------------------------
# User-defined part start
#

# BIN_LIB is the destination library for the service program.
# The rpg modules and the binder source file are also created in BIN_LIB.
# Binder source file and rpg module can be remove with the clean step 
# (make clean).
BIN_LIB=ILEASTIC

BIND_LIB=*LIBL

TARGET_CCSID=*JOB
TARGET_RLS=*CURRENT
OUTPUT=*NONE

# Library which contains RUTESTCASE service program
RU_LIB=*LIBL

#
# User-defined part end
#-------------------------------------------------------------------------------

TGTCCSID = $(if $(filter V7R3M0,$(TARGET_RLS)), "" , TGTCCSID($(TARGET_CCSID)))

# RCFLAGS = RPG compiler parameter
RCFLAGS=OUTPUT($(OUTPUT)) OPTION(*NOUNREF *SRCSTMT) STGMDL(*INHERIT) INCDIR('../../headers' '../..') DBGVIEW(*ALL) TGTRLS($(TARGET_RLS)) DEFINE($(DEFINE)) $(TGTCCSID)

# Do not touch below
INCLUDE='/QIBM/include' '.' '../../headers/'  

# C compile flags
CCFLAGS=OUTPUT($(OUTPUT)) OPTION(*NOSHOWINC) OPTIMIZE(10) ENUM(*INT) TERASPACE(*YES) STGMDL(*INHERIT) SYSIFCOPT(*IFSIO) INCDIR($(INCLUDE)) DBGVIEW(*ALL) DEFINE($(DEFINE)) TGTCCSID($(TARGET_CCSID)) TGTRLS($(TARGET_RLS))

MODULES = base64url.rpgmod hmac.rpgmod jwk.rpgmod jwt.rpgmod jwtplugin.rpgmod message.c rsa.rpgmod

all: env compile bind

# remove all default suffix rules
.SUFFIXES:

%.rpgmod: .PHONY
	system -q "CHGATR OBJ('$*.rpgmod') ATR(*CCSID) VALUE(819)"
	system -i "CRTRPGMOD MODULE($(BIN_LIB)/$*) SRCSTMF('$*.rpgmod') $(RCFLAGS)"

%.c: .PHONY
	system -q "CHGATR OBJ('$*.c') ATR(*CCSID) VALUE(1252)"
	system "CRTCMOD MODULE($(BIN_LIB)/$(notdir $*)) SRCSTMF('$*.c') $(CCFLAGS)"

env:
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/JWTSRC) OBJTYPE(*FILE)"
	system -i "CRTSRCPF FILE($(BIN_LIB)/JWTSRC) RCDLEN(200)"
	-system -qi "ADDBNDDIRE BNDDIR($(BIN_LIB)/ILEASTIC) OBJ(($(BIND_LIB)/JWT))"
	-system -qi "ADDBNDDIRE BNDDIR($(BIN_LIB)/ILEASTIC) OBJ(($(BIND_LIB)/ILJWTPLUG))"

compile: $(MODULES)

bind:
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/QSRVSRC) OBJTYPE(*FILE)"
	system -i "CRTSRCPF FILE($(BIN_LIB)/QSRVSRC) RCDLEN(112)"
	system -i "CPYFRMSTMF FROMSTMF('jwt.bnd') TOMBR('/QSYS.LIB/$(BIN_LIB).LIB/QSRVSRC.FILE/JWT.MBR') MBROPT(*ADD)"
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/JWT) OBJTYPE(*SRVPGM)"
	system -pieb "CRTSRVPGM SRVPGM($(BIN_LIB)/JWT) MODULE($(BIN_LIB)/JWT $(BIN_LIB)/HMAC $(BIN_LIB)/RSA $(BIN_LIB)/BASE64URL $(BIN_LIB)/MESSAGE) BNDSRVPGM(($(BIN_LIB)/ILEASTIC) ($(BIN_LIB)/JSONXML)) OPTION(*DUPPROC) DETAIL(*BASIC) STGMDL(*INHERIT) SRCFILE($(BIN_LIB)/QSRVSRC) TGTRLS($(TARGET_RLS)) TEXT('ILEastic - JWT')"
	system -i "CPYFRMSTMF FROMSTMF('jwtplugin.bnd') TOMBR('/QSYS.LIB/$(BIN_LIB).LIB/QSRVSRC.FILE/ILJWTPLUG.MBR') MBROPT(*ADD)"
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/ILJWTPLUG) OBJTYPE(*SRVPGM)"
	system -pieb "CRTSRVPGM SRVPGM($(BIN_LIB)/ILJWTPLUG) MODULE($(BIN_LIB)/JWTPLUGIN $(BIN_LIB)/JWK $(BIN_LIB)/BASE64URL) BNDSRVPGM(($(BIND_LIB)/ILEASTIC) ($(BIND_LIB)/JSONXML) ($(BIND_LIB)/JWT)) OPTION(*DUPPROC) DETAIL(*BASIC) STGMDL(*INHERIT) SRCFILE($(BIN_LIB)/QSRVSRC) TGTRLS($(TARGET_RLS)) TEXT('ILEastic - JWT Plugin')"

clean:
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/QSRVSRC) OBJTYPE(*FILE)"
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/JWTSRC) OBJTYPE(*FILE)"
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/HMAC) OBJTYPE(*MODULE)"
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/JWT) OBJTYPE(*MODULE)"
	-system -qi "DLTOBJ OBJ($(BIN_LIB)/JWTPLUGIN) OBJTYPE(*MODULE)"

.PHONY:
