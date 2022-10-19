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

BINDIR = $(ROOTDIR)bin$(S)
ASMOPTS = -q -b -Wall -c -L output$(S)basic.lst -l output$(S)basic.lbl -Wall 
APPNAME = basic.rom
SCRIPTDIR = scripts$(S)
EMULATOR = $(BINDIR)jr256$(APPSTEM)
TTYPORT = /dev/ttyUSB0
LANGUAGE = en

EMU_REPO= ..$(S)..$(S)junior-emulator
UTL_REPO= ..$(S)..$(S)junior-utilities
KRN_REPO= ..$(S)..$(S)junior-tinykernel

START = $(EMULATOR) $(APPNAME)@8000 storage$(S)load.dat@3000 $(BINDIR)graphics.bin@30000
# 3000 is hardcoded in backload.asm

all :  basic
#
#		Run on emulator with/without autorun
#	
run : basic	
	python scripts$(S)checkload.py
	$(START)

testbasic:prelim
	64tass -D AUTORUN=1 $(ASMOPTS) _basic.asm -o $(APPNAME)
	$(CCOPY) $(APPNAME) $(BINDIR)
#
#		Run on real hardware
#
go : basic 
	python scripts$(S)checkload.py
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary $(BINDIR)$(S)monitor.rom --address F000
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary $(BINDIR)$(S)graphics.bin --address 30000
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary storage$(S)load.dat --address 3000
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary basic.rom --address 8000
#
#		Create sprites
#
sprites:
	make -B -C ..$(S)spritebuild
#
#		Build and download tools
#
tools: emu monitor fnxmgr

fnxmgr:	
	make -B -C $(UTL_REPO)
	$(CCOPY) $(UTL_REPO)$(S)fnxmgr.zip $(BINDIR)
	$(CCOPY) $(UTL_REPO)$(S)foenixmgr.ini .

monitor:
	make -B -C $(KRN_REPO)
	$(CCOPY) $(KRN_REPO)$(S)monitor.rom $(BINDIR)

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
	64tass -D AUTORUN=0 $(ASMOPTS) _basic.asm -o $(APPNAME)
	$(CCOPY) $(APPNAME) $(BINDIR)

autorun:testbasic
	python scripts$(S)checkload.py
	$(START)
	
prelim:
	make -C ../graphics integrated
	python $(SCRIPTDIR)errors.py $(LANGUAGE)
	python $(SCRIPTDIR)opcodes.py >common$(S)generated$(S)asmcore.asm
	python $(SCRIPTDIR)makebuild.py
	python $(SCRIPTDIR)tokens.py
	python $(SCRIPTDIR)constants.py
	python $(SCRIPTDIR)timestamp.py
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
	64tass -D AUTORUN=1 $(ASMOPTS) _basic.asm -o $(APPNAME)
	$(START)
	python $(SCRIPTDIR)linecheck.py
