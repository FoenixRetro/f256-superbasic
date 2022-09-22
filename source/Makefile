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

all :  basic

run : basic
	$(EMULATOR) $(APPNAME)@8010

go : basic 
	$(BINDIR)makeboot $(APPSTEM) basic.rom upload.bin
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary upload.bin --address 8000

update-tools:
	$(CCOPY) ..$(S)..$(S)junior-emulator$(S)jr256* $(BINDIR)
	$(CCOPY) ..$(S)..$(S)junior-utilities$(S)fnxmgr.zip $(BINDIR)
	$(CCOPY) ..$(S)..$(S)junior-utilities$(S)makeboot$(APPSTEM) $(BINDIR)
	$(CCOPY) ..$(S)..$(S)junior-utilities$(S)foenixmgr.ini .

emu:
	make -B -C ..$(S)..$(S)junior-emulator
	
basic : prelim
	64tass $(ASMOPTS) _basic.asm -o $(APPNAME)

prelim:
	python $(SCRIPTDIR)errors.py $(LANGUAGE)
	python $(SCRIPTDIR)makebuild.py
	python $(SCRIPTDIR)tokens.py

test:
	python $(SCRIPTDIR)tests.py >storage$(S)load.dat