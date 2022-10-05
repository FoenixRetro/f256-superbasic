; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		procscan.asm
;		Purpose:	Scan for procedures
;		Created:	2nd October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;					   Scan program code for PROC definitions
;
; ************************************************************************************************

ProcedureScan:
		.cresetcodepointer 					; start of program
_PSLoop:
		.cget0 								; exit if at end
		beq 	_PSExit
		ldy 	#3 							; is it PROC ?
		.cget 
		cmp 	#KWD_PROC
		bne 	_PSNext
		;
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
		iny 								; character after variable call.
		
		tya 								; save Y offset at +7
		ldy 	#7
		sta 	(zTemp0),y
		;
		lda 	#NSTProcedure 				; mark it as procedure
		ldy 	#2
		sta 	(zTemp0),y
		;
		ldx 	#0 							; copy code-Ptr in
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
		rts
_PSSyntax:
		jmp 	SyntaxError

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
