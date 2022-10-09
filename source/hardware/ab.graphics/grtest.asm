; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		grtest.asm
;		Purpose:	Graphics test code.
;		Created:	6th October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code
RunDemos:		
		stz 	1

		lda 	#$0F
		sta 	$D000
		lda 	#1
		sta 	$D100
		stz 	$D101
		stz 	$D102
		lda 	#2
		sta 	$D103

		lda 	#16
		sta 	gxBasePage

		lda 	#240
		sta 	gxHeight

plot:	.macro
		lda 	#((\1)*2)+(((\2) >> 8) & 1)		
		ldx 	#((\2) & $FF)
		ldy 	#(\3)
		jsr 	GraphicDraw
		.endm
		
loop:	
		.plot 	2,$20,0
		.plot 	3,$1C,0+8*7
		.plot 	16,20,10
		.plot 	4,'F',0
;		rts

demo:	jsr 	Random32Bit 
		inc 	gxEORValue
		lda 	#16*2
		ldx 	RandomSeed+0
		ldy 	RandomSeed+1
		jsr 	GraphicDraw
		lda 	RandomSeed+2
		and 	#127
		tax
		lda 	#4*2
		jsr 	GraphicDraw
		bra 	demo

		rts

		.send code

; ************************************************************************************************
;
;									Changes and Updates
;
; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;
; ************************************************************************************************
