; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		find.asm
;		Purpose:	Get address, size and LUT of sprite (address is offset from base)
;		Created:	10th October 2022
;		Reviewed: 	17th February 2022
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;					Get address, size and LUT of sprite A (assume already opened)
;					in sprite data structure. Returns CS if bad sprite, CC if okay.
;
; ************************************************************************************************

GXFindSprite:
		tax

		lda 	gxSpritePage 				; access the base page of the sprite
		sta 	GXEditSlot
		;
		lda 	GXMappingAddress+256,x 		; check a valid sprite
		ora 	GXMappingAddress,x
		beq 	_GXFSFail
		;
		lda 	GXMappingAddress+256,x 		; MSB
		sta 	gxSpriteOffset+1
		;
		lda 	GXMappingAddress,x 			; LSB
		pha 								; save twice
		pha
		and 	#3 							; get sprite size
		sta 	gxSizeBits 					; save raw (0-3)
		tax
		lda 	_GXFXSSTTable,x 			; read sprite size
		sta 	gxSizePixels 				; save (8/16/24/32)

		pla 								; get LUT
		lsr		a
		lsr		a
		and 	#3
		sta 	gxSpriteLUT
		;
		pla 								; address, neeeds to be x 4
		and 	#$F0
		sta 	gxSpriteOffset

		asl 	gxSpriteOffset
		rol 	gxSpriteOffset+1
		asl 	gxSpriteOffset
		rol 	gxSpriteOffset+1

		clc
		rts
_GXFSFail:
		sec
		rts
	;

_GXFXSSTTable:
		.byte 	8,16,24,32

		.send code
		.section storage

gxSizePixels: 									; sprite size (in pixels)
		.fill 	1
gxSizeBits: 								; size (0-3)
		.fill 	1
gxSpriteLUT: 									; LUT to use
		.fill 	1
gxSpriteOffset: 								; offset from base page.
		.fill 	2

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