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
		iny 								; advance horizontal position
		sty 	EXTColumn		
		cpy 	EXTScreenWidth 				; reached RHS ?
		bcc 	_EXPCExit 					; no, then exit.
		;
		;		Carriage return.
		;
_EXPCCRLF:		
		inc 	EXTRow  					; bump row 		
		stz 	EXTColumn 					; back to column 0
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
		;		Move left / beginning of line.
		;
_EXPCLeft:
		dec 	EXTColumn
		bpl 	_EXPCExit
_EXPCBegin:
		stz 	EXTColumn
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
		cmp 	#$A0						; 80-9F set foreground/background
		bcs 	_EXPCExit
		jsr 	_EXPCHandleColour 
		bra 	_EXPCExit
		;
		;		Handle control characters 00-1F 80-FF
		;
_EXPCControl:
		cmp 	#$11 						; only handle 00-10.
		bcs 	_EXPCExit
		asl 	a 							; double into X
		tax
		jmp 	(_EXPCActionTable,x) 		; and execute code.
		;
		;		Up
		;
_EXPCUp:
		lda 	EXTRow 						; already at top ?
		beq 	_EXPCExit		
		dec 	EXTRow 						; up one in position/address
		sec
		lda 	EXTAddress
		sbc 	EXTScreenWidth
		sta 	EXTAddress
		bcs 	_EXPCExit
		dec 	EXTAddress+1
		bra 	_EXPCExit
		;
		;		Right/End of line
		;
_EXPCRight:
		iny 	
		sty 	EXTColumn
		cpy 	EXTScreenWidth		
		bne 	_EXPCExit
_EXPCEnd:
		lda 	EXTScreenWidth
		dec 	a
		sta 	EXTColumn		
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
		;
		;		Clear
		;
_EXPCClearScreen:
		jsr		EXTClearScreenCode	
		bra 	_EXPCExit
		;
		;		Down
		;
_EXPCDown:		
		lda 	EXTScreenHeight 			; at the bottom
		dec 	a
		cmp 	EXTRow
		beq 	_EXPCExit
		inc 	EXTRow 						; down one in position/address
		clc
		lda 	EXTAddress
		adc 	EXTScreenWidth
		sta 	EXTAddress
		bcc 	_EXPCExit
		inc 	EXTAddress+1
		bra 	_EXPCExit
		;
		;		Tab
		;
_EXPCTab:
		lda 	EXTColumn 					; next tab stop
		and 	#$F8
		clc 	
		adc 	#8
		sta 	EXTColumn
		cmp 	EXTScreenWidth 				; too far, stick end of line.
		bcc 	_EXPCExit
		bra 	_EXPCEnd
		;
		;		Backspace
		;	
_EXPCBackSpace:
		dey
		bmi 	_EXPCExit
		dec 	EXTColumn
		lda 	#2
		sta 	1
		lda 	#32
		sta 	(EXTAddress),y
		bra 	_EXPCExit
		;
		;		Vector table for CTRL+A to CTRL+P
		;			
_EXPCActionTable:
		.word 	_EXPCExit 					; 00 
		.word 	_EXPCBegin 					; 01 A Start of Line
		.word 	_EXPCLeft 					; 02 B Left
		.word 	_EXPCExit 					; 03 <Break>
		.word 	_EXPCExit 					; 04 
		.word 	_EXPCEnd 					; 05 E End of Line
		.word 	_EXPCRight 					; 06 F Right
		.word 	_EXPCExit 					; 07 
		.word 	_EXPCBackspace 				; 08 H Backspace
		.word 	_EXPCTab 					; 09 I Tab
		.word 	_EXPCExit 					; 0A 
		.word 	_EXPCExit 					; 0B 
		.word 	_EXPCClearScreen			; 0C L CLS
		.word 	_EXPCCRLF 					; 0D M CR/LF
		.word 	_EXPCDown 					; 0E N Down
		.word 	_EXPCExit 					; 0F 
		.word 	_EXPCUp 					; 10 P Up
;
;		Handle colour change (80-9F)
;
_EXPCHandleColour
		cmp 	#$90 						; 8x foreground 9x background
		bcs 	_EXPCBackground
		;
		asl 	a 							; shift it 4 bits to the right.
		asl 	a
		asl 	a
		asl 	a
		ldx 	#$0F 						; Mask in X
_EXPCUpdate:
		pha 								; save new colour
		txa 								; get mask
		and 	EXTTextColour 				; mask out old.
		sta 	EXTTextColour
		pla 								; or in new colour
		ora 	EXTTextColour
		sta 	EXTTextColour
		rts
_EXPCBackground:
		and 	#$0F 						; get the colour
		ldx 	#$F0 						; mask
		bra 	_EXPCUpdate		

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
