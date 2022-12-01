; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		deekpeek.asm
;		Purpose:	1/2 byte memory reads
;		Created:	1st December 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

PeekUnary: ;; [peek(]
		clc
		bra 	DPUnary
DeekUnary: ;; [deek(]
		sec
DPUnary:
		plx 								; restore position.
		php									; save on stack, CS = Deek, CC = Peek
		jsr		Evaluate16BitInteger 		; address as constant.
		jsr 	CheckRightBracket
		;
		plp 								; function back.
		lda 	#NSBIsReference+NSTInteger+1 ; 1 byte read
		bcc 	_DPUpdate
		inc 	a 							; 2 byte read
_DPUpdate:
		sta 	NSStatus,x 					; set to 1/2 byte reference.
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
