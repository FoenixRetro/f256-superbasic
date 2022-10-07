; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		graphics.asm
;		Purpose:	Graphics startup/test code.
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
		sta 	gxForeground
		lda 	#1
		sta 	gxBackground

		jsr 	GXOpenBitmap

		lda 	gxBasePage
		sta 	GFXEditSlot

		ldx 	#0
		tax
copyout:
		stz 	$A300,x
		stz 	$A200,x
		stz 	$A100,x
		sta 	$A000,x
		dex
		bne 	copyout
		inc 	a
		bne 	copyout

		jsr 	GXCloseBitmap

		lda 	#1
		sta 	$D000
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
