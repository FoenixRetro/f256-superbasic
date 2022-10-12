
; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		gcommands.asm
;		Purpose:	GFX commands
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
		lda 	#3*2						; clear to that colour
		jsr 	GXGraphicDraw
		ply
		rts
BitmapSwitch:
		phy
		ldy 	#0 							; gfx 1,on/off,0
		lda 	#1*2
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
		lda 	#2*2
		jsr 	GXGraphicDraw
		ply
		rts

		.send code

		.section storage

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
