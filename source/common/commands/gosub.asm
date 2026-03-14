; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		gosub.asm
;		Purpose:	Subroutine call (and return)
;		Created:	1st October 2022
;		Reviewed: 	28th November 2022
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;											GOSUB command
;
; ************************************************************************************************

Command_GOSUB:	;; [gosub]
		ldx 	#0
		jsr 	Evaluate16BitInteger 		; line number in Stack.0
		lda 	#STK_GOSUB+3
		jsr 	StackOpen 					; create frame
		jsr 	STKSaveCodePosition 		; save current position
		bra 	GotoStackX

; ************************************************************************************************
;
;		RETURN command — handles both GOSUB return and function return.
;
;		Inside a function body (fnNestLevel > 0):
;		  return expr  — evaluate and return value
;		  return       — return zero
;
;		Outside a function body:
;		  return       — return from GOSUB
;
; ************************************************************************************************

Command_RETURN:	;; [return]
		lda 	fnNestLevel
		beq 	_CRGosubReturn 				; not in function → GOSUB return
		jmp 	FunctionReturnWithExpr 		; inside function → return from function
_CRGosubReturn:
		lda 	#STK_GOSUB 					; check TOS is this
		ldx 	#ERRID_GOSUB 				; this error
		jsr 	StackCheckFrame
		jsr 	STKLoadCodePosition 		; restore code position
		jmp 	StackClose

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
