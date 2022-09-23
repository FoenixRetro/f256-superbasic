; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		utility.asm
;		Purpose:	Floating point utilities
;		Created:	23rd September 2022
;		Reviewed: 	
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
; 					Prepare for floating point operation post popping X
;
; ************************************************************************************************

FloatPrepare:
		jsr 	DereferenceTopTwo 			; dereference the top two values
		lda 	NSStatus,x 					; check ints/floats
		ora 	NSStatus+1,x
		and 	#NSBIsString
		bne 	_FDType
		rts
_FDType:
		jmp 	TypeError

; ************************************************************************************************
;
;									  Normalise Stack[X]
;
; ************************************************************************************************

NSNormalise:
		lda 	NSStatus,x 					; make float, keep sign
		and 	#$80
		ora 	#NSTFloat  					
		sta 	NSStatus,x

		jsr 	NSMIsZero 					; if zero exit 
		bne 	_NSNormaliseLoop 			; if so, normalise it.
		asl 	NSStatus,x 					; clear the sign bit.
		ror 	NSStatus,x 					; (no -0)
		lda 	#0 							; set Z flag
		rts

_NSNormaliseLoop:		
		bit 	NSMantissa3,x 				; bit 30 set ?
		bvs 	_NSNExit 					; exit if so with Z flag clear
		jsr 	NSMShiftLeft 				; shift mantissa left
		dec 	NSExponent,x 				; adjust exponent
		bra 	_NSNormaliseLoop
_NSNExit:
		lda 	#$FF 						; clear Z flag
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
