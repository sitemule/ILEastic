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
OUTPUT=*NONE

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

# CCFLAGS = C compiler parameter
CCFLAGS2=OPTION(*STDLOGMSG) OUTPUT($(OUTPUT)) OPTIMIZE(10) TGTCCSID(37) TGTRLS($(TARGET_RLS)) ENUM(*INT) TERASPACE(*YES) STGMDL(*INHERIT) SYSIFCOPT(*IFSIO) DBGVIEW(*ALL) INCDIR($(INCLUDE)) 

MODULES = $(BIN_LIB)/githash $(BIN_LIB)/stream $(BIN_LIB)/ileastic $(BIN_LIB)/ileasticr $(BIN_LIB)/varchar $(BIN_LIB)/api $(BIN_LIB)/sndpgmmsg $(BIN_LIB)/strutil $(BIN_LIB)/e2aa2e $(BIN_LIB)/xlate $(BIN_LIB)/simpleList $(BIN_LIB)/serialize $(BIN_LIB)/base64 $(BIN_LIB)/fastCGI $(BIN_LIB)/teramem
	
all: env noxDB ILEfastCGI compile bind
 
env:
	-system -qi "CRTLIB $(BIN_LIB) TYPE(*TEST) TEXT('ILEastic: Programmable applications server for ILE')"                                          
	-system -qi "CRTBNDDIR BNDDIR($(BIN_LIB)/ILEASTIC)"
	-system -qi "ADDBNDDIRE BNDDIR($(BIN_LIB)/ILEASTIC) OBJ(($(BIND_LIB)/ILEASTIC))"
	system -qi "CHGATR OBJ('headers/*') ATR(*CCSID) VALUE(1208)"
	-system -q "CRTSRCPF FILE($(BIN_LIB)/QRPGLEREF) RCDLEN(132)"
	system "CPYFRMSTMF FROMSTMF('headers/ileastic.rpgle') TOMBR('/QSYS.lib/$(BIN_LIB).lib/QRPGLEREF.file/ileastic.mbr') MBROPT(*REPLACE)"

compile: .PHONY
# get the git hash and put it into the version file so it becomes part of the copyright notice in the service program
	-$(eval gitshort := $(shell git rev-parse --short HEAD))
	-$(eval githash := $(shell git rev-parse --verify HEAD))
	-touch src/githash.c 
	-setccsid 1252 src/githash.c
	-echo "#pragma comment(copyright,\"System & Method A/S - Sitemule: git checkout $(gitshort) (hash: $(githash) )\")" > src/githash.c 

	cd src && $(MAKE) BIN_LIB=$(BIN_LIB) TARGET_RLS=$(TARGET_RLS)

noxDB: .PHONY
	cd noxDB && $(MAKE) BIN_LIB=$(BIN_LIB) TARGET_RLS=$(TARGET_RLS)

ILEfastCGI: .PHONY
	cd ILEfastCGI && $(MAKE) BIN_LIB=$(BIN_LIB) TARGET_RLS=$(TARGET_RLS)

		
bind:

	liblist -a $(LIBLIST);\
	system -q "DLTOBJ OBJ($(BIN_LIB)/QSRVSRC) OBJTYPE(*FILE)";\
	system "CRTSRCPF FILE($(BIN_LIB)/QSRVSRC) RCDLEN(112)";\
	system "CPYFRMSTMF FROMSTMF('headers/ileastic.bnd') TOMBR('/QSYS.lib/$(BIN_LIB).lib/QSRVSRC.file/ILEASTIC.mbr') MBROPT(*replace)";\
	system -q "DLTOBJ OBJ($(BIN_LIB)/ILEASTIC) OBJTYPE(*SRVPGM)";\
	system -kpieb "CRTSRVPGM SRVPGM($(BIN_LIB)/ILEASTIC) MODULE($(MODULES)) TGTRLS($(TARGET_RLS)) BNDSRVPGM(($(BIND_LIB)/ILEFASTCGI *DEFER) ($(BIND_LIB)/JSONXML *DEFER)) OPTION(*DUPPROC) DETAIL(*BASIC) STGMDL(*INHERIT) SRCFILE($(BIN_LIB)/QSRVSRC) TEXT('ILEastic - programable applicationserver for ILE')";
ifndef KEEP_MODULES
	@for module in $(MODULES); do\
		system -q "dltmod $$module" ; \
	done
endif
clean:
	-system -q "CLRLIB $(BIN_LIB)"

test: .PHONY
	cd unittests && $(MAKE)

PLUGINS = cors authsystem basicauth mediatype
$(PLUGINS): .PHONY
	cd plugins/$@ && $(MAKE) all SHELL=$(SHELL)

plugins: $(PLUGINS)

# For vsCode 
current: env
	system "CRTCMOD MODULE($(BIN_LIB)/$(SRC)) SRCSTMF('src/$(SRC).c') $(CCFLAGS2) "
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

