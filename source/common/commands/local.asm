; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		local.asm
;		Purpose:	LOCAL command
;		Created:	5th October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************

; ************************************************************************************************
;
;									Local - non array values
;
; ************************************************************************************************

		.section code

Command_LOCAL: ;; [local]
		ldx 	#0 							; at level 0
		jsr 	LocaliseNextTerm 			; convert term to a local.
		.cget 								; followed by comma ?
		iny
		cmp 	#KWD_COMMA
		beq 	Command_LOCAL
		dey 								; unpick pre-get
		rts

; ************************************************************************************************
;
;				Get a term reference and push its value on BASIC stack, using Stack[x]
;
; ************************************************************************************************

LocaliseNextTerm:
		.debug
		jsr 	EvaluateTerm 				; evaluate the term
		lda 	NSStatus,x
		and 	#NSBIsReference 			; check it is a reference
		bne		_LNTError


_LNTError:
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
