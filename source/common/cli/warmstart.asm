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
		jsr 	ResetIOTracking 			; reset the I/O tracking.
		jsr 	EXTInputLine 				; get line to lineBuffer
		jsr 	TKTokeniseLine 				; tokenise the line
		;
		;		Decide whether editing or running
		;
		lda 	tokenLineNumber 			; line number <> 0
		ora 	tokenLineNumber+1
		bne 	_WSEditCode 				; if so,edit code.
		;
		;		Run code in token buffer
		;		
		stz 	tokenOffset 				; zero the "offset", meaning it only runs one line.
		.csetcodepointer tokenOffset		; set up the code pointer.
		lda 	tokenBuffer 				; nothing to run
		cmp 	#KWC_EOL
		beq 	WarmStart
		jsr 	RUNCodePointerLine 			; execute that line.
		bra 	WarmStart
		;
		;		Editing code in token buffer.
		;
_WSEditCode:
		jsr 	EditProgramCode 			; edit the program code 
		jsr 	ClearSystem 				; clear all variables etc.
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
