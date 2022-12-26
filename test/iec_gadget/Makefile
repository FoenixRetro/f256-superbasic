
ifeq ($(OS),Windows_NT)
include ..\..\documents\common.make
else
include ../../documents/common.make
endif

all : ramkernel

BINDIR = ..$(S)..$(S)bin$(S)
ASMOPTS = -q -b -Wall -c -L output$(S)testcode.lst -l output$(S)testcode.lbl -Wall 
KRN_REPO= ..$(S)..$(S)..$(S)F256_Jr_Kernel_DOS
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
	$(CCOPY) $(KRN_REPO)$(S)kernel$(S)*.bin .
	$(CCOPY) $(KRN_REPO)$(S)kernel$(S)api.asm .

#
#		Build RAM based kernel / test ROM combo and boot.
#
ramkernel: testcode.bin ramboot
	cat 3f.bin 3e.bin 01.bin testcode.bin  >kernel.ram 
	cat kernel.ram $(BINDIR)$(S)basic.rom >ramkernel.bin
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary ramkernel.bin --address E000
#
#		Build image
#
testcode.bin: cmd_read.asm reader.asm display.asm
	64tass $(ASMOPTS) cmd_read.asm reader.asm display.asm  -o testcode.bin