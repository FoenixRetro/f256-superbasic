; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		fn.asm
;		Purpose:	Function call handler — invoked from VariableHandler for FN functions
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
		;
		;		Stack the arguments on the evaluation stack.
		;
		phx 								; preserve caller's stack level
		inx 								; params start above function variable
		jsr 	EvaluateParamList 			; evaluate arguments onto stack
		iny 								; skip right bracket
		plx 								; restore caller's stack level
		stx 	fnStackLevel 				; save stack level for result
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
		jsr 	JumpToDefinition 			; load safePtr+Y from (zTemp0), resync
		;
		;		Localise parameters (copy from evaluation stack to local variables).
		;
		ldx 	fnStackLevel 				; params started at fnStackLevel + 1
		inx
		jsr 	LocaliseParams 				; localise params and check )
		jsr 	CheckRightBracket
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
		;		If string result, copy to temp before popping locals.
		;
		lda 	NSStatus,x
		and 	#NSBTypeMask
		cmp 	#NSTString
		bne 	_FCSLRestore
		jsr 	FRCopyString
_FCSLRestore:
		;
		;		Restore: pop locals, restore code position.
		;
		lda 	#STK_PROC
		ldx 	#ERRID_PROC
		jsr 	StackCheckFrame 			; pops all locals, checks frame
		jsr 	STKLoadCodePosition 		; restore code pointer to after fn(...)
		jsr 	StackClose 					; release the stack frame
		ldx 	fnStackLevel 				; restore X to result stack level
		rts

; ************************************************************************************************
;
;		Multi-line function: save state and enter the command loop.
;		The function body runs as normal BASIC code until ENDFN or RETURN.
;
; ************************************************************************************************

_FCMultiLine:
		ldx 	fnNestLevel
		cpx 	#8 							; nesting stack overflow?
		bcs 	_FCTooManyParam
		lda 	fnStackLevel
		sta 	fnStackLevelStack,x
		lda 	fnSavedSP
		sta 	fnSavedSPStack,x
		inc 	fnNestLevel
		;
		;		Save caller's eval stack entries S[0]..S[fnStackLevel-1]
		;		on the hardware stack. Command handlers always evaluate at
		;		stack level 0, so without this the function body would
		;		overwrite the calling expression's intermediate values.
		;		The data is preserved because fnSavedSP (captured below)
		;		sits above it, and RunNewLine resets SP to fnSavedSP.
		;
		ldx 	fnStackLevel
		beq 	_FCMLNoSave
		dex
_FCMLSaveLoop:
		lda 	NSMantissa0,x
		pha
		lda 	NSMantissa1,x
		pha
		lda 	NSMantissa2,x
		pha
		lda 	NSMantissa3,x
		pha
		lda 	NSExponent,x
		pha
		lda 	NSStatus,x
		pha
		dex
		bpl 	_FCMLSaveLoop
_FCMLNoSave:
		tsx
		stx 	fnSavedSP
		.cnextline
		jmp 	RunNewLine

_FCTooManyParam:
		.error_parameters

		.send code

		.section storage
fnNestLevel:
		.fill 	1 							; function nesting depth (0 = not in function)
fnSavedSP:
		.fill 	1 							; hardware SP at function entry
fnStackLevelStack:
		.fill 	8 							; per-nesting-level fnStackLevel saves
fnSavedSPStack:
		.fill 	8 							; per-nesting-level fnSavedSP saves
		.send storage

