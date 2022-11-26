; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		divide.asm
;		Purpose:	32x32 bit integer division (2 variants)
;		Created:	22nd September 2022
;		Reviewed: 	27th November 2022
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section 	code

; ************************************************************************************************
;
;									Integer Division
;
; ************************************************************************************************

IntegerDivide: ;; [\]
		plx
		.dispatchintegeronly
		jsr 	CheckDivideZero 			; do div zero check
		jsr 	Int32Divide 				; do the division
		jsr 	CalculateSign 				; calculate result sign
		;
NSMCopyPlusTwoToZero:		
		lda 	NSMantissa0+2,x 			; copy result down from +2
		sta 	NSMantissa0,x
		lda 	NSMantissa1+2,x
		sta 	NSMantissa1,x
		lda 	NSMantissa2+2,x
		sta 	NSMantissa2,x
		lda 	NSMantissa3+2,x
		sta 	NSMantissa3,x
		rts

CheckDivideZero: 							; check Stack[X+1] not zero
		inx
		jsr 	NSMIsZero
		beq 	_CDVError
		dex
		rts
_CDVError:
		.error_divzero

; ************************************************************************************************
;
;									Integer Modulus
;
; ************************************************************************************************

IntegerModulus: ;; [%]
		plx
		.dispatchintegeronly
IntegerModulusNoCheck:		
		jsr 	CheckDivideZero 			; do div zero check
		jsr 	Int32Divide 				; do the division
		asl 	NSStatus,x 					; clear the sign bit.
		lsr 	NSStatus,x
		rts

; ************************************************************************************************
;
;		32 bit unsigned division of FPA Mantissa A by FPA Mantissa B, 32 bit result.
;									(see divide.py)
;
; ************************************************************************************************

Int32Divide:
		pha 								; save AXY
		phy
		jsr 	NSMShiftUpTwo 				; copy S[X] to S[X+2]
		jsr 	NSMSetZeroMantissaOnly 		; set S[X] to zero

		ldy 	#32 						; loop 32 times
_I32DivideLoop:
		inx
		inx
		jsr 	NSMShiftLeft				; shift S[X+2] S[X] left as a 64 bit element
		dex
		dex
		jsr 	NSMRotateLeft
		;		
		jsr 	DivideCheckSubtract 		; check if subtract possible
		bcc 	_I32DivideNoCarryIn
		inc 	NSMantissa0+2,x 			; if possible, set Mantissa0[X+2].0
_I32DivideNoCarryIn:
		dey 								; loop round till division completed.
		bne 	_I32DivideLoop

		ply 								; restore AXY and exit
		pla
		rts

; ************************************************************************************************
;
;		Shifted Division used in Floating Point Divide - does (a << 30) // b
;									(see divide.py)
;
; ************************************************************************************************

Int32ShiftDivide:
		pha 								; save AY
		phy

		inx 								; clear S[X+2]
		inx
		jsr 	NSMSetZero
		dex
		dex

		ldy 	#31 						; loop 31 times.
_I32SDLoop:
		jsr 	DivideCheckSubtract 		; check if subtract possible
		inx
		inx
		jsr 	NSMRotateLeft				; shift 64 bit FPA left, rotating carry in
		dex
		dex
		jsr 	NSMRotateLeft
		dey 	 							; do 31 times
		bne 	_I32SDLoop
		ply 								; restore AY and exit
		pla
		rts

; ************************************************************************************************
;
;							Do the division - check subtraction code
;
;			If can subtract FPB from FPA.Upper, do so, return carry set if was subtracted
;			Common code to both divisions.
;
; ************************************************************************************************

DivideCheckSubtract:
		jsr 	SubTopTwoStack 				; subtract Stack[X+1] from Stack[X+0]
		bcs 	_DCSExit 					; if carry set, then could do, exit
		jsr 	AddTopTwoStack 				; add it back in
		clc 								; and return False
_DCSExit:
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
