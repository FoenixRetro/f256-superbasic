; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		procedure.asm
;		Purpose:	Procedure call/EndProc
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

ParameterStackPos = 2

CallProcedure:
		;
		;		Stack the parameters on the Evaluation stack.
		;
		ldx 	#ParameterStackPos 			; start storing parameters at 2.
		.cget 								; found right bracket , no parameters ?
		cmp 	#KWD_RPAREN 				
		beq 	_CPEndParam
_CPParamLoop:				
		jsr 	EvaluateValue 				; get parameter onto stack
		inx 								; bump next stack
		.cget 								; get next character and consume
		iny
		cmp 	#KWD_COMMA 					; if comma, go back and try again.
		beq 	_CPParamLoop
		dey 								; unpick.
_CPEndParam:
		stx 	lastParameter 				; save the last parameters index.
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
		ldy 	#1 							; copy code address back.
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
		iny 								; get Y offset -> Y
		lda 	(zTemp0),y
		tay
		.cresync 							; resync any code pointer stuff
		;
		;		Now handle any parameters
		;
		ldx 	#ParameterStackPos 			; start position of parameters
		cpx	 	lastParameter 				; check zero parameters at the start
		beq 	_ParamExit 					; if so, exit.
_ParamExtract:
		dex 								; put a local term on the level before
		jsr 	LocaliseNextTerm			; also pushes original param value to basic stack
		jsr 	AssignVariable 				; assign stacked value to the variable.
		inx 								; advance to next parameter to do.
		inx
		cpx 	lastParameter 				; are we done ?
		beq 	_ParamExit
		jsr 	CheckComma 					; comma seperating parameters
		bra 	_ParamExtract

_ParamExit:				
		jsr 	CheckRightBracket 			; check )
		rts 								; and continue from here

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
		jsr 	StackClose
		rts

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
