; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		display.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Created : 	28th December 2022
;		Purpose :	Display support, very simple I/O
;
; ***************************************************************************************
; ***************************************************************************************

		.cpu    "65c02"

; ***************************************************************************************
;
;							  Macros displaying state
;
; ***************************************************************************************

status 	.macro
		pha
		lda 	#\1
		jsr 	displayPrintCharacter
		lda 	#\2
		jsr 	displayPrintCharacter
		jsr 	displayPrintSpace
		pla
		.endm

; ***************************************************************************************
;
;								Initialise the 'console'
;
; ***************************************************************************************

displayInitialise:
		lda 	#$C0
		sta 	screenPos+1
		stz 	screenPos
		rts

; ***************************************************************************************
;
;							Print character to the 'console'
;
; ***************************************************************************************

displayPrintCharacter:		
		pha
		phx
		phy

		ldx 	1

		ldy 	#2		
		sty 	1
		sta 	(screenPos)
		inc 	1
		lda 	#$52
		sta 	(screenPos)

		stx 	1

		inc 	screenPos
		bne 	_dpcSkip
		inc 	screenPos+1
		lda 	screenPos+1
		and 	#$0F
		ora 	#$C0
		sta 	screenPos+1
_dpcSkip:		
		ply
		plx
		pla
		rts

; ***************************************************************************************
;
;								Print A in Hexadecimal
;
; ***************************************************************************************

displayPrintHexSpace:
		jsr 	displayPrintSpace
displayPrintHex:
		pha
		pha
		lsr 	a
		lsr 	a
		lsr 	a
		lsr 	a
		jsr 	_dphNibble
		pla		
		jsr 	_dphNibble
		pla
		rts

_dphNibble:		
		and 	#15
		cmp 	#10
		bcc 	_dphNotAlpha
		adc 	#6
_dphNotAlpha:
		adc 	#48
		jmp 	displayPrintCharacter

; ***************************************************************************************
;
;								Print Space
;
; ***************************************************************************************

displayPrintSpace:
		pha
		lda 	#' '
		jsr 	displayPrintCharacter
		pla
		rts