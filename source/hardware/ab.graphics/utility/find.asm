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
;
; ************************************************************************************************

GXFindSprite:
		tax

		lda 	GXSpriteBasePage 			; access the base page of the sprite
		sta 	GFXEditSlot
		;
		lda 	GXMappingAddress+256,x 		; MSB
		sta 	GXSAddress+1
		;
		lda 	GXMappingAddress,x 			; LSB
		pha 								; save twice
		pha

		and 	#3 							; get sprite size
		sta 	GXSSizeRaw 					; save raw (0-3)
		tax
		lda 	_GXFXSSTTable,x 			; read sprite size
		sta 	GXSSize 					; save (8/16/24/32)

		pla 								; get LUT
		lsr		a
		lsr		a
		and 	#3
		sta 	GXSLUT
		;
		pla 								; address, neeeds to be x 4
		and 	#$F0
		sta 	GXSAddress

		asl 	GXSAddress
		rol 	GXSAddress+1
		asl 	GXSAddress
		rol 	GXSAddress+1

		rts
	;		

_GXFXSSTTable:
		.byte 	8,16,24,32	

		.send code
		.section storage
GXSSize: 									; sprite size (in pixels)
		.fill 	1
GXSSizeRaw: 								; size (0-3)
		.fill 	1		
GXSLUT: 									; LUT to use
		.fill 	1		
GXSAddress: 								; offset from base page.
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
