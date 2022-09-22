; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		simple.asm
;		Purpose:	Simple binary operations
;		Created:	21st September 2022
;		Reviewed: 	No
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
		.dispatcher NotDoneError,NotDoneError
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
		rts

SubInteger: 	;; [-]
		plx
		.dispatcher NotDoneError,NotDoneError
		lda 	NSStatus+1,x 				; negate the second value.
		eor 	#$80
		sta 	NSStatus+1,x
		bra 	AddCode 					; and do the same code as add.

AndInteger: 	;; [&]
		plx
		.dispatchintegeronly
		.simple32 and
		rts

OraInteger: 	;; [|]
		plx
		.dispatchintegeronly
		.simple32 ora
		rts

EorInteger: 	;; [^]
		plx
		.dispatchintegeronly
		.simple32 eor
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
