; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		def.asm
;		Purpose:	DEFFN / ENDDEF — function definition and return
;		Created:	12th March 2026
;		Author:		Matthias Brukner
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;		DEFFN is encountered during normal execution. The definition is only used when
;		the function is called, so we skip it.
;
;		Single-line:  deffn name(params) = expr   → skip one line
;		Multi-line:   deffn name(params) ... enddef → skip until ENDDEF
;
; ************************************************************************************************

Command_DEFFN: ;; [deffn]
		;
		;		Skip the variable reference (2 bytes: high + low).
		;
		iny
		iny
		;
		;		Skip the parameter list: ( [var, var, ...] )
		;		Each parameter is a 2-byte variable reference, separated by commas.
		;
		iny 								; skip '('
		.cget
		cmp 	#KWD_RPAREN
		beq 	_CDAtRParen 				; no parameters
_CDParamLoop:
		iny 								; skip param var ref high
		iny 								; skip param var ref low
		.cget
		cmp 	#KWD_RPAREN
		beq 	_CDAtRParen
		iny 								; skip comma
		bra 	_CDParamLoop
_CDAtRParen:
		iny 								; skip ')'
		;
		;		Check for single-line (= expr) or multi-line definition.
		;
		.cget
		cmp 	#KWD_EQUAL
		beq 	_CDSingleLine
		;
		;		Multi-line: scan forward for matching ENDDEF (handles nested DEFFN).
		;
		lda 	#KWD_ENDDEF
		tax
		jsr 	ScanForward
		; Fall through to skip past the ENDDEF line.
_CDSingleLine:
		.cnextline 							; skip past definition/ENDDEF line
		rts

; ************************************************************************************************
;
;		ENDDEF — return from a multi-line function (VBA-style).
;
;		Two forms:
;		  enddef expr  — evaluate expression and return its value
;		  enddef       — return zero (bare block closer)
;
;		Assign to the function name variable to set the return value:
;		  deffn absval(x)
;		    if x < 0
;		      absval = -x
;		    else
;		      absval = x
;		    endif
;		  enddef absval
;
; ************************************************************************************************

Command_ENDDEF: ;; [enddef]
		lda 	fnNestLevel
		beq 	_EDSyntax 					; ENDDEF outside a function body
		;
		;		Restore fnStackLevel and outer fnSavedSP from the nesting stacks.
		;
		dec 	fnNestLevel
		ldx 	fnNestLevel
		lda 	fnStackLevelStack,x
		sta 	fnStackLevel
		lda 	fnSavedSPStack,x
		sta 	fnOuterSavedSP 				; save old fnSavedSP (zTemp0 gets clobbered)
		;
		;		Check for bare ENDDEF (no expression) vs ENDDEF expr.
		;
		.cget
		cmp 	#KWC_EOL
		beq 	_EDReturnZero
		cmp 	#KWD_COLON
		beq 	_EDReturnZero
		;
		;		ENDDEF expr: evaluate the return expression (locals still in scope).
		;
		ldx 	fnStackLevel
		jsr 	EvaluateValue 				; result at stack[fnStackLevel]
		bra 	_EDUnwind
		;
		;		Bare ENDDEF: return zero.
		;
_EDReturnZero:
		ldx 	fnStackLevel
		stz 	NSMantissa0,x
		stz 	NSMantissa1,x
		stz 	NSMantissa2,x
		stz 	NSMantissa3,x
		stz 	NSExponent,x
		stz 	NSStatus,x
		;
		;		Unwind the BASIC stack: pop locals and discard any control structure
		;		frames (FOR, WHILE, REPEAT) until we reach the PROC frame.
		;
_EDUnwind:
		lda 	(basicStack) 				; TOS marker
		cmp 	#STK_LOCALN
		beq 	_EDPopLocal
		cmp 	#STK_LOCALS
		beq 	_EDPopLocal
		;
		;		Check if this is the PROC frame (upper nibble $B0).
		;
		eor 	#STK_PROC
		and 	#$F0
		beq 	_EDAtProc
		;
		;		Some other frame (FOR, WHILE, REPEAT, GOSUB) — discard it.
		;
		jsr 	StackClose
		bra 	_EDUnwind
_EDPopLocal:
		jsr 	LocalPopValue 				; restore the local variable value
		bra 	_EDUnwind
_EDAtProc:
		;
		;		At the PROC frame. Restore code position and close it.
		;
		jsr 	STKLoadCodePosition 		; restore code pointer to after fn(...)
		jsr 	StackClose 					; release the PROC frame
		;
		;		Restore hardware SP and outer fnSavedSP, then return.
		;
		ldx 	fnSavedSP 					; current function's entry SP
		lda 	fnOuterSavedSP
		sta 	fnSavedSP 					; restore for outer function
		txs 								; restore hardware stack
		ldx 	fnStackLevel 				; X = result stack level
		rts 								; return to expression evaluator

_EDSyntax:
		jmp 	SyntaxError

		.send code
