; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		simple.asm
;		Purpose:	Simple binary operations
;		Created:	21st September 2022
;		Reviewed: 	27th November 2022
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;									Macro to simplify simple handlers
;
; ************************************************************************************************

simple32 .macro
		lda		NSMantissa0,x
		\1 		NSMantissa0+1,x 	
		sta 	NSMantissa0,x
		lda		NSMantissa1,x
		\1 		NSMantissa1+1,x 	
		sta 	NSMantissa1,x
		lda		NSMantissa2,x
		\1 		NSMantissa2+1,x 	
		sta 	NSMantissa2,x
		lda		NSMantissa3,x
		\1 		NSMantissa3+1,x 	
		sta 	NSMantissa3,x
		.endm

; ************************************************************************************************
;
;								Two's complement math operators
;
; ************************************************************************************************

AddTopTwoStack:		
		clc
		.simple32 adc
		rts

SubTopTwoStack:		
		sec
		.simple32 sbc
		rts

; ************************************************************************************************
;
;									Simple Binary Operators
;
; ************************************************************************************************

AddInteger: 	;; [+]
		plx
		.dispatcher FloatingPointAdd,StringConcat
AddCode:
		lda 	NSStatus,x 					; signs are the same, can just add the mantissae.
		eor 	NSStatus+1,x
		bpl 	AddTopTwoStack
		;
		jsr 	SubTopTwoStack 				; do a physical subtraction
		bit 	NSMantissa3,x 				; result is +ve, okay
		bpl 	_AddExit 	
		lda 	NSStatus+1,x 				; sign is that of 2nd value
		sta 	NSStatus,x
		jsr 	NSMNegateMantissa 			; negate the mantissa and exit
_AddExit:
		jsr 	NSMIsZero 					; check for -0
		bne 	_AddNonZero
		stz 	NSStatus,x
_AddNonZero:		
		rts

SubInteger: 	;; [-]
		plx
		.dispatcher FloatingPointSub,NotDoneError
		lda 	NSStatus+1,x 				; negate the second value.
		eor 	#$80
		sta 	NSStatus+1,x
		bra 	AddCode 					; and do the same code as add.

AndInteger: 	;; [&]
		plx
		.dispatchintegeronly
		.simple32 and
		stz	 	NSStatus,x 					; ignore sign.
		rts

OraInteger: 	;; [|]
		plx
		.dispatchintegeronly
		.simple32 ora
		stz	 	NSStatus,x 					; ignore sign.
		rts

EorInteger: 	;; [^]
		plx
		.dispatchintegeronly
		.simple32 eor
		stz	 	NSStatus,x 					; ignore sign.
		rts

; ************************************************************************************************
;
;								Binary Indirection Operators
;
; ************************************************************************************************

WordIndirect: 	;; [!]
		plx
		.dispatchintegeronly
		jsr 	AddCode 					; add the two values
		lda 	#NSBIsReference+2 			; make a 2 byte reference
		sta 	NSStatus,x
		rts

ByteIndirect: 	;; [?]
		plx
		.dispatchintegeronly
		jsr 	AddCode 					; add the two values
		lda 	#NSBIsReference+1 			; make a 1 byte reference
		sta 	NSStatus,x
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
