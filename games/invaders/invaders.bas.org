'
'		Simple Space Invaders Game
'
cls:bitmap on:sprites on:bitmap clear 0
defineVariables()
resetlevel()
repeat
	if event(moveInvadersEvent,invaderSpeed) then moveInvaders()
until false
end:tax
'
'		Move invaders across/down
'
proc moveInvaders()
	xInvaders = xInvaders + xiInvaders
	if xInvaders < leftEdge 
		xInvaders = leftEdge
		yInvaders = yInvaders + abs(xiInvaders)
		xiInvaders = -xiInvaders
	endif
	if xInvaders > rightEdge
		xInvaders = rightEdge
		yInvaders = yInvaders + abs(xiInvaders)
		xiInvaders = -xiInvaders
	endif
	drawInvaders(xInvaders,yInvaders)
endproc
'
'		Draw invaders sprites at correct position
'
proc drawInvaders(xPos,yPos)
	local x,y,s
	altGraphic = 1 - altGraphic
	for x = 0 to 7
		s = x * 5
		if colHeight(x) > 0
			for y = 0 to colHeight(x)-1
				sprite s image graphic(y)+altGraphic to xPos+x*24,yPos+y*24
				s = s + 1
			next
		endif
	next
endproc	
'
'		Calculate invader movement rate
'
proc calculateSpeed()
	invaderSpeed = 4+invTotal*2
endproc
'
'		Set up variables
'
proc defineVariables()
	local i
	dim colheight(7),graphic(4)
	for i = 0 to 4:graphic(i) = i % 3 * 2:next:altGraphic = 0
endproc
'
'		Set up new level
'
proc resetlevel()
	local i
	for i = 0 to 7:colHeight(i) = 5:next
	invTotal = 5*8
	leftEdge = 8:rightEdge = 320-8-7*24
	xInvaders = 160-7*12:yInvaders = 26:xiInvaders = 8
	drawInvaders(xInvaders,yInvaders)
	calculateSpeed()
endproc