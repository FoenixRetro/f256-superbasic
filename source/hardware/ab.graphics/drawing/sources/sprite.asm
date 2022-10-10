; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		sprite.asm
;		Purpose:	Sprite Source Handler
;		Created:	9th October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;								Access from Sprite Memory
;
; ************************************************************************************************

GXSpriteHandler:
		lda 	#GXSpritePage
		sta 	GXspriteBasePage
		lda 	#8
		ldx 	#GXSpriteAcquire & $FF
		ldy 	#GXSpriteAcquire >> 8
		jsr 	GXDrawGraphicElement
		rts

GXSpriteAcquire:
		lda 	GXspriteBasePage		
		sta 	GFXEditSlot
		ldy 	#0
		txa
		asl 	a
		asl 	a
		asl 	a
		tax
_GXSALoop:
		lda 	GXMappingAddress+$200,x
		inx
		sta 	gxPixelBuffer,y
		iny
		cpy 	#8
		bne 	_GXSALoop
		rts

		.send code

		.section storage
GXspriteBasePage:
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
