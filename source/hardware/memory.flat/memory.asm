; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		memory.asm
;		Purpose:	BASIC program space manipulation
;		Created:	19th September 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;									Erase the current program
;
; ************************************************************************************************

MemoryNew:
		.cresetCodePointer 					; point to start of program memory
		lda 	#0 							; write zero there erasing the program.
		.cset0	
		rts

; ************************************************************************************************
;
;									Get inline code address
;
; ************************************************************************************************

MemoryInline:
		tya 								; put address into stack,x
		clc 
		adc 	codePtr
		sta 	NSMantissa0,x
		lda 	codePtr+1
		adc 	#0
		sta 	NSMantissa1,x
		stz 	NSMantissa2,x
		stz 	NSMantissa3,x
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
