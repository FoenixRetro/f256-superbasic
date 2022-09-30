; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		print.asm
;		Purpose:	Print (to Screen)
;		Created:	30th September
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;										PRINT statement
;
; ************************************************************************************************

Command_Print:	;; [print]
		clc 								; carry being clear means last print wasn't comma/semicolon
		;
		;		Print Loop
		;
_CPLoop:
		php 								; save last action flag
		.cget 								; get next character
		cmp  	#KWC_EOL 					; end of line or colon, exit now.
		beq 	_CPExit
		cmp 	#KWD_COLON
		beq 	_CPExit
		pla 								; throw last action flag
		;
		;		Decide what's next
		;
		.cget 								; next character and bump
		iny
		cmp 	#KWD_SEMICOLON				; is it a semicolon
		beq 	_CPContinueWithSameLine
		cmp 	#KWD_COMMA 					; comma
		beq 	_CPTab
		cmp 	#KWD_QUOTE 					; apostrophe (new line)
		beq 	_CPNewLine
		dey 								; undo the get.
		ldx 	#0
		jsr 	EvaluateValue 				; get a value into slot 0
		lda 	NSStatus,x 					; is it a number
		and 	#NSBIsString
		beq 	_CPNumber
		;
		ldx 	NSMantissa1 				; string, print the text.
		lda 	NSMantissa0
		jsr 	PrintStringXA
		bra 	Command_Print 				; loop round clearing carry so NL if end		
		;
		;		Print number
		;
_CPNumber:
		lda 	#5 							; maximum decimals
		jsr 	ConvertNumberToString 		; convert to string
		ldx 	#DecimalBuffer >> 8
		lda 	#DecimalBuffer & $FF
		jsr 	PrintStringXA
		bra 	Command_Print 				; loop round clearing carry so NL if end		
		;
		;		New line
		;
_CPNewLine:
		lda 	#13		
		bra 	_CPPrintChar
		;
		;		Comma, Semicolon.
		;
_CPTab:	
		lda 	#9 							; print TAB
_CPPrintChar:
		jsr 	EXTPrintCharacter

_CPContinueWithSameLine:		
		sec 								; loop round with carry set, which
		bra 	_CPLoop 					; will inhibit final CR
		;
		;		Exit
		;
_CPExit:
		plp 								; get last action flag
		bcs 	_CPExit2  					; carry set, last was semicolon or comma
		lda 	#13 						; print new line
		jsr 	EXTPrintCharacter			
_CPExit2:		
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
