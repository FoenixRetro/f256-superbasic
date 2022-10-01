; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		repeat.asm
;		Purpose:	Repeat/Until loops
;		Created:	1st October 2022
;		Reviewed: 	
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;										WHILE command
;
; ************************************************************************************************

Command_WHILE:	;; [while]
		phy 								; save position of the test
		;
		ldx 	#0
		jsr 	EvaluateNumber 				; work out the number
		jsr 	NSMIsZero 					; check if zero
		beq 	_WHExitLoop 				; if so exit the loop
		;
		;		Test passed, so push the loop position (pre-number) on the stack.
		;
		tya 								; position *after* test.
		ply 								; restore position before test, at WHILE
		dey
		pha 								; push after test on the stack

		lda 	#STK_WHILE+3 				; allocate 6 bytes on the return stack.
		jsr 	StackOpen 
		jsr 	STKSaveCodePosition 		; save loop position - where the test value is.

		ply 								; restore the position *after* the test
		rts
		;
		;		End the while loop, so scan forward past the matching WEND.
		;
_WHExitLoop:
		pla 								; throw post loop position
		lda 	#KWD_WEND 					; scan forward past WEND
		tax
		jsr 	ScanForward
		rts

; ************************************************************************************************
;
;										WEND command
;
; ************************************************************************************************

Command_WEND:	;; [wend]
		lda 	#STK_WHILE+3 				; check WHILE is TOS
		ldx 	#ERRID_WHILE 				; this error
		jsr 	StackCheckFrame
		jsr 	STKLoadCodePosition 		; loop back
		jsr 	StackClose		 			; erase the frame
		rts

		.send code

; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;
; ************************************************************************************************
