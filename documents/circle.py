# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		circle.py
#		Purpose :	Bresenham circle algorithm (we will stretch it)
#		Date :		8th October 2022
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

from PIL import Image,ImageDraw
import math

def plot(draw,x,y):
	draw.point((x+160,y+120),fill = (0,255,0))
	draw.point((-x+160,y+120),fill = (0,255,0))

screen = Image.new("RGB",(320,240))
draw = ImageDraw.Draw(screen)

r = 45
x = 0
y = r 
d = 3 - 2 * r 

def plot2(draw,x,y):
	plot(draw,x*2/2,y)			# scale here to make ellipse
	plot(draw,x*2/2,-y)

def plot1(draw,x,y):
	plot2(draw,x,y)
	plot2(draw,y,x)

while x <= y:
	plot1(draw,x,y)
	if d < 0:
		x += 1
		d = d + 4 * x + 6
	else:
		x += 1
		y -= 1
		d = d + 4 * (x-y) + 20



screen.show()