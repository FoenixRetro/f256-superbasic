BINDIR = ../../../bin/
TTYPORT = /dev/ttyUSB0


all: assemble


assemble: 
	64tass -q -b -Wall -c -C -L tiles.lst tiles.asm -o tiles.bin

upload: assemble
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary tiles.bin --address 2000

