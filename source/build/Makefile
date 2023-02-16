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

#
#	Build parts and flash them.
#	
all: downloads build flash
#
#		Download any other ROMs
#
downloads:
	$(CDEL) pexec*.bin*
	wget https://raw.githubusercontent.com/dwsJason/superbasic/pexec/howto/update/pexec.bin

#
#		Split up into parts - requires the latest Gadget build of 01.bin, 3e.bin and 3f.bin
#
build:	
	$(CDEL) 01.bin 02.bin 03.bin 04.bin 05.bin
	$(CDEL) bulk.csv
	64tass -q -b -c lockout.as65 -o lockout.bin 
	python splitrom.py 
#
#		Reflash.
#
flash:
	python ..$(S)..$(S)bin$(S)fnxmgr.zip --port $(TTYPORT) --flash-bulk bulk.csv

#
#	
#