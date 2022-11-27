; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		divide.asm
;		Purpose:	Divide Stack[x] by Stack[x+1] floating point
;		Created:	23rd September 2022
;		Reviewed: 	27th November 2022
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section 	code

; ************************************************************************************************
;
;									Floating point division
;
; ************************************************************************************************

FDivideCommand: ;; [/]
		plx	 								; restore stack position
		jsr 	FloatPrepare 				; prepare for floats

FloatDivide:	
		pha
		inx 
		jsr 	NSNormalise		 			; normalise S[x+1] and error if zero.
		dex
		cmp 	#0
		beq 	_FDZero 					

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
		pla
		rts
_FDZero:
		.error_divzero

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
