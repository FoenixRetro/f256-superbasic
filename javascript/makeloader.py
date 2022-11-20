# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		makeloader.py
#		Purpose :	Creating loading file 
#		Date :		19th November 2022
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys,math,datetime,re

defined = {}
for s in [x.lower() for x in sys.argv[1:]]:
	if s != "-d":
		m = re.match("^(.*?)_address=0x(.*)$",s)
		defined[m.group(1).lower()] = int(m.group(2),16)
		h = open("loaders.h","w")

for root,dirs,files in os.walk("loading"):
	for f in files:
		file = root+os.sep+f 
		parts = f.split(".")
		binary = [x for x in open(file,"rb").read(-1)]
		h.write("static const BYTE8 {0}_image[] = {{ {1} }};\n".format(parts[0],",".join([str(x) for x in binary])))
		if parts[1].lower() in defined:
			a = defined[parts[1].lower()]
		else:
			a = int(parts[1],16)
		h.write("CPUCopyROM(0x{1:x},{2},{0}_image);\n".format(parts[0],a,len(binary)))
h.close()