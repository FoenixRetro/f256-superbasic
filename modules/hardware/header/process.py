# ************************************************************************************************
# ************************************************************************************************
#
#		Name:		process.py
#		Purpose:	Process boot screen files
#		Created:	14th December 2022
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# ************************************************************************************************
# ************************************************************************************************
#
#		$FF <byte> <count> 	repeat
#		$FF 00 				end
#
def rleCompress(b):
	r = []
	while len(b) != 0:
		assert b[0] != compress,"Compress {0} not allowed".format(b[0])
		#
		if len(b) > 3 and b[0] == b[1] and b[1] == b[2]:
			c = 0
			while c < 250 and c+1 < len(b) and b[0] == b[c+1]:
				c+=1
			r.append(compress)
			r.append(b[0])
			r.append(c)
			b = b[c:]
		else:
			r.append(b[0])
			b = b[1:]
	r.append(compress)
	r.append(0)			
	return r

import os,sys

height = 14
compress = 255 

h = open("headerdata.asm","w")
h.write(";\n;\tAutomatically generated.\n;\n")
h.write("\t.section code\n\n")

h.write("Header_Height = {0}\n\n".format(height))
h.write("Header_RLE = {0}\n\n".format(compress))

for parts in ["attrs","chars"]:
	h.write("Header_{0}:\n".format(parts))
	src = [x for x in open(parts+".bin","rb").read(-1)][:height * 80]
	src = rleCompress(src)
	h.write("\t.byte\t{0}\n\n".format(",".join([str(x) for x in src])))

h.write("Header_Palette:\n")	
for x in open("palette.hex").readlines():
	x = x.strip()
	if x != "":
		h.write("\t.dword ${0}\n".format(x))

h.write("\t.send code\n\n")
h.close()

h = open("font.dat","w")
h.write(";\n;\tAutomatically generated.\n;\n")
h.write("\t.section code\n\n")
h.write("FontBinary:\n")
font = open("font.json").read(-1).replace(",","").replace("[","").replace("]","").replace("{","").replace("}","").replace(":","").replace('"',"").split("data")[1:]
fontBin = [ 0 ] * 256 * 8
for i in range(0,256):
	fontData = font[i]
	for b in range(0,8):
		for r in range(0,8):
			if fontData[b*8+r] == '1':
				fontBin[i*8+b] |= (0x80 >> r)

h.write("\t.byte\t{0}\n".format(",".join(["${0:02x}".format(c) for c in fontBin])))
h.write("\t.send code\n\n")
h.close()