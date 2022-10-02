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

def getData(md,a,t):
	return md.decode(md.readLong(a),md.read(a+4),t) #+ (" @${0:02x}".format(a))
	#return ("{0:x}".format(a)) 

def extractArray(md,v,x1):
	a1 = md.read(v+5)
	a2 = md.read(v+6)
	p = md.readWord(v+3)
	size = (2 if (md.read(v+2) & 0x10) != 0 else 5)
	array = "\t\t\t\t[" 
	array = array+",".join([getData(md,p + (i+x1*(a1+1)) * size,md.read(v+2)) for i in range(0,a1+1)])
	return array+"]"
	

if __name__ == "__main__":
	ls = LabelStore()
	md = MemoryDump()
	print("Identifier Memory:")
	print()
	
	vs = ls.get("VariableSpace")
	while md.read(vs) != 0:
		name = ""
		isArray = False
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
			isArray = True
		else:
			v = md.decode(md.readLong(vs+3),md.read(vs+7),t)
		if (t & 0x18) == 0x18:
			v = "(procedure)"
			name += ")"
		print("\t@${0:04x} {1:16} [${2:02x}] = {3}".format(vs,name,md.read(vs+2),v))
		if isArray:
			if md.read(vs+6) == 0:
				print("{0}".format(extractArray(md,vs,0)))
			else:
				print("\t\t\t\t[")
				for i in range(0,md.read(vs+6)+1):
					print("\t{0}".format(extractArray(md,vs,i)))
				print("\t\t\t\t]")
		vs += md.read(vs)


