; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		addsub.asm
;		Purpose:	Add/Subtract S[X+1] to S[X]
;		Created:	23rd September 2022
;		Reviewed: 	27th November 2022
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section 	code

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
		beq 	_FAReturn1

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
		bpl 	_FACheckZero 				; if no, check for -0
		jsr 	NSMNegate 					; netate result
		jsr 	NSMNegateMantissa 			; negate (2'c) the mantissa
_FACheckZero:		
		jsr 	NSMIsZero	 				; check for -0
		bne 	_FAExit
		stz 	NSStatus,x
		bra 	_FAExit

_FAReturn1:									; copy slot X+1 into slot X
		lda 	NSMantissa0+1,x 			; called when S(X) is zero.
		sta 	NSMantissa0,x
		lda 	NSMantissa1+1,x
		sta 	NSMantissa1,x
		lda 	NSMantissa2+1,x
		sta 	NSMantissa2,x
		lda 	NSMantissa3+1,x
		sta 	NSMantissa3,x
		lda 	NSExponent+1,x 				
		sta 	NSExponent,x
		lda 	NSStatus+1,x
		sta 	NSStatus,x 			
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
		;
		; 	Possible byte shift optimise here, but is it worth it ?
		;
_FAShiftToExponent2:
		tya 								; compare Y to exponent  								
		cmp 	NSExponent,x 				; reached the exponent required ?
		beq 	_FASEExit 					; exit if so.
		jsr 	NSMShiftRight	 			; shift the mantissa right
		inc 	NSExponent,x 				; increment exponent
		bra 	_FAShiftToExponent2
_FASEExit:
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
