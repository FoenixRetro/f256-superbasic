; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		editor.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	5th October 2022
;		Reviewed :	1st December 2022
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
		;		Delete the line first
		;
		lda 	tokenLineNumber 			; try to find the line.
		ldx 	tokenLineNumber+1
		jsr 	MemorySearch
		bcc 	_EPCNoDelete 				; reached the end : don't delete
		bne 	_EPCNoDelete 				; found slot but didn't match : no delete
		jsr 	MemoryDeleteLine 			; delete the line
_EPCNoDelete:		
		;
		;		Insert the line.
		;
		lda 	tokenBuffer 				; buffer empty - we just want to delete a line.
		cmp 	#KWC_EOL
		beq 	_EPCNoInsert

		lda 	tokenLineNumber 			; find the line - it cannot exist as we've just deleted it.
		ldx 	tokenLineNumber+1 			; so this can't fail, it returns some point in the code.
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
