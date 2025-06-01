;;
; Clear screen/hardware cursor utilities.
;;
		.section code

;;
; Clear the screen and home the cursor.
;
; Clears the screen by filling the text page with spaces and color page with
; the current text color, then homes the cursor to the top-left corner (row 0,
; column 0).
;
; \in EXTTextColour     The color value to fill the color memory.
; \out EXTColumn        0
; \out EXTRow           0
; \out EXTAddress       `EXTMemory`
; \sideeffects          - Updates I/O page register 1.
;                       - Modifies registers `A` and `Y`.
;                       - Resets `EXTColumn`, `EXTRow`, and `EXTAddress`.
;                       - Updates text and color memory.
;						- Updates hardware cursor registers $D014-$D017.
; \see                  EXTHomeCursor, EXTSetHardwareCursor
;;
EXTClearScreenCode:
		;
		lda 	#2 							; select text page
		sta 	1
		lda		#32 						; fill with space
		jsr 	_EXTCSFill
		inc 	1 							; select color page
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

;;
; Home the cursor.
;
; Sets the current cursor position `EXTRow`, `EXTColumn` to the top-left
; corner of the display and the current screen line address pointer
; `EXTAddress` to the start of the text memory, updates the hardware cursor
; registers to reflect the new position.
;
; \out EXTColumn    0
; \out EXTRow       0
; \out EXTAddress   `EXTMemory`
; \sideeffects      - Modifies register `A`.
;                   - Resets `EXTColumn`, `EXTRow`, and `EXTAddress`.
;					- Updates hardware cursor registers $D014-$D017.
;;
EXTHomeCursor:
		stz 	EXTRow 						; reset row & column
		stz 	EXTColumn
		lda 	#EXTMemory & $FF 			; set address in I/O memory
		sta 	EXTAddress
		lda 	#EXTMemory >> 8
		sta 	EXTAddress+1
		; fall through to set hardware cursor

;;
; Position the hardware cursor.
;
; Sets the hardware cursor position on the display based on `EXTColumn`
; and `EXTRow` values.
;
; \in EXTColumn     The column position for the cursor (0-based).
; \in EXTRow        The row position for the cursor (0-based).
; \sideeffects      - Zeroes I/O page register 1.
;                   - Modifies register `A`.
;                   - Updates hardware cursor registers $D014-$D017.
;;
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
