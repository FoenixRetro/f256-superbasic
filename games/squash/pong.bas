'
'		Simple PNG Game. Testing the BASICs :)
'
cls:bitmap on:sprites on
drawScreen()
score = 0:refreshScore(score)
ballx = 160:bally = 120:ballyi = random(2)*2-1:ballxi = 1
sprite 1 image 1 to 32,120
repeat
	if event(ballEvent,2) then moveBall()
until false
end
'
'	Move the ball
'
proc moveBall()
	sprite 0 image 0 to ballx,bally
	ballx = ballx + ballxi << 2
	bally = bally + ballyi << 2
	if ballx > 312 | ballx < 64 then ballxi = -ballxi
	if bally < 28 | bally > 232
		ballyi = -ballyi
		score = score + 1:refreshScore(score)
	endif
endproc
'
' 	Refresh the score
'
proc refreshScore(n)
	print score
	local s$:s$ = right$("00"+str$(n),3)
	print n,s$
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