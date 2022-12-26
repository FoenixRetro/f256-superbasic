; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		tostring.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	29th September 2022
;		Reviewed :	27th November 2022
;		Purpose :	Convert Integer to String
;
; ***************************************************************************************
; ***************************************************************************************

		.section 	code

; ***************************************************************************************
;
;							Convert XA to string return in XA
;
; ***************************************************************************************

ConvertInt16:
		sta 	NSMantissa0 				; set up as 32 bit conversion
		stx 	NSMantissa1
		stz 	NSMantissa2
		stz 	NSMantissa3		
		stz 	NSStatus 					; positive integer
		ldx 	#0 							; stack level
		lda 	#10 						; base 10 decimal.
		bra 	ConvertInt32

; ***************************************************************************************
;
;						Convert string at Level X Base A
;
; ***************************************************************************************

ConvertInt32:
		phy
		ldy  	#0 							; index into buffer.
		bit 	NSStatus 					; output a - if not negative.
		bpl 	_CI32NotNeg
		pha
		lda 	#'-'
		sta 	numberBuffer,y
		iny
		pla
_CI32NotNeg:
		jsr 	_CI32DivideConvert 			; recursive conversion
		lda 	#0 							; make ASCIIZ
		sta 	numberBuffer,y
		ply
		ldx 	#numberBuffer >> 8 			; return address in XA
		lda 	#numberBuffer & $FF
		rts

_CI32DivideConvert:
		inx 								; write to next slot up
		jsr 	NSMSetByte 		 			; write the base out.
		dex
		jsr 	Int32Divide 				; divide
		;
		lda 	NSMantissa0,x 				; save remainder
		pha 

		jsr 	NSMCopyPlusTwoToZero 		; Copy the divide result into place.
		;
		jsr 	NSMIsZero 					; is it zero ?
		beq 	_CI32NoRecurse 				; if so, don't recursively call.
		;
		lda 	NSMantissa0+1,x 			; this is the base which is not changed by divide
		jsr 	_CI32DivideConvert 			; and recusrively call.
_CI32NoRecurse:
		pla 								; remainder
		cmp 	#10 						; convert to ASCII, allowing for hexadecimal.
		bcc 	_CI32NotHex
		adc 	#6+32
_CI32NotHex:
		adc 	#48		
		sta 	numberBuffer,y 				; write out and exit		
		iny
		rts

		.send 	code
		
; ***************************************************************************************
;
;									Changes and Updates
;
; ***************************************************************************************
;
;		Date			Notes
;		==== 			=====
;
; ***************************************************************************************
