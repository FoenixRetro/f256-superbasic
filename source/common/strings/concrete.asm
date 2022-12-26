; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		concrete.asm
;		Purpose:	Concrete string
;		Created:	30th September 2022
;		Reviewed: 	28th November 2022
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;									Concrete the string at S[X]
;
; ************************************************************************************************

StringConcrete:
		phy 								; save position on stack
		jsr 	CheckIdentifierStringSpace 	; check memory allocation.
		;
		;		ZTemp0 points to the string to be concreted.
		;
		lda 	NSMantissa0,x 				; copy target string to zTemp1
		sta 	zTemp1
		lda 	NSMantissa1,x
		sta 	zTemp1+1
		;
		ldy 	#$FF	 					; calculate string length
_SALength:
		iny
		lda 	(zTemp1),y
		bne 	_SALength
		cpy 	#253 						; string too long - cannot concrete.
		bcs 	_SALengthError

		tya 				 				; length of the new string
		clc 
		adc 	#5+3 						; add 5 characters total plus 3 (length,status,EOS)
		bcc 	_SAHaveLength
		lda 	#255 						; string max length is 255
_SAHaveLength:
		pha 								; save length.
		;
		sec
		eor 	#$FF 						; add to StringMemory using 2's complement
		adc 	stringMemory
		sta 	stringMemory
		sta 	zTemp2 						; update storage address
		sta 	NSMantissa0,x 				; update mantissa address
		;
		lda 	#$FF 						; now do the MSB
		adc 	stringMemory+1
		sta 	stringMemory+1
		sta 	zTemp2+1
		sta 	NSMantissa1,x
		;
		pla 								; save length-3 (chars allowed) in first byte
		sec
		sbc 	#3
		sta 	(zTemp2)
		lda 	#0 							; clear the status byte.
		ldy 	#1
		sta 	(zTemp2),y		
		;
		;		Copy string into the space
		;
_SACopyNewString:
		ldy 	#0
_SACopyNSLoop:
		lda 	(zTemp1),y 					; get character
		iny 								; write two on in string storage
		iny
		sta 	(zTemp2),y
		dey 								; this makes it one one.
		cmp 	#0 							; until EOS copied
		bne 	_SACopyNSLoop
		ply
		rts		

_SALengthError:
		.error_string

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
