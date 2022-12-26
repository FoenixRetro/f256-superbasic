; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		memory.asm
;		Purpose:	BASIC program space manipulation
;		Created:	19th September 2022
;		Reviewed: 	23rd November 2022
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
		.cresetcodepointer 					; point to start of program memory
		lda 	#0 							; write zero there erasing the program.
		.cset0	
		rts

; ************************************************************************************************
;
;							Get inline code address into current stack level.
;
;		Used for inline strings. If this is paged, it may have to go into temporary storage,
; 		a buffer or similar.
;
; ************************************************************************************************

MemoryInline:
		tya 								; put address into stack,x
		clc  								; get the offset, add codePtr
		adc 	codePtr
		sta 	NSMantissa0,x 				; store the result in the mantissa.
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
