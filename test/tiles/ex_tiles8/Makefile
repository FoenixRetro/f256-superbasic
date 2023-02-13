BINDIR = ../../../bin/
TTYPORT = /dev/ttyUSB0


all: assemble


assemble: 
	64tass -q -b -Wall -c -C -L tiles8.lst tiles8.asm -o tiles8.bin
	64tass -q -b -Wall -c -C tiles_pix.asm -o tile_images.bin
	64tass -q -b -Wall -c -C tile_map.asm -o tile_map.bin
	cp tile_map.bin tile_images.bin ../../../bin
	
upload: assemble
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary tiles8.bin --address 2000

