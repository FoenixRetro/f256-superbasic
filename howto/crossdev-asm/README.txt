-------------------------------------------------------------------------
-------------------------------------------------------------------------

This helper file allows you to program the F256 in Assembler using a PC as 
an editor. (Note, this requires release 31 or higher of SuperBASIC)

It is not meant as an introduction to 65C02 assembler.

-------------------------------------------------------------------------
-------------------------------------------------------------------------

Set up your hardware as described in SETUPHARDWARE.txt. This should also
allow you to determine which serial 'port' your F256 machine is connected
to.

These are different on different operating systems and different machines.

-------------------------------------------------------------------------

Change upload.bat (Windows) upload.sh (Linux) so that the value following --port
is the name of this serial port on each line that begins 'python fnxmgr.zip'

These are set to COM3 and /dev/ttyUSB0 by default, which may already be correct.

-------------------------------------------------------------------------

You will need to install 64tass, a 6502 assembler. The Windows version 
1.58 is included in a Zip file. For Linux, see your installer,  most Linux
distros can install 64tass directly.

-------------------------------------------------------------------------
					UPLOADING AN ASSEMBLY PROGRAM
-------------------------------------------------------------------------

There are several ways of running 65C02 assembler on the F256 Junior/K but
this is probably the simplest. The machine code is loaded to memory location
$2000 over the fast serial link.

The machine code program has a special header. When BASIC starts, it checks
for this special header and if found it runs the machine code instead.

To assemble and run either use

	sh upload.sh 

or

	upload.bat 

depending on Windows, Mac or Linux.	The screen should blink, as the computer
resets, and run the program, which displays text on the console in a loop 
changing the colour every draw.

An easy change to make is line 53, which can slow down or speed up the 
redrawing.
-------------------------------------------------------------------------

Want help - ask on our Discord at https://discord.gg/7smtgA9Xs8

All feedback & suggestions welcomed.

Paul Robson (paul@robsons.org.uk)


