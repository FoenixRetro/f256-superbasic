; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		variable.asm
;		Purpose:	Variable handler
;		Created:	30th September 2022
;		Reviewed: 	28th November 2022
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
		adc 	#3 							; this is the address of the data.
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

; ************************************************************************************************
;
;									Accessing an array.
;
; ************************************************************************************************

_VHArray:
		;
		inx
		jsr 	Evaluate8BitInteger 		; get the 1st index.
		;
		lda 	#$FF 						; set Status of X+2 to a duff value so we know if we picked it up.
		sta 	NSStatus+1,x
		;
		.cget 								; followed by comma
		cmp 	#KWD_COMMA
		bne 	_VHNoSecondIndex
		iny 								; skip the comma
		inx
		jsr 	Evaluate8BitInteger 		; get the 2nd index.
		dex
_VHNoSecondIndex:
		dex 								; set X back.
		jsr 	CheckRightBracket 			; and check the right bracket.

		; -----------------------------------------------------------------------------------------------------
		;
		;		So at this point S[X] refers to the array record S[X+1] the 1st index, and S[X+2] the second
		;		Status[X+2] is $FF if there was only one array index, $00 if there were two.
		;		
		; -----------------------------------------------------------------------------------------------------
		;
		;		So first check if the number of indices match
		;
		phy 								; save position
		;
		lda 	NSMantissa0,x 				; copy record address to zaTemp (moved 6/12/22)
		sta 	zaTemp
		lda 	NSMantissa1,x
		sta 	zaTemp+1
		;
		ldy 	#2 							; check first index is not-zero, e.g. array defined
		lda 	(zaTemp),y
		beq 	_VHBadArray
		;
		ldy 	#3 							; get the second index - which is 0 if there is one index.
		lda 	(zaTemp),y
		beq 	_VHHas2Mask
		lda 	#$FF
_VHHas2Mask: 								; so we are now 0 if there is 1 index, and $FF if there is 2 - the inverse of Status, Stack[X+2]
		cmp 	NSStatus+2,x 				; so if they are the same there are the wrong number of indices
		beq 	_VHBadIndex
		;
		;		Now check the indices are in range.
		;
		asl 	a 							; carry will be set if a second index
		bcc 	_VHCheckFirstIndex
		;
		;		Second index
		;
		ldy 	#3 			 				; check the 2nd size >= 2nd index				
		lda 	(zaTemp),y
		cmp 	NSMantissa0+2,x
		bcc 	_VHBadIndex
		;
		;		First index
		;
_VHCheckFirstIndex:
		ldy 	#2 			 				; check the 2nd size >= 2nd index				
		lda 	(zaTemp),y
		cmp 	NSMantissa0+1,x
		bcc 	_VHBadIndex
		;
		;		Now calculate second index * first size if required.
		;
		stz 	zTemp0 						; clear zTemp0 (if 1 index)
		stz 	zTemp0+1
		lda 	NSStatus+2,x 				; if only one index provided, don't need to multiply
		bmi 	_VHNoMultiply
		;
		;		Make zTemp0 = 2nd index * (first max index+1)
		;
		phx
		lda 	NSMantissa0+2,x 			; get 2nd index on stack
		pha
		ldy 	#2 							; get 1st size in A
		lda 	(zaTemp),y
		inc 	a 							; add 1 for zero base
		plx 								
		jsr 	Multiply8x8 				; calculate -> Z0
		plx
_VHNoMultiply:
		;
		; 		Add the 1st index, gives us an offset (by number) in the array memory
		;
		clc
		lda 	zTemp0
		adc 	NSMantissa0+1,x
		sta 	zTemp0
		lda 	zTemp0+1
		adc 	#0
		sta 	zTemp0+1
		;
		;		Get the type (from Status,0) and use it to scale up 
		;
		lda 	NSStatus,x
		jsr 	ScaleByBaseType
		;
		;		Add the base memory address to get the final address.
		;
		clc
		lda 	(zaTemp)
		adc 	zTemp0
		sta 	NSMantissa0,x
		;
		ldy 	#1
		lda 	(zaTemp),y
		adc 	zTemp0+1
		sta 	NSMantissa1,x
		;
		ply 								; restore position
		rts

_VHBadIndex:
		.error_arrayidx
_VHBadArray:
		.error_arraydec

		.send code

; ************************************************************************************************
;
;									Changes and Updates
;
; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;		06/12/22 		Added array not declared error.
;		06/12/22 		At the check of indices match, around line 87, the copy into zaTemp was
;						done *before* zaTemp was initialised,so it checked the last assigned value.
;						Swapped round. Would only be picked up with uninitialised arrays.
;
; ************************************************************************************************
