; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		procedure.asm
;		Purpose:	Procedure call/EndProc and shared call helpers
;		Created:	2nd October 2022
;		Reviewed: 	1st December 2022
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;				Handed Procedure call from LET. The info on the record is in Stack[0]
;
; ************************************************************************************************

CallProcedure:
		;
		;		Stack the parameters on the Evaluation stack.
		;
		ldx 	#2 							; start storing parameters at 2.
		jsr 	EvaluateParamList 			; evaluate arguments onto stack
		iny									; skip right bracket
		;
		;		Save return address
		;
		lda 	#STK_PROC+3 				; allocate 6 bytes on the return stack.
		jsr 	StackOpen
		jsr 	STKSaveCodePosition 		; save loop position
		;
		;		Copy the target address - the value in the identifier record - to codePtr
		;
		lda 	NSMantissa0 				; copy variable (e.g. procedure) address to zTemp0
		sta 	zTemp0 						; this is the DATA not the RECORD
		lda 	NSMantissa1
		sta 	zTemp0+1
		;
		jsr 	JumpToDefinition 			; load safePtr+Y from (zTemp0), resync
		;
		;		Now handle any parameters
		;
		ldx 	#2 							; start position of parameters
		jsr 	LocaliseParams 				; localise params, check ) and return
		jmp 	CheckRightBracket

; ************************************************************************************************
;
;		EvaluateParamList — evaluate call-site arguments onto the expression stack.
;
;		Entry:	X = first stack slot for parameters.
;				Y = code position (at first argument or ')').
;		Exit:	X past last parameter, lastParameter set, Y past last arg.
;				Does NOT skip the closing ')'.
;
; ************************************************************************************************

EvaluateParamList:
		.cget 								; found right bracket, no parameters?
		cmp 	#KWD_RPAREN
		beq 	_EPLDone
_EPLLoop:
		jsr 	EvaluateValue 				; get parameter onto stack
		inx 								; bump next stack
		cpx		#MathStackSize				; check if parameters overflow stack
		bcs		_EPLTooMany
		.cget 								; get next character and consume
		iny
		cmp 	#KWD_COMMA 					; if comma, go back and try again.
		beq 	_EPLLoop
		dey 								; unpick.
_EPLDone:
		stx 	lastParameter 				; save the last parameters index.
		rts

_EPLTooMany:
		.error_parameters

; ************************************************************************************************
;
;		JumpToDefinition — read a definition record from (zTemp0) and resync.
;
;		Entry:	zTemp0 points to the definition record (address + Y offset).
;		Exit:	safePtr and Y set to the definition, code pointer resynced.
;
; ************************************************************************************************

JumpToDefinition:
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
		rts

; ************************************************************************************************
;
;		LocaliseParams — localise parameters from evaluation stack to definition variables.
;
;		Entry:	X = first parameter stack index.
;				lastParameter = index past last parameter.
;				Y = code position in definition (at first param or ')').
;		Exit:	Parameters localised. Does NOT skip ')'.
;
; ************************************************************************************************

LocaliseParams:
		cpx 	lastParameter 				; zero parameters?
		beq 	_LPDone
_LPLoop:
		dex
		jsr 	LocaliseNextTerm
		jsr 	AssignVariable
		inx
		inx
		cpx 	lastParameter
		beq 	_LPDone
		jsr 	CheckComma
		bra 	_LPLoop
_LPDone:
		rts

; ************************************************************************************************
;
;										ENDPROC
;
; ************************************************************************************************

Command_ENDPROC:	;; [endproc]
		lda 	#STK_PROC 					; check TOS is this
		ldx 	#ERRID_PROC
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
;		21/10/22 		Calling EvaluateExpression so wasn't working for references, changed to
;						EvaluateValue.
;
; ************************************************************************************************
