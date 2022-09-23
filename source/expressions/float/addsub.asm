; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		addsub.asm
;		Purpose:	Add/Subtract S[X+1] to S[X]
;		Created:	23rd September 2022
;		Reviewed: 	
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;										Float Handlers
;
; ************************************************************************************************

FloatingPointAdd:
		jsr 	FloatPrepare 				; prepare for floats
		bra 	FloatAdd
FloatingPointSub:
		jsr 	FloatPrepare 				; prepare for floats

; ************************************************************************************************
;
;									 Subtract FPB from FPA
;
; ************************************************************************************************

FloatSubtract:
		lda 	NSStatus+1,x 				; negate FPB
		eor 	#$80
		sta 	NSStatus+1,x				; and fall through.

; ************************************************************************************************
;
;							Add FPB to FPA, result not normalised
;									    (see binary.py)
;
; ************************************************************************************************

FloatAdd:
		pha
		phy
		jsr 	NSNormalise 				; normalise S[X]

		inx 								; normalise S[X+1]
		jsr 	NSNormalise
		dex
		cmp 	#0
		beq 	_FAExit 					; if so, just return A

		lda 	NSExponent,x 				; are the exponents the same ?
		cmp 	NSExponent+1,x
		beq 	_FAExponentsEqual

		;
		;		Work out the larger exponent, both at this level as normalised
		; 		use signed compare, result in Y
		;
		lda 	NSExponent,x 				; work out the larger exponent
		tay
		sec 								; do a signed comparison of the exponents.
		sbc 	NSExponent+1,x
		bvc 	_FANoSignedChange
		eor 	#$80
_FANoSignedChange:							; if bit 7 set then Exp[X] < Exp[X+1]
		and 	#$80
		bpl 	_FAHaveMax		 			
		ldy 	NSExponent+1,x 				
_FAHaveMax:			
		jsr 	_FAShiftToExponent  		; shift both to the exponent in Y
		inx
		jsr 	_FAShiftToExponent 
		dex
		;
		;		Exponents are now equal, so we can add or subtract the mantissae
		;
_FAExponentsEqual:		
		lda 	NSStatus,x 					; are the signs the same
		eor 	NSStatus+1,x
		bmi 	_FADifferentSigns
		;
		;		"Add" code, e.g. both have same sign
		;
		jsr 	AddTopTwoStack 				; do the add of the mantissae
		lda 	NSMantissa3,x 				; do we have an overflow in Mantissa A ?
		bpl 	_FAExit 					; if no, we are done.
		jsr 	NSMShiftRight 				; shift A right, renormalising it.
		inc 	NSExponent,x 				; bump the exponent and exit
		bra 	_FAExit
		;
		;		"Subtract" code, e.g. both have different sign.
		;
_FADifferentSigns:
		jsr 	SubTopTwoStack 				; subtract mantissa B from A
		lda 	NSMantissa3,x 				; is the result negative ?
		bpl 	_FAExit 					; if no, we are done.

		jsr 	NSMNegate 					; netate result
		jsr 	NSMNegateMantissa 			; negate (2'c) the mantissa

_FAExit:
		ply
		pla
		rts

; ************************************************************************************************
;
;										Helper : Shift X to Exponent Y.
;
; ************************************************************************************************

_FAShiftToExponent:
		tya 								; compare Y to exponent  								
		cmp 	NSExponent,x 				; reached the exponent required ?
		beq 	_FASEExit 					; exit if so.
		jsr 	NSMShiftRight	 			; shift the mantissa right
		inc 	NSExponent,x 				; increment exponent
		bra 	_FAShiftToExponent
_FASEExit:
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
