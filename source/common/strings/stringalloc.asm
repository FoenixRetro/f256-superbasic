; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		stringalloc.asm
;		Purpose:	String allocation handler
;		Created:	29th September 2022
;		Reviewed: 	27th November 2022
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;							  Reset the concreted string pointer.
;
; ************************************************************************************************

StringSystemInitialise:
		.set16	stringMemory,EndVariableSpace-1
		stz 	EndVariableSpace-1 			; put a zero at the end, so know end of string memory.
		rts

; ************************************************************************************************
;
;							  Initialise the string space
;
; ************************************************************************************************

StringSpaceInitialise:
		jsr 	CheckIdentifierStringSpace 	; check memory allocation.
		;
		lda 	#$FF 						; only initialise once (set to $FF, bit used to test it)
		sta 	stringInitialised
		;
		lda 	stringMemory 				; allocate 256 bytes for one concreted string
		sta 	stringTempPointer 			; so temporary string space is allocated below that.
		lda 	stringMemory+1
		dec 	a
		sta 	stringTempPointer+1
		rts

; ************************************************************************************************
;
;		Allocate bytes for string of length A, temporary, and put in zTemp1 and MantissaA
;
;					  * FOR TEMPORARY STRING USAGE DURING ONE INSTRUCTION *
;
; ************************************************************************************************

StringTempAllocate:
		cmp 	#252+1 						; max length of strings
		bcs 	_STALength
		;
		bit 	stringInitialised 			; already initialised
		bmi 	_STAAllocate
		;
		pha 								; save value to subtract.
		jsr 	StringSpaceInitialise 		; initialise string memory allocation
		pla 								; restore it
_STAAllocate:
		;
		eor 	#$FF 						; 2's complement add to StringTempPointer
		clc  								; deliberate allows one more
		adc 	stringTempPointer 			; subtract from temp pointer
		sta 	stringTempPointer  			
		sta 	NSMantissa0,x 				; address in mantissa
		sta 	zsTemp 						; and zsTemp
		lda 	stringTempPointer+1
		adc 	#$FF
		sta 	stringTempPointer+1 		
		sta 	zsTemp+1
		sta 	NSMantissa1,x
		;
		stz 	NSMantissa2,x 				; set the typing data and the upper address bytes.
		stz 	NSMantissa3,x
		lda 	#NSTString
		sta 	NSStatus,x
		;
		lda 	#0 							; clear the target string
		sta 	(zsTemp)
		;
		rts

_STALength:
		.error_string

; ************************************************************************************************
;
;								Write A to temp string
;
; ************************************************************************************************

StringTempWrite:
		pha
		sta 	(zsTemp) 					; write byte
		inc 	zsTemp 						; bump pointer
		bne 	_STWNoCarry
		inc 	zsTemp+1
_STWNoCarry:		
		lda 	#0 							; make ASCIIZ
		sta 	(zsTemp)
		pla
		rts

		.send 	code
		
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
