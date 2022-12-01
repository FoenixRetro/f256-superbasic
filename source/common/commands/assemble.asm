; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		assemble.asm
;		Purpose:	Assemble command
;		Created:	4th October 2022
;		Reviewed: 	1st December 2022
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
		;
		jsr 	CheckComma
		jsr 	Evaluate8BitInteger 		; options 0-3
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
