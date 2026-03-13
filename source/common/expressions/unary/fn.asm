; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		fn.asm
;		Purpose:	Function call handler — invoked from VariableHandler for DEFFN functions
;		Created:	12th March 2026
;		Author:		Matthias Brukner
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;		FunctionCall — called from _VHArray when a function-type variable is detected.
;
;		Entry:	X = stack level (function variable reference at NSMantissa[x])
;				Y = code position (at first argument or `)` in the call)
;
;		The function variable's data area (at NSMantissa) holds the definition's code
;		pointer (4 bytes) and Y offset (1 byte), stored by ProcedureScan.
;
; ************************************************************************************************

FunctionCall:
		stx 	fnStackLevel 				; save stack level for result
		;
		;		Stack the arguments on the evaluation stack.
		;		Start params at fnStackLevel+1 so they don't overlap with the
		;		definition pointer at NSMantissa[fnStackLevel]. Save fnStackLevel
		;		on the hardware stack since nested calls during param eval clobber it.
		;
		phx 								; preserve caller's stack level
		inx 								; params start above function variable
		.cget 								; check for right bracket (no args)
		cmp 	#KWD_RPAREN
		beq 	_FCEndParam
_FCParamLoop:
		jsr 	EvaluateValue 				; get parameter onto stack
		inx 								; bump next stack
		cpx 	#MathStackSize 				; overflow check
		blt 	_FCParamOK
		jmp 	_FCTooManyParam
_FCParamOK:
		.cget 								; get next character
		iny
		cmp 	#KWD_COMMA 					; if comma, loop back for next param
		beq 	_FCParamLoop
		dey 								; unpick
_FCEndParam:
		stx 	lastParameter 				; save last parameter index
		iny 								; skip right bracket
		plx 								; restore caller's stack level
		stx 	fnStackLevel
		;
		;		Read the definition pointer while NSMantissa[fnStackLevel] is intact,
		;		then save the code position on the BASIC stack.
		;
		lda 	NSMantissa0,x 				; copy variable's stored code position to zTemp0
		sta 	zTemp0
		lda 	NSMantissa1,x
		sta 	zTemp0+1
		;
		lda 	#STK_PROC+3 				; allocate a PROC-sized frame (6 bytes)
		jsr 	StackOpen
		jsr 	STKSaveCodePosition 		; save where we are (return point)
		;
		;		Jump to the DEFFN definition.
		;
		ldy 	#1 							; copy code address from record
		lda 	(zTemp0)
		sta 	safePtr
		lda 	(zTemp0),y
		sta 	safePtr+1
		iny
		lda 	(zTemp0),y
		sta 	safePtr+2
		iny
		lda 	(zTemp0),y
		sta 	safePtr+3
		iny 								; get Y offset
		lda 	(zTemp0),y
		tay
		.cresync 							; resync code pointer
		;
		;		Localise parameters (copy from evaluation stack to local variables).
		;
		ldx 	fnStackLevel 				; params started at fnStackLevel + 1
		inx
		cpx 	lastParameter 				; zero parameters?
		beq 	_FCParamsDone
_FCParamExtract:
		dex 								; level before for localise
		jsr 	LocaliseNextTerm 			; push original value to BASIC stack
		jsr 	AssignVariable 				; assign the argument value
		inx 								; next parameter
		inx
		cpx 	lastParameter 				; done?
		beq 	_FCParamsDone
		jsr 	CheckComma 					; comma between params
		bra 	_FCParamExtract
_FCParamsDone:
		jsr 	CheckRightBracket 			; skip ) in DEFFN definition
		;
		;		Check for single-line (= expr) definition.
		;
		.cget
		cmp 	#KWD_EQUAL 					; is there an = sign?
		bne 	_FCMultiLine
		iny 								; skip the =
		;
		;		Single-line: evaluate the function body expression.
		;
		ldx 	fnStackLevel 				; save fnStackLevel on hardware stack
		phx 								; (nested calls may overwrite it)
		jsr 	EvaluateValue 				; this leaves the result at stack[x]
		plx 								; restore fnStackLevel
		stx 	fnStackLevel
		;
		;		Restore: pop locals, restore code position.
		;
		lda 	#STK_PROC 					; check frame type
		ldx 	#ERRID_PROC 				; reuse PROC error ID for mismatch
		jsr 	StackCheckFrame 			; pops all locals, checks frame
		jsr 	STKLoadCodePosition 		; restore code pointer to after fn(...)
		jsr 	StackClose 					; release the stack frame
		ldx 	fnStackLevel 				; restore X to result stack level
		rts

; ************************************************************************************************
;
;		Multi-line function: save state and enter the command loop.
;		The function body runs as normal BASIC code until ENDDEF is reached.
;
; ************************************************************************************************

_FCMultiLine:
		;
		;		Save fnStackLevel and outer fnSavedSP on the nesting stacks.
		;
		ldx 	fnNestLevel
		cpx 	#8 							; nesting stack overflow?
		bcs 	_FCTooManyParam 			; reuse "too many parameters" error
		lda 	fnStackLevel
		sta 	fnStackLevelStack,x
		lda 	fnSavedSP
		sta 	fnSavedSPStack,x
		inc 	fnNestLevel
		;
		;		Set fnSavedSP to current hardware SP (preserves expression evaluator
		;		return addresses below this point on the 6502 stack).
		;
		tsx
		stx 	fnSavedSP
		;
		;		Advance past the DEFFN line and enter the command loop.
		;
		.cnextline
		jmp 	RunNewLine

_FCTooManyParam:
		.error_parameters

		.send code

		.section storage
fnStackLevel:
		.fill 	1 							; saved stack level for function evaluation
fnNestLevel:
		.fill 	1 							; function nesting depth (0 = not in function)
fnSavedSP:
		.fill 	1 							; hardware SP at function entry
fnStackLevelStack:
		.fill 	8 							; per-nesting-level fnStackLevel saves
fnSavedSPStack:
		.fill 	8 							; per-nesting-level fnSavedSP saves
fnOuterSavedSP:
		.fill 	1 							; temp for outer fnSavedSP during ENDDEF unwind
		.send storage

