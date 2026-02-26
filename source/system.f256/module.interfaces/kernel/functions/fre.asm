; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		fre.asm
;		Purpose:	Free program memory (unary handler, calls module)
;		Created:	27th February 2026
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section	code

; ************************************************************************************************
;
;		FRE() - returns total free program memory in bytes.
;		Calculation is done in the hardware module (Export_EXTFreMemory).
;
; ************************************************************************************************

FreUnary: ;; [fre(]
		plx
		jsr 	EvaluateInteger 		; evaluate parameter (result on math stack)
		jsr 	CheckRightBracket
		phy 							; save token buffer position (Y)
		jsr 	EXTFreMemory 			; module reads param from math stack, dispatches
		ply 							; restore token buffer position
		rts

		.send	code
