; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		rect.asm
;		Purpose:	Rectangle/Solid Rectangle drawing code
;		Created:	8th October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;									Draw/Fill Rectangle
;
; ************************************************************************************************

GXFillRectangle: ;; [19:FillRect]
		sec
		bra 	GXRectangle
GXFrameRectangle: ;; [18:FrameRect]
		clc
GXRectangle:		
		php 								; save Fill flag (CS)
		jsr 	GXOpenBitmap 				; start drawing
		jsr 	GXSortXY 					; sort both X and Y so top left/bottom right
		;
		;		Do the top line first. 
		;
		jsr 	GXPositionCalc 				; setup gsTemp, gsOffset and the position.
		sec 								; sec = Draw line
		jsr 	GXDrawLineX1X0 				; draw a line length X1-X0		

		lda 	gxY0 						; reached end of rectangle ?
		cmp 	gxY1
		beq 	_GXRectangleExit
_GXRectLoop:
		jsr 	GXMovePositionDown 			; down one.
		inc 	gxY0 						; change Y pos
		lda 	gxY0 						; reached last line
		cmp 	gXY1
		beq 	_GXLastLine
		plp 								; get flag back
		php
		jsr 	GXDrawLineX1X0 				; draw horizontal line
		bra 	_GXRectLoop

_GXLastLine: 								; draw the last solid line.
		sec
		jsr 	GXDrawLineX1X0
_GXRectangleExit:
		pla 								; throw fill flag.		
		jsr 	GXCloseBitmap 				; stop drawing and exit
		clc
		rts

; ************************************************************************************************
;
;					Draw solid line/ends from current position length x1-x0
;
; ************************************************************************************************

GXDrawLineX1X0:
		php 								; save solid/either-end
		sec 								
		lda		gXX1
		sbc 	gXX0
		sta 	gzTemp0 	
		lda 	gXX1+1
		sbc 	gXX0+1
		sta 	gzTemp0+1
		plp
		;
; ************************************************************************************************
;
;					Draw solid line/ends from current position length gzTemp0
;
; ************************************************************************************************

GXDrawLineTemp0:		

		lda 	gsTemp 						; push gsTemp, gsOffset and GFXEditSlot on stack
		pha
		lda 	gsTemp+1
		pha
		lda 	gsOffset
		pha
		lda 	GFXEditSlot
		pha
		ldy 	gsOffset 					; Y offset
		bcc 	_GXDLTEndPoints 			; if CC draw end points only.
		;
		;		Draw solid line.
		;
_GXDLTLine:
		lda 	(gsTemp),y 					; set pixel
		.plotpixel
		sta 	(gsTemp),y
		;
		lda 	gzTemp0 					; decrement counter
		bne 	_GXDLTNoBorrow 
		dec 	gzTemp0+1 					; borrow, if goes -ve then exit
		bmi 	_GXDLTExit
_GXDLTNoBorrow:
		dec 	gzTemp0
		iny 								; next slot.
		bne 	_GXDLTLine		
		inc 	gsTemp+1 					; carry to next
		jsr 	GXDLTCheckWrap				; check for new page.
		bra 	_GXDLTLine
		;
		;		Draw end points only.
		;
_GXDLTEndPoints:
		lda 	(gsTemp),y 					; set pixel
		.plotpixel
		sta 	(gsTemp),y
		;
		tya 								; advance to right side
		clc
		adc 	gzTemp0
		tay
		lda 	gsTemp+1
		adc 	gzTemp0+1
		sta 	gsTemp+1
		jsr 	GXDLTCheckWrap 			; fix up.

		lda 	(gsTemp),y 					; set pixel on the right
		.plotpixel
		sta 	(gsTemp),y

_GXDLTExit: 								; restore screen position.
		pla
		sta 	GFXEditSlot
		pla
		sta 	gsOffset
		pla
		sta 	gsTemp+1
		pla
		sta 	gsTemp
		rts		
;
;		Check if gsTemp needs wrapping round.
;
GXDLTCheckWrap:
		lda 	gsTemp+1 					; check end of page
		cmp 	#((GXMappingAddress+$2000) >> 8) 
		bcc 	_GXDLTCWExit
		sbc 	#$20 						; fix up
		sta 	gsTemp+1
		inc 	GFXEditSlot
_GXDLTCWExit:	
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
