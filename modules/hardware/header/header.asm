; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		header.asm
;		Purpose:	Display the header/boot display
;		Created:	14th December 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;											Show header
;
; ************************************************************************************************

EXTShowHeader:
		lda 	1
		pha
		lda 	8+3
		pha
		lda 	8+4
		clc
		adc 	#3
		sta 	8+3
		;
		ldx 	#(Header_jchars & $FF)
		ldy 	#(Header_jchars >> 8)-$40

		stz 	1
		lda 	$D6A7
		and 	#$10
		beq 	_EXTSHNotK1

		ldx 	#(Header_kchars & $FF)
		ldy 	#(Header_kchars >> 8)-$40
_EXTSHNotK1:		
		lda 	#2
		jsr 	_ESHCopyBlock
		;
		ldx 	#(Header_jattrs & $FF)
		ldy 	#(Header_jattrs >> 8)-$40

		stz 	1
		lda 	$D6A7
		and 	#$10
		beq 	_EXTSHNotK2

		ldx 	#(Header_kattrs & $FF)
		ldy 	#(Header_kattrs >> 8)-$40
_EXTSHNotK2:		
		lda 	#3
		jsr 	_ESHCopyBlock
		;
		stz 	1
		ldx 	#16*4-1
_EXTCopyLUT:
		lda 	Header_Palette-$4000,x
		sta 	$D800,x
		sta 	$D840,x
		dex
		bpl 	_EXTCopyLUT		
		pla
		sta 	8+3
		pla
		rts

_ESHCopyBlock:
		sta 	1 
		stx 	zTemp0 						; zTemp0 is RLE packed data
		sty 	zTemp0+1
		.set16 	zTemp1,$C000 				; where it goes.
_ESHCopyLoop:
		lda 	(zTemp0) 					; get next character
		cmp 	#Header_RLE 				; packed ?
		beq 	_ESHUnpack 				
		sta 	(zTemp1) 					; copy it out.
		lda 	#1 							; source add 1
		ldy 	#1 							; dest add 1
_ESHNext:
		clc 								; zTemp0 + A
		adc 	zTemp0
		sta 	zTemp0
		bcc 	_ESHNoCarry
		inc 	zTemp0+1
_ESHNoCarry:
		tya 								; zTemp1 + Y
		clc				
		adc 	zTemp1
		sta 	zTemp1
		bcc 	_ESHCopyLoop
		inc 	zTemp1+1
		bra 	_ESHCopyLoop
		;
_ESHUnpack:
		ldy 	#2 							; get count into X
		lda 	(zTemp0),y
		tax
		dey 								; byte into A
		lda 	(zTemp0),y
		beq 	_ESHExit 					; exit if zero.		
		ldy 	#0 							; copy start position
_ESHCopyOut:
		sta 	(zTemp1),y
		iny
		dex
		bne 	_ESHCopyOut				
		lda 	#3 							; Y is bytes on screen, 3 bytes from source
		bra 	_ESHNext
		;
_ESHExit:
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
