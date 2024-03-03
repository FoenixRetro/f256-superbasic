# F256 SuperBASIC
Improved BASIC for F256 Junior

### Usage

SuperBASIC Reference Manual PDF:
[reference/source/f256jr_basic_ref.pdf](reference/source/f256jr_basic_ref.pdf)

### Developing
You need Make, Python and 64tass assembler on your machine.

You will also need a few repos besides SuperBASIC.  
SuperBASIC is fully intended to work with the _latest_ Kernel/DOS.

### Building
```
git clone git@github.com:FoenixRetro/f256-superbasic.git
git clone git@github.com:WartyMN/Foenix-F256JR-bootscreens.git
git clone git@github.com:ghackwrench/F256_Jr_Kernel_DOS.git
cd f256-superbasic

# this will build everything against/including latest kernel 
make -B pullkernel updatekernel build release

# or just build basic
make -B basic release
```

This will output a set of binary files in the `release/` folder
and a file called `release/bulk.csv` that shows where those files
get flashed in memory.

### Testing

#### Real Hardware 
You can upload it over a USB cable to the debug port on your F256 machine using FoenixMgr. 

This doc doesn't cover setting that up, but once you have it set up you should be able to 
try out your build using the `--flash-bulk` command. 

Example on Mac:
```
❯ cd release
❯ python3 ~/FoenixMgr/fnxmgr.py --port /dev/cu.usbmodemR23963534611 --flash-bulk bulk.csv
Attempting to program sector 0x3F with lockout.bin
Binary file uploaded...
Flash sector erased...
Flash sector programmed...
Attempting to program sector 0x01 with sb01.bin
     ...
```


### Additional References
F256 Documentation Wiki
https://wiki.f256foenix.com

More information on flashing SuperBASIC to your machine
https://wiki.f256foenix.com/index.php?title=Kernel_%26_SuperBASIC_Updates

F256 emulator
https://github.com/FoenixRetro/junior-emulator

F256 Kernel and DOS
https://github.com/ghackwrench/F256_Jr_Kernel_DOS

F256 Command Line USB upload tool
https://github.com/pweingar/FoenixMgr

BootScreens
https://github.com/WartyMN/Foenix-F256JR-bootscreens

