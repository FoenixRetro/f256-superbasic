m; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		verify.asm
;		Purpose:	VERIFY command
;		Created:	1st January 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;									VERIFY a Basic file
;
; ************************************************************************************************

		.section code

Command_VERIFY: ;; [VERIFY]
		jsr 	EvaluateString 				; file name to verify

		ldx 	zTemp0+1					; zTemp0 -> XA
		lda 	zTemp0 
		jsr 	KNLOpenFileRead 			; open file for reading
		bcs 	_CVErrorHandler 			; error, so fail.
		sta 	BasicFileStream 			; save the reading stream.
		jsr     LoadReadByteInit            ; Init reader with the stream
		stz 	LoadEOFFlag 				; clear EOF Flag.
		.cresetcodepointer 					; prepare to loop through code.

_CVLoop:
		jsr 	LoadReadLine 				; get next line.
		beq 	_CVExit 					; end, exit.

		jsr 	TKTokeniseLine 				; tokenise the line.

		lda 	tokenLineNumber 			; line number = 0
		ora 	tokenLineNumber+1
		beq 	_CVLoop 					; not legal code, blank line or maybe a comment.

		ldy 	#0 							; start compare
_CVCompareLoop:
		.cget 								; tokenised code
		cmp 	tokenOffset,y 				; compare against actual code.
		bne 	_CVCompareError
		iny
		cpy 	tokenOffset 				; until done whole line of code
		bne 	_CVCompareLoop

		.cnextline 							; go to next line.
		bra 	_CVLoop

_CVExit:			
		lda 	BasicFileStream
		jsr 	KNLCloseFile
		jmp 	CLComplete

_CVCompareError:
		.error_verify

_CVErrorHandler:
		jmp 	CLErrorHandler

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
