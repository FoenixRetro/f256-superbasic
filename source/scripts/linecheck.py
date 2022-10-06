# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		linecheck.py
#		Purpose :	Check line editing works
#		Date :		6th October 2022
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys,re
from showstack import *

if __name__ == "__main__":
	ls = LabelStore()
	md = MemoryDump()

	codeAt = ls.get("BasicStart")
	count = 0

	requiredCode = [x for x in open("common/generated/linetest.bin","rb").read(-1)]
	for i in range(0,len(requiredCode)):
		mdCode = md.read(i+codeAt)
		if requiredCode[i] != mdCode:
			print("Test:${0:02x} Actual:${0:02x}".format(requiredCode[i],mdCode))
			count += 1

if count == 0:
	print("Edited correctly.")
sys.exit(0 if count == 0 else 1)