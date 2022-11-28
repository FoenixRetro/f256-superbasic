; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		let.asm
;		Purpose:	Assignment command
;		Created:	30th September 2022
;		Reviewed: 	28th November 2022
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

LetCommand: ;; [let]
		ldx 	#0
		.cget 								; check for @<let>
		cmp 	#KWD_AT
		bne 	_LCStandard
		;
		;		Handle let @value which is integer indirection.
		;
		iny 								; skip equal
		jsr 	EvaluateTerm 				; get a number (the address of the reference)
		jsr 	Dereference 				; dereference it to a value
		lda 	NSStatus,x 					; check integer
		eor 	#NSBIsReference	 			; toggle reference
		sta 	NSStatus,x
		and 	#NSBIsReference 			; if it is now a reference, continue
		bne 	_LCMain
		jmp 	TypeError 					; was a reference before.

_LCStandard:
		lda 	PrecedenceLevel+"*"			; precedence > this
		jsr 	EvaluateExpressionAtPrecedence
		;
		lda 	NSStatus,x 					; is it a reference to an array marked as procedure ?
		cmp		#NSTProcedure+NSBIsReference
		beq 	_LetGoProc 					; it's a procedure call.
		;
_LCMain:		
		lda 	#"=" 						; check =
		jsr 	CheckNextA
		;
		inx 								; RHS
		jsr 	EvaluateValue
		dex
		;
		jsr 	AssignVariable
		rts

_LetGoProc:
		jmp 	CallProcedure		

; ************************************************************************************************
;
;								Assign Stack[X+1] to Stack[X]
;
; ************************************************************************************************

AssignVariable:
		lda 	NSStatus,x 					; check the string/number type bits match
		pha 								; save a copy
		eor 	NSStatus+1,x
		and 	#NSBIsString
		bne 	_ASError
		pla 								; get back
		and 	#NSBIsString 				; check type
		bne 	_ASString
		jmp 	AssignNumber
_ASString:
		jmp 	AssignString		
_ASError:
		jmp 	TypeError		
		
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
