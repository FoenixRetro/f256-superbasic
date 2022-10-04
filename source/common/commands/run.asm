; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		run.asm
;		Purpose:	Run Program
;		Created:	22nd September 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;										Run Program
;
; ************************************************************************************************

CommandRUN:	;; [run]
		jsr 	ClearCommand 				; clear variable/stacks/etc.
		.resetCodePointer 					; set code address to start

		; ----------------------------------------------------------------------------------------
		;
		;		New line comes here		
		;
		; ----------------------------------------------------------------------------------------
		
RUNNewLine:		
		.cget0 								; is there any program to run ?
		beq 	CRNoProgram         		; no then END.
		ldx 	#$FF 						; reset stack
		txs
		;
		;		Run a line from here.
		;
RUNCodePointerLine:		
		ldy 	#2 							; start of program
		
		; ----------------------------------------------------------------------------------------
		;
		; 		Main run loop, with/without preincrementing
		;
		; ----------------------------------------------------------------------------------------

_CRIncMainLoop:
		iny		
_CRMainLoop:
		stz 	stringInitialised 			; clear the temporary string initialised flag.
		.cget 				 				; get next command to execute.
		bpl 	_CRNotKeyword
		cmp 	#KWC_LAST_UNARY+1 			; if after unary, legitimate command
		bcs 	_CRIsKeyword
		cmp 	#KWC_FIRST_UNARY 			; if unary, syntax error.
		bcs		_CRSyntaxError
_CRIsKeyword:		
		iny 								; consume command
		asl 	a 							; double losing the MSB which is '1' as tokens are $80-$FF
		tax 								; put in X for vector jump
		jsr 	_CRCallVector0 				; call the vector - effectively jsr (vectortable,X)
		bra 	_CRMainLoop 				; and loop round

		; ----------------------------------------------------------------------------------------
		;
		;		Not a keyword - it's a punctuation operator *or* a variable reference.
		;
		; ----------------------------------------------------------------------------------------

_CRNotKeyword:		
		cmp 	#KWD_COLON 					; if a :, consume it and go round.
		beq 	_CRIncMainLoop	
		cmp 	#$40 						; variable/call reference
		bcc 	_CRNotVariable
;
;		Implied LET
;
_CRGoLet:		
		jsr 	LetCommand
		bra 	_CRMainLoop
;
;		Not colon, not a variable
;	
_CRNotVariable:
		cmp 	#KWD_QMARK
		beq 	_CRGoLet
		cmp 	#KWD_PLING
		beq 	_CRGoLet
		cmp 	#KWD_QUOTE
		beq 	_CRGoRem
		.debug
;
;		' synonym for REM
;
_CRGoRem:
		iny
		jsr 	RemCommand
		bra 	_CRMainLoop

_CRSyntaxError:
		jmp 	SyntaxError

_CRCallVector0:
		jmp 	(VectorSet0,x)		

CRNoProgram:
		jmp 	EndCommand
		
; ************************************************************************************************
;
;										End of line Command
;
; ************************************************************************************************

EOLCommand: ;; [!0:EOF0]
		.cnextline
		bra 	RunNewLine

; ************************************************************************************************
;
;										Shift 1/2 commands
;
; ************************************************************************************************

Shift1Command: ;; [!1:SH10]
		.cget 								; get next token
		iny
		asl 	a
		tax
		jmp 	(VectorSet1,x)

Shift2Command: ;; [!2:SH20]
		.cget 								; get next token
		iny
		asl 	a
		tax
		jmp 	(VectorSet2,x)

; ************************************************************************************************
;
;										Unused
;
; ************************************************************************************************		

Unused1: 	;; [proc]
Unused2: 	;; [to]
Unused3: 	;; [downto]
Unused4:	;; [then]
		jmp 	SyntaxError

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