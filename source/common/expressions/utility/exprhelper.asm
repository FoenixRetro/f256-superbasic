; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		exprhelper.asm
;		Purpose:	Expression support routines
;		Created:	22nd September 2022
;		Reviewed: 	27th November 2022
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;								Evaluate a Value (e.g. dereference)
;
; ************************************************************************************************

EvaluateValue:
		pha
		jsr		EvaluateExpression 			; expression
		jsr 	Dereference					; derefernce it
		pla
		rts
		
; ************************************************************************************************
;
;										Evaluate a number
;
; ************************************************************************************************

EvaluateNumber:
		jsr 	EvaluateValue 				; get a value
		lda 	NSStatus,x 					; check if string.
		and 	#NSBIsString 				
		bne 	HelperTypeError
		rts

; ************************************************************************************************
;
;										Evaluate a string
;
; ************************************************************************************************

EvaluateString:
		jsr 	EvaluateValue 				; get a value
		lda 	NSStatus,x 					; check if string.
		and 	#NSBIsString 				
		beq 	HelperTypeError
CopyAddressToTemp0:		
		lda 	NSMantissa0,x 				; copy address -> zTemp0
		sta 	zTemp0 						; (so we can do something with it)
		lda 	NSMantissa1,x
		sta 	zTemp0+1
		rts

HelperTypeError:
		jmp 	TypeError

; ************************************************************************************************
;
;										Evaluate an integer
;
; ************************************************************************************************

EvaluateInteger:
		jsr 	EvaluateNumber
		lda 	NSExponent,x 				; check exponent is zero
		bne 	HelperValueError 			; if not, it's a float.
		rts

EvaluateUnsignedInteger:
		jsr 	EvaluateInteger 			; check integer is +ve
		lda 	NSStatus,x
		bmi 	HelperValueError
		rts

HelperValueError:
		jmp 	ArgumentError

; ************************************************************************************************
;
;									Evaluate a 16 bit value (unsigned)
;
; ************************************************************************************************

Evaluate16BitInteger:
		jsr	 	EvaluateUnsignedInteger		; get integer
		lda 	NSMantissa3,x	 			; bytes 2 & 3 must be zero
		ora 	NSMantissa2,x
		bne 	HelperValueError
		rts

; ************************************************************************************************
;
;							Evaluate a 16 bit value (signed, 2's complement)
;
; ************************************************************************************************

Evaluate16BitIntegerSigned:
		jsr	 	EvaluateInteger				; get integer
		lda 	NSMantissa3,x	 			; bytes 2 & 3 must be zero
		ora 	NSMantissa2,x
		bne 	HelperValueError
		lda 	NSStatus,x 					; signed ?
		bpl 	_EISNotSigned
		jsr 	NSMNegateMantissa 			; makes it an actual 2's complement value.
_EISNotSigned:		
		rts

; ************************************************************************************************
;
;									Evaluate an 8 bit value => A
;
; ************************************************************************************************

Evaluate8BitInteger:
		jsr	 	EvaluateUnsignedInteger 	; get an integer
		bne 	HelperValueError
		lda 	NSMantissa3,x	 			; bytes 1, 2 & 3 must be zero
		ora 	NSMantissa2,x
		ora 	NSMantissa1,x
		bne 	HelperValueError
		lda 	NSMantissa0,x
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
