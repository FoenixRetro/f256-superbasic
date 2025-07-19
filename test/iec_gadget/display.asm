		.cpu    "65c02"

		.section    data
screenPos:      
		.fill   1            
		.send

		.section    code

initputc
		stz 	screenPos
		rts

putc:
		pha
		phx
		phy

		ldy 	1
		phy

		ldx 	screenPos
		ldy 	#2		
		sty 	1
		sta 	$C000,x
		inc 	1
		lda 	#$52
		sta 	$C000,x

		ply
		sty 	1

		inc 	screenPos

		ply
		plx
		pla
		rts

puth:	pha
		pha
		pha
		lda 	#' '
		jsr 	putc
		pla
		lsr 	a
		lsr 	a
		lsr 	a
		lsr 	a
		jsr 	putn
		pla
		jsr 	putn
		pla
		rts
putn:
		and 	#15
		cmp 	#10
		bcc 	_putn2
		adc 	#6
_putn2:	adc 	#48
		jmp 	putc		
		.send

