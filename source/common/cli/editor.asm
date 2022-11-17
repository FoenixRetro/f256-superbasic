; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		editor.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	5th October 2022
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
		;
		;		Delete first
		;
		lda 	TokenLineNumber 			; find the line.
		ldx 	TokenLineNumber+1
		jsr 	MemorySearch
		bcc 	_EPCNoDelete 				; reached the end don't delete
		bne 	_EPCNoDelete 				; found slot but didn't match, no delete
		jsr 	MemoryDeleteLine 			; delete the line
_EPCNoDelete:		
		;
		;		Insert the line.
		;
		lda 	TokenBuffer 				; buffer empty
		cmp 	#KWC_EOL
		beq 	_EPCNoInsert

		lda 	TokenLineNumber 			; find the line - it cannot exist.
		ldx 	TokenLineNumber+1 			; so this can't fail, it returns some point in the code.
		jsr 	MemorySearch
		clc 								; insert at this point.
		jsr 	MemoryInsertLine 			; insert the line
_EPCNoInsert:
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
