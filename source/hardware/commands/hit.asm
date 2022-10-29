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
;									hit(sprite0,sprite1)
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
		phy 								; save Y position, end of unary func.

		ldy 	#zTemp1 					; sprite address in zTemp1
		jsr 	_UHCalculateSpriteAddress
		sta 	zTemp2+1 					; save half width 1 in zTemp2+1
		dex
		ldy 	#zTemp0 					; sprite address in zTemp0		
		jsr 	_UHCalculateSpriteAddress
		sta 	zTemp2 						; half width 0 in zTemp2


		jsr 	NSMSetZero 					; return zero.
		ply
		rts

; ************************************************************************************************
;
;		Calculate sprite address at stack entry X, store in A (zTemp0/zTemp1)
;		Return in A the width of the sprite / 2
;
; ************************************************************************************************

_UHCalculateSpriteAddress:
		phx 								; save X
		lda 	NSMantissa0,x 				; sprite #, check range
		cmp 	#64							
		bcs		_UHGSNError

		asl 	a 							; x 8, overflow in carry flag
		asl 	a
		asl 	a
		sta 	0,y 						; write LSB, also to zsTemp
		lda 	#$D9 						; sprites start at $D900
		adc 	#0 							; add carry out
		sta 	1,y 						; write MSB
		;
		tya 								; calculate the size
		tax
		lda 	(0,x) 						; read the sprite control register.
		and 	#$60 						; size bits (00:32 20:24 40:60:8)
		eor 	#$60 						; 00:8 20:16 40:24 60:32
		lsr 	a 							; / 4 and CLC
		lsr 	a 							; 00:8 08:16 10:24 18:32 
		adc 	#8 							; 08:8 10:16 18:24 20:32

		lsr 	a 							; half the size.
		plx 								; restore X
		rts
_UHGSNError:
		.error_range		


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
