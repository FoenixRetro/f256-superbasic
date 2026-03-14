; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		def.asm
;		Purpose:	FN / ENDFN / PROC skip — function definition and return
;		Created:	12th March 2026
;		Author:		Matthias Brukner
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;		FN and PROC are encountered during normal execution. The definitions are
;		only used when called, so we skip them.
;
;		Single-line:  fn name(params) = expr     → skip one line
;		Multi-line:   fn name(params) ... endfn  → skip until ENDFN
;		Procedure:    proc name(params) ... endproc → skip until ENDPROC
;
; ************************************************************************************************

Command_FN: ;; [fn]
		ldx 	#KWD_ENDFN 					; scan for ENDFN
		bra 	SkipDefinition

Command_PROC: ;; [proc]
		ldx 	#KWD_ENDPROC 				; scan for ENDPROC

; ************************************************************************************************
;
;		Shared skip logic for PROC and FN definitions encountered during execution.
;		X = closing token to scan for (KWD_ENDPROC or KWD_ENDFN).
;
; ************************************************************************************************

SkipDefinition:
		;
		;		Skip the variable reference (2 bytes: high + low).
		;
		iny
		iny
		;
		;		Skip the parameter list and closing ')'.
		;
		jsr 	SkipParamList
		;
		;		Check for single-line (= expr) or multi-line definition.
		;
		.cget
		cmp 	#KWD_EQUAL
		beq 	_CDSingleLine
		;
		;		Multi-line: scan forward for matching closing token.
		;
		txa
		jsr 	ScanForward
		; Fall through to skip past the closing line.
_CDSingleLine:
		.cnextline 							; skip past definition line
		jmp 	RunNewLine 					; reset Y and enter command loop

; ************************************************************************************************
;
;		ENDFN — bare block closer for a multi-line function.
;
;		Always returns zero (ENDFN is at EOL, so FunctionReturnWithExpr's .cget
;		sees KWC_EOL and takes the return-zero path). Use RETURN expr to return
;		a value explicitly.
;
; ************************************************************************************************

Command_ENDFN: ;; [endfn]
		lda 	fnNestLevel
		bne 	FunctionReturnWithExpr 		; inside function body → return
		jmp 	SyntaxError 				; ENDFN outside a function body

; ************************************************************************************************
;
;		FunctionReturnWithExpr — entered from Command_RETURN when fnNestLevel > 0,
;		or fallen into from Command_ENDFN.
;
;		Evaluate the expression after RETURN and return it as the function result.
;		Bare RETURN (or ENDFN at EOL) returns zero.
;
; ************************************************************************************************

FunctionReturnWithExpr:
		;
		;		Read fnStackLevel WITHOUT decrementing fnNestLevel yet.
		;		This protects the nesting stack slot from being overwritten
		;		if the return expression triggers a recursive call.
		;
		ldx 	fnNestLevel
		lda 	fnStackLevelStack-1,x 		; stack[fnNestLevel-1]
		sta 	fnStackLevel
		;
		;		Check for bare RETURN (no expression) vs RETURN expr.
		;
		.cget
		cmp 	#KWC_EOL
		beq 	_FRReturnZero
		cmp 	#KWD_COLON
		beq 	_FRReturnZero
		;
		;		RETURN expr: evaluate the return expression (locals still in scope).
		;		Re-read fnStackLevel from the nesting stack after EvaluateValue
		;		because recursive function calls will overwrite it.
		;
		ldx 	fnStackLevel
		jsr 	EvaluateValue 				; result at stack[fnStackLevel]
		ldx 	fnNestLevel
		lda 	fnStackLevelStack-1,x 		; re-read stack[fnNestLevel-1]
		sta 	fnStackLevel
		tax 								; X = fnStackLevel for string check
		;
		;		If the result is a string, copy it to temp storage before
		;		unwinding locals — otherwise LocalPopValue will overwrite the
		;		string data that the result points to.
		;
		lda 	NSStatus,x
		and 	#NSBTypeMask
		cmp 	#NSTString
		bne 	_FRDecUnwind
		jsr 	FRCopyString
		bra 	_FRDecUnwind
		;
		;		Bare RETURN: return zero.
		;
_FRReturnZero:
		ldx 	fnStackLevel
		jsr 	NSMSetZero
_FRDecUnwind:
		dec 	fnNestLevel 				; NOW safe to decrement

; ************************************************************************************************
;
;		FunctionReturnUnwind — shared unwind logic for ENDFN and RETURN.
;
;		Unwind the BASIC stack: pop locals and discard any control structure
;		frames (FOR, WHILE, REPEAT) until we reach the PROC frame.
;
; ************************************************************************************************

FunctionReturnUnwind:
		lda 	(basicStack) 				; TOS marker
		cmp 	#STK_LOCALS+1 				; STK_LOCALN=$01, STK_LOCALS=$02
		bcc 	_FRPopLocal 				; < 3 means it's a local variable save
		;
		;		Check if this is the PROC frame (upper nibble $B0).
		;
		eor 	#STK_PROC
		and 	#$F0
		beq 	_FRAtProc
		;
		;		Some other frame (FOR, WHILE, REPEAT, GOSUB) — discard it.
		;
		jsr 	StackClose
		bra 	FunctionReturnUnwind
_FRPopLocal:
		jsr 	LocalPopValue 				; restore the local variable value
		bra 	FunctionReturnUnwind
_FRAtProc:
		;
		;		At the PROC frame. Restore code position and close it.
		;
		jsr 	STKLoadCodePosition 		; restore code pointer to after fn(...)
		jsr 	StackClose 					; release the PROC frame
		;
		;		Restore hardware SP and fnSavedSP, then pop the caller's
		;		eval stack entries from the hardware stack.
		;
		sty 	zTemp0 						; save code position Y (restored by STKLoadCodePosition)
		ldx 	fnSavedSP 					; current function's entry SP
		ldy 	fnNestLevel
		lda 	fnSavedSPStack,y 			; outer fnSavedSP from nesting stack
		sta 	fnSavedSP 					; restore for outer function
		txs 								; restore hardware stack
		ldy 	zTemp0 						; restore code position Y
		;
		;		Pop saved eval stack entries (pushed by _FCMultiLine).
		;		After txs, SP is right below the saved data.
		;
		ldx 	#0
_FRRestoreLoop:
		cpx 	fnStackLevel
		beq 	_FRDoneRestore
		pla
		sta 	NSStatus,x
		pla
		sta 	NSExponent,x
		pla
		sta 	NSMantissa3,x
		pla
		sta 	NSMantissa2,x
		pla
		sta 	NSMantissa1,x
		pla
		sta 	NSMantissa0,x
		inx
		bra 	_FRRestoreLoop
_FRDoneRestore:
		rts 								; X = fnStackLevel, return to expression evaluator

; ************************************************************************************************
;
;		FRCopyString — copy the string result at S[X] to temp storage.
;
;		Measures the ASCIIZ string at NSMantissa0/1, allocates temp space,
;		and copies the bytes. X is preserved.
;
; ************************************************************************************************

FRCopyString:
		phy
		lda 	NSMantissa0,x 				; source address → zTemp0
		sta 	zTemp0
		lda 	NSMantissa1,x
		sta 	zTemp0+1
		;
		ldy 	#$FF 						; measure string length
_FRCSLen:
		iny
		lda 	(zTemp0),y
		bne 	_FRCSLen
		;
		tya 								; A = length
		jsr 	StringTempAllocate 			; allocate temp space, sets zsTemp
		;
		;		Copy source string including the null terminator.
		;
		ldy 	#0
_FRCSCopy:
		lda 	(zTemp0),y 					; copy byte from source
		sta 	(zsTemp),y
		beq 	_FRCSDone 					; copied the null terminator
		iny
		bra 	_FRCSCopy
_FRCSDone:
		ply
		rts

; ************************************************************************************************
;
;		SkipParamList — skip a parameter list in the token stream.
;
;		Entry:	Y points at the first parameter variable (or ')' if none).
;		Exit:	Y points past the closing ')'.
;
; ************************************************************************************************

SkipParamList:
		.cget
		cmp 	#KWD_RPAREN
		beq 	_SPLAtRParen 				; no parameters
_SPLLoop:
		iny 								; skip param var ref high
		iny 								; skip param var ref low
		.cget
		cmp 	#KWD_RPAREN
		beq 	_SPLAtRParen
		iny 								; skip comma
		bra 	_SPLLoop
_SPLAtRParen:
		iny 								; skip ')'
		rts

		.send code
