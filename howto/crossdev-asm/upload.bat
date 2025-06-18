@echo off
rem
rem		Script for Windows to assemble and upload 6502 code.
rem
64tass -q -b -Wall -C -c demo.asm -L demo.lst -o demo.bin
python fnxmgr.zip --port COM3 --binary demo.bin --address 2000
