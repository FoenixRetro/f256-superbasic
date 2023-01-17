'
'		Simplified Space Invaders Game
'
cls:bitmap on:sprites on:bitmap clear 0
skillLevel = 0:score = 0:lives = 3
defineVariables():text "SCORE<1>" dim 1 colour $FF to 136,1
resetlevel():resetPlayer():displayScore()
repeat
	if event(moveInvadersEvent,invaderSpeed) then moveInvaders()
	if event(movePlayerEvent,3) then movePlayer():if yBullet >= 0 then moveBullet()
	if event(moveMissileEvent,2) then moveMissile()
until lives = 0
end
'
'		Display the score
'
proc displayScore()
	local a$:a$ = right$("00000"+str$(score),6)
	text a$ dim 1 colour $FF,4 to 144,10
	text "LIVES "+str$(lives) colour $1C,4 to 10,230
endproc
'
'		Move the player
'
proc movePlayer()
	xPlayer = min(304,max(16,xPlayer+joyx(0)<<2))
	sprite 63 image 6 to xPlayer,220
	if joyb(0) & yBullet < 0 then xBullet = xPlayer:yBullet = 200
endproc
'
'		Flash player for 2 seconds
'
proc flashPlayer()
	local tEnd:tEnd = timer()+70*2
	repeat
		if timer() & 8
			sprite 63 image 6
		else
			sprite 63 off 
		endif
	until timer() > tEnd
endproc
'
'		Move the player bullet
'
proc moveBullet()
	local xo
	yBullet = yBullet - 10 
	if yBullet < 0
		sprite 62 off
	else
		sprite 62 image 11 to xBullet,yBullet
		xo = xBullet - xInvaders + 8 
		if xo >= 0 & xo < 8*24 & xo % 24 < 16 then checkHit(xo \ 24)
	endif
endproc
'
'		Move current missile
'
proc moveMissile()
	local r
	currentMissile = currentMissile + 1:if currentMissile > missileCount then currentMissile = 1 
	if yMissile(currentMissile) < 0 
		r = random(8)
		if colHeight(r) > 0 & (random()& 3) = 0
			xMissile(currentMissile) = xInvaders + 24 * r 
			yMissile(currentMissile) = yInvaders + 24 * colHeight(r) - 24
		endif 
	else
		yMissile(currentMissile) = yMissile(currentMissile) + 8
		if yMissile(currentMissile) > 220 
			if abs(xMissile(currentMissile)-xPlayer) < 12
				lives = lives - 1:displayScore()
				flashPlayer()
				if lives > 0 then resetLevel()
			endif
			sprite currentMissile+50 off
			yMissile(currentMissile) = -1
		else
			sprite currentMissile+50 image 9 to xMissile(currentMissile),yMissile(currentMissile)
		endif
	endif
endproc
'
'		Check if column hit
'
proc checkHit(col)
	yo = abs(yInvaders + (colHeight(col)-1)*24 - yBullet)
	if yo < 12 & colHeight(col) <> 0
		sprite col*5+colHeight(col)-1 off
		sprite 61 image 7 to col*24+xInvaders,(colHeight(col)-1)*24+yInvaders
		yBullet = -1:sprite 62 off 
		score = score+(6-colHeight(col))*10:displayScore()
		colHeight(col) = colHeight(col)-1
		invTotal = invTotal - 1 
		if invTotal > 0 & colHeight(col) = 0 then recalculateEdge()
		if invTotal = 0
			skillLevel = (skillLevel+1) % 10
			resetlevel()
		endif
		recalculateSpeed()
	endif
endproc
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
			sprite 61 off
		endif
	next
endproc	
'
'		Set up variables
'
proc defineVariables()
	local i:missileCount = 4
	dim colheight(7),graphic(4),xMissile(missileCount),yMissile(missileCount)
	for i = 0 to 4:graphic(i) = i % 3 * 2:next:altGraphic = 0
endproc
'
'		Reset the player
'
proc resetPlayer()
	xPlayer = 160:xBullet = 0:yBullet = -1
	movePlayerEvent = 0
endproc
'
'		Set up new level
'
proc resetlevel()
	local i
	for i = 0 to 7:colHeight(i) = 5:next
	for i = 1 to missileCount:yMissile(i) = -1:sprite i+50 off:next
	invTotal = 5*8
	xInvaders = 160-7*12:yInvaders = 26+skillLevel*8:xiInvaders = 8
	drawInvaders(xInvaders,yInvaders)
	invaderSpeed = 4+invTotal*2
	moveInvadersEvent = 0:currentMissile = 0
	recalculateEdge():recalculateSpeed()
endproc
'
'		Recalaulate speed
'
proc recalculateSpeed()
	invaderSpeed = 2+invTotal*3\2
endproc

'
'		Recalculate left/right edge
'
proc recalculateEdge()
	local i
	leftEdge = 8
	i = 0:while colHeight(i) = 0:i = i + 1:leftEdge = leftEdge-24:wend
	rightEdge = 320-8-7*24
	i = 7:while colHeight(i) = 0:i = i - 1:rightEdge = rightEdge+24:wend
endproc