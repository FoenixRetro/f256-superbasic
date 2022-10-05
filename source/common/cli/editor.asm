; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		editor.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		5th October 2022
;		Reviewed :	No
;		Purpose :	Process token buffer for editor
;
; ***************************************************************************************
; ***************************************************************************************

		.section code

; ***************************************************************************************
;
;			Using the tokenised data in the token buffer, insert/delete code
;
; ***************************************************************************************

EditProgramCode:
		.debug

;		lda 	#TokenBuffer & $FF
;		ldx 	#TokenBuffer >> 8
;		jsr 	MDLDeleteLine
;		;
;		lda 	TokenBuffer 				; if offset is 4 (offset, lo, high , EOL)
;		cmp 	#4
;		beq 	_WSECExit 					; then it's delete only.
;		lda 	#TokenBuffer & $FF
;		ldx 	#TokenBuffer >> 8
;		jsr 	MDLInsertLine 				; insert the new line.
;_WSECExit:
;		jsr 	MDLClose
		rts
	
		.send code

; ***************************************************************************************
;
;									Changes and Updates
;
; ***************************************************************************************
;
;		Date			Notes
;		==== 			=====
;
; ***************************************************************************************
