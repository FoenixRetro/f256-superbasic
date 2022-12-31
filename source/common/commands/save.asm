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

		.cresetcodepointer 					; prepare to loop through code.
_CSLoop:
		.cget0 								; any more ?
		beq 	_CSExit
		jsr 	CSGetCleanLine
		sty 	zTemp0+1 					; save write address of data
		sta 	zTemp0
		lda 	CurrentFileStream 			; stream to write, count already in X
		jsr 	KNLWriteBlock 				; write it out.
		; 
		.cnextline 							; go to next line.
		bra 	_CSLoop

_CSExit:
		lda 	CurrentFileStream 			; close file
		jsr 	KNLCloseFile

		jmp 	CLComplete 					; display complete message.

_CSErrorHandler:
		jmp 	CLErrorHandler

; ************************************************************************************************
;
;					Strip control codes from tokenised line, append CR, len in X
;
; ************************************************************************************************

CSGetCleanLine:
		lda 	#0 							; no indent.
		jsr 	TKListConvertLine 			; convert line into token Buffer

		ldx 	#0 							; copy stripping controls.
		ldy 	#0
_CSClean:
		lda 	tokenBuffer,y
		beq 	_CSDoneClean
		bmi 	_CSIgnoreCharacter
		sta 	lineBuffer,x
		inx
_CSIgnoreCharacter:
		iny
		bra 	_CSClean		
_CSDoneClean:
		lda 	#13 						; add CR, length now in X and ASCIIZ.
		sta 	lineBuffer,x
		inx
		stz 	lineBuffer,x

		ldy 	#(lineBuffer >> 8) 			; line address in YA
		lda 	#(lineBuffer & $FF) 	
		rts

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
