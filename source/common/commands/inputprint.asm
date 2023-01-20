; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		inputprint.asm 
;		Purpose:	Print (to Screen) / Input (from keyboard)
;		Created:	30th September 2022
;		Reviewed: 	28th November 2022
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;									INPUT/PRINT statement
;
;		These operate identically *except* when a variable is found, when it is INPUT or PRINT
; 		respectively. All I/O goes through two vectors.
;
; ************************************************************************************************

Command_Input:  ;; [input]
		stz 	isPrintFlag
		bra 	Command_IP_Main

Command_CPrint:	;; [cprint]
		lda 	#$7F 						; set input flag to character mode
		sta 	isPrintFlag 				; clear input flag
		bra 	Command_IP_Main

Command_Print:	;; [print]
		lda 	#$FF 						; set input flag
		sta 	isPrintFlag 				; clear input flag
		;
Command_IP_Main:		
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
		jsr 	EvaluateExpressionAt0 		; evaluate expression at 0.
		lda 	NSStatus,x 					; read the status
		and 	#NSBIsReference 			; is it a reference
		beq 	_CPIsValue 					; no, display it.
		;
		lda 	isPrintFlag 				; if print, dereference and print.
		bne 	_CPIsPrint 					; otherwise display.
		jsr 	CIInputValue 				; input a value to the reference
		bra 	_CPNewLine

_CPIsPrint:
		jsr 	Dereference 				; dereference if required.
_CPIsValue:
		lda 	NSStatus,x 					; is it a number
		and 	#NSBIsString
		beq 	_CPNumber
		;
		ldx 	NSMantissa1 				; string, print the text.
		lda 	NSMantissa0
		jsr 	CPPrintStringXA
		bra 	Command_IP_Main 			; loop round clearing carry so NL if end		
		;
		;		Print number
		;
_CPNumber:
		lda 	#5 							; maximum decimals
		jsr 	ConvertNumberToString 		; convert to string (in unary str$() function)
		ldx 	#decimalBuffer >> 8
		lda 	#decimalBuffer & $FF
		jsr 	CPPrintStringXA 			; print it.
		bra 	Command_IP_Main				; loop round clearing carry so NL if end		
		;
		;		New line
		;
_CPNewLine:
		lda 	#13		
		bra 	_CPPrintCharDirect
		;
		;		Comma, Semicolon.
		;
_CPTab:	
		lda 	#9 							; print TAB
_CPPrintCharDirect:
		jsr 	CPPVControl 				; print TAB/CR using the non PETSCII 

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
		jsr 	CPPVControl
_CPExit2:		
		rts

; ************************************************************************************************
;
;								Input to reference at level 0
;
; ************************************************************************************************

CIInputValue:
		ldx 	#0 							; input a line.
_CIInputLine:
		jsr 	CPInputVector 				; get key
		cmp 	#13 						; 13 = End
		beq 	_CIHaveValue
		cmp 	#8 							; 8 = BS
		beq 	_CIBackspace 
		cmp 	#32 						; ignore other control characters
		bcc 	_CIInputLine
		cpx 	#80 						; max length
		bcs 	_CIInputLine
		sta 	lineBuffer,x
		inx
		jsr 	EXTPrintCharacter 			; echo it.
		bra 	_CIInputLine
		;
_CIBackspace:
		cpx 	#0 							; nothing to delete
		beq 	_CIInputLine
		jsr 	EXTPrintCharacter 			; echo it.
		dex
		bra 	_CIInputLine
		;
_CIHaveValue:
		stz 	lineBuffer,x 				; ASCIIZ string now in line buffer.
		lda 	NSStatus 					; was it a string assignment
		and 	#NSBIsString 				
		beq 	_CIAssignNumber 			; assign a number
		;
		;		Assign string
		;
		ldx 	#1
		lda 	#lineBuffer & $FF 			; set up to point to new string
		sta 	NSMantissa0,x 				
		lda 	#lineBuffer >> 8
		sta 	NSMantissa1,x
		stz 	NSMantissa2,x
		stz 	NSMantissa3,x
		lda 	#NSBIsString 				; so it becomes a string value
		sta  	NSStatus,x	
		dex 								; X = 0
		jsr 	AssignVariable
		rts
		;
		;		Assign number
		;
_CIAssignNumber:		
		lda 	#lineBuffer & $FF 			; set up to point to new string
		sta 	zTemp0
		lda 	#lineBuffer >> 8
		sta 	zTemp0+1
		ldx 	#1 							; put in slot 1
		jsr 	ValEvaluateZTemp0 			; use the VAL() code
		bcc 	_CIIsOkay
		lda 	#"?" 						; error ?
		jsr 	CPPrintVector
		bra 	CIInputValue

_CIIsOkay:		
		dex 								; X = 0
		jsr 	AssignVariable
		rts

; ************************************************************************************************
;
;								Vectorable Print String
;
; ************************************************************************************************

CPPrintStringXA:
		phy
		stx 	zTemp0+1
		sta 	zTemp0
		ldy 	#0
_PSXALoop:
		lda 	(zTemp0),y
		beq 	_PSXAExit
		jsr 	CPPrintVector
		iny
		bra 	_PSXALoop
_PSXAExit:
		ply
		rts		

; ************************************************************************************************
;
;								Vectorable Print Character
;
; ************************************************************************************************

CPPrintVector:
		bit 	isPrintFlag 				; check if char only mode and call appropriate handler.
		bmi 	CPPVControl
		jmp 	EXTPrintNoControl
CPPVControl:		
		jmp 	EXTPrintCharacter

CPInputVector:
		jmp 	KNLGetSingleCharacter

		.send code

; ************************************************************************************************
;
;									Changes and Updates
;
; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;		01/01/23 		isInputFlag => isPrintFlag. Added CPrint command using that to detect
;						print type.
;		08/01/23 		When inputting a string, the CPRINT routine was called causing the
;						Backspace to display a solid block.
;
; ************************************************************************************************
