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
include ..\..\..\documents\common.make
else
include ../../../documents/common.make
endif

GRAPHICS = alien11:16,10 alien12:34,11 alien21:15,30 alien22:39,30 alien31:16,46 alien32:52,46 \
		   explosion:96,15 base:169,43 bullet1:170,20 bullet21:62,13 bullet22:76,13 saucer:130,29

BINDIR = ..$(S)..$(S)..$(S)bin$(S)

all :
	python $(BINDIR)ripgfx.py $(GRAPHICS)