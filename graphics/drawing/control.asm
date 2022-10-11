; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		control.asm
;		Purpose:	Graphics test code.
;		Created:	11th October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;										Bitmap Control
;
; ************************************************************************************************

GXControlBitmap: ;; [0:BITMAPCTL]
		stz 	1
		lda 	gzTemp0 					; get control bits
		lsr 	a 							; bit 0 into carry.
		lda 	$D000 						; read Vicky MCR
		ora 	#7 							; turn graphics, text, textoverlay on.
		and 	#$F7 						; clear bitmap bit
		bcc 	_CBNotOn
		ora 	#$08 						; bitmap on if 1 on 0 off
_CBNotOn:		
		sta 	$D000 						; update Vicky MCR

		lda 	gzTemp0 					; get control settings (bits 0-2)
		and 	#7
		sta 	$D100 						; write in Vicky Bitmap Control Register #0

		lda 	gzTemp0+1 					; get the base page
		bne 	_CBNotDefault
		lda 	#8  						; if zero, use 8 e.g. bitmap at $10000
_CBNotDefault:		
		sta 	gxBasePage
		jsr 	GXCalculateBaseAddress 	 	; convert page# to address

		lda 	gzTemp0+1 					; copy address into Bitmap address registers
		sta 	$D103
		lda 	gzTemp0
		sta 	$D102
		stz 	$D101

		ldx 	#240 						; height is 240
		lda 	$D001 						; read MCR bit 0
		and 	#1
		beq 	_CBHaveHeight
		ldx 	#200 						; if bit 0 set 320x200
_CBHaveHeight		
		stx 	gxHeight
		clc
		rts

; ************************************************************************************************
;
;										Sprite Control
;
; ************************************************************************************************

GXControlSprite: ;; [1:SPRITECTL]
		stz 	1
		lda 	gzTemp0 					; get control bits
		lsr 	a 							; bit 0 into carry.
		lda 	$D000 						; read Vicky MCR
		ora 	#7 							; turn graphics, text, textoverlay on.
		and 	#$DF 						; clear sprite bit
		bcc 	_CSNotOn
		ora 	#$20 						; sprite on if 1 on 0 off
_CSNotOn:		
		sta 	$D000 						; update Vicky MCR

		lda 	gzTemp0+1 					; get the base page
		bne 	_CSNotDefault
		lda 	#24  						; if zero, use 24 e.g. sprites at $30000
_CSNotDefault:		
		sta 	gxSpritePage
		jsr 	GXCalculateBaseAddress 	 	; convert page# to address
		lda 	zTemp0
		sta 	GXSAddress
		lda 	zTemp0+1
		sta 	GXSAddress+1
		;
		ldx 	#0 							; disable all sprites, clears all sprite memory.
_CSClear:
		stz 	$D900,x
		stz 	$DA00,x
		dex
		bne 	_CSClear
		;
		lda 	#2
		jsr 	GXFindSprite
		lda 	#1+$18
		sta 	$D900
		lda 	GXSAddress
		sta	 	$D901
		lda 	GXSAddress+1
		sta	 	$D902
		lda 	#3
		sta 	$D903
		lda 	#64
		sta 	$D904
		sta 	$D906
		clc
		rts

; ************************************************************************************************
;
;								Convert page number to an address
;
; ************************************************************************************************

GXCalculateBaseAddress:
		sta 	gzTemp0
		stz 	gzTemp0+1
		lda 	#5
_GXShift:
		asl 	gzTemp0	
		rol 	gzTemp0+1
		dec		a
		bne 	_GXShift
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
