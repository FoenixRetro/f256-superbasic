; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		procscan.asm
;		Purpose:	Scan for procedures and function definitions
;		Created:	2nd October 2022
;		Reviewed: 	1st December 2022
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;			Scan program code for PROC and DEFFN definitions
;
; ************************************************************************************************

ProcedureScan:
		jsr 	SwapDataCodePtrs 			; swap code and data
		.cresetcodepointer 					; start of program
_PSLoop:
		.cget0 								; exit if at end
		beq 	_PSExit
		;
		ldy 	#3 							; check first token on the line
		.cget
		cmp 	#KWD_PROC 					; is it PROC ?
		beq 	_PSIsProc
		cmp 	#KWD_DEFFN					; is it DEFFN ?
		bne 	_PSNext
		;
		;		DEFFN: mark as function (NSTProcedure + NSBIsArray)
		;		so VariableHandler dispatches to function call.
		;
		lda 	#NSTProcedure+NSBIsArray
		bra 	_PSGetVar
		;
		;		PROC: mark as procedure (NSTProcedure only)
		;
_PSIsProc:
		lda 	#NSTProcedure
		;
		;		Get the address of the variable record in zTemp0.
		;		A = type byte to store.
		;
_PSGetVar:
		pha 								; save type byte
		iny 								; get the address of the record to zTemp0 and
		.cget 								; validate it is $4000-$7FFF
		and 	#$C0
		cmp 	#$40
		bne 	_PSSyntax
		.cget 								; get it back and convert to real address
		clc
		adc 	#((VariableSpace >> 8) - $40) & $FF
		sta 	zTemp0+1
		iny 								; LSB
		.cget
		sta 	zTemp0
		iny 								; character after variable reference
		;
		; 		Now copy the current position into the identifier data.
		;
		tya 								; save Y offset at +7 (exponent slot)
		ldy 	#7
		sta 	(zTemp0),y
		;
		pla 								; retrieve and store type byte
		ldy 	#2
		sta 	(zTemp0),y
		;
		ldx 	#0 							; copy code-Ptr into offset 3-6 (mantissa)
_PSCopy:
		lda 	safePtr,x
		iny
		sta 	(zTemp0),y
		inx
		cpx 	#4
		bne 	_PSCopy
_PSNext:
		.cnextline  						; next line and try again
		bra 	_PSLoop
_PSExit:
		jmp 	SwapDataCodePtrs 			; swap code and data
_PSSyntax:
		pla 								; clean up stack
		jmp 	SyntaxError

		.send code
