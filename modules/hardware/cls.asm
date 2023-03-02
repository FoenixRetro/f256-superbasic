; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		cls.asm
;		Purpose:	Clear Screen
;		Created:	14th November 2022
;		Reviewed: 	17th February 2022
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;									Clear the display
;
; ************************************************************************************************
				
EXTClearScreenCode:
		;
		lda 	#2 							; select text page
		sta 	1
		lda		#32 						; fill with space
		jsr 	_EXTCSFill
		inc 	1 							; select colour page
		lda 	EXTTextColour
		jsr 	_EXTCSFill
		bra 	EXTHomeCursor				; home cursor
		;
		;		Fill all text memory C000-D2FF with A - page set by caller
		;		
_EXTCSFill:
		tax
		lda 	#EXTMemory & $FF
		sta 	EXTAddress
		lda 	#EXTMemory >> 8
		sta 	EXTAddress+1
_EXTCSFill1:	
		ldy 	#0
		txa
_EXTCSFill2:	
		sta 	(EXTAddress),y
		iny
		bne 	_EXTCSFill2	
		inc 	EXTAddress+1
		lda 	EXTAddress+1
		cmp 	#$D2
		bne 	_EXTCSFill1
		txa
_EXTCSFill3:		
		sta 	(EXTAddress),y
		iny
		cpy 	#$C0
		bne 	_EXTCSFill3
		rts

; ************************************************************************************************
;
;									Home the cursor
;
; ************************************************************************************************

EXTHomeCursor:		
		stz 	EXTRow 						; reset row & column
		stz 	EXTColumn
		lda 	#EXTMemory & $FF 			; set address in I/O memory
		sta 	EXTAddress
		lda 	#EXTMemory >> 8
		sta 	EXTAddress+1

; ************************************************************************************************
;
;									Position the cursor
;
; ************************************************************************************************

EXTSetHardwareCursor:
		stz 	1 							; I/O Page zero
		lda 	EXTColumn
		sta 	$D014 						; set cursor position
		stz 	$D015
		lda 	EXTRow
		sta 	$D016
		stz 	$D017
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
;		02/03/23 		Cursor being set up moved to initialise.
;
; ************************************************************************************************
