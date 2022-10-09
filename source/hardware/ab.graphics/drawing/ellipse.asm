; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		ellipse.asm
;		Purpose:	Ellipse drawing code
;		Created:	9th October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;									Draw/Fill Ellipse
;
; ************************************************************************************************

GXFillEllipse:
		sec
		bra 	GXEllipse
GXFrameEllipse:
		clc
GXEllipse:		
		php 								; save Fill flag (CS)
		jsr 	GXSortXY 					; topleft/bottomright
		jsr 	GXOpenBitmap 				; start drawing		
		jsr 	GXEllipseSetup 				; set up for drawing
_GXEllipseDraw:
		lda 	gX 							; while x <= y
		cmp 	gY
		beq 	_GXEllipseContinue
		bcc 	_GXEllipseContinue
		plp 								; throw fill flag.
		jsr 	GXCloseBitmap 				; close the bitmap
		rts

_GXEllipseContinue:
		.debug
		jsr 	GXEllipseMove 				; adjust the coordinates		
		bra 	_GXEllipseDraw

; ************************************************************************************************
;
;						Adjust coordinates (e.g. the coord change part)
;
; ************************************************************************************************

GXEllipseMove:
		
; ************************************************************************************************
;
;										Ellipse setup
;
; ************************************************************************************************

GXEllipseSetup:
		;
		;		Calculate R (y1-y0)/2
		;
		sec
		lda 	gxY1
		sbc 	gxY0
		lsr 	a
		sta 	gRadius
		;
		;		Calculate centres (x0+x1)/2
		;
		ldx 	#0
		jsr 	_GXCalculateCentre
		ldx 	#2
		jsr 	_GXCalculateCentre
		;
		;		X = 0, Y = R
		;
		stz 	gX
		lda 	gRadius
		sta 	gY
		;
		;		d = 3 - 2 x R
		;
		asl 	a 							; R x 2
		sta 	gzTemp0
		sec		
		lda 	#3
		sbc 	gzTemp0	
		sta 	gzTemp1
		lda 	#0
		sbc 	#0
		sta 	gzTemp1+1
		rts
;
;		Calculates midpoint for X/Y
;
_GXCalculateCentre:
		sec
		lda 	gxX1,x
		sbc 	gXX0,x
		sta 	gXX1,x
		lda 	gXX1+1,x
		sbc 	gXX0+1,x
		lsr 	a
		sta 	gXX1+1,x
		ror 	gXX1,x
		rts

		.send code

		.section storage
gRadius:
		.fill 	1
gX:
		.fill 	1		
gY:
		.fill 	1		
		.send storage

; ************************************************************************************************
;
;		Usage
;			gsTemp and gsOffset are used as usual
;			gzTemp0 holds the line length and is general workspace.
;			x1,y1 hold the ellipse centre
;			gX,gY are the coordinates x,y (note x, y both < 128)
;			d is stored in gzTemp1 (2 bytes)
;			r is stored in gRadius
;
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
