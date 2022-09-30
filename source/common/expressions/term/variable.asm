; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		variable.asm
;		Purpose:	Variable handler
;		Created:	30th September 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;									Variable handler
;
; ************************************************************************************************

VariableHandler:
		.cget 								; copy variable address to zTemp0
		clc 								
		adc 	#((VariableSpace >> 8) - $40) & $FF
		sta 	zTemp0+1
		iny
		.cget
		sta 	zTemp0
		iny
		;
		clc									; copy variable address+3 to mantissa
		adc 	#3
		sta 	NSMantissa0,x
		lda 	zTemp0+1
		adc 	#0
		sta 	NSMantissa1,x
		;
		stz 	NSMantissa2,x
		stz 	NSMantissa3,x
		stz 	NSExponent,x
		;
		phy
		ldy 	#2 							; read type
		lda 	(zTemp0),y
		ply
		;
		and 	#NSBTypeMask+NSBIsArray 	; get type information
		ora 	#NSBIsReference 			; make a reference.
		sta 	NSStatus,x

		and 	#NSBIsArray
		bne 	_VHArray
		rts
		;
		;		Accessing an array.
		;
_VHArray:
		.debug
		bra 	_VHArray
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
