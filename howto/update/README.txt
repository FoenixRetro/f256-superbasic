-------------------------------------------------------------------------

This helper file allows you to update the F256Jr/K on Windows or Linux. 

-------------------------------------------------------------------------

You will need :-

1) 	Python3 installed.
2) 	The Python Serial Library.

Connect the PC to your F256 using the USB cable which plugs into the 
debug port on the board.

This will create a serial port on your machine. 

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

-------------------------------------------------------------------------

Run either update.bat or update.sh - your F256 should reflash and reboot over
a period of about 5 seconds or so.

-------------------------------------------------------------------------
Want help - ask on our Discord at https://discord.gg/7smtgA9Xs8

Paul Robson (paul@robsons.org.uk)


