# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		ripgfx.py
#		Purpose :	Graphics extractor
#		Date :		23rd October 2022
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

from PIL import Image
import os,sys,re

# *******************************************************************************************
#
#								Rippable graphic class
#
# *******************************************************************************************

class RippableGraphic(object):
	def __init__(self,imageFile = "source.png"):
		self.image = Image.open(imageFile).convert("RGBA") 										# get image and convert to RGBA format.
		self.background = self.image.getpixel((0,0)) 											# backround colour.
		self.width = self.image.size[0]
		self.height = self.image.size[1]
	#
	def ripGraphic(self,x,y):
		self.left = x - 6 																		# initial frame.
		self.right = x + 6
		self.top = y - 6
		self.bottom = y + 6

		while not self.isFramed(): 																# Expand frame until wrapped.
			if not self.hClear(self.top):
				self.top -= 1
			if not self.hClear(self.bottom):
				self.bottom += 1
			if not self.vClear(self.left):
				self.left -= 1
			if not self.vClear(self.right):
				self.right += 1

		return self.image.crop((self.left,self.top,self.right+1,self.bottom+1))
	#
	def isFramed(self):
		return self.hClear(self.top) and self.hClear(self.bottom) and self.vClear(self.left) and self.vClear(self.right)
	#
	def vClear(self,x):
		for y in range(self.top,self.bottom	+1):
			if not self.isBackground((x,y)):
				return False 
		return True 
	#
	def hClear(self,y):
		for x in range(self.left,self.right+1):
			if not self.isBackground((x,y)):
				return False 
		return True 
	#
	def isBackground(self,pt):
		if pt[0] < 0 or pt[1] < 0 or pt[0] >= self.width or pt[1] >= self.height:
			return True
		return self.image.getpixel(pt) == self.background

rg = RippableGraphic()
for part in sys.argv[1:]:
	m = re.match("^(.*?)\\:(\\d+)\\,(\\d+)$",part)
	assert m is not None,"Bad line "+part
	#print("Extracting {0}.png at ({1},{2})".format(m.group(1).lower(),m.group(2),m.group(3)))
	gx = rg.ripGraphic(int(m.group(2)),int(m.group(3)))
	gx.save(m.group(1).lower()+".png")
