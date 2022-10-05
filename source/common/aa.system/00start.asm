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
		ldx 	#(Prompt >> 8) 				; prompt
		lda 	#(Prompt & $FF)
		jsr 	PrintStringXA
		;
		jsr 	NewCommand 					; erase current program
		jsr 	BackloadProgram
		.if 	AUTORUN==1 					; run straight off
		jmp 	CommandRun
		.else
		jmp 	WarmStart
		.endif

Prompt:	.text 	13,13,"*** F256 Junior SuperBASIC ***",13,13
		.text 	"Written by Paul Robson 2022.",13,13
		.include "../generated/timestamp.asm"
		.byte 	13,13,0
		.align 2
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
