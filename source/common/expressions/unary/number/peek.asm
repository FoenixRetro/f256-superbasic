; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		peek.asm
;		Purpose:	1/2/3/4 byte memory reads
;		Created:	1st December 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

PeekByteUnary: ;; [peek(]
		lda 	#1
		bra 	PeekUnary
PeekWUnary: ;; [peekw(]
		lda 	#2
		bra 	PeekUnary
PeekLUnary: ;; [peekl(]
		lda 	#3
		bra 	PeekUnary
PeekDUnary: ;; [peekd(]
		lda 	#4

PeekUnary:
		plx 								; restore position.
		pha 								; save count to copy on stack
		jsr		Evaluate16BitInteger 		; address as constant.
		jsr 	CheckRightBracket
		;
		lda 	NSMantissa0,x 				; save mantissa in zTemp0 as address
		sta 	zTemp0
		lda 	NSMantissa1,x
		sta 	zTemp0+1
		;
		jsr 	NSMSetZero 					; clear the result to zero.
		;
		pla 								; count in zTemp2
		sta 	zTemp2
		phx 								; save stack position and offset of read
		phy
		ldy 	#0 							; byte read offset.
_PULoop:
		lda 	(zTemp0),y 					; get next byte, write to mantissa0,x
		sta 	NSMantissa0,x 				; we change X not the index before it.

		iny 								; next byte to write		
		txa 								; next byte to read - stack layout in 04data.inc
		clc
		adc 	#MathStackSize
		tax
		;
		dec 	zTemp2 						; done them all
		bne 	_PULoop
		;
		ply 								; restore stack/code pos and exit.
		plx
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
;		17/12/22 		Rewritten and changed to PEEKW() syntax
;
; ************************************************************************************************
