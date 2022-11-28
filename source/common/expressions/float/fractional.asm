; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		fractional.asm
;		Purpose:	Extract fractional part 
;		Created:	29th September 2022
;		Reviewed: 	28th November 2022
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section 	code

; ************************************************************************************************
;
;									Get fractional part of Stack,X
;
; ************************************************************************************************

FloatFractionalPart:
		phy

		lda 	NSStatus,x 					; take absolute value 
		and 	#$7F
		sta 	NSStatus,x
		jsr 	NSNormalise

		lda 	NSExponent,x 				; calculate exponent-$E0 = digits to blank
		sec
		sbc 	#$E0
		bcc 	_FFPExit 					; already fractional

		cmp 	#32 						; will be zero as blanking 32+ digits.
		bcs 	_FFPZero
		;
		tay 								; put count to do in Y
		;
		lda 	NSMantissa3,x 				; do each in turn.
		jsr 	_FFPPartial
		sta 	NSMantissa3,x

		lda 	NSMantissa2,x
		jsr 	_FFPPartial
		sta 	NSMantissa2,x

		lda 	NSMantissa1,x
		jsr 	_FFPPartial
		sta 	NSMantissa1,x

		lda 	NSMantissa0,x
		jsr 	_FFPPartial
		sta 	NSMantissa0,x
		
		jsr 	NSMIsZero 					; zeroed check.
		bne 	_FFPExit

_FFPZero:
		jsr 	NSMSetZero
_FFPExit:	
		ply	
		rts		
;
;		Clear up to 8 bits from A from the left, subtract from the todo count in Y
;
_FFPPartial:
		cpy 	#0 							; no more to do
		beq 	_FFFPPExit
		cpy 	#8 							; whole byte to do ?
		bcs 	_FFFPPWholeByte 
		;
		phy
_FFFPPLeft:
		asl 	a
		dey 	
		bne 	_FFFPPLeft		
		ply
_FFFPPRight:
		lsr 	a
		dey 	
		bne 	_FFFPPRight
		bra 	_FFFPPExit

_FFFPPWholeByte:
		tya 								; subtract 8 from count
		sec
		sbc 	#8
		tay
		lda 	#0 							; and clear all
_FFFPPExit:		
		rts

		.send 	code

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
