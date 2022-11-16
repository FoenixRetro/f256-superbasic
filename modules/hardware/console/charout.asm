; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		charout.asm
;		Purpose:	Output character
;		Created:	14th November 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;									Output Character A
;
;		control+'a'  ($01)  begin
;		control+'b'  ($02)  left
;		control+'e'  ($05)  end
;		control+'f'  ($06)  right   
;		control+'h'  ($08)  backspace
;		control+'i'  ($09)  tab
;		control+'l'  ($0C)  ff
;		control+'m'  ($0D)  cr
;		control+'n'  ($0E)  down
;		control+'p'  ($10)  up
;					  $8x 	set background
;					  $9x 	set foreground
;
; ************************************************************************************************
	
EXTPrintCharacter:
		pha
		phx
		phy

		ldx 	1
		phx

		ldy 	EXTColumn 					; Y = Row, e.g. points to character.

		ora 	#$00 						; check $80-$FF
		bmi 	_EXPCColour
		cmp 	#$20 						; check $00-$1F
		bcc 	_EXPCControl
		;
		;		Handle character.
		;
		ldx 	#2 							; select char memory
		stx 	1
		sta 	(EXTAddress),y
		inc 	1 							; select colour memory
		lda 	EXTTextColour
		sta 	(EXTAddress),y
		;
		;		Move right one.
		;
_EXPCRight:
		iny 								; advance horizontal position
		sty 	EXTColumn		
		cpy 	EXTScreenWidth 				; reached RHS ?
		bcc 	_EXPCExit 					; no, then exit.
		;
		;		Carriage return.
		;
_EXPCCRLF:		
		stz 	EXTColumn 					; back to column 0
		inc 	EXTRow  					; bump row 
		lda 	EXTRow 						; check if reached the bottom ?
		cmp 	EXTScreenHeight 			; if so, then scroll.
		beq 	_EXPCScroll
		;
		clc 								; add width to address.
		lda 	EXTAddress
		adc 	EXTScreenWidth
		sta 	EXTAddress
		bcc 	_EXPCExit
		inc 	EXTAddress+1
		bra 	_EXPCExit
		;
		;		Scroll screen up, blank line.
		;
_EXPCScroll:
		dec 	EXTRow 						; the height-1 th line.
		jsr 	EXTScreenScroll 			; scroll the screen
		bra 	_EXPCExit		
		;
		;		Set FGR/BGR colour
		;
_EXPCColour:
		;
		;		Handle control characters.
		;
_EXPCControl:
		cmp 	#$11 						; only handle 00-10.
		bcs 	_EXPCExit
		asl 	a 							; double into X
		tax
		jmp 	(_EXPCActionTable,x) 		; and execute code.
		;
		;		Exit
		;
_EXPCExit:		
		jsr 	EXTSetHardwareCursor 		; place the physical cursor.
		pla
		sta 	1
		ply
		plx
		pla
		rts

_EXPCClearScreen:
		jsr		EXTClearScreenCode	
		bra 	_EXPCExit

_EXPCActionTable:
		.word 	_EXPCExit 					; 00 Nothing
		.word 	_EXPCExit 					; 01
		.word 	_EXPCExit 					; 02
		.word 	_EXPCExit 					; 03 Nothing
		.word 	_EXPCExit 					; 04 Nothing
		.word 	_EXPCExit 					; 05
		.word 	_EXPCExit 					; 06
		.word 	_EXPCExit 					; 07 Nothing
		.word 	_EXPCExit 					; 08
		.word 	_EXPCExit 					; 09
		.word 	_EXPCExit 					; 0A Nothing
		.word 	_EXPCExit 					; 0B Nothing
		.word 	_EXPCClearScreen			; 0C CLS
		.word 	_EXPCCRLF 					; 0D CR/LF
		.word 	_EXPCExit 					; 0E
		.word 	_EXPCExit 					; 0F Nothing
		.word 	_EXPCExit 					; 10

EXTScreenScroll:
		lda 	#2 							; select text page
		sta 	1
		lda		#32 						; fill with space
		jsr 	EXTScrollFill
		inc 	1 							; select colour page
		lda 	EXTTextColour
		jsr 	EXTScrollFill
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
