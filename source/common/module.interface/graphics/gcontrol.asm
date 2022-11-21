
; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		gcontrol.asm
;		Purpose:	GFX Control Commands
;		Created:	12th October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;									 Bitmap on/off/clear
;
; ************************************************************************************************

BitmapCtrl: ;; [bitmap]
		.cget 								; next keyword
		iny
		ldx 	#1
		cmp 	#KWD_ON
		beq 	BitmapSwitch
		dex
		cmp 	#KWD_OFF
		beq 	BitmapSwitch		
		jsr 	Evaluate8BitInteger 		; get the colour
		phy
		tax
		lda 	#GCMD_Clear					; clear to that colour
		jsr 	GXGraphicDraw
		ply
		rts
BitmapSwitch:
		phy
		ldy 	#0 							; gfx 1,on/off,0
		lda 	#GCMD_BitmapCtl
		jsr 	GXGraphicDraw
		lda 	#GCMD_Colour				; set colour to $FF
		ldy 	#0
		ldx 	#$FF
		jsr 	GXGraphicDraw
		stz 	gxFillSolid
		stz 	gxXPos
		stz 	gxXPos+1
		stz 	gxYPos
		stz 	gxDrawScale
		lda 	#GCMD_Move 						; home cursor
		ldx 	#0
		ldy 	#0
		jsr 	GXGraphicDraw
		ply
		rts

; ************************************************************************************************
;
;									 Sprites On/Off
;
; ************************************************************************************************

SpritesCtrl: ;; [sprites]
		.cget 								; next keyword
		iny
		ldx 	#1
		cmp 	#KWD_ON
		beq 	SpriteSwitch
		dex
		cmp 	#KWD_OFF
		beq 	SpriteSwitch		
		jmp 	SyntaxError
SpriteSwitch:
		phy
		ldy 	#0 							; gfx 2,on/off,0
		lda 	#GCMD_SpriteCtl
		jsr 	GXGraphicDraw
		ply
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
