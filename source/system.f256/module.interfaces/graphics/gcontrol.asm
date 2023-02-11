
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
;									 Bitmap on/off/clear/at
;
; ************************************************************************************************

BitmapCtrl: ;; [bitmap]
		stz 	BitmapPageNumber
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
		.send 	storage	

; ************************************************************************************************
;
;									Changes and Updates
;
; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;		11/02/23 		Chaining BITMAP command.
;
; ************************************************************************************************
