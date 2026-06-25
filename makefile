#-------------------------------------------------------------------------------
# User-defined part start
#

# note: ILE RPG compilers don't support UTF-8, so we use win-1252; However ILE C supports UTF-8

# BIN_LIB is the destination library for the service program.
# The rpg modules and the binder source file are also created in BIN_LIB.
# Binder source file and rpg module can be remove with the clean step 
# (make clean).
BIN_LIB=ILEASTIC
LIBLIST=$(BIN_LIB)
TARGET_RLS=*CURRENT
OUTPUT=*PRINT
MAKE=/QOpenSys/pkgs/bin/gmake

BIND_LIB=*LIBL

# The shell we use
SHELL=/QOpenSys/usr/bin/qsh

#
# The folder where the copy books for ILEastic will be copied to with the 
# install step (make install).
#
export USRINCDIR=/usr/local/include

#
# User-defined part end
#-------------------------------------------------------------------------------


# system and application include folder
INCLUDE='/QIBM/include' 'headers/' 'ILEfastCGI/include' 'noxDB/headers'

# TGTCCSID is only valid for RPG compilers on IBM i 7.4+
OS_VERSION=$(shell echo "$$(uname -v)$$(uname -r)")
HAS_TGTCCSID=$(shell if [ $(OS_VERSION) -ge 74 ]; then echo yes; else echo no; fi)
ifeq ($(HAS_TGTCCSID),yes)
RPG_TGTCCSID=TGTCCSID(37)
endif

# CCFLAGS = C compiler parameter (CRTCMOD always supports TGTCCSID)
CCFLAGS2=OPTION(*STDLOGMSG) OUTPUT($(OUTPUT)) OPTIMIZE(10) TGTCCSID(37) TGTRLS($(TARGET_RLS)) ENUM(*INT) TERASPACE(*YES) STGMDL(*INHERIT) SYSIFCOPT(*IFSIO) DBGVIEW(*ALL) INCDIR($(INCLUDE))
RPGFLAGS2=OUTPUT($(OUTPUT)) $(RPG_TGTCCSID) TGTRLS($(TARGET_RLS)) INCDIR($(INCLUDE)) DBGVIEW(*ALL) OPTION(*NOXREF *NOUNREF *NOSHOWCPY)

MODULES = $(BIN_LIB)/githash $(BIN_LIB)/stream $(BIN_LIB)/ileastic $(BIN_LIB)/ileasticr $(BIN_LIB)/varchar $(BIN_LIB)/api $(BIN_LIB)/sndpgmmsg $(BIN_LIB)/strutil $(BIN_LIB)/e2aa2e $(BIN_LIB)/xlate $(BIN_LIB)/simpleList $(BIN_LIB)/serialize $(BIN_LIB)/base64 $(BIN_LIB)/fastCGI $(BIN_LIB)/teramem $(BIN_LIB)/mediatype
	
all: env noxDB ILEfastCGI compile
 
env:
	-system -qi "CRTLIB $(BIN_LIB) TYPE(*TEST) TEXT('ILEastic: Programmable applications server for ILE')"                                          
	-system -qi "CRTBNDDIR BNDDIR($(BIN_LIB)/ILEASTIC)"
	-system -qi "ADDBNDDIRE BNDDIR($(BIN_LIB)/ILEASTIC) OBJ(($(BIND_LIB)/ILEASTIC))"
	system -qi "CHGATR OBJ('headers/*') ATR(*CCSID) VALUE(1208)"
	-system -q "CRTSRCPF FILE($(BIN_LIB)/QRPGLEREF) RCDLEN(132)"
	system "CPYFRMSTMF FROMSTMF('headers/ileastic.rpgle') TOMBR('/QSYS.lib/$(BIN_LIB).lib/QRPGLEREF.file/ileastic.mbr') MBROPT(*REPLACE)"


noxDB: .PHONY
	cd noxDB && $(MAKE) BIN_LIB=$(BIN_LIB) TARGET_RLS=$(TARGET_RLS)

ILEfastCGI: .PHONY
	cd ILEfastCGI && $(MAKE) BIN_LIB=$(BIN_LIB) TARGET_RLS=$(TARGET_RLS)


compile: .PHONY
	cd src && $(MAKE) BIN_LIB=$(BIN_LIB) TARGET_RLS=$(TARGET_RLS)

bind: .PHONY
	cd src && $(MAKE) bind BIN_LIB=$(BIN_LIB) TARGET_RLS=$(TARGET_RLS)
clean:
	-system -q "CLRLIB $(BIN_LIB)"

test: .PHONY
	cd unittests && $(MAKE)

PLUGINS = cors authsystem basicauth mediatype
$(PLUGINS): .PHONY
	cd plugins/$@ && $(MAKE) all SHELL=$(SHELL)

plugins: $(PLUGINS)

bind-update:
	liblist -a $(LIBLIST);\
	system -ik "UPDSRVPGM SRVPGM($(BIN_LIB)/ILEASTIC) MODULE($(MODULES))"

# install the copybooks in the user provided directory (variable USRINCDIR)
install:
	-mkdir $(USRINCDIR)/ILEastic
	cp headers/ileastic.rpgle $(USRINCDIR)/ILEastic/
	$(eval cwd := $(shell pwd))
	set -e; \
	for plugin in $(PLUGINS); \
	do \
		cd plugins/$$plugin; \
		$(MAKE) $@ SHELL=$(SHELL); \
		cd $(cwd); \
	done

.PHONY:

