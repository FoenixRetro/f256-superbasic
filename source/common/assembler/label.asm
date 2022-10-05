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

LabelHere:
		iny 								; skip .
		ldx 	#0 							; get a term
		jsr 	EvaluateTerm 				; get a term
		lda 	NSStatus 					; needs to be an integer reference.
		cmp 	#NSTInteger+NSBIsReference
		bne 	_ALType
		;
		lda 	NSMantissa0,x 				; copy reference address to zTemp0
		sta 	zTemp0
		lda 	NSMantissa1,x
		sta 	zTemp0+1

		phy 								; copy address in.
		ldy 	#1
		lda	 	AssemblerAddress
		sta 	(zTemp0)
		lda	 	AssemblerAddress+1
		sta 	(zTemp0),y
		iny
		lda 	#0
		sta 	(zTemp0),y
		iny
		sta 	(zTemp0),y
		iny
		sta 	(zTemp0),y
		ply
		rts

_ALType:
		jmp 	TypeError

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
