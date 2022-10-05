; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		warmstart.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		5th October 2022
;		Reviewed :	No
;		Purpose :	Main console I/O loop
;
; ***************************************************************************************
; ***************************************************************************************

; ***************************************************************************************
;
;									Warm Start
;
; ***************************************************************************************

		.section code

WarmStart:
		ldx 	#$FF
		txs
		jsr 	EXTInputLine 				; get line to lineBuffer
		jsr 	TokeniseLine 				; tokenise the line
		;
		;		Decide whether editing or running
		;
		lda 	TokenLineNumber 			; line number ?
		ora 	TokenLineNumber+1
		bne 	_WSEditCode 				; if so,edit code.
		;
		;		Run code in token buffer
		;		
		stz 	TokenOffset 				; zero offset, meaning it only runs one line.
		.csetCodePointer TokenOffset		; set up the code pointer.
		lda 	TokenBuffer 				; nothing to run
		cmp 	#KWC_EOL
		beq 	WarmStart
		jsr 	RUNCodePointerLine 			; execute that line.
		bra 	WarmStart
		;
		;		Editing code in token buffer.
		;
_WSEditCode:
		jsr 	EditProgramCode
		jsr 	ClearCommand
		bra 	WarmStart

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
