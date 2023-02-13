BINDIR = ../../../bin/
TTYPORT = /dev/ttyUSB0


all: assemble


assemble: 
	64tass -q -b -Wall -c -C -L tiles8.lst tiles8.asm -o tiles8.bin

upload: assemble
	python $(BINDIR)fnxmgr.zip --port $(TTYPORT) --binary tiles8.bin --address 2000

