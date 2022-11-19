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

import os,sys,math,datetime

h = open("loaders.h","w")

for root,dirs,files in os.walk("loading"):
	for f in files:
		file = root+os.sep+f 
		parts = f.split(".")
		binary = [x for x in open(file,"rb").read(-1)]
		h.write("static const BYTE8 {0}_image[] = {{ {1} }};\n".format(parts[0],",".join([str(x) for x in binary])))
		h.write("CPUCopyROM({1},{2},{0}_image);\n".format(parts[0],int(parts[1],16),len(binary)))
h.close()