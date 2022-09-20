; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		00start.asm
;		Purpose:	Start up code.
;		Created:	18th September 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

Start:	ldx 	#$FF 						; stack reset
		txs	
		;
		jsr 	NewCommand 					; erase current program
		jsr 	BackloadProgram
		.set16  codePtr,BasicStart
		ldy 	#4
		ldx 	#1
		jsr 	EvaluateTerm
		.debug 
		lda 	#$20+$00
		sta 	NSStatus,x
		jsr 	Dereference
WarmStart:
		.debug
		bra 	WarmStart

ErrorHandler:		
		.debug
		jmp 	ErrorHandler

		.include "../generated/vectors.dat"

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
