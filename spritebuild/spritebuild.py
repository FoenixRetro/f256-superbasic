# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		spritebuild.py
#		Purpose :	Composite Sprite Builder Application
#		Date :		13th October 2022
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

from PIL import Image
import os,sys,re

# *******************************************************************************************
#
#									Sprite Object Class
#
# *******************************************************************************************

class SpriteImage(object):
	def __init__(self,imageFile):
		self.image = Image.open(imageFile).convert("RGBA") 										# get image and convert to RGBA format.
		self.background = self.image.getpixel((0,0))  											# top left pixel is background colour
		while self.clipImage():																	# reduce to minimum size.
			pass
		self.calculateSizeAndOffset()															# figure out size of finished sprite and offset.
	#
	#		Work out size and offset of sprite
	#
	def calculateSizeAndOffset(self):
		self.spriteSize = int((max(self.image.size[0],self.image.size[1])+7)/8)*8  				# 8/16/24/32 pixel size
		assert self.spriteSize <= 32
		self.xOffset = int(self.spriteSize/2 - self.image.size[0] / 2) 							# offset in graphic to make square centred sprite
		self.yOffset = int(self.spriteSize/2 - self.image.size[1] / 2)
		print(self.spriteSize,self.xOffset,self.yOffset,self.image.size)
	#
	#		Translate a coordinate pair
	#
	def translate(self,cp):
		return cp 
	#
	#		Read a pixel value. Return [R,G,B] or None
	#
	def read(self,c):
		c = self.translate(c) 																	# convert so we can flip etc.
		x = c[0] - self.xOffset  																# index in pixels
		y = c[1] - self.yOffset
		if x < 0 or y < 0 or x >= self.image.size[0] or y >= self.image.size[1]:				# off sprite area ?
			return None 
		if self.isBackground(x,y): 																# background colour
			return None 
		return self.image.getpixel((x,y))[:3] 													# clip out alpha
	#
	#		Reduce image to its minimum size
	#
	def clipImage(self):
		w = self.image.size[0] 																	# get size handy
		h = self.image.size[1]
		if self.canHorizontalClip(0):															# clip all 4 dimensions in turn.
			self.image = self.image.crop((0,1,w,h))
			return True 
		if self.canHorizontalClip(h-1):
			self.image = self.image.crop((0,0,w,h-1))
			return True 
		if self.canVerticalClip(0):
			self.image = self.image.crop((1,0,w,h))
			return True 
		if self.canVerticalClip(w-1):
			self.image = self.image.crop((0,0,w-1,h))
			return True 
		return False 
	#
	#		Can we horizontally clip y
	#
	def canHorizontalClip(self,y):
		for x in range(0,self.image.size[0]):
			if not self.isBackground(x,y):
				return False
		return True
	#
	#		Can we vertically clip y ?
	#
	def canVerticalClip(self,x):
		for y in range(0,self.image.size[1]):
			if not self.isBackground(x,y):
				return False
		return True
	#
	#		Is pixel (x,y) background ?
	#
	def isBackground(self,x,y):
		return self.image.getpixel((x,y)) == self.background 

	# def importGraphic(self,name):
	# 	gr = Image.open(name)
	# 	assert gr.size[0] == gr.size[1],"Not square"
	# 	size = gr.size[0]
	# 	assert size == 8 or size == 16 or size == 24 or size == 32
	# 	gr = gr.convert("RGBA")
	# 	self.index.append([self.offset,size])
	# 	for y in range(0,size):
	# 		for x in range(0,size):
	# 			pixel = gr.getpixel((x,y))
	# 			colour = 0 
	# 			if pixel[0] > 16:
	# 				colour = ((pixel[0] >> 5) << 5)
	# 				colour += ((pixel[1] >> 5) << 2)
	# 				colour += ((pixel[2] >> 6) << 0)
	# 				if colour == 0:
	# 					colour = 0x20
	# 			#print("{0} ${1:x}".format(pixel,colour))
	# 			self.data.append(colour)
	# 			self.offset += 1
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
	# def export(self):
	# 	self.binIndex = [ 0 ] * 512
	# 	slot = 0
	# 	for e in self.index:
	# 		a = ((e[1] >> 3) - 1) + ((e[0] & 0xFFFC0) >> 2)
	# 		self.binIndex[slot] = a & 0xFF
	# 		self.binIndex[slot + 256] = a >> 8
	# 		slot += 1
	# 	h = open("graphics.bin","wb")
	# 	h.write(bytes(self.binIndex))
	# 	h.write(bytes(self.data))
	# 	h.close()

	# def showIndex(self):
	# 	for i in range(0,256):
	# 		e = self.binIndex[i] + self.binIndex[i+256] * 256
	# 		if e != 0:
	# 			print("Address ${0:04x} Size {1:2} LUT {2}".format((e & 0xFFF0) << 2,(e & 3)*8+8,(e >> 2) & 3))


s = SpriteImage("sprite32.png")
for y in range(0,s.spriteSize):
	s1 = ""
	for x in range(0,s.spriteSize):
		s1 += "." if s.read((x,y)) is None else "*"
	print(s1)
