; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		render.asm
;		Purpose:	Graphic Renderer
;		Created:	9th October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;							Render : A (size) YX (Data retrival)
;
; ************************************************************************************************

GXDrawGraphicElement:
		sta 	gxSize 						; save size 
		dec 	a
		sta 	gxMask 						; and mask

		lda 	gxY0 						; push Y on stack
		pha 

		stz 	gxVFlip 					; set the flip bytes
		stz 	gxHFlip
		bit 	gxUseMode
		bpl 	_GXNotVertical
		sta 	gxVFlip
_GXNotVertical:		
		bvc 	_GXNotHorizontal
		sta 	gxHFlip
_GXNotHorizontal:

		sty 	gxAcquireVector+1 			; and acquisition vector
		stx 	gxAcquireVector
		jsr 	gxOpenBitmap 				; open the bitmap.

		lda 	gxUseMode 					; scale bits
		lsr 	a
		lsr 	a
		lsr 	a
		and		#7
		inc 	a
		sta 	gxScale

		stz 	gzTemp1						; start first line
_GXGELoop:
		lda 	gzTemp1 					; current line number to read.
		eor 	gxVFlip
		tax 								; get the Xth line.
		jsr 	_GXCallAcquire 				; get that data.
		lda 	gxScale 					; do scale identical copies of that line.
		sta 	gzTemp1+1
_GXGELoop2:
		lda 	gxY0 						; off screen
		cmp 	gxHeight
		bcs 	_GXDGEExit

		jsr 	GXRenderOneLine 			; render line
		dec 	gzTemp1+1 					; scale times.
		bne 	_GXGELoop2		
		inc 	gzTemp1 					; done all lines.
		lda 	gzTemp1
		cmp 	gxSize
		bne 	_GXGELoop
_GXDGEExit:
		pla 								; restore Y for next time
		sta 	gxY0
		;
		ldx 	gxScale 					; get scale (1-8)
_GXShiftLeft:
		clc
		lda 	gxSize
		adc 	gxX0
		sta 	gxX0
		bcc 	_GXSLNoCarry
		inc 	gxX0+1
_GXSLNoCarry:
		dex
		bne 	_GXShiftLeft		

		jsr 	GXCloseBitmap
		rts		

_GXCallAcquire:
		jmp 	(gxAcquireVector)

; ************************************************************************************************
;
;										Render one line.
;
; ************************************************************************************************

GXRenderOneLine:
		jsr 	GXPositionCalc 				; calculate position/offset.
		ldy 	gsOffset 					; Y contains position.
		stz 	gzTemp2 					; do size pixels
_GXROLLoop1:
		lda 	gxScale 					; set to do 'scale' times
		sta 	gzTemp2+1
_GXROLLoop2:
		lda 	gzTemp2 					; get current pixel
		eor 	gxHFlip
		tax 								; read from the pixel buffer
		lda 	gxPixelBuffer,x
		beq 	_GXZeroPixel 				; don't draw if zero.
		lda 	(gsTemp),y
		and 	gxANDValue
		eor 	gxPixelBuffer,x
		sta 	(gsTemp),y
_GXZeroPixel:
		iny 								; advance pointer
		bne 	_GXNoShift
		inc 	gsTemp+1 					; carry to next
		jsr 	GXDLTCheckWrap				; check for new page.
_GXNoShift:		
		dec 	gzTemp2+1 					; do the inner loop gxScale times.
		bne 	_GXROLLoop2 
		inc 	gzTemp2 					; next pixel.
		lda 	gzTemp2
		cmp 	gxSize
		bne 	_GXROLLoop1
		inc 	gxY0
		rts

		.send code

		.section storage
gxSize:
		.fill 	1
gxMask:
		.fill 	1
gxAcquireVector:
		.fill 	2				
gxScale:
		.fill 	1		
gxVFlip:
		.fill 	1		
gxHFlip:
		.fill 	1		
gxUseMode:
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
