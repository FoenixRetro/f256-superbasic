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

all: jattrs.bin jchars.bin kattrs.bin kchars.bin palette.hex
	python process.py


jattrs.bin: $(PROMPTDIR)f256jr_boot_attrs.bin
	$(CCOPY) $^ $@
	
jchars.bin: $(PROMPTDIR)f256jr_boot_chars.bin
	$(CCOPY) $^ $@

kattrs.bin: $(PROMPTDIR)f256k_boot_attrs.bin
	$(CCOPY) $^ $@

kchars.bin: $(PROMPTDIR)f256k_boot_chars.bin
	$(CCOPY) $^ $@

palette.hex: $(PROMPTDIR)f256jr_std_text_palette.hex
	$(CCOPY) $^ $@
