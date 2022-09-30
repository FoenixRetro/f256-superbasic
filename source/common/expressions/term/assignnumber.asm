; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		assignnumber.asm
;		Purpose:	Assign a numeric value
;		Created:	30th September 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;				Assign a numeric reference, can be 1,2 or 4 byte integers, or a float
;
; ************************************************************************************************

AssignNumber:
		phy
		lda 	NSMantissa0,x 				; copy mantissa0/1 to zTemp0
		sta 	zTemp0
		lda 	NSMantissa1,x
		sta 	zTemp0+1
		;
		lda 	NSStatus,x 					; clear reference bits
		and 	#(NSBIsReference ^ $FF)
		sta 	NSStatus,x
		;
		and 	#NSBTypeMask				; assigning to a float ?
		cmp 	#NSTFloat
		beq 	_ANFloat
		;
		;		Assign an integer
		;
		.debug
		; write zero to type on exit.

		;
		;		Assign a float
		;
_ANFloat:
		jsr 	_ANCopy4PackSign 			; write all 4 bytes and packed sign		
		lda 	NSExponent+1,x 				; copy exponent to slot 4
		ldy 	#4
		sta 	(zTemp0),y 
_ANExit:
		ply
		rts		
;
;		Copy all 4 bytes, with sign bit, from (zTemp),y+3
;
_ANCopy4PackSign:
		ldy 	#3
		lda 	NSStatus+1,x 				; sign bit into status		
		and 	#$80 						; put into high bit of mantissa 3
		ora 	NSMantissa3+1,x
		sta 	(zTemp0),y
		dey
		lda 	NSMantissa2+1,x
		sta 	(zTemp0),y
		dey
		lda 	NSMantissa1+1,x
		sta 	(zTemp0),y
		dey
		lda 	NSMantissa0+1,x
		sta 	(zTemp0),y
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
