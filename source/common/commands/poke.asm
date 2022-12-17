; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		poke.asm
;		Purpose:	1/2/3/4 byte memory writes
;		Created:	1st December 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

PokeBCommand: ;; [poke]
		lda 	#1
		bra 	PokeCommand
PokeWCommand: ;; [pokew]
		lda 	#2
		bra 	PokeCommand
PokeLCommand: ;; [pokel]
		lda 	#3
		bra 	PokeCommand
PokeDCommand: ;; [poked]
		lda 	#4
		bra 	PokeCommand

PokeCommand:
		pha 								; save count on stack

		ldx 	#0 							; bottom of stack
		jsr		Evaluate16BitInteger 		; address
		jsr 	CheckComma
		inx
		jsr		EvaluateInteger 			; data
		;
		lda 	NSMantissa0 				; copy address
		sta 	zTemp0
		lda 	NSMantissa1
		sta 	zTemp0+1
		;
		pla 								; count -> zTemp1
		sta 	zTemp1 
		phy 								; save Y position.

		ldy 	#0 							; index to write
		ldx 	#0 							; index to read
_PCLoop:
		lda 	NSMantissa0+1,x 			; read byte from mantissa and copy out
		sta 	(zTemp0),y
		;
		iny 								; next byte to write		
		txa 								; next byte to read - stack layout in 04data.inc
		clc
		adc 	#MathStackSize
		tax
		;
		dec 	zTemp1 						; done them all
		bne 	_PCLoop
		ply 								; restore position.
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
;		17/12/22 		Rewritten entirely POKE[WLD] syntax used.
;
; ************************************************************************************************
