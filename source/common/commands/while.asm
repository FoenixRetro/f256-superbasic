; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		while.asm
;		Purpose:	While Wend loop
;		Created:	1st October 2022
;		Reviewed: 	1st December 2022
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
		ldx 	#0 							; work out the while test.
		jsr 	EvaluateNumber 				
		jsr 	NSMIsZero 					; check if zero
		beq 	_WHExitLoop 				; if so exit the loop, while has failed.
		;
		;		Test passed, so push the loop position (pre-number) on the stack.
		;
		tya 								; position *after* test.
		ply 								; restore position before test, at WHILE
		dey 								; so we execute the WHILE command again.
		pha 								; push after test on the stack

		lda 	#STK_WHILE+3 				; allocate 6 bytes on the return stack.
		jsr 	StackOpen 
		jsr 	STKSaveCodePosition 		; save loop position - where the test value expr is.

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
		lda 	#STK_WHILE+3 				; check WHILE is TOS e.g. in a while loop :)
		ldx 	#ERRID_WHILE 				; this error if not.
		jsr 	StackCheckFrame
		jsr 	STKLoadCodePosition 		; loop back to the WHILE keyword.
		jsr 	StackClose		 			; erase the frame
		rts

		.send code

; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;
; ************************************************************************************************
