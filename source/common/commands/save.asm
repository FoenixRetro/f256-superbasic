; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		save.asm
;		Purpose:	SAVE command
;		Created:	31st December 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;									SAVE a Basic file
;
; ************************************************************************************************

		.section code

Command_Save: ;; [SAVE]
		jsr 	EvaluateString 				; file name to load

		ldx 	zTemp0+1					; zTemp0 -> XA
		lda 	zTemp0 
		jsr 	KNLOpenFileWrite 			; open file for writing
		bcs 	_CSErrorHandler 			; error, so fail.
		sta 	CurrentFileStream 			; save the reading stream.

		ldx 	#$80
		stx 	zTemp0+1
		stz 	zTemp0
		ldx 	#32
		lda 	CurrentFileStream
		jsr 	KNLWriteBlock

		lda 	CurrentFileStream 			; close file
		jsr 	KNLCloseFile

		jmp 	CLComplete 					; display complete message.

_CSErrorHandler:
		jmp 	CLErrorHandler

		.send 	code

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
