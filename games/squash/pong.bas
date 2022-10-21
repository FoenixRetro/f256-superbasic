'
'		Simple PNG Game. Testing the BASICs :)
'
cls:bitmap on:sprites on
drawScreen()
score = 0:refreshScore(score)
ballx = 160:bally = 120:ballyi = random(2)*8-4:ballxi = 4:baty = 140
rate = 2
repeat
	if event(ballEvent,rate) then moveBall()
	if event(batEvent,rate) then moveBat()
until ballx < 10
end
'
'	Move the ball
'
proc moveBall()
	sprite 0 image 0 to ballx,bally
	ballx = ballx + ballxi 
	bally = bally + ballyi 
	if ballx > 312:ballxi = -ballxi:endif
	if bally > 232 | bally < 32 then ballyi = -ballyi
	if ballx < 32 & ballx >= 26 & abs(baty-bally) < 16 then bounce()
endproc
'
'	Move the bat
'
proc moveBat()
	sprite 1 image 1 to 32,baty
	baty = baty + joyy(0) * 4
	if baty < 40 then baty = 40
	if baty >= 210 then baty = 210
endproc
'
'	Bounce the ball off the bat
'
proc bounce()
	ballyi = abs(baty-bally) \ 4 + 1
	if baty > bally then ballyi = -ballyi
	ballxi = abs(ballxi)
	score = score+1:refreshScore(score)
endproc
'
' 	Refresh the score
'
proc refreshScore(n)
	local s$:s$ = right$("00"+str$(n),3)
	text s$ dim 2 colour $FC,4 to 10,3 : ' Sets mode bit 2, which draws the background forcing overwrite $FC is yellow.
endproc
'
'	Draw frame
'
proc drawScreen()
	bitmap clear 0
	rect solid colour $F0 0,20 to 319,24
	rect 0,236 to 319,239
	rect 316,20 to 319,239
endproc