'
'	Simple title screen
'
proc title(name$)
bitmap on:bitmap clear 0:cls
centre(210,1,$1F,"Press FIRE to Start")
centre(120,1,$FC,"A Foenix F256 Demo Game in BASIC")
centre(130,1,$F0,"Written by Paul Robson 2022")
n = 0
while joyb(0) = 0
	drawTitleAt(n$,n):n = (n + 1) & 7
wend
while joyb(0) <> 0:wend
bitmap off
endproc
'
proc centre(y,size,c,msg$)
text msg$ dim size colour c to 160-len(msg$)*size*4,y
endproc
'
proc drawTitleAt(n$,offset)
	text name$ colour random() & $FF dim 3 to 160-len(name$)*12+offset,32+offset
endproc