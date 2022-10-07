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
;									Draw line (see lines2.py)
;
; ************************************************************************************************

GXLine:
		jsr 	GXSortY						; sort pairs so Y1 >= Y0 e.g. top to bottom.
		jsr 	GXLineSetup 				; the calculations in the linescanner constructor
_GXDrawLoop:
		jsr 	GXLineIsComplete 			; is the line complete ?		
		beq 	_GXLExit
		jsr 	GXLineAdvance 				; code as per advance method
		bra 	_GXDrawLoop
_GXLExit:
		rts

; ************************************************************************************************
;
;								Is line complete , return Z if so
;
; ************************************************************************************************

GXLineIsComplete:
		lda 	GXIsDiffYLarger 			; is dy larger
		bne 	_GXLICCompareY 				; if so compare Y1/Y0

		lda 	GXX0 						; compare X, LSB and MSB
		eor 	GXX1		
		bne 	_GXLICExit
		lda 	GXX0+1
		eor 	GXX1+1		
_GXLICExit:
		rts

_GXLICCompareY: 							; compare Y
		lda 	GXY1
		eor 	GXY0		
		rts

; ************************************************************************************************
;
;								  Advance the line position
;
; ************************************************************************************************

GXLineAdvance:
		clc 								; add adjust to position
		lda 	GXAdjust
		adc 	GXPosition
		sta 	GXAdjust
		stz 	GXAddSelect 				; clear add select flag
		cmp 	GXTotal 					; if exceeded total
		bcc 	_GXLANoExtra
		dec 	GXAddSelect 				; set addselect to $FF
		sec 								; subtract total and write back
		sbc 	GXTotal 		
		sta 	GXAdjust
_GXLANoExtra:		
		lda 	GXIsDiffYLarger
		beq 	_GXDXLarger
		;
		;		dy larger, so always do y and sometimes x
		;
		jsr 	GXIncrementY
		lda 	GXAddSelect
		beq 	_GXLAExit
		jsr 	GXAdjustX
		bra 	_GXLAExit
		;
		;		dx larger, so always do x and sometimes Y
		;
_GXDXLarger:
		jsr 	GXAdjustX
		lda 	GXAddSelect
		beq 	_GXLAExit
		jsr 	GXIncrementY
_GXLAExit:
		rts

; ************************************************************************************************
;
;										 Advance X/Y
;
; ************************************************************************************************

GXAdjustX:
		lda 	GXDXNegative
		bpl 	_GXAXRight
		;
		;		Go left.
		;
		lda 	GXX0
		bne 	_GXAXNoBorrow
		dec 	GXX0+1
_GXAXNoBorrow:
		dec 	GXX0
		rts
		;
		;		Go right.
		;	
_GXAXRight:		
		inc 	GXX0
		bne 	_GXAXNoCarry
		inc 	GXX0+1
_GXAXNoCarry:
		rts

GXIncrementY:
		inc 	GXY0
		rts


; ************************************************************************************************
;
;										Set up the draw
;
; ************************************************************************************************

GXLineSetup:
		;
		; 		diffY = (y1 - y0) / 2
		;
		lda 	GXY1 						
		sec
		sbc 	GXY0
		lsr 	a
		sta 	GXDiffY
		;
		; 		diffX = |(x1-x0)|/2 , and set the flag for dX being negative.
		;
		stz 	GXDXNegative 				; clear -ve flag
		sec 								
		lda 	GXX1
		sbc 	GXX0
		sta 	GXDiffX
		;
		lda 	GXX1+1 						; calculate MSB
		sbc 	GXX0+1
		ror 	a 							; rotate bit into DiffX halving it
		ror 	GXDiffX
		asl 	a
		bpl 	_GDXNotNegative 			
		lda 	#0 							; make absolute value of |dx|
		sec
		sbc 	GXDiffX
		sta 	GXDiffX
		dec 	GXDXNegative 				; -ve flag = $FF.
_GDXNotNegative:		
		;
		; 		See if dy > dx, and set adjust and total accordingly.
		;
		stz 	GXIsDiffYLarger 			; clear larger flag

		lda 	GXDiffY 					; set adjust and total.
		sta 	GXAdjust
		lda 	GXDiffX
		sta 	GXTotal

		lda 	GXDiffY 					; if dy > dx
		cmp 	GXDiffX
		bcc 	_GDXNotLarger
		dec 	GXIsDiffYLarger 			; set the dy larger flag
		lda 	GXDiffX 					; set adjust and total other way round
		sta 	GXAdjust
		lda 	GXDiffY
		sta 	GXTotal
_GDXNotLarger:			
		;
		;		Pos = total / 2
		;
		lda 	GXTotal
		lsr 	a
		sta 	GXPosition
		rts

		.send code

; ************************************************************************************************
;
;										Data for Line drawing
;
; ************************************************************************************************

		.section storage
GXDiffX:
		.fill 	1
GXDiffY:
		.fill 	1
GXIsDiffYLarger:
		.fill 	1		
GXDXNegative:
		.fill 	1
GXPosition:
		.fill 	1		
GXAdjust:
		.fill 	1
GXTotal:		
		.fill 	1
GXAddSelect:
		.fill 	1

		.send storage

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
