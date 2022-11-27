; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		expression.asm
;		Purpose:	Evaluate an expression
;		Created:	21st September 2022
;		Reviewed: 	27th November 2922
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;						Punctuation operator -> Precedence level table
;
; ************************************************************************************************

		.include "../generated/precedence.dat"

; ************************************************************************************************
;
;									Evaluate an expression 
;
; ************************************************************************************************

EvaluateExpressionAt0:
		ldx 	#0 							; bottom stack level
EvaluateExpression:
		lda 	#0 							; lowest precedence level
EvaluateExpressionAtPrecedence:

		pha 								; save precedence level
		jsr 	EvaluateTerm 				; evaluate term into level X.
		pla 								; restore precedence level.

		; ----------------------------------------------------------------------------------------
		;
		;								Main Evaluation Loop
		;		
		; ----------------------------------------------------------------------------------------

_EXPRLoop:
		sta 	zTemp0 						; save current precedence level.

		.cget 								; get next character, the binary operator.
		cmp		#$40 						; if >= $40 cannot be an operator
		bcs 	_EXPRExit
		;
		phx 								; read the operator precedence
		tax
		lda 	PrecedenceLevel,x 			
		plx
		;
		cmp 	#0							; if zero exit (not an operator)
		beq 	_EXPRExit 	
		sta 	zTemp0+1 					; save operator precedence level.
		;
		lda 	zTemp0 						; compare current precedence vs. operator precedence
		cmp 	zTemp0+1
		bcs		_EXPRExit 					; if current >= operator exit
		;
		pha 								; save current precedence.
		;
		.cget 								; get, consume and save binary operator
		iny
		pha 
		;
		lda 	zTemp0+1 					; get operator precedence level
		inx 								; work out the right hand side.
		jsr 	EvaluateExpressionAtPrecedence 
		dex
		;
		pla 								; get operator, call the code.
		jsr 	_EXPRCaller

		pla 								; restore precedence level
		bra 	_EXPRLoop 					; and go round.
		;
_EXPRExit:
		lda 	zTemp0 						; A = current precedence level.
		rts

		; ----------------------------------------------------------------------------------------
		;
		;						Call binary function handler - note initial PHX
		;		
		; ----------------------------------------------------------------------------------------

_EXPRCaller:
		phx 								; save on stack, first thing is to restore it
		asl 	a 							; double so can use vectors into X
		tax
		jmp 	(VectorSetPunc,x) 			; and go to the code.

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
