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
;								Reset bitmap, tiles and sprites
;
; ************************************************************************************************

ResetBitmapSpritesTiles:
		stz 	BitmapPageNumber
		stz 	SpritePageNumber
		stz 	TileMapPageNumber
		stz 	TileImagePageNumber
		lda 	#64
		sta 	TileMapWidth
		lda 	#32
		sta 	TileMapHeight
		rts

; ************************************************************************************************
;
;									 Bitmap on/off/clear/at
;
; ************************************************************************************************

BitmapCtrl: ;; [bitmap]
BitmapCtrlLoop:
		.cget 								; next keyword
		iny
		ldx 	#1
		cmp 	#KWD_ON
		beq 	BitmapSwitch
		dex
		cmp 	#KWD_OFF
		beq 	BitmapSwitch
		cmp 	#KWD_AT  					; set address
		beq 	BitmapAddress
		cmp 	#KWD_CLEAR
		beq 	BitmapClear
		dey
		rts
		;
		;		Set colour
		;		
BitmapClear:		
		jsr 	Evaluate8BitInteger 		; get the colour
		phy
		tax
		lda 	#GCMD_Clear					; clear to that colour
		jsr 	GXGraphicDraw
		ply
		bra 	BitmapCtrlLoop
		;
		;		Set Address.
		;
BitmapAddress:
		jsr 	GetPageNumber
		sta 	BitmapPageNumber
		bra 	BitmapCtrlLoop
		;
		;		Switch on/off
		;
BitmapSwitch:
		phy
		ldy 	BitmapPageNumber 			; gfx 1,on/off,0
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
		bra 	BitmapCtrlLoop

; ************************************************************************************************
;
;									 Sprites On/Off
;
; ************************************************************************************************

SpritesCtrl: ;; [sprites]
SpritesCtrlLoop:		
		.cget 								; next keyword
		iny
		ldx 	#1
		cmp 	#KWD_ON
		beq 	SpriteSwitch
		dex
		cmp 	#KWD_OFF
		beq 	SpriteSwitch		
		cmp 	#KWD_AT
		beq 	SpriteSetAddress
		dey
		rts
		;
		;		AT xxxxxx		
		;
SpriteSetAddress:		
		jsr 	GetPageNumber
		sta 	SpritePageNumber
		bra 	SpritesCtrlLoop
		;
		;		ON/OFF
		;
SpriteSwitch:
		phy
		ldy 	SpritePageNumber 			; gfx 2,on/off,0
		lda 	#GCMD_SpriteCtl
		jsr 	GXGraphicDraw
		ply
		bra 	SpritesCtrlLoop

; ************************************************************************************************
;
;									 Tiles On/Off
;
; ***********************************************************************************************

TilesCtrl: ;; [tiles]
TilesCtrlLoop:		
		.cget 								; next keyword
		iny
		ldx 	#$80
		cmp 	#KWD_ON
		beq 	TileSwitch
		ldx 	#$00
		cmp 	#KWD_OFF
		beq 	TileSwitch		
		cmp 	#KWD_AT
		beq 	TileSetAddress
		cmp 	#KWD_DIM
		beq 	TileSetSize
		dey
		rts
		;
		;		DIM x,y
		;
TileSetSize:
		ldx 	#0
		jsr 	Evaluate8BitInteger 		
		sta 	TileMapWidth		
		jsr 	CheckComma
		jsr 	Evaluate8BitInteger 		
		sta 	TileMapHeight
		bra 	TilesCtrlLoop
		;
		;		AT xx,xx
		;
TileSetAddress:		
		jsr 	GetPageNumber 				; map page
		sta 	TileMapPageNumber
		jsr 	CheckComma
		jsr 	GetPageNumber 				; image page
		sta 	TileImagePageNumber
		bra 	TilesCtrlLoop
		;
		;		ON/OFF and seet up.
		;
TileSwitch:
		phy

		phx 								; set the on/off state and the pages.
		txa
		ora 	TileMapPageNumber
		tax
		ldy 	TileImagePageNumber
		lda 	#GCMD_TileCtl
		jsr 	GXGraphicDraw
		plx
		bpl 	TilesCtrlLoop 				; nothing else.

		lda 	#GCMD_TileSize 				; set size of tile map.
		ldx 	TileMapWidth
		ldy 	TileMapHeight
		jsr 	GXGraphicDraw

		lda 	#GCMD_TileScrollX 			; reset scroll
		jsr 	_TileResetScroll
		lda 	#GCMD_TileScrollY
		jsr 	_TileResetScroll
		ply
		jmp 	TilesCtrlLoop

_TileResetScroll:
		ldx 	#0
		ldy 	#0
		jmp 	GXGraphicDraw
; ************************************************************************************************
;
;							Get a valid page number via its address
;
; ************************************************************************************************

GetPageNumber:
		ldx 	#0
		jsr 	EvaluateUnsignedInteger 	; evaluate where to go.
		;
		lda 	NSMantissa1 				; check on page
		and 	#$1F
		ora 	NSMantissa0
		bne 	_GPNError
		;
		lda 	NSMantissa2
		asl 	NSMantissa1					; get page number
		rol 	a
		asl 	NSMantissa1		
		rol 	a
		asl 	NSMantissa1		
		rol 	a
		rts

_GPNError:
		.error_argument

		.send code

		.section storage

BitmapPageNumber:
		.fill 	1
SpritePageNumber:
		.fill 	1
TileMapPageNumber:
		.fill 	1
TileImagePageNumber:		
		.fill 	1
TileMapWidth:
		.fill 	1
TileMapHeight:
		.fill 	1

		.send 	storage	

; ************************************************************************************************
;
;									Changes and Updates
;
; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;		11/02/23 		Chaining BITMAP and SPRITES command.
;
; ************************************************************************************************
