; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		label.asm
;		Purpose:	Handle assembler labels
;		Created:	4th October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section 	code

; ************************************************************************************************
;
;											Define a label
;
; ************************************************************************************************

AssemblerLabel:
		jsr 	EvaluateTermAutoCreate		; evaluate the term which is the var/array element to assign
		lda 	FPAStatus 					; the status should be 1. e.g. a number reference
		cmp 	#1
		bne 	_ALSyntax
		;
		lda 	FPAMantissa 				; copy mantissa to zTemp0
		sta 	zTemp0
		lda 	FPAMantissa+1
		sta 	zTemp0+1

		phy
		ldy 	#1
		lda 	PVariable 					; write P to lower 16 bits
		sta 	(zTemp0)
		lda 	PVariable+1
		sta 	(zTemp0),y
		iny
		lda 	#0 							; upper bits zero
		sta 	(zTemp0),y
		iny
		sta 	(zTemp0),y
		iny
		lda 	#IntExponent 				; it's an integer exponent.
		sta 	(zTemp0),y
		ply
		rts

_ALSyntax:
		jmp 	SyntaxError

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
