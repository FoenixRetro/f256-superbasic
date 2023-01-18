
	* = $2000
	bra 	Start
	.text 	"BT65"
Start:	
	ldx 	#0
Fill1:	
	lda 	#2
	sta 	1
	txa
	sta 	$C000,x
	lda 	#3
	sta 	1
	lda 	#$F0
	sta 	$C000,x	
	dex
	bne 	Fill1
	lda 	#2
	sta 	1
Anim:
	inc 	$C000
	bne 	Anim
	inc 	$C001
	bne 	Anim
	inc 	$C002
	bne 	Anim
	inc 	$C003
	bra 	Anim		