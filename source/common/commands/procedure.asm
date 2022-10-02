; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		procedure.asm
;		Purpose:	Procedure call/EndProc
;		Created:	2nd October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;				Handed Procedure call from LET. The info on the record is in Stack,X
;
; ************************************************************************************************

CallProcedure:
		jsr 	CheckRightBracket
		
		lda 	#STK_PROC+3 				; allocate 6 bytes on the return stack.
		jsr 	StackOpen 
		jsr 	STKSaveCodePosition 		; save loop position
		;
		lda 	NSMantissa0,x 				; copy variable (e.g. procedure) address to zTemp0
		sta 	zTemp0 						; this is the DATA not the RECORD
		lda 	NSMantissa1,x
		sta 	zTemp0+1
		;
		ldy 	#1 							; copy code address back.
		lda 	(zTemp0)
		sta 	safePtr
		lda 	(zTemp0),y
		sta 	safePtr+1
		iny
		lda 	(zTemp0),y
		sta 	safePtr+2
		iny
		lda 	(zTemp0),y
		sta 	safePtr+3
		iny 								; get Y offset -> Y
		lda 	(zTemp0),y
		tay
		.cresync 							; resync any code pointer stuff
		jsr 	CheckRightBracket 			; check )
		rts 								; and continue from here
		.send code

; ************************************************************************************************
;
;										ENDPROC 
;
; ************************************************************************************************

Command_ENDPROC:	;; [endproc]
		lda 	#STK_PROC 					; check TOS is this
		ldx 	#ERRID_PROC
		jsr 	StackCheckFrame
		jsr 	STKLoadCodePosition 		; restore code position
		jsr 	StackClose
		rts

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
