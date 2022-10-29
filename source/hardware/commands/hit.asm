; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		hit.asm
;		Purpose:	Check Sprite Collision
;		Created:	29th October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;					hit(x0,y0,x1,y1) returns the larger of |x0-x1| and |y0-y1|
;
; ************************************************************************************************

UnaryHit: ;; [hit(]
		plx
		;
		lda 	#zTemp0 
		jsr 	Evaluate8BitInteger 		; get sprite number 0
		jsr 	CheckComma
		inx
		jsr 	Evaluate8BitInteger 		; get sprite number 1
		jsr		CheckRightBracket
		dex 								; fix back up again.

		phx 								; save X/Y
		phy
		ldy 	NSMantissa0+1,x 			; get the sprite numbers into X/Y
		lda 	NSMantissa0,x
		tax										
		lda 	#9*2 						; command 9
		jsr 	GXGraphicDraw 				; calculate result
		ply 								; restore XY
		plx
		jsr 	NSMSetByte 					; return the hit result
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
