; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		clear.asm
;		Purpose:	CLEAR command
;		Created:	18th September 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

ClearCommand: ;; [clear]
		;
		;		Scan through all the variables resetting them to zero.
		;
		.set16 	zTemp0,VariableSpace
_ClearZeroLoop:		
		lda 	(zTemp0) 					; end of variables
		beq 	_ClearZeroEnd

		ldy 	#3 							; erase the variables
		lda 	#0
_ClearOneVariable:	
		sta 	(zTemp0),y
		iny
		cpy 	#8
		bne 	_ClearOneVariable	

		ldy 	#2 							; has it been marked procedure
		lda 	(zTemp0),y
		cmp 	#NSTProcedure
		bne 	_ClearNotProcedure
		lda 	#NSTInteger+NSBIsArray 		; set it back to an integer array
		sta 	(zTemp0),y
_ClearNotProcedure:

		clc 								; go to the next variable
		lda 	(zTemp0)
		adc 	zTemp0
		sta 	zTemp0
		bcc 	_ClearZeroLoop
		inc 	zTemp0+1
		bra 	_ClearZeroLoop

_ClearZeroEnd:
		;
		;		Reset the low memory allocation pointer
		;
		clc
		lda 	zTemp0
		adc 	#1
		sta 	lowMemPtr
		lda 	zTemp0+1
		adc 	#0
		sta 	lowMemPtr+1
		;
		;		Reset the BASIC Stack pointer
		;
		jsr 	StackReset
		;
		;		Reset the BASIC string pointer
		;
		jsr 	StringSystemInitialise		
		;
		;		Scan the program code for Procedures (possibly convert intarrys back above ?)
		;
		jsr 	ProcedureScan
		;
		;		Restore the DATA pointer
		;
		jsr 	Command_Restore	
		;
		;		Reset the assembler control and location values.
		;
		stz 	AssemblerAddress	
		stz 	AssemblerAddress+1
		stz 	AssemblerControl	
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
