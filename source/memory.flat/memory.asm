; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		memory.asm
;		Purpose:	BASIC program space manipulation
;		Created:	19th September 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;									Erase the current program
;
; ************************************************************************************************

MemoryNew:
		.resetCodePointer 					; point to start of program memory
		lda 	#0 							; write zero there erasing the program.
		.cset0	
		rts

; ************************************************************************************************
;
;								Append tokenised line to program
;
; ************************************************************************************************

MemoryAppend:
		.resetCodePointer 					; point to start of program memory
_MAFindEnd:
		lda 	(codePtr)
		beq 	_MAFoundEnd
		.cnextline
		bra 	_MAFindEnd
_MAFoundEnd:		
		ldy 	tokenOffset 				; bytes to copy
		cpy 	#4 							; blank line
		beq 	_MANoLine
		lda 	#0 							; end of program
		sta 	(codePtr),y				
_MACopy:
		dey
		lda 	tokenOffset,y
		sta 	(codePtr),y
		cpy 	#0
		bne 	_MACopy
_MANoLine:			
		rts
		
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
