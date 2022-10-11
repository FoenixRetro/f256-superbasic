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
;		For GXX0,GXY0 calculate position in gxzScreen, offset in gsOffset and select current
;		segment.
;
; ************************************************************************************************
;
;		The main calculation is GXY0*320 = GXY0 * 5 * 64
;
GXPositionCalc:
		lda 	gxzTemp0 					; save temp memory slot
		pha
		;
		;		Calculate GXY0 * 5 => gxzScreen
		;
		lda 	GXY0 						; gxzScreen = Y0
		sta 	gxzScreen
		stz 	gxzScreen+1
		;
		asl 	gxzScreen 						; gxzScreen = Y0 * 4
		rol 	gxzScreen+1
		asl 	gxzScreen
		rol 	gxzScreen+1
		;
		clc 								; gxzScreen = Y0 * 5, as it's still in A
		adc 	gxzScreen
		sta 	gxzScreen
		bcc 	_GXPCNoCarry
		inc 	gxzScreen+1
_GXPCNoCarry:
		asl 	gxzScreen 						; now Y0 * 10. Needs to be multiplied by another
		rol 	gxzScreen+1 					; 32. At this point the MSB contains the offset
		lda	 	gxzScreen+1 					; so save this in zTemp0 and zero it.
		sta 	gxzTemp0 					
		stz 	gxzScreen+1
		;
		lda 	#5 							; now multiply by 32, this puts this in the range 0..8191
_GXPCMultiply32:
		asl 	gxzScreen
		rol 	gxzScreen+1
		dec 	a
		bne 	_GXPCMultiply32
		;
		clc
		lda 	GXX0 						; add X to this value, put the result in gsOffset, gxzScreen has to be on a page boundary
		adc 	gxzScreen 						
		sta 	gsOffset
		lda 	GXX0+1
		adc 	gxzScreen+1
		;
		cmp 	#$20 						; has it overflowed into the next one ?
		bcc 	_GXPCNoOverflow
		and 	#$1F 						; fix it up
		inc 	gxzTemp0 					; add 1 to the page number
_GXPCNoOverflow:
		ora 	#(GXMappingAddress >> 8) 	; make it the address mapped in.
		sta 	gxzScreen+1
		stz 	gxzScreen
		;
		clc
		lda 	gxzTemp0 					; get the page number
		adc 	gxBasePage 					; by adding the base page
		sta 	GXEditSlot 				; and map it into memory.
		;
		pla 
		sta 	gxzTemp0
		rts

; ************************************************************************************************
;
;						Move the (gxzScreen),gsOffset down one line
;
; ************************************************************************************************

GXMovePositionDown:
		clc 								; add 320 to offset/temp+1
		lda 	gsOffset
		adc 	#64
		sta 	gsOffset
		lda 	gxzScreen+1
		adc 	#1
		sta 	gxzScreen+1
		cmp 	#((GXMappingAddress+$2000) >> 8) ; on to the next page
		bcc 	_GXMPDExit
		sec  								; next page
		sbc 	#$20 	
		sta 	gxzScreen+1
		inc 	GXEditSlot
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
