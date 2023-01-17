'
'	Solarfox in SuperBasic
'
cls:sprites on:bitmap on:bitmap clear 0
initialise()
newLevel(level)
repeat
	repeat
		if event(moveEnemies,4) 
			updateEnemies()
			n = random(mcount):if remain(n) = 0 then launch(n)		
		endif
		if event(moveMissiles,6) then moveMissiles()
		if event(movePlayer,3) then movePlayer()
	until collectZeroCount = 0 | playerHit 
	if playerHit
		lives = lives-1:updateLives():resetmissiles()
		playerHit = False:flashplayer()
	else
		level = level+1:newLevel(level)
		score = score + 1000*level:updateScore()
	endif
until lives = 0
bitmap clear 0:sprites off
end
'
'	Set up a new game
'
proc initialise()
	xSize = 14:ySize = 11:mCount = 8
	xOrg = 160-xSize*8:yOrg = 140-ySize*8
	dim x(7),y(7),xi(7),yi(7),remain(7)	
	dim collect(xSize-1,ySize-1)
	score = 0:lives = 3:level = 0
endproc
'
'	Move the player
'
proc movePlayer()
	local x,y
	x = joyx(0):y = joyy(0)
	if x <> 0 & (yPlayer & 15) = 0 then xiPlayer = x * 4:yiPlayer = 0:iPlayer = 1-x
	if y <> 0 & (xPlayer & 15) = 0 then yiPlayer = y * 4:xiPlayer = 0:iPlayer = 2-y
	if (xPlayer | yPlayer & 15) = 0 then checkCollect(xPlayer >> 4,yPlayer >> 4)
	xPlayer = min((xSize-1) << 4,max(0,xPlayer + xiPlayer))
	yPlayer = min((ySize-1) << 4,max(0,yPlayer + yiPlayer))
	sprite 50 image iPlayer to xOrg+xPlayer,yOrg+yPlayer
endproc
'
'	Flash the player
'
proc flashplayer()
	local t:t = timer() + 140
	while timer() < t 
		if timer() & 16:sprite 50 image iPlayer:else sprite 50 off:endif
	wend
endproc
'
'	Fire a new missile from slot 'n'
'
proc launch(n)
	if random() & 1:horizontalLaunch(n):else:verticalLaunch(n):endif
endproc
'
'	Launch a missile from top or bottom
'
proc verticalLaunch(n)
	x(n) = xOrg-16:y(n) = yOrg+((yFire+8) & $F0):xi(n) = 4:yi(n) = 0	
	remain(n) = abs((xSize*16+16) \ xi(n))
	if random() & 1 then x(n) = x(n) + remain(n)*xi(n):xi(n) = -xi(n)
	sprite n image 11 to x(n),y(n)
endproc
'
'	Launch a missile from left or right
'
proc horizontalLaunch(n)
	y(n) = yOrg-16:x(n) = xOrg+((xFire+8) & $F0):yi(n) = 4:xi(n) = 0	
	remain(n) = abs((ySize*16+16) \ yi(n))
	if random() & 1 then y(n) = y(n) + remain(n)*yi(n):yi(n) = -yi(n)
	sprite n image 12 to x(n),y(n)
endproc
'
'	Move all missiles
'
proc moveMissiles()
	local i
	for i = 0 to mCount-1
		if remain(i) > 0
			x(i) = x(i)+xi(i):y(i) = y(i)+yi(i)
			if hit(i,50) > 0 then if hit(i,50) < 10 then playerHit = True
			remain(i) = remain(i)-1
			if remain(i) > 0:sprite i to x(i),y(i):else:sprite i off:endif
		endif
	next
endproc
'
'	Start a new level
'
proc newLevel(n)
	local x,y,c$
	bitmap clear 0
	drawBackground():resetmissiles():updateEnemies()
	xPlayer = xSize\2*16:yPlayer = ySize\2*16:iPlayer = 0:xiPlayer = 0:yiPlayer = 0
	sprite 50 image iPlayer to xOrg+xPlayer,yOrg+yPlayer:playerHit = False 
	for x = 0 to xSize-1:for y = 0 to ySize-1:collect(x,y) = 0:next:next
	collectZeroCount = 0
	getLevelData(level % 6):p = 1:if level >= 6 then p = 2
	for x = 0 to 6:for y = 0 to 4
		c$ = mid$(level$,x+y*8+1,1):if c$ = "X" then setqcollect(x,y,p)
	next:next:mCount = min(3+level\3,7)
endproc
'
'	Check collection
'
proc checkCollect(x,y)
	if collect(x,y) <> 0
		local n:n = collect(x,y)-1:collect(x,y) = n 
		renderCollect(x,y,n)
		if n = 0 then collectZeroCount = collectZeroCount - 1
		score = score + 25:updateScore()
	endif
endproc
'
'	Update score
'
proc updateScore()
	text right$("00000"+str$(score),6) dim 1 colour $1F,4 to 80-24,12
endproc
'
'	Update lives display
'
proc updateLives()
	rect solid colour 0 from 240,6 to 300,16
	if lives > 0
		for i = 1 to lives
			image 10 to 240+i*12,8
		next 
	endif 
endproc
'
'	Set the collection in all 4 quadrant
'
proc setqcollect(x,y,n)
	setcollect(x,y,n):setcollect(xSize-1-x,y,n):setcollect(x,ySize-1-y,n):setcollect(xSize-1-x,ySize-1-y,n)	
endproc
'
'	Set the collect for one cell (non-erase, creation *only*)
'
proc setcollect(x,y,n)
	if collect(x,y) = 0
		collectZeroCount = collectZeroCount + 1
		collect(x,y) = n
		renderCollect(x,y,n)
	endif	
endproc
'
'	Render a collection item 0,1,2. 0 Erases. These are drawn on the background not sprites.
'
proc renderCollect(x,y,n)
	if n > 0
		image 7+n dim 1 to x*16+xOrg-4+1,y*16+yOrg-4+1
	else
		local xc,yc:xc = x * 16+xOrg:yc = y * 16 + yOrg
		rect solid colour $0 from xc-6,yc-6 to xc+6,yc+6
		line colour $25 from xc-6,yc to xc+6,yc from xc,yc-6 to xc,yc+6
	endif
endproc
'
'	Reset all Missiles
'
proc resetmissiles()
	local i
	for i = 0 to 7:remain(i) = 0:sprite i off:next
endproc
'
'	Draw the screen background
'
proc drawBackground()
	local x,y:line colour $25
	for x = 0 to xSize-1:line xOrg+x*16,yOrg-8 by 0,ySize*16:next
	for y = 0 to ySize-1:line xOrg-8,yOrg+y*16 by xSize*16,0:next
	rect colour $E0 outline xOrg-24,yOrg-24 by xSize*16+32,ySize*16+32
	rect colour $FF outline xOrg-25,yOrg-25 by xSize*16+34,ySize*16+34
	updateScore():text "1 Up" colour $E0 to 64,2:updateLives()
endproc
'
'	Use the timer to set the positions of the shooting enemies
'
proc updateEnemies()
	local t:t = timer()
	xFire = abs((t % (xSize << 5))-(xSize << 4))
	sprite 10 image 5 to xOrg+xFire,yOrg-16
	sprite 11 image 7 to xOrg+xFire,yOrg+ySize<<4
	yFire = abs((t % (ySize << 5))-(ySize << 4))
	sprite 12 image 4 to xOrg-16,yOrg+yFire
	sprite 13 image 6 to xOrg+xSize<<4,yOrg+yFire
endproc	

