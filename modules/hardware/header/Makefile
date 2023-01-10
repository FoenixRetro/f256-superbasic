# ************************************************************************************************
# ************************************************************************************************
#
#		Name:		Makefile
#		Purpose:	Header make file
#		Created:	14th December 2022
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# ************************************************************************************************
# ************************************************************************************************

ifeq ($(OS),Windows_NT)
include ..\..\..\documents\common.make
else
include ../../../documents/common.make
endif

PROMPTDIR = ..$(S)..$(S)..$(S)..$(S)Foenix-F256JR-bootscreens$(S)
FONTDIR = ..$(S)..$(S)..$(S)..$(S)Foenix-Fonts$(S)
all:
	$(CCOPY) $(PROMPTDIR)f256jr_boot_attrs.bin attrs.bin
	$(CCOPY) $(PROMPTDIR)f256jr_boot_chars.bin chars.bin	
	$(CCOPY) $(PROMPTDIR)f256jr_std_text_palette.hex palette.hex
	$(CCOPY) $(FONTDIR)standard/f256jr_std-charset.bin font.bin

	python process.py
	
	$(CCOPY) font.bin ..$(S)..$(S)..$(S)source$(S)common$(S)generated