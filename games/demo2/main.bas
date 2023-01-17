'
'		Demo
'
cls:bitmap on:sprites on:bitmap clear $6D:spriteCount = 20
palette $6D,$40,$40,$40:palette $FC,255,128,0
text "65C02 Foenix F256" dim 2 colour $FC to 24,10
dim x(spriteCount),y(spriteCount),xv(spriteCount),yv(spriteCount)
g = 2:line colour $E0 from 0,235 to 319,235
i = 20:while i <= 300:line i,35 to i,235:i = i + 20:wend
i = 35:while i < 235:line 20,i to 300,i:i = i + 20:wend
for i = 1 to spriteCount
	x(i) = random(300)+10:y(i) = 10+random(200)
	xv(i) = random(20)-10:yv(i) = 0
next
repeat
	for i = 1 to spriteCount
		if y(i) >= 0:sprite i image 0 to x(i),y(i):else:sprite 1 off:endif
		yv(i) = yv(i)+g
		x(i) = x(i)+xv(i):y(i) = y(i)+yv(i)
		if y(i) > 220 then y(i) = y(i)-yv(i):yv(i) = -abs(yv(i)*7\8)
		if x(i) < 4 | x(i) > 316 then xv(i) = -xv(i):x(i) = x(i)+xv(i)
		if yv(i) = 0 then yv(i) = random(8)+12
	next
until false