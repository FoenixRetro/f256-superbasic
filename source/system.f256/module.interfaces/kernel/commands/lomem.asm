; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		lomem.asm
;		Purpose:	LOMEM command (module interface, calls hardware module)
;		Created:	9th March 2026
;		Author:		Matthias Brukner (mbrukner@gmail.com)
;
; ************************************************************************************************
; ************************************************************************************************

		.section	code

; ************************************************************************************************
;
;		LOMEM <address>
;		Set the physical page from which new program pages are allocated.
;		Address must be a multiple of $2000 (8KB page boundary).
;		e.g. LOMEM $38000 allocates from page 28 onward.
;		Actual work is done in the hardware module (Export_EXTLomem).
;
; ************************************************************************************************

LomemCommand: ;; [lomem]
		ldx 	#0
		jsr 	EvaluateNumber 				; get address into NSMantissa0-3
		phy 								; save token offset
		jsr 	EXTLomem 					; delegate to hardware module
		ply 								; restore token offset
		bcs 	_LCRange
		rts
_LCRange:
		jmp 	RangeError

		.send	code
