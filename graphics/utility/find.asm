; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		find.asm
;		Purpose:	Get address, size and LUT of sprite (address is offset from base)
;		Created:	10th October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;					Get address, size and LUT of sprite A (assume already opened)
;					Returns CS if bad sprite, CC if okay.
;
; ************************************************************************************************

GXFindSprite:
		tax

		lda 	GXSpritePage 				; access the base page of the sprite
		sta 	GXEditSlot
		;
		lda 	GXMappingAddress+256,x 		; check a valid sprite
		ora 	GXMappingAddress,x
		beq 	_GXFSFail
		;
		lda 	GXMappingAddress+256,x 		; MSB
		sta 	GXSpriteOffset+1
		;
		lda 	GXMappingAddress,x 			; LSB
		pha 								; save twice
		pha

		and 	#3 							; get sprite size
		sta 	GXSizeBits 					; save raw (0-3)
		tax
		lda 	_GXFXSSTTable,x 			; read sprite size
		sta 	GXSizePixels 					; save (8/16/24/32)

		pla 								; get LUT
		lsr		a
		lsr		a
		and 	#3
		sta 	GXSpriteLUT
		;
		pla 								; address, neeeds to be x 4
		and 	#$F0
		sta 	GXSpriteOffset

		asl 	GXSpriteOffset
		rol 	GXSpriteOffset+1
		asl 	GXSpriteOffset
		rol 	GXSpriteOffset+1

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

GXSizePixels: 									; sprite size (in pixels)
		.fill 	1
GXSizeBits: 								; size (0-3)
		.fill 	1		
GXSpriteLUT: 									; LUT to use
		.fill 	1		
GXSpriteOffset: 								; offset from base page.
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
