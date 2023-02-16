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
		bcs 	CSErrorHandler 				; error, so fail.
		sta 	BasicFileStream 			; save the reading stream.

		.cresetcodepointer 					; prepare to loop through code.
_CSLoop:
		.cget0 								; any more ?
		beq 	_CSExit
		jsr 	CSGetCleanLine
		sty 	zTemp0+1 					; save write address of data
		sta 	zTemp0
		jsr 	CLWriteByteBlock 			; write the block out.
		.cnextline 							; go to next line.
		bra 	_CSLoop

_CSExit:
		lda 	BasicFileStream 			; close file
		jsr 	KNLCloseFile
		jsr 	CLComplete 					; display complete message.
		jmp 	WarmStart 					; and warm start

CSErrorHandler:
		jmp 	CLErrorHandler


; ************************************************************************************************
;
;					Write X bytes out to BasicFileStream from zTemp0
;
; ************************************************************************************************
		
CLWriteByteBlock:		
		cpx 	#0 							; written the lot ?
		beq 	_CLWBBExit					; if so, exit

		lda 	BasicFileStream 			; stream to write, count in X
		jsr 	KNLWriteBlock 				; call one write attempt
		bcs 	CSErrorHandler 				; error occurred

		sta 	zTemp1 						; save bytes written.

		txa 								; subtract bytes written from X, total count.
		sec
		sbc 	zTemp1
		tax

		clc 								; advance zTemp0 pointer by bytes written.
		lda 	zTemp0
		adc 	zTemp1
		sta 	zTemp0
		bcc 	CLWriteByteBlock
		inc 	zTemp0+1
		bra 	CLWriteByteBlock 			; and retry write out.

_CLWBBExit:
		rts

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
; 		16/02/23 		Changed end to Jsr CLComplete / Jmp Warmstart as was returning to runner
; 						after save.
;
; ************************************************************************************************
