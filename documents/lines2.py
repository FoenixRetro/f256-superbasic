# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		lines.py
#		Purpose :	Quick 320x240 max line drawing algorithm
# 					Approximate 1-2 pixel error possible
#					Ideas from Bresenham basic concept and Elite line drawer w/o division
#		Date :		26th August 2022
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

from PIL import Image,ImageDraw
import math

# *******************************************************************************************
#
#				Sort of Bresenham running between two coordinates, top to bottom
#
#					Slightly inaccurate but does byte maths at range 320x240
#
# *******************************************************************************************

class LineScanner:
	#
	#		Set up
	#
	def __init__(self,x0,y0,x1,y1,draw = None):
		if y1 >= y0:											# sort them so y1 > y0
			self.x0 = x0
			self.y0 = y0
			self.x1 = x1
			self.y1 = y1
		else:
			self.x0 = x1
			self.y0 = y1
			self.x1 = x0
			self.y1 = y0
		#
		if draw is not None: 									# accuracy test.
			draw.line((self.x0,self.y0,self.x1,self.y1),fill = (255,0,0))
		#
		diffy = (self.y1-self.y0) >> 1 							# inaccuracy here but no 16 bit maths.
		diffx = abs(self.x1 - self.x0) >> 1 					# calculate |dx/2| |dy/2|
		#
		self.xDir = (1 if self.x0 < self.x1 else -1) 			# which way does X go ?
		#
		self.isDiffyLarger = diffy > diffx 						# which slope ?
		if self.isDiffyLarger: 									# work out addition vs limit.
			self.adjust = diffx
			self.total = diffy
		else:
			self.adjust = diffy
			self.total = diffx
		self.pos = self.total / 2 								# current position in line algorithm
	#
	def isComplete(self):
		return (self.y1 == self.y0) if self.isDiffyLarger else (self.x1 == self.x0)
	#
	def advance(self):
		if not self.isComplete():								# finished the line ?
			self.pos += self.adjust 							# step
			addSelect = False
			if self.pos >= self.total:							# time to wrap back.
				self.pos -= self.total 
				addSelect = True 
			if self.isDiffyLarger:
				self.y0 += 1
				if addSelect:
					self.x0 += self.xDir 
			else:
				if addSelect:
					self.y0 += 1
				self.x0 += self.xDir 
	#
	def draw(self,draw):
		while not self.isComplete():
			draw.point((self.x0,self.y0),fill = (0,255,0))
			self.advance()
		draw.point((self.x0,self.y0),fill = (0,255,0))

screen = Image.new("RGB",(320,240))
draw = ImageDraw.Draw(screen)
LineScanner(10,10,310,10).draw(draw)
LineScanner(12,12,12,190).draw(draw)
cx = 155
cy = 115
for d in range(0,360,3):
	r = math.radians(d)
	LineScanner(cx,cy,int(cx+150*math.cos(r)),int(cy+110*math.sin(r)),draw).draw(draw)
screen.show()