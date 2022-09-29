; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		fractional.asm
;		Purpose:	Extract fractional part 
;		Created:	29th September 2022
;		Reviewed: 	
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;									Get fractional part of Stack,X
;
; ************************************************************************************************

FloatFractionalPart:
		pha
		phx
		phy
		;
		lda 	NSExponent,x 				; if exponent = integer, return zero
		beq 	_FFPZero
		;
		lda 	NSStatus,x 					; take absolute value
		and 	#$7F
		sta 	NSStatus,x

		jsr 	NSNormaliseX
		;
		lda		FPAExponent 				; calculate bits to zero
		clc 								; e.g. how many of the most significant
		adc 	#32 			 			; bits we keep to keep the fractional part.
		bcs 	_FFPZero
		;
		bcc 	_FFPExit 					; if bit shift <= 0 then exit now (already fractional)
		beq 	_FFPExit
		cmp 	#32 						; >= 32 ? this means the number does not have the precision to tell.
		bcs 	_FFPZero 					; return zero as will be all blanked

		ldx 	#3 							; offset in the mantissa, start at the high byte
		tay 								; count in Y
_FFPLoop:
		cpy 	#0 							; finished ?
		beq 	_FFPExit
		cpy 	#8 							; can we do a whole byte at once.
		bcs 	_FFPFreeByte
		;
		phy 								; 1-7 to do, so do that many shift lefts, then that
_FFPShiftLeft: 								; many shift rights.
		asl 	FPAMantissa,x 				; this zeros the first n bits.
		dey
		bne 	_FFPShiftLeft
		ply
_FFPShiftRight:
		lsr 	FPAMantissa,x
		dey
		bne 	_FFPShiftRight
		bra 	_FFPExit
		;
_FFPFreeByte:
		stz 	FPAMantissa,x 				; do a whole byte
		dex 								; previous byte in mantissa, e.g. going right to left
		tya 								; take 8 from count
		sec
		sbc 	#8
		tay
		bra 	_FFPLoop

_FFPZero:
		ldx 	#FPX_A0 					; return zero
		jsr 	NSSetZero
_FFPExit:	
		ply	
		plx
		pla
		rts		

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
