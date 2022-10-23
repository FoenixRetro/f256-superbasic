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
include ..\..\documents\common.make
else
include ../../documents/common.make
endif

BINDIR = ..$(S)..$(S)bin$(S)
EMULATOR = $(BINDIR)jr256$(APPSTEM)
TTYPORT = /dev/ttyUSB0
LANGUAGE = en
SOURCE = invaders.bas

START = $(EMULATOR) $(BINDIR)basic.rom@8000 storage$(S)load.dat@3000 graphics.bin@30000
# 3000 is hardcoded in backload.asm

#
#		Extract Graphics, perhaps
#
graphics:
	make -B -C graphics
#
#		Create sprites
#
sprites:
	python $(BINDIR)spritebuild.py sprites.def
#
#		Create autorunning test basic
#
auto:
	make -B -C ..$(S)..$(S)source testbasic
#
#		Build program
#
program:
	python $(BINDIR)basconv.py $(SOURCE) >storage$(S)load.dat
#
#		Run program (if built autorunning BASIC)
#
run: sprites program
	$(START)	