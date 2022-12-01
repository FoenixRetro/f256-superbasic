; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		dokepoke.asm
;		Purpose:	1/2 byte memory writes
;		Created:	1st December 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

PokeCommand: ;; [poke]
		clc
		bra 	DPCommand
DokeCommand: ;; [doke]
		sec
DPCommand:
		php									; save on stack, CS = Doke, CC = Poke				
		ldx 	#0 							; bottom of stack
		jsr		Evaluate16BitInteger 		; address
		jsr 	CheckComma
		inx
		jsr		Evaluate16BitInteger 		; data
		;
		lda 	NSMantissa0 				; copy address
		sta 	zTemp0
		lda 	NSMantissa1
		sta 	zTemp0+1
		;
		lda 	NSMantissa0+1 				; low byte
		sta 	(zTemp0)
		;
		plp 								; done if POKE
		bcc 	_DPExit 
		;
		phy 								; write high byte out.
		ldy 	#1
		lda 	NSMantissa1+1
		sta 	(zTemp0),y
		ply

_DPExit:
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
