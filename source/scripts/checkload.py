# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		checkload.py
#		Purpose :	Check backloaded file has terminators
#		Date :		2nd October 2022
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys

h = open("storage/load.dat","rb")
code = [x for x in h.read(-1)]
h.close()

if code[-1] < 128:
	code += [ 255,255,255,255 ]
	h = open("storage/load.dat","wb")
	h.write(bytes(code))
	h.close()
