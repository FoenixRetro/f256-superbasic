#
#		Script for Linux to update F256Jr BASIC & Kernel
#
python fnxmgr.zip --port /dev/ttyUSB0 --flash-bulk bulk.csv
python fnxmgr.zip --port /dev/ttyUSB0 --boot flash 
