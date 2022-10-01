; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		if.asm
;		Purpose:	IF command
;		Created:	1st October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************
;
;		Warning - disinfect your hands after editing this code.
;
; ************************************************************************************************

		.section code

IfCommand: ;; [if]
		ldx 	#0 							; If what.
		jsr 	EvaluateNumber
		;
		.cget 								; what follows ?
		cmp 	#KWD_THEN  					; could be THEN <stuff> or GOTO
		beq 	_IfOldStyle		
		cmp 	#KWD_GOTO
		bne 	_IfStructured
		; ------------------------------------------------------------------------
		;
		;		either IF ... THEN <statement> or IF .. GOTO <line number>	
		;
		; ------------------------------------------------------------------------
_IfOldStyle:
		jsr 	NSMIsZero 					; is it zero
		beq 	_IfFail 					; if fail, go to next line
		.cget 								; is it if GOTO
		iny 								; consume GOTO or THEN
		cmp 	#KWD_GOTO 			
		beq 	_IfGoto
		rts 								; if THEN just continue
_IfGoto:
		jmp 	GotoCommand		
_IfFail:
		jmp 	EOLCommand

		; ------------------------------------------------------------------------
		;
		;		   The modern, structured, nicer IF ... ELSE ... ENDIF
		;
		; ------------------------------------------------------------------------

_IfStructured:
		.debug
		bra 	_IfStructured

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
