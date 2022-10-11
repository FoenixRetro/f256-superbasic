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
		lda 	gzTemp0 					; illegal sprite #
		cmp 	#64
		bcs 	_GXSFail

		ldy 	gzTemp0+1 					; control value.
		lda  	#0 							; multiply sprite # x 8 => A
		asl 	gzTemp0
		asl 	gzTemp0
		asl 	gzTemp0
		rol 	a
		adc 	#$D9 						; sprite area
		sta 	GSCurrentSprite+1 			; address to GSCurrentSprite and gzTemp
		sta 	gzTemp0+1
		lda 	gzTemp0
		sta 	GSCurrentSprite
		;
		tya 								; control value
		and 	#1 
		stz 	1 							; access sprite control.
		sta 	(gzTemp0) 					; write to control register		

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

		lda 	gzTemp0 					; sprite image
		pha
		jsr 	GXOpenBitmap

		pla		
		jsr 	GXFindSprite

		ldy 	#1
		lda 	GSCurrentSprite
		sta 	gzTemp0
		lda 	GSCurrentSprite+1
		sta 	gzTemp0+1

		lda 	GXSAddress
		sta	 	(gzTemp0),y
		clc
		lda 	GXSAddress+1
		adc 	GXSAddressBase
		iny
		sta	 	(gzTemp0),y

		lda 	GXSAddressBase+1
		adc 	#0
		iny
		sta	 	(gzTemp0),y

		lda 	(gzTemp0)					; get LSB into gzTemp1
		and 	#1
		sta 	gzTemp1

		lda 	GXSSizeRaw 					; get raw size
		eor 	#3 							; make it right (00=32 etc.)
		rol 	a 							; x 2
		asl 	a 							; x 4
		asl 	a 							; x 8
		asl 	a 							; x 16
		ora 	GXSLUT 						; Or with LUT
		asl 	a 							; 1 shift
		ora 	gzTemp1 					; Or in the enable bit
		sta 	(gzTemp0) 					; and write back

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
