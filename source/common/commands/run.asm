; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		run.asm
;		Purpose:	Run Program
;		Created:	22nd September 2022
;		Reviewed: 	27th November 2022
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

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
;								Run Program (optional load)
;
; ************************************************************************************************

CommandRUNOptLoad:	;; [run]
		.cget 								; what follows
		cmp 	#KWC_EOL 					; EOL / : just RUN
		beq 	RunCurrentProgram
		cmp 	#KWD_COLON
		beq 	RunCurrentProgram
		jsr 	LoadFile 					; load expected name file.

; ************************************************************************************************
;
;							    Run program with current code
;
; ************************************************************************************************

RunCurrentProgram:
		jsr 	ClearSystem 				; clear variable/stacks/etc.
		.cresetcodepointer 					; set code address to start

		; ----------------------------------------------------------------------------------------
		;
		;		New line comes here		
		;
		; ----------------------------------------------------------------------------------------
		
RunNewLine:		
		.cget0 								; is there any more program to run ?
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
		.breakcheck							; break check
		bne 	_CRBreak
		.tickcheck TickHandler  			; if time elapsed call the tick handler.
_CRNoBreakCheck:		
		; 									
		iny									; next token
_CRMainLoop:
		stz 	stringInitialised 			; clear the temporary string initialised flag.
		.cget 				 				; get next command to execute.
		bpl 	_CRNotKeyword				; not a token.
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
		cmp 	#KWD_AT 					; handle @ 
		beq 	_CRGoLet
		cmp 	#KWD_QMARK 					; handle ? !
		beq 	_CRGoLet
		cmp 	#KWD_PLING
		beq 	_CRGoLet
		cmp 	#KWD_QUOTE 					; handle ' (comment)
		beq 	_CRGoRem
		cmp 	#KWD_PERIOD 				; handle . (assembler label)
		bne 	_CRSyntaxError
		jsr 	LabelHere
		bra 	_CRMainLoop
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

_CRBreak:
		.error_break
		
CRNoProgram:
		jmp 	EndCommand
		

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

; ************************************************************************************************		
;
;										Vectors
;
; ************************************************************************************************		

		.align 2
		.include "../generated/vectors.dat"

		.send code

; ************************************************************************************************
;
;									Changes and Updates
;
; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;		27/11/22 		Break check was not being reset, checked every time. Added dec
;						instruction making it $FF => 8 more fails.
;		02/01/23 		Break check call now a macro.
;		18/01/23 		Can now RUN "program"
;
; ************************************************************************************************
