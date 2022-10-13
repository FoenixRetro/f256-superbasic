# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		makegfx.py
#		Purpose :	Sample graphic builder
#		Date :		9th October 2022
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

from PIL import Image
import os,sys,re

class SpriteCollection(object):
	def __init__(self):
		self.index = []															# (pairs of offset, scale (0-3)), up to 256
		self.data = []
		self.offset = 0x200	 													# space for 256 word pairs.

	def importGraphic(self,name):
		gr = Image.open(name)
		assert gr.size[0] == gr.size[1],"Not square"
		size = gr.size[0]
		assert size == 8 or size == 16 or size == 24 or size == 32
		gr = gr.convert("RGBA")
		self.index.append([self.offset,size])
		for y in range(0,size):
			for x in range(0,size):
				pixel = gr.getpixel((x,y))
				colour = 0 
				if pixel[0] > 16:
					colour = ((pixel[0] >> 5) << 5)
					colour += ((pixel[1] >> 5) << 2)
					colour += ((pixel[2] >> 6) << 0)
					if colour == 0:
						colour = 0x20
				#print("{0} ${1:x}".format(pixel,colour))
				self.data.append(colour)
				self.offset += 1
	#
	#		Format:
	#			256 low bytes
	#			256 high bytes
	#
	#		00aaaaaa aallss
	#
	# 		00aaaaaaa is the address >> 6 (masked, >> 2)
	#		ll is the LUT to use 0-3
	# 		ss is the size (8/16/24/32)
	#
	def export(self):
		self.binIndex = [ 0 ] * 512
		slot = 0
		for e in self.index:
			a = ((e[1] >> 3) - 1) + ((e[0] & 0xFFFC0) >> 2)
			self.binIndex[slot] = a & 0xFF
			self.binIndex[slot + 256] = a >> 8
			slot += 1
		h = open("graphics.bin","wb")
		h.write(bytes(self.binIndex))
		h.write(bytes(self.data))
		h.close()

	def showIndex(self):
		for i in range(0,256):
			e = self.binIndex[i] + self.binIndex[i+256] * 256
			if e != 0:
				print("Address ${0:04x} Size {1:2} LUT {2}".format((e & 0xFFF0) << 2,(e & 3)*8+8,(e >> 2) & 3))

sc = SpriteCollection()
sc.importGraphic("sprite8.png")		
sc.importGraphic("sprite16.png")		
sc.importGraphic("sprite32.png")		
sc.export()
sc.showIndex()

