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
include ..\documents\common.make
else
include ../documents/common.make
endif
#
#		Current version. (In Beta from 01/03/23)
#
VERSION = 1

#	System 0 = F256
SYSTEM = 0 						
BINDIR = $(ROOTDIR)bin$(S)
ASMOPTS = -q -b -Wall -c -C -D HARDWARE="$(SYSTEM)" -L output$(S)basic.lst -l output$(S)basic.lbl -Wall 
APPNAME = build$(S)basic.rom
SCRIPTDIR = scripts$(S)
EMULATOR = $(BINDIR)jr256$(APPSTEM)
LANGUAGE = en

EMU_REPO= ..$(S)..$(S)junior-emulator
LDR_FILE= ..$(S)..$(S)FoenixMgr
KRN_REPO= ..$(S)..$(S)F256_Jr_Kernel_DOS

MODULES= +hardware +graphics +tokeniser +sound +kernel

START = $(EMULATOR) $(APPNAME)@b storage$(S)load.dat@x $(BINDIR)graphics.bin@s $(BINDIR)tile_map.bin@24000 $(BINDIR)tile_images.bin@26000

all :  basic
#
#		Run on emulator with/without autorun
#	
run : basic	
	python scripts$(S)checkload.py
	$(START)

testbasic:prelim
	64tass -D AUTORUN=1 $(AADDRESSES) $(ASMOPTS) _basic.asm -o $(APPNAME)
	$(CCOPY) $(APPNAME) $(BINDIR)

trun: testbasic
	python scripts$(S)checkload.py
	$(START)

#
#		Build & update Kernel & api.asm
#
pullkernel:
	cd $(KRN_REPO) && git reset --hard
	cd $(KRN_REPO) && git pull

updatekernel: 	
	make -B -C $(KRN_REPO)
	$(CCOPY) $(KRN_REPO)$(S)kernel$(S)*.bin build
	$(CCOPY) $(KRN_REPO)$(S)kernel$(S)api.asm  common$(S)api

#
#		Build RAM based kernel / ROM combo and boot.
#
ramkernel: 
	cat build$(S)3f.bin build$(S)3e.bin build$(S)01.bin  >build$(S)kernel.ram 
	cat build$(S)kernel.ram build$(S)basic.rom >build$(S)ramkernel.bin
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary build$(S)ramkernel.bin --address E000
#
#		Run on real hardware (Flash RAM operation)
#	
rgo : ramkernel putcode
#
#		Run on real hardware (RAM operation)
#
go : graphics
	python scripts$(S)checkload.py
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary $(BINDIR)$(S)lockout.rom --address $(LLOCKOUT)
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary storage$(S)load.dat --address $(LSOURCE)
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary $(APPNAME) --address $(LBASIC)
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary $(BINDIR)$(S)monitor.rom --address $(LMONITOR)
#
#		Upload sprites, tiles, tileimages.
#		
graphics:
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary $(BINDIR)$(S)graphics.bin --address $(LSPRITES)
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary $(BINDIR)$(S)tile_map.bin --address $(LTILEMAP)
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary $(BINDIR)$(S)tile_images.bin --address $(LTILEIMAGES)

#
#		Store Basic code in upper RAM
#
putcode:
	python scripts$(S)checkload.py
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary storage$(S)load.dat --address $(LSOURCE)
#
#		Run on real hardware (Flash Operation)
#
fupload: basic
	make -C build 
#
#		Autorun on real hardware
#
fauto: testbasic fgo
	make -C build
	
fgo: 
	python scripts$(S)checkload.py
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary storage$(S)load.dat --address 28000
#
#		Create sprites
#
sprites:
	make -B -C ..$(S)spritebuild
#
#		Build and download tools
#
tools: emu fnxmgr

shim:
	64tass -q -b _shim.asm -o shim.bin
	
fnxmgr:	
	$(CDEL) temp$(S)*.*
	$(CCOPY) $(LDR_FILE)$(S)FoenixMgr$(S)*.* temp
	$(CCOPY) temp$(S)fnxmgr.py temp$(S)__main__.py 
	zip temp$(S)fnxmgr.zip -j temp$(S)__main__.py temp$(S)constants.py temp$(S)foenix_config.py temp$(S)intelhex.py \
			temp$(S)pgx.py temp$(S)srec.py temp$(S)foenix.py temp$(S)pgz.py temp$(S)wdc.py
	$(CCOPY) temp$(S)fnxmgr.zip $(BINDIR) 

emu:
	make -B -C $(EMU_REPO)
	$(CCOPY) $(EMU_REPO)$(S)bin$(S)jr256$(APPSTEM) $(BINDIR)
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
	64tass -D AUTORUN=0 $(AADDRESSES) $(ASMOPTS) _basic.asm -o $(APPNAME)
	$(CCOPY) $(APPNAME) $(BINDIR)

autorun:
	python scripts$(S)checkload.py
	$(START)
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
	$(CCOPY) $(APPNAME) release$(S)$(S)roms$(S)basic_autoload.rom
	make -C . basic
	$(CCOPY) $(APPNAME) release$(S)roms$(S)basic.rom

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

assembler: 
	python $(SCRIPTDIR)asmtest.py
	64tass -q -b -c common$(S)generated$(S)asmtest.tass -L output$(S)asmtest.lst -o output$(S)asmtest.bin
	$(EMULATOR) $(APPNAME)@b storage$(S)load.dat@x
	python $(SCRIPTDIR)asmcheck.py

lineedit:
	python $(SCRIPTDIR)linetest.py
	64tass -D AUTORUN=1 $(AADDRESSES) $(ASMOPTS) _basic.asm -o $(APPNAME)
	$(START)
	python $(SCRIPTDIR)linecheck.py

paging:
	python $(SCRIPTDIR)checkpaging.py
#
#		Machine code boot test.
#	
mcboot:
	64tass -q -b -Wall -C -c storage$(S)mcboot.as -L output$(S)mcboot.lst -o output$(S)mcboot.bin

mctest:mcboot	
	$(START) output$(S)mcboot.bin@2000

mcflash:mcboot 
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary output$(S)mcboot.bin --address 2000
