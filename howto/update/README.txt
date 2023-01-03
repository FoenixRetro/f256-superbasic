-------------------------------------------------------------------------
-------------------------------------------------------------------------

This helper file allows you to update the F256Jr/K on Windows or Linux. 

-------------------------------------------------------------------------
-------------------------------------------------------------------------

-------------------------------------------------------------------------
Mac users. There is a technical issue (with the Mac, not the F256) which 
limits the connection. We have someone working on a solution, but a short
term alternative is to install Windows or Linux in a VirtualBox image.
Linux is probably the easiest. 
-------------------------------------------------------------------------

You will need :-

1) 	Python3 installed (http://www.python.org)
2) 	The Python Serial Library "pyserial" (usually pip install pyserial)

Windows users may need to update the drivers for the EXAR serial ports,
the file xrusbuser_2600_signed_win7.zip seems to be the most recent.

-------------------------------------------------------------------------

Connect the PC to your F256 using the USB cable which plugs into the 
debug port on the board.

This will create a serial port on your machine. This seems to be more 
often than not COM3 on Windows and /dev/ttyUSB0 on Linux.

-------------------------------------------------------------------------

From a command prompt (Windows), or a terminal (Linux) run the following
command:

	python fnxmgr.zip --list-ports

This will give a list of the serial ports on the machine, for example my 
machine responds with

	/dev/ttyS0
	   Description: ttyS0
	   Manufacturer: None
	   Product: None

	/dev/ttyUSB0
	   Description: XR21B1411
	   Manufacturer: Exar Corp.
	   Product: XR21B1411

The connection to the F256 is the "Exar Corp" serial port, e.g. /dev/ttyUSB0

-------------------------------------------------------------------------

Change update.bat (Windows) update.sh (Linux) so that the value following --port
is the name of this serial port on each line that begins 'python fnxmgr.zip'

These are set to COM3 and /dev/ttyUSB0 by default, which may already be correct.

-------------------------------------------------------------------------

Run either update.bat or update.sh - your F256 should reflash and reboot over
a period of about 5 seconds or so.

-------------------------------------------------------------------------
Want help - ask on our Discord at https://discord.gg/7smtgA9Xs8

Paul Robson (paul@robsons.org.uk)


