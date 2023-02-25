# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		spritebuild.py
#		Purpose :	Composite Sprite Builder Application (Sprite Format II)
#		Date :		Revised 25th February 2023 for Sprite format 2.
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
		self.baseName = os.path.splitext(imageFile.split(os.sep)[-1])[0].lower() 				# get base name
		self.isVflip = False
		self.isHflip = False
		self.rotateAngle = 0
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
		#print(self.spriteSize,self.xOffset,self.yOffset,self.image.size)
	#
	#		Get name of sprite
	#
	def getName(self):
		if not self.isVflip and not self.isHflip and self.rotateAngle == 0:
			return self.baseName
		return self.baseName + "_" + ("v" if self.isVflip else "") + ("h" if self.isHflip else "") + (str(self.rotateAngle) if self.rotateAngle != 0 else "")
	#
	#		Get sprite data
	#
	def getData(self):
		data = []
		for y in range(0,self.spriteSize):
			for x in range(0,self.spriteSize):
				d = 0
				rgb = self.read((x,y))
				if rgb is not None:
					d = self.rgbConvert(rgb)
				data.append(d)
		return(data)
	#
	#		Get sprite size
	#
	def getSize(self):
		return self.spriteSize
	#
	#		Get byte requirement
	#
	def getDataSize(self):
		return self.spriteSize * self.spriteSize
	#
	#		Translate a coordinate pair
	#
	def translate(self,cp):
		if self.isHflip:
			cp = [self.spriteSize-1-cp[0],cp[1]]
		if self.isVflip:
			cp = [cp[0],self.spriteSize-1-cp[1]]
		if self.rotateAngle != 0:
			for i in range(0,self.rotateAngle // 90):
				cp = [cp[1],self.spriteSize-1-cp[0]]
		return cp 
	#
	#		Set translations
	#
	def vFlip(self):
		self.isVflip = True
		return self 
	#
	def hFlip(self):
		self.isHflip = True
		return self 
	#
	def rotate(self,angle):
		assert angle >= 0 and angle < 360 and angle % 90 == 0,"Rotation only through 90 degree steps at present"
		self.rotateAngle = angle 
		return self 
	#
	#		Convert [r,g,b] to pixel data
	#
	def rgbConvert(self,pixel):
		colour = ((pixel[0] >> 5) << 5)
		colour += ((pixel[1] >> 5) << 2)
		colour += ((pixel[2] >> 6) << 0)
		return colour
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
	#
	#		Display a rough text version of the sprite.
	#
	def printSprite(self):
		for y in range(0,self.spriteSize):
			s1 = ""
			for x in range(0,self.spriteSize):
				s1 += "." if s.read((x,y)) is None else "*"
			print(s1)

# *******************************************************************************************
#
#								Sprite Collection class
#
# *******************************************************************************************

class SpriteCollection(object):
	def __init__(self):
		self.spriteList = []
	#
	#		Add a new sprite
	#
	def add(self,sprite):
		self.spriteList.append(sprite)
	#
	#		Output the sprite graphics object. 
	#
	#		+00 	$11 Header format
	#		+01 	Sprite 0 (size 0-3) or $80 for end of sprite data, 00 is 8x8 11 is 32x32, backwards from F256 but more logical.
	#		+02 	LUT of sprite 0.
	#		+03 	First byte of sprite 0 ....
	#
	def outputSprite(self,file = "graphics.bin"):
			h = open(file,"wb")
			h.write(bytes([0x11]))							

			for i in range(0,len(self.spriteList)):										# For each sprite
				s = self.spriteList[i] 							 						
				size = (s.getSize() >> 3)-1 											# Size 0-3.
				h.write(bytes([size,0]))												# Output size and LUT 0
				h.write(bytes(s.getData()))												# and the data

			h.write(bytes([0x80])) 														# end of list marker.
			h.close()

sc = SpriteCollection()

for f in sys.argv[1:]:	
	for s in [x.strip() for x in open(f).readlines() if x.strip() != "" and not x.startswith("#")]:
		m = re.match("^(.*?)\\s*([vh\\d]+)?\\s*$",s)
		assert m is not None,"Bad sprite line "+s+" in "+f
		s = SpriteImage(m.group(1))
		if m.group(2) is not None:
			if m.group(2) == "h":
				s.hFlip()
			elif m.group(2) == "v":
				s.vFlip()
			else:
				s.rotate(int(m.group(2)))
		sc.add(s)
sc.outputSprite()
