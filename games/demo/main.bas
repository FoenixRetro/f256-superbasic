'
'		Demo
'
cls:bitmap on:sprites on:bitmap clear 0:spriteCount = 8
dim x(spriteCount),y(spriteCount),xi(spriteCount),yi(spriteCount),img(spriteCount)
for i = 0 to spriteCount-1
	x(i) = 16+random(320)
	y(i) = 16+random(240)
	xi(i) = random(5)+2:yi(i) = 0:img(i) = 1
	if i % 2 = 0 then yi(i) = xi(i):xi(i) = 0:img(i) = 3
next 
currentSprite = 0
repeat
	demo(40)
	for d = 33 to 37
		demo(d)
	next
until false
'
'	Do demo using op n.
'
proc demo(op)
	bitmap clear 0
	gfx 32,160,120
	t1 = timer() + 70*3
	while timer() < t1
		gfx 4,random(256),0
		gfx op,random(320),random(240)
		if event(nextSprite,3) 
			for i = 0 to spriteCount-1
				moveSprite(i)
			next
		endif
	wend	
endproc

proc moveSprite(n)
	x(n) = x(n)+xi(n)
	y(n) = y(n)+yi(n)
	if x(n) < 10 | y(n) < 10 | x(n) > 310 | y(n) > 230
		xi(n) = -xi(n):yi(n) = -yi(n)
		img(i) = img(i) ^ 1
	else
		sprite n image img(n) to x(n),y(n)
	endif
endproc