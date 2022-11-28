; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		integer.asm
;		Purpose:	Make FPA Denormalised integer
;		Created:	29th September 2022
;		Reviewed: 	28th November 2022
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section 	code

; ************************************************************************************************
;
;									Make FPA into an integer
;
; ************************************************************************************************

FloatIntegerPart:
		pha
		;
		lda 	NSExponent,x 				; is it integer already ?
		beq 	_FIPExit 					; if so do nothing
		jsr 	NSMIsZero 					; is it zero ?
		beq 	_FIPZero 					; if so return zero.
		;
		jsr 	NSNormalise 				; normalise
		beq 	_FIPZero 					; normalised to zero, exit zero
		;
_FIPShift:
		lda 	NSExponent,x 				; if Exponent >= 0 exit.
		bpl 	_FIPCheckZero		 		

		jsr 	NSMShiftRight 				; shift mantissa right
		inc 	NSExponent,x 				; bump exponent 
		bra 	_FIPShift

_FIPCheckZero:
		jsr 	NSMIsZero 					; avoid -0 problem
		bne 	_FIPExit 					; set to zero if mantissa zero.		
_FIPZero:
		jsr 	NSMSetZero
_FIPExit:
		pla
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
