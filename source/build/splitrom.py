# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		splitrom.py
#		Purpose :	Create working parts of ROM.
#		Date :		5th December 2022
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys,re

code = [x for x in open("basic.rom","rb").read(-1)]									# load ROM in
pages = 2 if len(code) <= 16384 else 3  											# how many pages
while len(code) < 8192*pages: 														# pad out
	code.append(0xFF)

for p in range(1,pages+1):															# output binary slices FROM 2.
	chunk = code[(p-1)*8192:(p-0)*8192] 											# binary chunk
	h = open("sb{0:02x}.bin".format(p),"wb") 											# write out.
	h.write(bytes(chunk))
	h.close()

h = open("bulk.csv","w")  															# create CSV file
h.write("3f,lockout.bin\n")
rompages = [x for x in range(1,pages+1)]  					 						# pages to send.
for p in rompages:
 	h.write("{0:02x},sb{0:02x}.bin\n".format(p))	
h.write("{0:02x},dos.bin\n".format(pages+1)) 	
for p in [0x3C,0x3D,0x3E,0x3F]:
	h.write("{0:02x},{0:02x}.bin\n".format(p))	
h.close()