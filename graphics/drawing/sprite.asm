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

GXSelect: ;; [7:SPRUSE]
		lda 	gxSpritesOn
		beq 	_GXSFail

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

GXSelectImage: ;; [8:SPRIMG]
		lda 	gxSpritesOn
		beq 	_GXSIFail

		lda 	GSCurrentSprite+1 			; check sprite selected
		beq 	_GXSIFail

		stz 	1

		lda 	gxzTemp0+1 					; push show/hide on the stack.
		bne 	_GXSIHide

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

		lda 	GXSizeBits 					; get raw size
		eor 	#3 							; make it right (00=32 etc.)
		rol 	a 							; x 2
		asl 	a 							; x 4
		asl 	a 							; x 8
		asl 	a 							; x 16
		ora 	GXSpriteLUT 						; Or with LUT
		asl 	a 							; 1 shift
		ora 	#1 							; enable sprite.
		sta 	(gxzTemp0) 					; and write back
		jsr 	GXCloseBitmap 				
		clc
		rts

_GXSIHide:
		lda 	GSCurrentSprite
		sta 	gxzTemp0
		lda 	GSCurrentSprite+1
		sta 	gxzTemp0+1
		lda 	#0
		sta 	(gxzTemp0)
		clc
		rts

_GXSIFail:
		sec
		rts

; ************************************************************************************************
;
;									Move Sprite
;
; ************************************************************************************************		

GXMoveSprite: ;; [25:SPRMOVE]
		lda 	gxSpritesOn
		beq 	_GXSIFail

		lda 	GSCurrentSprite+1 			; check sprite selected
		beq 	_GXSIFail

		sta 	gxzTemp0+1
		ldy 	#4
		lda 	GSCurrentSprite
		sta 	gxzTemp0
		;
		lda 	#64 						; calculate 32-SpriteSize/2 (actually (64-SpriteSize)/2)
		sec
		sbc 	GXSizePixels
		lsr 	a
		pha
		;
		clc
		adc 	gxX0						; copy position.
		sta 	(gxzTemp0),y
		iny
		lda 	gxX0+1
		adc 	#0
		sta 	(gxzTemp0),y
		iny
		pla
		clc
		adc 	gxY0
		sta 	(gxzTemp0),y
		lda 	#0
		adc 	#0
		iny
		sta 	(gxzTemp0),y
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
