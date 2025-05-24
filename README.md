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
cd f256-superbasic/source

# this will build everything against/including latest kernel
make -B pullkernel updatekernel build release

# or just build basic
make -B basic release
```

This will output a set of binary files in the `release/` folder
and a file called `release/bulk.csv` that shows where those files
get flashed in memory.

### Testing

#### MAME

[MAME](https://www.mamedev.org/) is an emulation framework for a wide variety of computer
architectures, old and new alike. A work-in-progress fork of MAME for F256K is available
at https://github.com/dtremblay/mame.

Assuming you have the above repository cloned side-by-side with the `f256-superbasic` repo,
you can run the following commands to test your build in MAME F256K:

```
cd mame
cp -f ../f256-superbasic/source/release/sb*.bin roms/f256k/    # copy over SuperBASIC ROMs
./f256 f256 -window -resolution 1280x960                       # run the emulator
```

Note that because MAME embeds CRC checksums for all ROMs, you'll see warnings similar to
the following:

```
sb01.bin WRONG CHECKSUMS:
    EXPECTED: CRC(21f06e73) SHA1(bbeefb52d4b126b61367169c21599180f3358af7)
       FOUND: CRC(88ece5fe) SHA1(467a8a3fa1b5b686235439d023dd2248895f9ab7)
sb03.bin WRONG CHECKSUMS:
    EXPECTED: CRC(653f849d) SHA1(65942d98f26b86499e6359170aa2d0c6e16124ff)
       FOUND: CRC(0f3b2b61) SHA1(b540fa85b4906bad5345eba525b928534333b1f1)
sb04.bin WRONG CHECKSUMS:
    EXPECTED: CRC(f4aa6049) SHA1(11f02fee6ec412f0c96b27b0b149f72cf1770d15)
       FOUND: CRC(81a3ddb7) SHA1(4cccecb817bd5b358acbf3b2d44f7af71dfa89f3)
WARNING: the machine might not run correctly.
```

These warnings can be safely ignored.

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

- [F256 Documentation Wiki](https://wiki.f256foenix.com)
- [More information on flashing SuperBASIC to your machine](https://wiki.f256foenix.com/index.php?title=Kernel_%26_SuperBASIC_Updates)
- [More information on MAME for F256](https://wiki.f256foenix.com/index.php?title=Emulation#MAME)
- [F256 emulator](https://github.com/FoenixRetro/junior-emulator)
- [F256 Kernel and DOS](https://github.com/ghackwrench/F256_Jr_Kernel_DOS)
- [F256 Command Line USB upload tool](https://github.com/pweingar/FoenixMgr)
- [Foenix BootScreens](https://github.com/WartyMN/Foenix-F256JR-bootscreens)
