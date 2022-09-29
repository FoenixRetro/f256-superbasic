; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		multiply.asm
;		Purpose:	Multiply Stack[x] by Stack[x+1] floating point
;		Created:	23rd September 2022
;		Reviewed: 	
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;									Floating point division
;
; ************************************************************************************************

FloatingPointMultiply:
		jsr 	FloatPrepare 				; prepare for floats

FloatMultiply:	
		pha
		jsr 	NSNormalise		 			; normalise S[X] and exit if zero
		beq 	_FDExit 					; return zero if zero (e.g. zero/something)
		inx 
		jsr 	NSNormalise		 			; normalise S[x+1] and error if zero.
		dex
		cmp 	#0
		beq 	_FDSetZero 					

		jsr 	MultiplyShort 				; calculate the result.		
		adc 	NSExponent,x 				; calculate exponent including the shift.
		clc
		adc 	NSExponent+1,x
		sta 	NSExponent,x
		bra 	_FDExit

_FDSetZero:
		jsr 	NSMSetZero 					; return 0
_FDExit:
		jsr 	NSNormalise 				; normalise the result
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
