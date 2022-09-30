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
ASMOPTS = -q -b -Wall -Wno-portable -c -L output$(S)basic.lst -l output$(S)basic.lbl -Wall 
APPNAME = basic.rom
SCRIPTDIR = scripts$(S)
EMULATOR = $(BINDIR)jr256$(APPSTEM)
TTYPORT = /dev/ttyUSB0
LANGUAGE = en

EMU_REPO= ..$(S)..$(S)junior-emulator
UTL_REPO= ..$(S)..$(S)junior-utilities
KRN_REPO= ..$(S)..$(S)junior-tinykernel

all :  basic

run : basic
	# 3000 is hardcoded in backload.asm
	$(EMULATOR) $(APPNAME)@8000 storage$(S)load.dat@3000 

go : basic 
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary $(BINDIR)$(S)monitor.rom --address F000
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary storage$(S)load.dat --address 3000
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary basic.rom --address 8000

tools: emu
	make -B -C $(KRN_REPO)
	make -B -C $(UTL_REPO)
	$(CCOPY) $(UTL_REPO)$(S)fnxmgr.zip $(BINDIR)
	$(CCOPY) $(UTL_REPO)$(S)foenixmgr.ini .
	$(CCOPY) $(KRN_REPO)$(S)monitor.rom $(BINDIR)

emu:
	make -B -C $(EMU_REPO)
	$(CCOPY) $(EMU_REPO)$(S)bin$(S)jr256$(APPSTEM) $(BINDIR)

stack:
	python $(SCRIPTDIR)showstack.py
		
basic : prelim
	64tass $(ASMOPTS) _basic.asm -o $(APPNAME)

prelim:
	python $(SCRIPTDIR)errors.py $(LANGUAGE)
	python $(SCRIPTDIR)makebuild.py
	python $(SCRIPTDIR)tokens.py
	python $(SCRIPTDIR)constants.py

test:
	python $(SCRIPTDIR)tests.py 

astest:
	python $(SCRIPTDIR)assign.py 	