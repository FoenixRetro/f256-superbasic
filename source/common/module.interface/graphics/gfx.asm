; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		gfx.asm
;		Purpose:	Simple GFX command
;		Created:	12th October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

GfxCommand: ;; [gfx]
		ldx 	#0
		jsr 	Evaluate8BitInteger 		; command
		jsr 	CheckComma
		inx
		jsr 	Evaluate16BitInteger 		; X
		jsr 	CheckComma
		inx
		jsr 	Evaluate8BitInteger 		; Y
		;
		lda 	NSMantissa1+1  				; shift bit 0 of X into CS, should now be zero
		lsr 	a
		bne 	_GfxError
		rol 	NSMantissa0 				; rotate into command
		bcs 	_GfxError 					; bit 7 should have been zero
		;
		phy 								; save pos
		lda 	NSMantissa0 				; do the command
		ldx 	NSMantissa0+1
		ldy 	NSMantissa0+2
		jsr 	GXGraphicDraw
		bcs 	_GfxError
		ply 								; restore pos and exit.
		rts
_GfxError:
		jmp 	RangeError		

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
