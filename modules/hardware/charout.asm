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
;			Print character as standard, but treat all control characters as font
;
; ************************************************************************************************

Export_EXTPrintNoControl:
		pha
		phx
		phy

		ldx 	1
		phx

		ldy 	EXTColumn 					; Y = Row, e.g. points to character.
		bra 	PrintCharacterOnly

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

Export_EXTPrintCharacter:
PAGEDPrintCharacter:
		pha
		phx
		phy

		ldx 	1
		phx

		ldy 	EXTColumn 					; Y = current column

		ora 	#$00 						; check $80-$FF
		bmi 	EXPCColour
		cmp 	#$20 						; check $00-$1F
		bcc 	EXPCControl
		;
		;		Handle character.
		;
PrintCharacterOnly:
		pha
		lda		EXTPendingWrap				; check for a pending wrap state
		beq 	_print_char					; no pending wrap, jump to print
		jsr 	ApplyPendingWrap			; apply pending wrap, then print

	_print_char:
		pla
		ldx 	#2 							; select char memory
		stx 	1
		sta 	(EXTAddress),y
		inc 	1 							; select colour memory
		lda 	EXTTextColour
		sta 	(EXTAddress),y
		;
		iny 								; advance horizontal position
		cpy 	EXTScreenWidth 				; past the right-most character?
		beq		_line_wrap					; yes, handle line wrap
		sty 	EXTColumn					; store new column position and exit
		bra 	EXPCExit					;
		;
	_line_wrap:
		lda 	EXTRow 						; check if we're on the last line
		inc		a							;
		cmp 	EXTScreenHeight 			;
		bcc 	EXPCCRLF 					; if no, then wrap to next line

		; we're in the bottom-right corner
		lda		EXTPendingWrapEnabled		; check if pending wrap is enabled
		beq 	EXPCCRLF 					; if not, then wrap immediately

		lda 	#1
		sta 	EXTPendingWrap 				; set pending wrap flag
		bra 	EXPCExit 					; exit with hardware cursor set
											; to current position

		;
		;		Carriage return.
		;
EXPCCRLF:
		inc 	EXTRow  					; bump row
		stz 	EXTColumn 					; back to column 0
		stz 	EXTPendingWrap 				; clear pending wrap, if any
		lda 	EXTRow 						; check if reached the bottom ?
		cmp 	EXTScreenHeight 			; if so, then scroll.
		beq 	EXPCScroll
		;
		clc 								; add width to address.
		lda 	EXTAddress
		adc 	EXTScreenWidth
		sta 	EXTAddress
		bcc 	EXPCExit
		inc 	EXTAddress+1
		bra 	EXPCExit
		;
		;		Move left / beginning of line.
		;
EXPCLeft:
		dec 	EXTColumn
		stz 	EXTPendingWrap
		bpl 	EXPCExit
EXPCBegin:
		stz 	EXTColumn
		stz 	EXTPendingWrap
		bra 	EXPCExit
		;
		;		Scroll screen up, blank line.
		;
EXPCScroll:
		dec 	EXTRow 						; the height-1 th line.
		jsr 	EXTScreenScroll 			; scroll the screen
		bra 	EXPCExit
		;
		;		Set FGR/BGR colour
		;
EXPCColour:
		cmp 	#$A0						; 80-9F set foreground/background
		bcs 	EXPCExit
		jsr 	EXPCHandleColour
		bra 	EXPCExit
		;
		;		Handle control characters 00-1F 80-FF
		;
EXPCControl:
		cmp 	#$11 						; only handle 00-10.
		bcs 	EXPCExit
		asl 	a 							; double into X
		tax
		jmp 	(EXPCActionTable,x) 		; and execute code.
		;
		;		Up
		;
EXPCUp:
		lda 	EXTRow 						; already at top ?
		beq 	EXPCExit
		dec 	EXTRow 						; up one in position/address
		sec
		lda 	EXTAddress
		sbc 	EXTScreenWidth
		sta 	EXTAddress
		bcs 	EXPCExit
		dec 	EXTAddress+1
		bra 	EXPCExit

		;
		;		Exit
		;
EXPCExit:
		jsr 	EXTSetHardwareCursor 		; place the physical cursor.
		pla
		sta 	1
		ply
		plx
		pla
		rts

		;
		;		Right/End of line
		;
EXPCRight:
		iny
		sty 	EXTColumn
		cpy 	EXTScreenWidth
		bne 	EXPCExit
		dey
EXPCSetColumnY: 							; set column to Y
		sty 	EXTColumn
		bra 	EXPCExit
		;
		;		Clear
		;
EXPCClearScreen:
		jsr		EXTClearScreenCode
		bra 	EXPCExit
		;
		;		Down
		;
EXPCDown:
		lda 	EXTScreenHeight 			; at the bottom
		dec 	a
		cmp 	EXTRow
		beq 	EXPCExit
		inc 	EXTRow 						; down one in position/address
		clc
		lda 	EXTAddress
		adc 	EXTScreenWidth
		sta 	EXTAddress
		bcc 	EXPCExit
		inc 	EXTAddress+1
		bra 	EXPCExit
		;
		;		Tab
		;
EXPCTab:
		lda 	EXTColumn 					; next tab stop
		and 	#$F8
		clc
		adc 	#8
		sta 	EXTColumn
		cmp 	EXTScreenWidth 				; too far, new line.
		bcc 	EXPCExit
		jmp 	EXPCCRLF
		;
		;		Backspace
		;
EXPCBackSpace:
		dey
		bmi 	EXPCExit
		dec 	EXTColumn
		stz 	EXTPendingWrap
		lda 	#2
		sta 	1
		lda 	#32
		sta 	(EXTAddress),y
		bra 	EXPCExit
		;
		;		End of line
		;
EXPCEnd:
		lda 	#2 							; access text screen
		sta 	1
		ldy 	EXTScreenWidth 				; point to last character
		dey
EXPCEndSearch:
		dey 								; if past start, move to col 0.
		bmi 	EXPCFound
		lda 	(EXTAddress),y 				; keep going back till non space found
		cmp 	#' '
		beq 	EXPCEndSearch
EXPCFound:
		iny 								; move to following cell.
		bra 	EXPCSetColumnY
		;
		;		Clear to end of line
		;
EXPCClearEOL:
		lda 	#2 							; access character RAM
		sta 	1
		lda 	#' ' 						; write space
		sta 	(EXTAddress),y
		iny
		cpy 	EXTScreenWidth 				; until RHS of screen.
		bcc 	EXPCClearEOL
		jmp 	EXPCExit
		;
		;		Vector table for CTRL+A to CTRL+P
		;
EXPCActionTable:
		.word 	EXPCExit 					; 00
		.word 	EXPCBegin 					; 01 A Start of Line
		.word 	EXPCLeft 					; 02 B Left
		.word 	EXPCExit 					; 03 C <Break>
		.word 	EXPCExit 					; 04
		.word 	EXPCEnd 					; 05 E End of Line
		.word 	EXPCRight 					; 06 F Right
		.word 	EXPCExit 					; 07
		.word 	EXPCBackSpace 				; 08 H Backspace
		.word 	EXPCTab 					; 09 I Tab
		.word 	EXPCExit 					; 0A
		.word 	EXPCClearEOL 				; 0B K Clear to EOL
		.word 	EXPCClearScreen				; 0C L CLS
		.word 	EXPCCRLF 					; 0D M CR/LF
		.word 	EXPCDown 					; 0E N Down
		.word 	EXPCExit 					; 0F
		.word 	EXPCUp 						; 10 P Up
;
;		Handle colour change (80-9F)
;
EXPCHandleColour:
		cmp 	#$90 						; 8x foreground 9x background
		bcs 	EXPCBackground
		;
		asl 	a 							; shift it 4 bits to the right.
		asl 	a
		asl 	a
		asl 	a
		ldx 	#$0F 						; Mask in X
EXPCUpdate:
		pha 								; save new colour
		txa 								; get mask
		and 	EXTTextColour 				; mask out old.
		sta 	EXTTextColour
		pla 								; or in new colour
		ora 	EXTTextColour
		sta 	EXTTextColour
		rts
EXPCBackground:
		and 	#$0F 						; get the colour
		ldx 	#$F0 						; mask
		bra 	EXPCUpdate

EXTScreenScroll:
		lda 	#2 							; select text page
		sta 	1
		lda		#32 						; fill with space
		jsr 	EXTScrollFill
		inc 	1 							; select colour page
		lda 	EXTTextColour
		jsr 	EXTScrollFill
		rts

Export_EXTApplyPendingWrap:
ApplyPendingWrap:
		stz		EXTPendingWrap				; clear pending wrap flag
		stz 	EXTColumn 					; reset column to 0
		jsr 	EXTScreenScroll 			; scroll the screen
		jsr 	EXTSetHardwareCursor 		; place the physical cursor
		ldy 	EXTColumn 					; re-point Y to column 0
		rts

; ************************************************************************************************
;
;										Print Hex in space
;
; ************************************************************************************************

PAGEDPrintHex:
		pha
		lda 	#' '
		jsr 	PAGEDPrintCharacter
		pla
		pha
		lsr 	a
		lsr 	a
		lsr 	a
		lsr 	a
		jsr 	_PPHNibble
		pla
_PPHNibble:
		pha
		and 	#15
		cmp 	#10
		bcc 	_PPHOut
		adc 	#6
_PPHOut:adc 	#48
		jsr		PAGEDPrintCharacter
		pla
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
;		27/11/22 		Changed End so to end of text line, e.g. after last non space
;						Added Ctrl+K delete to EOL suggested by Jessie O.
;		01/01/23 		Added routine to print using only font characters.
;		04/04/23 		TAB was doing END if past screen width rather than CRLF.
;
; ************************************************************************************************
