# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		showstring.py
#		Purpose :	Show the string area.
#		Date :		23rd September 2022
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys,re
from showstack import *

if __name__ == "__main__":
	ls = LabelStore()
	md = MemoryDump()
	print("String Memory:")
	print()
	
	sm = ls.get("StringMemory")
	stringStart = md.readWord(sm)
	p = stringStart
	usedSize = 0
	unusedSize = 0
	while md.read(p) != 0:
		size = md.read(p)+3
		if (md.read(p+1) & 0x80) != 0:
			unusedSize += size
			val = "(DELETED)"
		else:
			usedSize += size
			val = '"'+md.readString(p+2)+'"'
		print("\t@ ${0:04x} Max Size:{1} : {2}".format(p,md.read(p),val))
		p = p + size

	print()
	print("String start ${0:04x}".format(stringStart))
	print("String end ${0:04x}".format(p))	
	
	if unusedSize+usedSize > 0:
		print()
		print("Used space    : {0} bytes".format(usedSize))		
		print("Unused space  : {0} bytes".format(unusedSize))
		pcUsed = int(usedSize/(unusedSize+usedSize)*100+0.5)
		print("Percent usage : {0} %".format(pcUsed))