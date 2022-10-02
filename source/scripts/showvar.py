# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		showvar.py
#		Purpose :	Show the variable area.
#		Date :		2nd October 2022
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys,re
from showstack import *

if __name__ == "__main__":
	ls = LabelStore()
	md = MemoryDump()
	print("Identifier Memory:")
	print()
	
	vs = ls.get("VariableSpace")
	while md.read(vs) != 0:
		name = ""
		p = vs + 8
		done = False
		while not done:
			name += chr(md.read(p) & 0x7F).lower()
			done = md.read(p) >= 0x80
			p += 1
		t = md.read(vs+2)
		if (t & 4) != 0:
			v = "Array @ ${0:04x} ".format(md.readWord(vs+3))
			name += str(md.read(vs+5))
			a2 = md.read(vs+6)
			if a2 != 0:
				name += ",{0}".format(a2)
			name += ")"
		else:
			v = md.decode(md.readLong(vs+3),md.read(vs+7),t)
		if (t & 0x18) == 0x18:
			v = "(procedure)"
			name += ")"
		print("\t@${0:04x} {1:16} [${2:02x}] = {3}".format(vs,name,md.read(vs+2),v))
		vs += md.read(vs)


