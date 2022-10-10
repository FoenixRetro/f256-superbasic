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
		lda 	gzTemp0+1 					; eor with mode
		eor 	gxMode
		sta 	gxUseMode

		lda 	#GXSpritePage
		sta 	GXSpriteBasePage

		ldx 	gzTemp0 					; sprite #
		phx
		jsr 	GXOpenBitmap 				; can access sprite information
		pla
		jsr 	GXFindSprite 				; get the sprite address
		jsr 	GXCloseBitmap

		lda 	GXSSize 					; return size
		ldx 	#GXSpriteAcquire & $FF
		ldy 	#GXSpriteAcquire >> 8
		jsr 	GXDrawGraphicElement
		rts

GXSpriteAcquire:
		lda 	GXspriteBasePage			; point to base page
		sta 	GFXEditSlot
		;
		;		Multiply Row Number by Sprite Size (0,1,2,3) + 1 * 8 e.g. 8,16,24 or 32
		;
		stx 	zTemp0 						; row number x 1,2,3,4
		lda 	#0
		ldx 	GXSSizeRaw
_GXTimesRowNumber:		
		clc
		adc 	zTemp0
		dex
		bpl 	_GXTimesRowNumber 			
		stz 	gzTemp0+1
		asl 	a 							; row x 2,4,6,8
		rol 	gzTemp0+1
		asl 	a 							; row x 4,8,12,16
		rol 	gzTemp0+1
		asl 	a 							; row x 8,16,24,32
		rol 	gzTemp0+1
		sta 	gzTemp0	
		;
		;		Add base address of sprite
		;
		clc 								; add base address.
		lda 	gzTemp0
		adc 	GXSAddress
		sta 	gzTemp0		
		lda 	gzTemp0+1
		adc 	GXSAddress+1
		; 								
		; 		Get MSB in range $00-$1F, e.g. in the current page, bumping the selected page.
		;
_GXSAFindPage:
		cmp 	#$20 						; on this page
		bcc 	_GXSAFoundPage
		sbc 	#$20 						; forward one page
		inc 	GFXEditSlot
		bra 	_GXSAFindPage
_GXSAFoundPage:		
		;
		;		Make gzTemp0 point to the sprite data, then copy it in.
		;
		ora 	#(GXMappingAddress >> 8) 	; physical address of page.
		sta 	gzTemp0+1 					; gzTemp0 now points to the page
		;
		ldy 	#0
_GXSACopyLoop:
		lda 	(gzTemp0),y
		sta 	gxPixelBuffer,y
		iny
		cpy 	GXSSize
		bne 	_GXSACopyLoop
		rts

		.send code

		.section storage
GXSpriteBasePage:
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
