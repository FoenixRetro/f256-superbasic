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

GRAPHICS = up:29,17 right:63,18 down:95,18 left:122,18


BINDIR = ..$(S)..$(S)..$(S)bin$(S)

all :
	python $(BINDIR)ripgfx.py $(GRAPHICS)