; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		alloc.asm
;		Purpose:	Memory allocation.
;		Created:	29th September 2022
;		Reviewed: 	No
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

		lda		NSMantissa1,y 				; get size
		tax
		lda 	NSMantissa0,y

		jsr 	AllocateXABytes 			; allocate memory

		sta 	NSMantissa0,y 				; write address out.
		txa
		sta 	NSMantissa1,y

		ply
		plx
		rts

; ************************************************************************************************
;
;								Allocate XA bytes of memory
;
; ************************************************************************************************

AllocateXABytes:
		phy
		ldy 	lowMemPtr 					; push current address on stack
		phy
		ldy 	lowMemPtr+1
		phy

		clc
		adc 	lowMemPtr
		sta 	lowMemPtr
		txa
		adc 	lowMemPtr+1
		sta 	lowMemPtr+1

		; ** TODO Check memory overflow **
		
		plx
		pla
		ply
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
