# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		basconv.py
#		Purpose :	BASIC program converter - numbers lines and processes comments
#		Date :		19th October 2022
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import re,os,sys 

line = 1000
for f in sys.argv[1:]:
	for l in [x.strip() for x in open(f).readlines() if x.strip() != ""]:
		n = l.find("'")
		if n >= 0:
			comment = l[n+1:].strip()
			l = l[:n+1]+("" if comment == "" else ' "'+comment+'"')			
		print("{0} {1}".format(line,l))
		line += 1
print("{0}{0}{0}{0}\n".format(chr(255)))