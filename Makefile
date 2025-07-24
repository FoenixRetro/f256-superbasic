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
include documents\common.make
else
include documents/common.make
endif
#
#		Current version. (In Beta from 01/03/23)
#
VERSION = 1

HARDWARE = 0        # 0 = F256
HARDWARE_GEN ?= 1   # 1 = J/K, 2 = J2/K2
ASMOPTS = -q -b -Wall -c -C -D HARDWARE="$(HARDWARE)" -D HARDWARE_GEN=$(HARDWARE_GEN) -L output$(S)basic.lst -l output$(S)basic.lbl -Wall
BUILD_OUT = build$(S)basic.rom
SCRIPTDIR = source$(S)scripts$(S)
LANGUAGE = en

MODULES= +hardware +graphics +tokeniser +sound +kernel

all :  basic

#
#		Update api.asm
#
updatekernel:
	cd source$(S)common$(S)api && curl -L -sS -o api.asm $(KRN_REPO)/raw/refs/heads/master/kernel/api.asm

#
#		Create sprites
#
sprites:
	make -B -C ..$(S)spritebuild
#
#		Build and download tools
#
tools: fnxmgr

#
#		Update FoenixMgr "binary"
#
fnxmgr:
	cd $(BINDIR) && curl -L -sS -o fnxmgr.zip $(LDR_REPO)/raw/refs/heads/master/FoenixMgr.zip

#
#		Show various things
#
stack:
	python $(SCRIPTDIR)showstack.py

strings:
	python $(SCRIPTDIR)showstring.py

vars:
	python $(SCRIPTDIR)showvar.py
#
#		Builds with/without autorun
#
basic : prelim
	64tass -D AUTORUN=0 $(AADDRESSES) $(ASMOPTS) _basic.asm -o $(BUILD_OUT)

#
#		Scripts run in advance generating tables etc.
#
prelim:
	make -B -C ..$(S)modules
	python $(SCRIPTDIR)errors.py $(LANGUAGE)
	python $(SCRIPTDIR)opcodes.py >common$(S)generated$(S)asmcore.asm
	python $(SCRIPTDIR)makebuild.py $(MODULES)
	python $(SCRIPTDIR)tokens.py
	python $(SCRIPTDIR)constants.py
	python $(SCRIPTDIR)timestamp.py $(VERSION)

#
#		Create a working release.
#
release:
	make -C . testbasic
	$(CCOPY) $(BUILD_OUT) release$(S)$(S)roms$(S)basic_autoload.rom
	make -C . basic
	$(CCOPY) $(BUILD_OUT) release$(S)roms$(S)basic.rom

	make -C build build
	$(CCOPY) build$(S)*.bin release
	$(CCOPY) build$(S)bulk.csv release

	$(CCOPY) ..$(S)CHANGES release$(S)documents
	$(CCOPY) ..$(S)reference$(S)source$(S)*.pdf release$(S)documents
	$(CCOPY) ..$(S)documents$(S)C256_Foenix_JR_UM_Rev002.pdf release$(S)documents
	$(CCOPY) ..$(S)documents$(S)superbasic.sublime-syntax release$(S)documents

	$(CDEL) release$(S)VERSION*
	echo "" >release$(S)VERSION_${VERSION}

	make -B -C ..$(S)howto
	cp ..$(S)howto$(S)howto*.zip release

	$(CDEL) release$(S)superbasic.zip
	zip -r release$(S)superbasic.zip release$(S)*

#
#		Run various tests.
#
test:
	python $(SCRIPTDIR)simpletests.py

astest:
	python $(SCRIPTDIR)assign.py

sastest:
	python $(SCRIPTDIR)assign.py all

artest:
	python $(SCRIPTDIR)array.py

benchmark:
	cp ..$(S)documents$(S)benchmarks$(S)bm$(ID).bas storage$(S)load.dat

paging:
	python $(SCRIPTDIR)checkpaging.py
