; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		alloc.asm
;		Purpose:	Memory allocation.
;		Created:	29th September 2022
;		Reviewed: 	27th November 2022
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code


; ************************************************************************************************
;
; 										Allocate memory
;
; ************************************************************************************************

AllocUnary: ;; [alloc(]	
		plx 								; restore stack pos
		jsr 	Evaluate16BitInteger		; get bytes required.
		jsr 	CheckRightBracket

		phx 								; save X/Y
		phy

		txa 								; copy X into Y
		tay

		lda		NSMantissa1,y 				; get size into XA
		tax
		lda 	NSMantissa0,y

		jsr 	AllocateXABytes 			; allocate memory

		sta 	NSMantissa0,y 				; write address out.
		txa 	 							; typing is 16 bit integer.
		sta 	NSMantissa1,y

		ply
		plx
		rts

; ************************************************************************************************
;
;				Allocate XA bytes of memory - this is from the storage after the identifiers
;
; ************************************************************************************************

AllocateXABytes:
		phy
		ldy 	lowMemPtr 					; push current address on stack and to zTemp0
		sty 	zTemp0
		phy
		ldy 	lowMemPtr+1
		sty 	zTemp0+1
		phy

		clc 								; add to low memory pointer
		adc 	lowMemPtr
		sta 	lowMemPtr
		txa
		adc 	lowMemPtr+1
		sta 	lowMemPtr+1
		bcs 	CISSMemory

		jsr 	CheckIdentifierStringSpace 	; check identifier/string space 

_ClearMemory:
		lda 	lowMemPtr 					; cleared all memory allocated
		cmp 	zTemp0
		bne 	_CMClearNext
		lda 	lowMemPtr+1
		cmp 	zTemp0+1
		beq 	_CMExit
_CMClearNext:		
		lda 	#0 							; clear byte, advance to next.
		sta 	(zTemp0)
		inc 	zTemp0
		bne 	_ClearMemory
		inc		zTemp0+1
		bra 	_ClearMemory
_CMExit:		
		plx
		pla
		ply
		rts

; ************************************************************************************************
;
;				Check there is sufficent space between lowMemPtr and StringMemory
;
; ************************************************************************************************

CheckIdentifierStringSpace:
		pha
		lda 	lowMemPtr+1 				; get low memory pointer
		clc
		adc 	#2 							; need at least 2 256 byte pages
		cmp 	stringMemory+1 				; is it >= StringMemory
		bcs 	CISSMemory
		pla
		rts
CISSMemory:
		.error_memory

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
