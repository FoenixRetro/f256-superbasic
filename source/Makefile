# ************************************************************************************************
# ************************************************************************************************
#
#		Name:		Makefile
#		Purpose:	Main make file
#		Created:	18th September 2022
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# ************************************************************************************************
# ************************************************************************************************

ifeq ($(OS),Windows_NT)
include ..\documents\common.make
else
include ../documents/common.make
endif

#	System 0 = F256
SYSTEM = 0 						
BINDIR = $(ROOTDIR)bin$(S)
ASMOPTS = -q -b -Wall -c -D HARDWARE="$(SYSTEM)" -L output$(S)basic.lst -l output$(S)basic.lbl -Wall 
APPNAME = basic.rom
SCRIPTDIR = scripts$(S)
EMULATOR = $(BINDIR)jr256$(APPSTEM)
TTYPORT = /dev/ttyUSB0
LANGUAGE = en

EMU_REPO= ..$(S)..$(S)junior-emulator
UTL_REPO= ..$(S)..$(S)junior-utilities
KRN_REPO= ..$(S)..$(S)junior-tinykernel

MODULES= +hardware +graphics +tokeniser +sound
RELEASEDIR = ..$(S)release
RELEASE = "`cat $(SCRIPTDIR)$(S)buildcount.txt`"

START = $(EMULATOR) $(APPNAME)@b storage$(S)load.dat@$(LSOURCE) $(BINDIR)graphics.bin@$(LSPRITES) boot@8000

all :  basic
#
#		Run on emulator with/without autorun
#	
run : basic	
	python scripts$(S)checkload.py
	$(START)

testbasic:prelim
	64tass -D AUTORUN=1 $(AADDRESSES) $(ASMOPTS) _basic.asm -o $(APPNAME)
	$(CCOPY) $(APPNAME) $(BINDIR)
#
#		Run on real hardware
#
go : 
	python scripts$(S)checkload.py
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary $(BINDIR)$(S)lockout.rom --address $(LLOCKOUT)
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary $(BINDIR)$(S)graphics.bin --address $(LSPRITES)
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary storage$(S)load.dat --address $(LSOURCE)
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary basic.rom --address $(LBASIC)
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary $(BINDIR)$(S)monitor.rom --address $(LMONITOR)
#
#		Create sprites
#
sprites:
	make -B -C ..$(S)spritebuild
#
#		Build and download tools
#
tools: emu monitor fnxmgr

shim:
	64tass -q -b _shim.asm -o shim.bin
	
fnxmgr:	
	make -B -C $(UTL_REPO)
	$(CCOPY) $(UTL_REPO)$(S)fnxmgr.zip $(BINDIR)
	$(CCOPY) $(UTL_REPO)$(S)foenixmgr.ini .

monitor:
	make -B -C $(KRN_REPO)
	$(CCOPY) $(KRN_REPO)$(S)monitor.rom $(BINDIR)
	$(CCOPY) $(KRN_REPO)$(S)lockout.rom $(BINDIR)

emu:
	make -B -C $(EMU_REPO)
	$(CCOPY) $(EMU_REPO)$(S)bin$(S)jr256$(APPSTEM) $(BINDIR)
#
#		Show various things
#
stack:
	python $(SCRIPTDIR)showstack.py
	
strings:
	python $(SCRIPTDIR)showstring.py

vars:
	python $(SCRIPTDIR)showvar.py
#
#		Builds with/without autorun
#	
basic : prelim
	64tass -D AUTORUN=0 $(AADDRESSES) $(ASMOPTS) _basic.asm -o $(APPNAME)
	$(CCOPY) $(APPNAME) $(BINDIR)

autorun:
	python scripts$(S)checkload.py
	$(START)
	
prelim:
	make -C ../modules
	python $(SCRIPTDIR)errors.py $(LANGUAGE)
	python $(SCRIPTDIR)opcodes.py >common$(S)generated$(S)asmcore.asm
	python $(SCRIPTDIR)makebuild.py $(MODULES)
	python $(SCRIPTDIR)tokens.py
	python $(SCRIPTDIR)constants.py

release:
	python $(SCRIPTDIR)timestamp.py
	mkdir -p $(RELEASEDIR)$(S)$(RELEASE)	
	make -C .
	$(CCOPY) basic.rom $(RELEASEDIR)$(S)$(RELEASE)$(S)basic_$(RELEASE).rom	
	make -C . testbasic
	$(CCOPY) basic.rom $(RELEASEDIR)$(S)$(RELEASE)$(S)basic_autoload_$(RELEASE).rom	
#
#		Run various tests.
#
test:
	python $(SCRIPTDIR)simpletests.py 

astest:
	python $(SCRIPTDIR)assign.py 	

sastest:
	python $(SCRIPTDIR)assign.py all	

artest:
	python $(SCRIPTDIR)array.py 	
	
benchmark:
	cp ..$(S)documents$(S)benchmarks$(S)bm$(ID).bas storage$(S)load.dat

assembler: 
	python $(SCRIPTDIR)asmtest.py
	64tass -q -b -c common$(S)generated$(S)asmtest.tass -L output$(S)asmtest.lst -o output$(S)asmtest.bin
	$(EMULATOR) $(APPNAME)@8000 storage$(S)load.dat@3000 
	python $(SCRIPTDIR)asmcheck.py

lineedit:
	python $(SCRIPTDIR)linetest.py
	64tass -D AUTORUN=1 $(AADDRESSES) $(ASMOPTS) _basic.asm -o $(APPNAME)
	$(START)
	python $(SCRIPTDIR)linecheck.py

paging:
	python $(SCRIPTDIR)checkpaging.py