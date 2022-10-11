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

		.section code

; ************************************************************************************************
;
;								Clear bitmap to colour gzTemp0
;
; ************************************************************************************************

GXClearBitmap: ;; [2:Clear]
		pha
		phy
		jsr 	GXOpenBitmap 				; start access
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
		jsr 	GXCloseBitmap	 			; stop access
		ply
		pla
		rts

_GXClearBlock:
;
;		Clear 1 8k block
;
		.set16 	gzTemp1,GXMappingAddress
_GXCB0:
		lda 	gzTemp0
		ldy 	#0
_GXCB1:	
		sta 	(gzTemp1),y
		iny
		sta 	(gzTemp1),y
		iny
		sta 	(gzTemp1),y
		iny
		sta 	(gzTemp1),y
		iny
		bne 	_GXCB1
		inc 	gzTemp1+1
		lda 	gzTemp1+1
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
