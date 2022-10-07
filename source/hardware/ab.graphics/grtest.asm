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

		lda 	#$FC
		sta 	gxEORValue
		lda 	#$FF
		sta 	gxANDValue
		.plot 	0,4,0

plot:	.macro
		lda 	#((\1)*2)+(((\2) >> 8) & 1)		
		ldx 	#((\2) & $FF)
		ldy 	#(\3)
		jsr 	GraphicDraw
		.endm

			
loop:	
		ldx 	$7FFF
		ldy 	#0
		lda 	#16*2
		jsr 	GraphicDraw
		ldx 	$7FFF
		ldy 	#239
		lda 	#17*2
		jsr 	GraphicDraw
		inc 	$7FFF
		bra 	loop
		


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
