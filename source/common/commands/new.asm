; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		new.asm
;		Purpose:	NEW command
;		Created:	18th September 2022
;		Reviewed: 	23rd November 2022
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

NewCommand: ;; [new]
		jsr		IsDestructiveActionOK
		bcs		_not_ok
		jsr 	NewProgram 					; does the actual NEW.
_not_ok:
		jmp 	WarmStart 					; and warm starts straight away.

; ************************************************************************************************
;
;				Subroutine so that we can actually do NEW without warmstarting
;
; ************************************************************************************************

NewProgram:
		jsr 	MemoryNew
		stz 	VariableSpace 				; erase all variables.
		jsr 	ClearSystem					; clear everything.
		stz		programChanged
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
