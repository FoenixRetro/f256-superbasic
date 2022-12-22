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

#	System 0 = F256
SYSTEM = 0 						
BINDIR = $(ROOTDIR)bin$(S)
ASMOPTS = -q -b -Wall -c -D HARDWARE="$(SYSTEM)" -L output$(S)basic.lst -l output$(S)basic.lbl -Wall 
APPNAME = build$(S)basic.rom
SCRIPTDIR = scripts$(S)
EMULATOR = $(BINDIR)jr256$(APPSTEM)
LANGUAGE = en

EMU_REPO= ..$(S)..$(S)junior-emulator
TNY_REPO= ..$(S)..$(S)junior-tinykernel
LDR_FILE= ..$(S)..$(S)FoenixMgr
KRN_REPO= ..$(S)..$(S)F256_Jr_Kernel_DOS

MODULES= +hardware +graphics +tokeniser +sound +kernel
RELEASEDIR = ..$(S)release
RELEASE = "`cat $(SCRIPTDIR)$(S)buildcount.txt`"

START = $(EMULATOR) $(APPNAME)@b storage$(S)load.dat@x $(BINDIR)graphics.bin@s boot@8000

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
#
#		Switch to Flash-Boot or RAM-Boot
#	
flashboot:
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --boot flash 
ramboot:	
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --boot ram
#
#		Build & update Kernel & api.asm
#
updatekernel:
	make -B -C $(KRN_REPO)
	$(CCOPY) $(KRN_REPO)$(S)kernel$(S)*.bin build
	$(CCOPY) $(KRN_REPO)$(S)kernel$(S)api.asm  module.interface$(S)kernel

ramkernel: ramboot
	$(CCOPY) $(KRN_REPO)$(S)kernel$(S)kernel.ram build
	cat build$(S)kernel.ram build$(S)basic.rom >build$(S)ramkernel.bin
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary build$(S)ramkernel.bin --address E000

#
#		Run on real hardware (RAM operation)
#
go : ramboot
	python scripts$(S)checkload.py
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary $(BINDIR)$(S)lockout.rom --address $(LLOCKOUT)
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary $(BINDIR)$(S)graphics.bin --address $(LSPRITES)
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary storage$(S)load.dat --address $(LSOURCE)
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary $(APPNAME) --address $(LBASIC)
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary $(BINDIR)$(S)monitor.rom --address $(LMONITOR)
#
#		Run on real hardware (Flash Operation)
#
fupload: flashboot basic
	make -C build 

fgo: flashboot
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
tools: emu monitor fnxmgr

shim:
	64tass -q -b _shim.asm -o shim.bin
	
fnxmgr:	
	$(CDEL) temp$(S)*.*
	$(CCOPY) $(LDR_FILE)$(S)FoenixMgr$(S)*.* temp
	$(CCOPY) temp$(S)fnxmgr.py temp$(S)__main__.py 
	zip temp$(S)fnxmgr.zip -j temp$(S)__main__.py temp$(S)constants.py temp$(S)foenix_config.py temp$(S)intelhex.py \
			temp$(S)pgx.py temp$(S)srec.py temp$(S)foenix.py temp$(S)pgz.py temp$(S)wdc.py
	$(CCOPY) temp$(S)fnxmgr.zip $(BINDIR) 

monitor:
	make -B -C $(TNY_REPO)
	$(CCOPY) $(TNY_REPO)$(S)monitor.rom $(BINDIR)
	$(CCOPY) $(TNY_REPO)$(S)lockout.rom $(BINDIR)

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
	
prelim:
	make -B -C ..$(S)modules
	python $(SCRIPTDIR)errors.py $(LANGUAGE)
	python $(SCRIPTDIR)opcodes.py >common$(S)generated$(S)asmcore.asm
	python $(SCRIPTDIR)makebuild.py $(MODULES)
	python $(SCRIPTDIR)tokens.py
	python $(SCRIPTDIR)constants.py

release:
	python $(SCRIPTDIR)timestamp.py
	mkdir -p $(RELEASEDIR)$(S)$(RELEASE)	
	make -C .
	$(CCOPY) $(APPNAME) $(RELEASEDIR)$(S)$(RELEASE)$(S)basic_$(RELEASE).rom	
	make -C . testbasic
	$(CCOPY) $(APPNAME) $(RELEASEDIR)$(S)$(RELEASE)$(S)basic_autoload_$(RELEASE).rom	
	make -C build build
	$(CCOPY) build$(S)*.bin $(RELEASEDIR)$(S)$(RELEASE)
	$(CCOPY) build$(S)bulk.csv $(RELEASEDIR)$(S)$(RELEASE)
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