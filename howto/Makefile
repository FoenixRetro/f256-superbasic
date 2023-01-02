# ************************************************************************************************
# ************************************************************************************************
#
#		Name:		Makefile
#		Purpose:	Main make file
#		Created:	2nd January 2023
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# ************************************************************************************************
# ************************************************************************************************

ifeq ($(OS),Windows_NT)
include ..\documents\common.make
else
include ../documents/common.make
endif

all : update
	$(CDEL) *.zip
	zip -j howto-update.zip update/*
#
#		Build the update block
#
update:
	$(CDEL) update$(S)*.bin
	$(CCOPY) ..$(S)source$(S)build$(S)*.bin update
	$(CCOPY) ..$(S)source$(S)build$(S)bulk.csv update
	$(CDEL) update$(S)ramkernel.bin

	$(CCOPY) ..$(S)bin$(S)fnxmgr.zip update
	$(CCOPY) ..$(S)bin$(S)foenixmgr.ini update

