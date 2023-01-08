-------------------------------------------------------------------------
-------------------------------------------------------------------------

This helper file allows you to program the F256 in BASIC using a PC as 
an editor.

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
					UPLOADING YOUR FIRST PROGRAM
-------------------------------------------------------------------------

Programs are uploaded over the fast link to memory location $28000 , outside
the 6502's normal address space.  This is program1.bas, If you look at it it
is standard BASIC code, save for the last line which is an odd character, on
my system four y umlauts. This marks the end of the program..

To do this either run

	sh upload.sh program1.bas

or

	upload.bat program1.bas

depending on Windows, Mac or Linux.	The screen should blink, as the computer
resets.

In BASIC on the F256, type XLOAD then type LIST. You should see program.bas 
loaded on the machine. You can then RUN it.
	
To speed up this process, you can just use XGO which loads and runs it.

-------------------------------------------------------------------------
					UPLOADING YOUR SECOND PROGRAM
-------------------------------------------------------------------------

You don't actually need line numbers in SuperBASIC. They're mostly for 
editing and order. 

We will upload program2.bas, which has no line numbers. Use the Python script
included (number.py) to give them a line number, and it also adds the end of
file marker.
	
	python number.py <program2.bas >test.bas

and then 

	sh upload.sh test.bas OR upload.bat test.bas	

-------------------------------------------------------------------------
								NOTES
-------------------------------------------------------------------------

You can use the operating system to do whatever you want - keep your code
in seperate files, put them together have library files. 

-------------------------------------------------------------------------

Want help - ask on our Discord at https://discord.gg/7smtgA9Xs8

All feedback & suggestions welcomed.

Paul Robson (paul@robsons.org.uk)


