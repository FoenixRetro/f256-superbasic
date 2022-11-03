cls:sprites on:bitmap on:bitmap clear 0
initialise()
newLevel()
repeat
	if event(moveEnemies,4) 
		updateEnemies()
		n = random(mcount):if remain(n) = 0 then launch(n)		
	endif
	if event(moveMissiles,6) then moveMissiles()
until False
end

proc initialise()
	xSize = 14:ySize = 11:mCount = 8
	xOrg = 160-xSize*8:yOrg = 140-ySize*8
	dim x(mCount-1),y(mCount-1),xi(mCount-1),yi(mCount-1),remain(mCount-1)	
endproc

proc launch(n)
	if random() & 1:horizontalLaunch(n):else:verticalLaunch(n):endif
endproc

proc verticalLaunch(n)
	x(n) = xOrg-16:y(n) = yOrg+((yFire+8) & $F0):xi(n) = 4:yi(n) = 0	
	remain(n) = abs((xSize*16+16) / xi(n))
	if random() & 1 then x(n) = x(n) + remain(n)*xi(n):xi(n) = -xi(n)
	sprite n+0 image 11 to x(n),y(n)
endproc

proc horizontalLaunch(n)
	y(n) = yOrg-16:x(n) = xOrg+((xFire+8) & $F0):yi(n) = 4:xi(n) = 0	
	remain(n) = abs((ySize*16+16) / yi(n))
	if random() & 1 then y(n) = y(n) + remain(n)*yi(n):yi(n) = -yi(n)
	sprite n+0 image 12 to x(n),y(n)
endproc

proc moveMissiles()
	local i
	for i = 0 to mCount-1
		if remain(i) > 0
			x(i) = x(i)+xi(i):y(i) = y(i)+yi(i)
			remain(i) = remain(i)-1
			if remain(i) > 0:sprite i+0 to x(i),y(i):else:sprite i+0 off:endif
		endif
	next
endproc

proc newLevel()
	bitmap clear 0
	local i
	for i = 0 to mCount-1:remain(i) = 0:next
	drawBackground():updateEnemies()
endproc

proc drawBackground()
	local x,y:line colour $25
	for x = 0 to xSize-1:line xOrg+x*16,yOrg-8 by 0,ySize*16:next
	for y = 0 to ySize-1:line xOrg-8,yOrg+y*16 by xSize*16,0:next
	rect colour $E0 outline xOrg-24,yOrg-24 by xSize*16+32,ySize*16+32
	rect colour $FF outline xOrg-25,yOrg-25 by xSize*16+34,ySize*16+34
endproc

proc updateEnemies()
	local t:t = timer()
	xFire = abs((t % (xSize << 5))-(xSize << 4))
	sprite 10 image 5 to xOrg+xFire,yOrg-16
	sprite 11 image 7 to xOrg+xFire,yOrg+ySize<<4
	yFire = abs((t % (ySize << 5))-(ySize << 4))
	sprite 12 image 4 to xOrg-16,yOrg+yFire
	sprite 13 image 6 to xOrg+xSize<<4,yOrg+yFire
endproc	


