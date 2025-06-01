;;
; Expression evaluation
;;

		.section code

;;
; Punctuation operator -> Precedence level table
;;
		.include "../generated/precedence.dat"

;;
; Evaluate an expression at stack level 0.
;
; Evaluates a mathematical or string expression starting at the lowest stack level (0)
; with the lowest precedence level. This is the main entry point for expression evaluation.
;
; \in Y         Relative offset to the start of the expression.
; \out A        Current precedence level after evaluation.
; \sideeffects  - Clears registers `X` and `A`.
;               - See `EvaluateExpressionAtPrecedence`
; \see     		EvaluateExpression, EvaluateExpressionAtPrecedence, EvaluateTerm
;;
EvaluateExpressionAt0:
		ldx 	#0 							; bottom stack level

;;
; Evaluate an expression at stack level `X`.
;
; Evaluates a mathematical or string expression starting at the specified stack level (`X`)
; with the lowest precedence level. This function is used when evaluating expressions
; at different stack depths during recursive expression parsing.
;
; \in Y         Relative offset to the start of the expression.
; \in X   		Stack level to use for evaluation.
; \out A        Current precedence level after evaluation.
; \sideeffects  - Modifies register `A`.
;               - See `EvaluateExpressionAtPrecedence`
; \see     		EvaluateExpressionAt0, EvaluateExpressionAtPrecedence, EvaluateTerm
;;
EvaluateExpression:
		lda 	#0 							; lowest precedence level

;;
; Evaluate an expression at a specific stack and precedence level.
;
; Evaluates a mathematical or string expression starting at the specified stack level (`X`)
; and precedence level (`A`). This is the core expression evaluation function that handles
; operator precedence and recursive evaluation of sub-expressions.
;
; \in Y         Relative offset to the start of the expression.
; \in  X        Stack level to use for evaluation.
; \in  A        Precedence level for this evaluation.
; \out A        Current precedence level after evaluation.
; \sideeffects  - Modifies registers `A`, `X`, `Y` and `zTemp0`, `zTemp0+1`.
;               - Uses math stack levels X and X+1 for operand storage.
;               - Advances code pointer past the expression.
;               - May throw "too complex" error if stack depth exceeded.
; \see          EvaluateExpressionAt0, EvaluateExpression, EvaluateTerm, VectorSetPunc
;;
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
		cpx		#MathStackSize
		bge		_EXPRTooComplex

		phx 								; save on stack, first thing is to restore it
		asl 	a 							; double so can use vectors into X
		tax
		jmp 	(VectorSetPunc,x) 			; and go to the code.

_EXPRTooComplex:
		.error_toocomplex

		.send code
