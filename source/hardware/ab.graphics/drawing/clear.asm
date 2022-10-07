; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		clear.asm
;		Purpose:	Clear Screen
;		Created:	6th October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

ScreenSize200 = 320 * 200
ScreenSize240 = 320 * 240

; ************************************************************************************************
;
;										Clear bitmap to colour A
;
; ************************************************************************************************

		.section code

GXClearBitmap:
		pha
		phy
		sta 	gzTemp1

		ldy 	#ScreenSize200 / 8192 		; X is pages to clear
		lda 	gxHeight
		cmp 	#200 						; 200 ?
		ldy 	#ScreenSize240 / 8192
_GXCalcLastPage:
		tya 								; add to base page
		clc
		adc 	gxBasePage
		sta 	GFXEditSlot  				; clear from this page back

_GXClearAll:
		jsr 	_GXClearBlock 				; clear 8k block
		dec 	GFXEditSlot  				; back to previous
		lda 	GFXEditSlot
		cmp 	gxBasePage 					; until before base page
		bcs 	_GXClearAll
		ply
		pla
		rts

_GXClearBlock:
		;
		;		Clear 1 8k block
		;
		.set16 	gzTemp0,GXMappingAddress
_GXCB0:
		lda 	gzTemp1
		ldy 	#0
_GXCB1:	sta 	(gzTemp0),y
		iny
		bne 	_GXCB1
		inc 	gzTemp0+1
		lda 	gzTemp0+1
		cmp	 	#(GXMappingAddress >> 8)+$20
		bne 	_GXCB0
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
