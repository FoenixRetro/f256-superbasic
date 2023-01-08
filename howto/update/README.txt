-------------------------------------------------------------------------
-------------------------------------------------------------------------

This helper file allows you to update the F256Jr/K on Windows or Linux. 

-------------------------------------------------------------------------
-------------------------------------------------------------------------

Set up your hardware as described in SETUPHARDWARE.txt. This should also
allow you to determine which serial 'port' your F256 machine is connected
to.

These are different on different operating systems and different machines.

-------------------------------------------------------------------------

Change update.bat (Windows) update.sh (Linux) so that the value following --port
is the name of this serial port on each line that begins 'python fnxmgr.zip'

These are set to COM3 and /dev/ttyUSB0 by default, which may already be correct.

-------------------------------------------------------------------------
						UPDATING YOUR FLASH ROM
-------------------------------------------------------------------------

Run either update.bat or update.sh - your F256 should reflash and reboot over
a period of about 5 seconds or so.

-------------------------------------------------------------------------
Want help - ask on our Discord at https://discord.gg/7smtgA9Xs8

All feedback & suggestions welcomed.

Paul Robson (paul@robsons.org.uk)


