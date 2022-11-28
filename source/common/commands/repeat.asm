; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		repeat.asm
;		Purpose:	Repeat/Until loops
;		Created:	1st October 2022
;		Reviewed: 	28th November 2022
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;										REPEAT command
;
; ************************************************************************************************

Command_REPEAT:	;; [repeat]
		lda 	#STK_REPEAT+3 				; allocate 6 bytes on the return stack.
		jsr 	StackOpen 
		jsr 	STKSaveCodePosition 		; save loop position
		rts

; ************************************************************************************************
;
;										UNTIL command
;
; ************************************************************************************************

Command_UNTIL:	;; [until]
		lda 	#STK_REPEAT+3 				; check REPEAT is TOS
		ldx 	#ERRID_REPEAT 				; this error
		jsr 	StackCheckFrame
		ldx 	#0
		jsr 	EvaluateNumber 				; work out the number
		jsr 	NSMIsZero 					; check if zero
		beq 	_CULoopBack 				; if so keep looping
		jsr 	StackClose		 			; return
		rts

_CULoopBack:		
		jsr 	STKLoadCodePosition 		; loop back
		rts

		.send code

; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;
; ************************************************************************************************
