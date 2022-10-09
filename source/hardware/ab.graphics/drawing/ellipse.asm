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
		lda 	#255
		bra 	GXEllipse
GXFrameEllipse:
		lda 	#0
GXEllipse:		
		sta 	gIsFillMode					; save Fill flag 
		jsr 	GXSortXY 					; topleft/bottomright
		jsr 	GXOpenBitmap 				; start drawing		
		jsr 	GXEllipseSetup 				; set up for drawing
_GXEllipseDraw:
		lda 	gX 							; while x <= y
		cmp 	gY
		beq 	_GXEllipseContinue
		bcc 	_GXEllipseContinue
		jsr 	GXCloseBitmap 				; close the bitmap
		rts

_GXEllipseContinue:
		jsr 	GXPlot2 					; draw it
		jsr 	GXEllipseMove 				; adjust the coordinates		
		bra 	_GXEllipseDraw

; ************************************************************************************************
;
;									Plot line/points
;
; ************************************************************************************************

GXPlot2:	
		jsr 	GXPlot1 						; plot and swap, fall through does twice
GXPlot1:	
		jsr 	GXPlot0 						; plot and negate
		jsr 	_GXSwapXY
		jsr 	GXPlot0 						; twice, undoing negation
		jsr 	_GXSwapXY
		rts

_GXSwapXY:		
		lda 	gX 								; swap X and Y
		ldx	 	gY
		sta 	gY
		stx 	gX
		rts
		;
		;		Draw offset gX (always +ve) gY (can be -ve)
		;
GXPlot0:
		ldx 	#2 								; copy Y1-A => Y0
		lda 	gY
		jsr 	_GXSubCopy
		ldx 	#0 								; copy X1-A => X0, 
		lda 	gX
		jsr 	_GXSubCopy 
		pha 									; save last offset X
		jsr 	GXPositionCalc 					; calculate position/offset.
		pla
		;
		asl 	a 								; store 2 x last offset in gzTemp0
		sta 	gzTemp0 		
		stz 	gzTemp0+1
		rol 	gzTemp0+1

		lda 	gIsFillMode
		adc 	#128
		jsr 	GXDrawLineTemp0 				; routine from Rectangle.

		sec 									; GY = -GY
		lda 	#0
		sbc 	gY
		sta 	gY
_GXPlot0Exit:		
		rts		
;
;		16 bit calc of XY1 - A => XY0 ; A is in gzTemp0
;		
_GXSubCopy:
		sta 	gzTemp0
		stz 	gzTemp0+1
		and 	#$80
		beq 	_GXNoSx
		dec 	gzTemp0+1
_GXNoSx:		
		;
		sec
		lda 	gXX1,x
		sbc 	gzTemp0
		sta 	gXX0,x
		lda 	gXX1+1,x
		sbc 	gzTemp0+1
		sta 	gXX0+1,x
		lda 	gzTemp0 						; return A
		rts

; ************************************************************************************************
;
;						Adjust coordinates (e.g. the coord change part)
;
; ************************************************************************************************

GXEllipseMove:
		stz 	gYChanged 					; clear Y changed flag
		lda 	gzTemp1+1 					; check sign of D
		bpl 	_GXEMPositive
		;
		;		D < 0 : inc X, add 4x+6
		;
		inc 	gX 							; X++
		lda 	gX 							
		jsr 	_GXAdd4TimesToD 			; add 4 x A to D
		lda 	#6  						; and add 6
		bra 	_GXEMAddD
		;
		;		D >= 0 : inc X, dec Y, add 4(x-y)+10
		;
_GXEMPositive:
		inc 	gX 							; X++
		dec 	gy 							; Y--
		;
		sec 								; calculate X-Y
		lda 	gX
		sbc 	gY
		jsr 	_GXAdd4TimesToD 			; add 4 x A to D
		lda 	#10  						; and add 10
		dec 	gYChanged
_GXEMAddD:
		clc
		adc 	gzTemp1
		sta 	gzTemp1
		bcc 	_GXEMNoCarry
		inc 	gzTemp1+1
_GXEMNoCarry:		
		rts	
;
;		Add 4 x A (signed) to D
;
_GXAdd4TimesToD:
		sta 	gzTemp0 					; make 16 bit signed.
		and 	#$80
		beq 	_GXA4Unsigned
		lda 	#$FF
_GXA4Unsigned:
		sta 	gzTemp0+1
		;
		asl 	gzTemp0  					; x 4
		rol 	gzTemp0+1
		asl 	gzTemp0 
		rol 	gzTemp0+1
		;
		clc 								; add
		lda		gzTemp0
		adc 	gzTemp1
		sta 	gzTemp1
		lda		gzTemp0+1
		adc 	gzTemp1+1
		sta 	gzTemp1+1
		rts

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
		adc 	gXX0,x
		sta 	gXX1,x
		lda 	gXX1+1,x
		adc 	gXX0+1,x
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
gIsFillMode:
		.fill 	1		
gYChanged:
		.fill  	1		
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
