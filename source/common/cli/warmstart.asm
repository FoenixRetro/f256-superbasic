; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		warmstart.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	5th October 2022
;		Reviewed :	1st December 2022
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
		lda 	#CLICommandLine+$80 		; set console colour whatever the current colour is.
		jsr 	EXTPrintCharacter
		jsr 	EXTInputLine 				; get line to lineBuffer
		jsr 	TKTokeniseLine 				; tokenise the line
		;
		;		Decide whether editing or running
		;
		lda 	TokenLineNumber 			; line number <> 0
		ora 	TokenLineNumber+1
		bne 	_WSEditCode 				; if so,edit code.
		;
		;		Run code in token buffer
		;		
		stz 	TokenOffset 				; zero the "offset", meaning it only runs one line.
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
		jsr 	EditProgramCode 			; edit the program code 
		jsr 	ClearCommand 				; clear all variables etc.
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
;		26/11/22 		Added code to set console colour when typing in commands.
;
; ***************************************************************************************
