BINDIR = ../../../bin/
TTYPORT = /dev/ttyUSB0


all: assemble


assemble: 
	64tass -q -b -Wall -c -C -L tiles8.lst tiles8.asm -o tiles8.bin
#	64tass -q -b -Wall -c -C tiles_pix.asm -o tile_images.bin
#	64tass -q -b -Wall -c -C tile_map.asm -o tile_map.bin
#	cp tile_map.bin tile_images.bin ../../../bin
	
upload: assemble
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary tiles8.bin --address 2000

basic:
	touch ../../../../junior-emulator/emulator/src/sys_debug_uk101.cpp
	make -C ../../../../junior-emulator/emulator
	cp ../../../../junior-emulator/bin/jr256 $(BINDIR)

run: assemble
	$(BINDIR)jr256$(APPSTEM) $(BINDIR)basic.rom@b $(BINDIR)tile_map.bin@24000 $(BINDIR)tile_images.bin@26000 $(BINDIR)graphics.bin@30000 tiles8.bin@2000