#
#		Script for Linux to assemble and upload 6502 code.
#
64tass -q -b -Wall -C -c demo.asm -L demo.lst -o demo.bin
python fnxmgr.zip --port /dev/ttyUSB0  --binary demo.bin --address 2000
