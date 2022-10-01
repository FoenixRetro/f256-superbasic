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
;										IF (two forms)
;
; ************************************************************************************************

		.section code

IfCommand: ;; [if]
		ldx 	#0 							; If what.
		jsr 	EvaluateNumber
		;
		.cget 								; what follows ?
		cmp 	#KWD_THEN  					; could be THEN <stuff> or GOTO
		bne 	_IFStructured

		; ------------------------------------------------------------------------
		;
		;						 IF ... THEN <statement> 
		;
		; ------------------------------------------------------------------------

		iny 								; consume THEN
		jsr 	NSMIsZero 					; is it zero
		beq 	_IfFail 					; if fail, go to next line
		rts 								; if THEN just continue
_IfFail:
		jmp 	EOLCommand

		; ------------------------------------------------------------------------
		;
		;		   The modern, structured, nicer IF ... ELSE ... ENDIF
		;
		; ------------------------------------------------------------------------

_IfStructured:
		jsr 	NSMIsZero 					; is it zero
		bne 	_IfExit 					; if not, then continue normally.
		lda 	#KWD_ELSE 					; look for else/endif
		ldx 	#KWD_ENDIF
		jsr 	ScanForward 				; and run from there/
_IfExit:
		rts

; ************************************************************************************************
;
;										ELSE code
;
; ************************************************************************************************

ElseCode: ;; [else] 					
		lda 	#KWD_ENDIF 					; else is only run after the if clause succeeds
		tax 								; so just go to the structure exit
		jsr 	ScanForward
		rts

; ************************************************************************************************
;
;										ENDIF code
;
; ************************************************************************************************

EndIf:	;; [endif]							; endif code does nothing
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
;
; ************************************************************************************************
