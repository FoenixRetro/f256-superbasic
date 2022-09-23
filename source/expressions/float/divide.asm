; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		divide.asm
;		Purpose:	Divide Stack[x] by Stack[x+1] floating point
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

FDivideCommand: ;; [/]
		plx	 								; restore stack position
		jsr 	FloatPrepare 				; prepare for floats

FloatDivide:	
		inx 
		jsr 	NSNormalise		 			; normalise S[x+1] and error if zero.
		beq 	_FDZero 					
		dex

		jsr 	NSNormalise		 			; normalise S[X] and exit if zero
		beq 	_FDExit 					; return zero if zero (e.g. zero/something)

		jsr 	Int32ShiftDivide 			; do the shift division for dividing.
		jsr 	NSMCopyPlusTwoToZero 		; copy the mantissa down
		jsr		NSNormalise 				; renormalise
		jsr 	CalculateSign 				; calculate result sign

		lda 	NSExponent,x 				; calculate exponent
		sec
		sbc 	NSExponent+1,x
		sec
		sbc 	#30
		sta 	NSExponent,x
_FDExit:
		.debug
		rts
_FDZero:
		.error_divzero

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
