; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		sprite.asm
;		Purpose:	Sprite Functions
;		Created:	11th October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;									Select and show/hide sprite
;
; ************************************************************************************************

GXSelect: ;; [6:SPRUSE]
		lda 	gxzTemp0 					; illegal sprite #
		cmp 	#64
		bcs 	_GXSFail

		ldy 	gxzTemp0+1 					; control value.
		lda  	#0 							; multiply sprite # x 8 => A
		asl 	gxzTemp0
		asl 	gxzTemp0
		asl 	gxzTemp0
		rol 	a
		adc 	#$D9 						; sprite area
		sta 	GSCurrentSprite+1 			; address to GSCurrentSprite and gxzTemp
		sta 	gxzTemp0+1
		lda 	gxzTemp0
		sta 	GSCurrentSprite
		;
		tya 								; control value
		and 	#1 
		stz 	1 							; access sprite control.
		sta 	(gxzTemp0) 					; write to control register		

		lda 	#64
		sta 	$D91C
		sta 	$D91E

		clc
		rts

_GXSFail:
		sec
		rts		

; ************************************************************************************************
;
;									Select sprite image
;
; ************************************************************************************************

GXSelectImage: ;; [7:SPRIMG]
		lda 	GSCurrentSprite+1 			; check sprite selected
		beq 	_GXSIFail

		lda 	gxzTemp0 					; sprite image
		pha
		jsr 	GXOpenBitmap

		pla		
		jsr 	GXFindSprite

		ldy 	#1
		lda 	GSCurrentSprite
		sta 	gxzTemp0
		lda 	GSCurrentSprite+1
		sta 	gxzTemp0+1

		lda 	GXSpriteOffset
		sta	 	(gxzTemp0),y
		clc
		lda 	GXSpriteOffset+1
		adc 	GXSpriteOffsetBase
		iny
		sta	 	(gxzTemp0),y

		lda 	GXSpriteOffsetBase+1
		adc 	#0
		iny
		sta	 	(gxzTemp0),y

		lda 	(gxzTemp0)					; get LSB into gxzTemp1
		and 	#1
		sta 	gxzTemp1

		lda 	GXSizeBits 					; get raw size
		eor 	#3 							; make it right (00=32 etc.)
		rol 	a 							; x 2
		asl 	a 							; x 4
		asl 	a 							; x 8
		asl 	a 							; x 16
		ora 	GXSpriteLUT 						; Or with LUT
		asl 	a 							; 1 shift
		ora 	gxzTemp1 					; Or in the enable bit
		sta 	(gxzTemp0) 					; and write back

		jsr 	GXCloseBitmap 				
		clc
		rts

_GXSIFail:
		sec
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
