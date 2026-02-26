; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		goto.asm
;		Purpose:	GOTO command - for compatibility *ONLY*. Do not use in new stuff !
;		Created:	1st October 2022
;		Reviewed: 	28th November 2022
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************

; ************************************************************************************************
;
;					Warning - disinfect your hands after editing this code.
;
; ************************************************************************************************

		.section code

GotoCommand: ;; [goto]
		ldx 	#0 							; GOTO where
		jsr 	Evaluate16BitInteger
GotoStackX:
		ldx 	NSMantissa1 				; put line # in XA
		lda 	NSMantissa0
		jsr 	MemorySearch 				; transfer to line number AX.
		bcc 	_GotoError 					; not found, off end.
		bne 	_GotoError 					; not found exactly
		jmp 	RunNewLine 					; and go straight to new line code.
_GotoError:
		.error_line
				
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
