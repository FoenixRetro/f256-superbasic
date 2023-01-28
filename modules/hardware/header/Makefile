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

all:
	$(CCOPY) $(PROMPTDIR)f256jr_boot_attrs.bin jattrs.bin
	$(CCOPY) $(PROMPTDIR)f256jr_boot_chars.bin jchars.bin	
	$(CCOPY) $(PROMPTDIR)f256k_boot_attrs.bin kattrs.bin
	$(CCOPY) $(PROMPTDIR)f256k_boot_chars.bin kchars.bin	
	$(CCOPY) $(PROMPTDIR)f256jr_std_text_palette.hex palette.hex

	python process.py
	