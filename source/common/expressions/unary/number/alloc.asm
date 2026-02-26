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
;		Allocate XA bytes of memory from array space (slots 2-3, $4000-$7FFF)
;
; ************************************************************************************************

AllocateXABytes:
		phy
		ldy 	arrayMemPtr 				; push current address on stack and to zTemp0
		sty 	zTemp0
		phy
		ldy 	arrayMemPtr+1
		sty 	zTemp0+1
		phy

		clc 								; add to array memory pointer
		adc 	arrayMemPtr
		sta 	arrayMemPtr
		txa
		adc 	arrayMemPtr+1
		sta 	arrayMemPtr+1

		jsr 	CheckArraySpace 			; check array space not exhausted

_ClearMemory:
		lda 	arrayMemPtr 				; cleared all memory allocated
		cmp 	zTemp0
		bne 	_CMClearNext
		lda 	arrayMemPtr+1
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
;				Check there is sufficient space in array area ($4000-$7FFF)
;
; ************************************************************************************************

CheckArraySpace:
		pha
		lda 	arrayMemPtr+1 				; check high byte against ArrayEnd
		cmp 	#(ArrayEnd >> 8) 			; >= $80 means overflow
		bcs 	CISSMemory
		pla
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
