; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		graphics.asm
;		Purpose:	Graphics startup/test code.
;		Created:	6th October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;									Graphics Plot Routine
;
; ************************************************************************************************

GraphicDraw:
		cmp 	#$10*2 						; instructions 00-0F don't use 
		bcs 	_GDCoordinate
		;
		;		Non coordinate functions
		;
		stx 	gzTemp0 					; save X/Y
		sty 	gzTemp0+1
		bra 	_GDExecuteA 				; and execute
		;
		;		Coordinate functions
		;
_GDCoordinate:
		pha 								; save AXY
		phx 
		phy		
		ldx 	#3 							; copy currentX to lastX
_GDCopy1:		
		lda 	gxCurrentX,x
		sta 	gxLastX,x
		dex
		bpl 	_GDCopy1
		;
		pla 								; update Y
		sta 	gxCurrentY
		stz 	gxCurrentY+1
		;
		pla 
		sta 	gxCurrentX
		pla 								; get A (command+X.1) back
		pha
		and 	#1 							; put LSB as MSB of Current.X
		sta 	gxCurrentX+1
		;
		ldx 	#7 								; copy current and last to gxXY/12 work area
_GDCopy2:
		lda 	gxCurrentX,x
		sta 	gxX0,x
		dex
		bpl 	_GDCopy2		
		pla 								; get command back
		;
		;		Execute command X
		;		
_GDExecuteA:
		and 	#$FE 						; lose LSB
		tax
		jmp 	(GDVectors,x)

GXMove:
		rts

; ************************************************************************************************
;
;										Vector table
;
; ************************************************************************************************

GDVectors:
		.fill 	2 							; $00 		; Open/Close Bitmap
		.word 	GXClearBitmap 				; $01 	  	: Clear Bitmap to X		
		.fill 	14*2 						; $02-$0F 	: Reserved
		.word 	GXMove 						; $10     	: Move (does nothing other than update coords)
		.word 	GXLine 						; $11 		: Draw line
		.word 	GXFrameRectangle 			; $12 		; Framed rectangle
		.word 	GXFillRectangle 			; $13 		; Filled rectangle
		.word 	GXFrameEllipse 				; $14 		; Framed ellipse
		.word 	GXFillEllipse 				; $15 		; Filled ellipse
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
