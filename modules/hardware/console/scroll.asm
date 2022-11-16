; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		scroll.asm
;		Purpose:	Scroll one part of screen
;		Created:	16th November 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;						Scroll screen in current i/o page, fill with A
;
; ************************************************************************************************

EXTScrollFill:
		tax									; save value to fill with

		lda 	zTemp0 						; save zTemp0 (dest) zTemp1 (src)
		pha
		lda 	zTemp0+1
		pha
		lda 	zTemp1
		pha
		lda 	zTemp1+1
		pha

		lda 	#$C0 						; copy from C000+length to C000
		sta 	zTemp0+1
		sta 	zTemp1+1
		stz 	zTemp0
		lda 	EXTScreenWidth
		sta 	zTemp1
		ldy 	#0
_EXSFCopy1: 								; do one page
		lda 	(zTemp1),y
		sta 	(zTemp0),y
		iny
		bne 	_EXSFCopy1
		inc 	zTemp0+1 					; next page
		inc 	zTemp1+1
		lda 	zTemp1+1
		cmp 	#$D3
		bne 	_EXSFCopy1

		ldy 	EXTScreenWidth 				; blank the bottom line.
		txa
_EXSFFill1:	
		dey 
		sta 	(EXTAddress),y		
		cpy 	#0
		bpl 	_EXSFFill1

		pla 	
		sta 	zTemp1+1
		pla
		sta 	zTemp1
		pla 	
		sta 	zTemp0+1
		pla
		sta 	zTemp0

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
