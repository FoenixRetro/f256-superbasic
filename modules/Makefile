# ************************************************************************************************
# ************************************************************************************************
#
#		Name:		Makefile
#		Purpose:	Main module make file
#		Created:	14th November 2022
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# ************************************************************************************************
# ************************************************************************************************

ifeq ($(OS),Windows_NT)
include ..\documents\common.make
else
include ../documents/common.make
endif

all:
	make -B -C graphics

	make -B -C hardware$(S)header
	
	python _scripts$(S)makebuild.py graphics >_build$(S)_graphics.module

	$(CCOPY) ..$(S)source$(S)common$(S)generated$(S)kwdtext.dat tokeniser$(S)__kwdtext.asm
	python _scripts$(S)makebuild.py tokeniser >_build$(S)_tokeniser.module

	python _scripts$(S)makebuild.py hardware >_build$(S)_hardware.module	

	python _scripts$(S)makebuild.py sound >_build$(S)_sound.module		

	python _scripts$(S)makebuild.py kernel >_build$(S)_kernel.module

	python _scripts$(S)makeexport.py >_build$(S)_linker.module

