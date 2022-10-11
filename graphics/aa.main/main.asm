; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		main.asm
;		Purpose:	Graphics main entry point.
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
		ldx 	#7 							; copy current and last to gxXY/12 work area
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
		.fill 	2*2 						; $00-$01 	; Open/Close Bitmap/Sprites
		.word 	GXClearBitmap 				; $02 	  	: Clear Bitmap to X		
		.word 	GXSetColourMode 			; $03 		; Set colour and drawing mode
		.word 	GXFontHandler 				; $04 		; Draw from font
		.word 	GXSpriteHandler 			; $05 		; Draw from sprite
		.fill 	10*2 						; $06-$0F 	: Reserved
		.word 	GXMove 						; $10     	: Move (does nothing other than update coords)
		.word 	GXLine 						; $11 		: Draw line
		.word 	GXFrameRectangle 			; $12 		; Framed rectangle
		.word 	GXFillRectangle 			; $13 		; Filled rectangle
		.word 	GXFrameCircle 				; $14 		; Framed circle
		.word 	GXFillCircle 				; $15 		; Filled circle

; ************************************************************************************************
;
;								Set colour, mode (bits 0 & 1)
;
; ************************************************************************************************

GXSetColourMode:
		ldx 	gzTemp0
		stx 	gxColour 								; set colour
		lda 	gzTemp0+1 								;
		sta 	gxMode 									; set mode
		;
		;		Now process bits 0/1 to set the drawing type. Normal (0) EOR (1) AND (2) OR (3)
		;
		and 	#3 										; only interested in bits 0-3
		stz 	gxANDValue 								; initially AND with 0, and EOR with Colour
		ldx 	gxColour
		stx 	gxEORValue
		cmp 	#2 										; if mode 2/3 And with colour
		bcc 	_GXSDCNotAndColour
		stx 	gxANDValue
_GXSDCNotAndColour:		
		bne 	_GXSDCNotAnd 							; mode 2, Don't EOR with colour
		stz 	gxEORValue
_GXSDCNotAnd:
		lsr 	a 										; if bit 0 set, 1's complement AND value		
		bcc 	_GXSDCNoFlip
		lda	 	gxANDValue
		eor 	#$FF
		sta 	gxANDValue
_GXSDCNoFlip:
		rts		

; ************************************************************************************************
;											DRAWING MODES
; ************************************************************************************************
;
;		Mode 0: AND 0 EOR Colour 				Sets Colour
;		Mode 1: AND $FF EOR Colour 				Exclusive Or Colour
; 		Mode 2: And Colour:EOR 0 				AND with Colour.
;		Mode 3: AND ~Colour EOR Colour 			Or Colour
;
; ************************************************************************************************

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
