; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		line.asm
;		Purpose:	Line drawing code
;		Created:	6th October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;		For GXX0,GXY0 calculate position in gsTemp, offset in gsOffset and select current
;		segment.
;
; ************************************************************************************************
;
;		The main calculation is GXY0*320 = GXY0 * 5 * 64
;
GXPositionCalc:
		;
		;		Calculate GXY0 * 5 => gsTemp
		;
		lda 	GXY0 						; gsTemp = Y0
		sta 	gsTemp
		stz 	gsTemp+1
		;
		asl 	gsTemp 						; gsTemp = Y0 * 4
		rol 	gsTemp+1
		asl 	gsTemp
		rol 	gsTemp+1
		;
		clc 								; gsTemp = Y0 * 5, as it's still in A
		adc 	gsTemp
		sta 	gsTemp
		bcc 	_GXPCNoCarry
		inc 	gsTemp+1
_GXPCNoCarry:
		asl 	gsTemp 						; now Y0 * 10. Needs to be multiplied by another
		rol 	gsTemp+1 					; 32. At this point the MSB contains the offset
		lda	 	gsTemp+1 					; so save this in zTemp0 and zero it.
		sta 	gzTemp0 					
		stz 	gsTemp+1
		;
		lda 	#5 							; now multiply by 32, this puts this in the range 0..8191
_GXPCMultiply32:
		asl 	gsTemp
		rol 	gsTemp+1
		dec 	a
		bne 	_GXPCMultiply32
		;
		clc
		lda 	GXX0 						; add X to this value, put the result in gsOffset, gsTemp has to be on a page boundary
		adc 	gsTemp 						
		sta 	gsOffset
		lda 	GXX0+1
		adc 	gsTemp+1
		;
		cmp 	#$20 						; has it overflowed into the next one ?
		bcc 	_GXPCNoOverflow
		and 	#$1F 						; fix it up
		inc 	gzTemp0 					; add 1 to the page number
_GXPCNoOverflow:
		ora 	#(GXMappingAddress >> 8) 	; make it the address mapped in.
		sta 	gsTemp+1
		stz 	gsTemp
		;
		clc
		lda 	gzTemp0 					; get the page number
		adc 	gxBasePage 					; by adding the base page
		sta 	GFXEditSlot 				; and map it into memory.
		rts

; ************************************************************************************************
;
;						Move the (gsTemp),gsOffset down one line
;
; ************************************************************************************************

GXMovePositionDown:
		clc 								; add 320 to offset/temp+1
		lda 	gsOffset
		adc 	#64
		sta 	gsOffset
		lda 	gsTemp+1
		adc 	#1
		sta 	gsTemp+1
		cmp 	#((GXMappingAddress+$2000) >> 8) ; on to the next page
		bcc 	_GXMPDExit
		sec  								; next page
		sbc 	#$20 	
		sta 	gsTemp+1
		inc 	GFXEditSlot
_GXMPDExit:
		rts		
		.send 	code

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
