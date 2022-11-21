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
;					hit(s1,s2) returns pixel overlap or 0 if no collision
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
		lda 	#GCMD_SpriteCollide 		; command check collision.
		jsr 	GXGraphicDraw 				; calculate result
		inc 	a 							; so 255 (fail) -> 0, otherwise 1,2,3,4 pixels etc.
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
