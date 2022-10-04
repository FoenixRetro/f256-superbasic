; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		assemble.asm
;		Purpose:	Assemble command
;		Created:	4th October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

AssembleCommand: ;; [assemble]
		ldx 	#0
		jsr 	Evaluate16BitInteger 		; start address
		lda 	NSMantissa0
		sta 	AssemblerAddress
		lda 	NSMantissa1
		sta 	AssemblerAddress+1
		jsr 	CheckComma
		jsr 	Evaluate8BitInteger 		; options
		lda 	NSMantissa0
		sta 	AssemblerControl
		rts
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
