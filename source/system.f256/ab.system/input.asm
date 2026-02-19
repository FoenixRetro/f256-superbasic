; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		input.asm
;		Purpose:	Input one line, screen scrape
;		Created:	17th November 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;									Input line into lineBuffer
;
; ************************************************************************************************

InputLine:
		pha
		phx
		phy

		lda 	1 							; save I/O page
		pha
_EILLoop:
		jsr 	KNLGetSingleCharacter 		; get one single character
		cmp 	#13 						; Enter pressed?
		bne 	_EILNotEnter
		; Check if Shift is held - if so, just move to next line without evaluating
		jsr 	IsShiftPressed
		bne 	_EILShiftEnter				; shift held, don't exit
		jmp 	_EILExit 					; no shift, normal exit and evaluate
_EILShiftEnter:
		; Shift+Enter: move to next line without evaluating
		lda 	#13
		jsr 	EXTPrintCharacter 			; print carriage return
		; Skip over any continuation rows
_EILSkipCont:
		lda 	EXTRow
		cmp 	EXTScreenHeight
		bcs 	_EILSkipDone 				; at bottom, stop
		; Check if current row is a continuation
		jsr 	EILCheckWrap
		beq 	_EILSkipDone 				; not a continuation, done
		; This row is a continuation - move to next line
		lda 	#13
		jsr 	EXTPrintCharacter
		bra 	_EILSkipCont 				; check again
_EILSkipDone:
		jmp 	_EILLoop 					; continue input loop
_EILNotEnter:
		cmp 	#4 							; Ctrl+D delete at cursor
		bne 	_EILNotCtrlD
		jmp 	_EILDelete
_EILNotCtrlD:
		cmp 	#$B5 						; INS key (Shift+Backspace on F256K2)
		bne 	_EILNotIns
		jsr 	EXTInsertLine
		jmp 	_EILLoop
_EILNotIns:
		cmp 	#8 							; Ctrl+H backspace
		bne 	_EILNotBackspace
		jmp 	_EILBackspace
_EILNotBackspace:
		cmp 	#' '						; < space, print it
		bcs 	_EILNotControl
		jmp 	_EILPrintLoop
_EILNotControl:
		cmp 	#$7F 						; if -ve print it
		bcc 	_EILNotHighChar
		jmp 	_EILPrintLoop
_EILNotHighChar:
		;
		tax 								; save character in X
		lda	 	#2 							; screen character memory
		sta 	1
		ldy 	EXTScreenWidth 				; read the last character.
		dey
		lda 	(EXTAddress),y
		cmp 	#' ' 						; if not space then check overflow.
		bne 	_EILCheckOverflow
		;
_EILDoInsert:
		phx 								; save character on stack
		lda 	#2  						; insert a space
		sta 	1
		jsr 	EXTILInsert 				; insert in text screen
		inc 	1
		jsr 	EXTILInsert 				; insert in colour screen
		pla 								; get character back.
		jmp 	_EILPrintLoop
		;
_EILCheckOverflow:
		; Line is full - try overflow to next wrapped row
		; A = overflow char, X = typed char
		stx 	lwOverflowTyped
		jsr 	EILDoOverflow 				; carry set = success
		bcc 	_EILReject
		ldx 	lwOverflowTyped
		jmp 	_EILDoInsert
		;
_EILReject:
		jmp 	_EILLoop 					; reject input
		;
_EILPrintLoop:
		jsr 	EXTPrintCharacter
		jmp 	_EILLoop
_EILLoopJmp:
		jmp 	_EILLoop
		;
		;		Backspace
		;
_EILBackspace:
		lda 	EXTColumn					; can we backspace ?
		bne 	_EILBSDoIt					; not at column 0, do normal backspace
		;
		; At column 0 - check if current row is a wrapped continuation
		lda 	EXTRow
		beq 	_EILBSToLoop				; at row 0, can't go up
		jsr 	EILCheckWrap
		beq 	_EILBSToLoop				; not wrapped, can't backspace further
		;
		; Current row is a continuation - move to end of previous row
		; (don't clear wrap flag yet - EXTILDelete needs it to pull content)
		dec 	EXTRow
		lda 	EXTScreenWidth
		dec 	a
		sta 	EXTColumn					; set column to last position
		; Update EXTAddress to previous row
		sec
		lda 	EXTAddress
		sbc 	EXTScreenWidth
		sta 	EXTAddress
		bcs 	_EILBSAddrOK
		dec 	EXTAddress+1
_EILBSAddrOK:
		; Update hardware cursor position (control char 0 does nothing but updates cursor)
		lda 	#0
		jsr 	EXTPrintCharacter
		; Now delete at this position (will shift content from next row)
		bra 	_EILDelete
		;
_EILBSToLoop:
		jmp 	_EILLoop
		;
_EILBSDoIt:
		lda 	#2 							; move cursor left
		jsr 	EXTPrintCharacter
_EILDelete
		;
		lda 	#2 							; text block
		sta 	1
		lda 	#' ' 						; backspace text.
		jsr 	EXTILDelete
		;
		inc 	1 							; colour block
		ldy 	EXTColumn 					; get attribute of last character
		dey
		lda 	(EXTAddress),y
		jsr 	EXTILDelete 				; backspace attribute
		jmp 	_EILLoop 					; and go round.
		;
		;		Copy line from screen into input buffer and right trim.
		;		Handles wrapped lines by finding the logical line start
		;		and copying all continuation rows.
		;
_EILExit:
		lda 	#2 							; switch to page 2
		sta 	1

		; Save current row and address on stack for restoration later
		lda 	EXTRow
		pha
		lda 	EXTAddress
		pha
		lda 	EXTAddress+1
		pha

		; Find the start of the logical line by scanning up through wrapped rows
_EILFindStart:
		; Inline wrap flag check for current row
		lda 	EXTRow
		beq 	_EILStartFound 				; row 0 can't be wrapped, skip check
		jsr 	EILCheckWrap
		beq 	_EILStartFound 				; not wrapped, this is the start

		; Current row is wrapped - go up one row
		dec 	EXTRow
		sec
		lda 	EXTAddress
		sbc 	EXTScreenWidth
		sta 	EXTAddress
		bcs 	_EILFindStart 				; continue searching (no borrow)
		dec 	EXTAddress+1
		bra 	_EILFindStart 				; continue searching

_EILStartFound:
		; Now at the start of the logical line
		; Copy rows until we hit a non-continuation row
		stz 	zTemp0 						; output buffer index

_EILCopyRow:
		ldy 	#0 							; column index within row
_EILCopyChar:
		lda 	(EXTAddress),y
		ldx 	zTemp0
		cpx 	#252 						; don't overflow buffer
		bcs 	_EILCopyDone
		sta 	lineBuffer,x
		inc 	zTemp0
		iny
		cpy 	EXTScreenWidth
		bne 	_EILCopyChar

		; Finished copying this row - check if next row is wrapped
		inc 	EXTRow
		lda 	EXTRow
		cmp 	EXTScreenHeight
		bcs 	_EILCopyDone 				; past bottom of screen, done

		; Advance address to next row
		clc
		lda 	EXTAddress
		adc 	EXTScreenWidth
		sta 	EXTAddress
		bcc 	_EILCheckNextWrap
		inc 	EXTAddress+1

_EILCheckNextWrap:
		lda 	EXTRow
		jsr 	EILCheckWrap
		bne 	_EILCopyRow 				; wrapped, copy this row too

_EILCopyDone:

		; Restore original row/address
		pla
		sta 	EXTAddress+1
		pla
		sta 	EXTAddress
		pla
		sta 	EXTRow

		; Right trim the buffer
		ldy 	zTemp0 						; total chars copied
		;
_EILTrimSpaces: 							; right trim
		dey
		cpy 	#$FF 						; back past the start
		beq 	_EILEndTrim		 			; zero the input line.
		lda 	lineBuffer,y
		cmp 	#' '
		beq 	_EILTrimSpaces 				; if fail this found non space character
_EILEndTrim:
		iny 								; trim after non space character.
		lda 	#0 							; trim here.
		sta 	lineBuffer,y
		lda 	#13 						; echo the RETURN
		jsr 	EXTPrintCharacter
		; Skip over any continuation rows
_EILExitSkipCont:
		lda 	EXTRow
		cmp 	EXTScreenHeight
		bcs 	_EILExitSkipDone 			; at bottom, stop
		; Check if current row is a continuation
		jsr 	EILCheckWrap
		beq 	_EILExitSkipDone 			; not a continuation, done
		; This row is a continuation - move to next line
		lda 	#13
		jsr 	EXTPrintCharacter
		bra 	_EILExitSkipCont 			; check again
_EILExitSkipDone:
		pla 								; reset I/O page
		sta 	1

		ply
		plx
		pla
		rts
;
;		Backspace from current position, put A on the end
;		Handles wrapped continuation rows by pulling content from next row
;		Uses: zTemp0 = fill char, zTemp0+1 = current row number
;		      zTemp1 = working row address
;
EXTILDelete:
		sta 	zTemp0 						; save the fill character (space or color)
		;
		; Initialize working variables
		lda 	EXTRow
		sta 	zTemp0+1 					; current row number
		lda 	EXTAddress
		sta 	zTemp1
		lda 	EXTAddress+1
		sta 	zTemp1+1 					; zTemp1 = current row address
		ldy 	EXTColumn 					; start column
		;
_EXTDShiftRow:
		; Shift characters from Y+1 to Y, up to second-to-last position
_EXTDShiftLoop:
		iny
		cpy 	EXTScreenWidth
		bcs 	_EXTDCheckWrap 				; reached end of row
		lda 	(zTemp1),y 					; get char at Y
		dey
		sta 	(zTemp1),y 					; store at Y-1
		iny
		bra 	_EXTDShiftLoop
		;
_EXTDCheckWrap:
		; Row shifted. Last position needs to be filled.
		; Check if next row is a wrapped continuation.
		lda 	zTemp0+1
		inc 	a 							; next row number
		cmp 	EXTScreenHeight
		bcs 	_EXTDFillSpace 				; past bottom, fill with space
		;
		pha
		jsr 	EILCheckWrap
		beq 	_EXTDNotWrapped 			; not wrapped, pla + fill with space
		pla
		;
		; Next row IS wrapped - get its first char for current row's last position
		sta 	zTemp0+1 					; update row counter to next row
		; Get first char from next row (need to calculate its address)
		clc
		lda 	zTemp1
		adc 	EXTScreenWidth
		sta 	zTemp1
		bcc 	+
		inc 	zTemp1+1
+		; Check if entire row is spaces (empty)
		ldy 	#0
_EXTDCheckEmpty:
		lda 	(zTemp1),y
		cmp 	#' '
		bne 	_EXTDPullChar 				; found non-space, row has content
		iny
		cpy 	EXTScreenWidth
		bne 	_EXTDCheckEmpty
		;
		; Row is all spaces - clear wrap flag and stop pulling
		lda 	zTemp0+1 					; current row number (the wrapped row)
		lsr 	a
		lsr 	a
		lsr 	a 							; byte index
		tax
		lda 	zTemp0+1
		and 	#7 							; bit index
		tay
		lda 	EILBitTable,y
		eor 	#$FF 						; invert to make mask
		and 	lwWrapFlags,x
		sta 	lwWrapFlags,x 				; clear the wrap flag
		; Restore zTemp1 to previous row for fill
		sec
		lda 	zTemp1
		sbc 	EXTScreenWidth
		sta 	zTemp1
		bcs 	+
		dec 	zTemp1+1
+		bra 	_EXTDFillSpace 				; fill with space and exit
		;
_EXTDPullChar:
		ldy 	#0
		lda 	(zTemp1),y 					; get first char to pull
		; Store at last position of previous row
		ldy 	EXTScreenWidth
		dey
		sec
		pha 								; save the char
		lda 	zTemp1
		sbc 	EXTScreenWidth
		sta 	zTemp1
		bcs 	+
		dec 	zTemp1+1
+		pla 								; restore the char
		sta 	(zTemp1),y 					; store at end of previous row
		;
		; Now advance to next row and shift it from column 0
		clc
		lda 	zTemp1
		adc 	EXTScreenWidth
		sta 	zTemp1
		bcc 	+
		inc 	zTemp1+1
+		ldy 	#0 							; start from column 0
		jmp 	_EXTDShiftRow 				; shift this row too
		;
_EXTDNotWrapped:
		pla 								; discard saved row number
_EXTDFillSpace:
		; Fill last position with the saved fill character
		ldy 	EXTScreenWidth
		dey
		lda 	zTemp0 						; get fill char
		sta 	(zTemp1),y
		rts
;
;		Insert at current position.
;		
EXTILInsert:
		ldy 	EXTScreenWidth 				; end position
_EXTILoop:
		dey 								; back one
		cpy 	EXTColumn 					; exit if reached insert point.
		beq 	_EXTIExit
		dey 								; copy one byte up.
		lda 	(EXTAddress),y
		iny
		sta 	(EXTAddress),y
		bra 	_EXTILoop 
_EXTIExit:
		rts

;
;		Try to overflow character A to next wrapped row.
;		On entry: A = overflow char (last char of current line)
;		On exit: Carry set = success, Carry clear = fail
;		Uses zTemp1 for next row address. Does NOT modify EXTAddress.
;
EILDoOverflow:
		sta 	lwOverflowChar
		;
		; Check if next row exists and is a continuation
		lda 	EXTRow
		inc 	a
		cmp 	EXTScreenHeight
		bcs 	_EILDOFail
		jsr 	EILCheckWrap
		beq 	_EILDOFail
		;
		; Compute next row address into zTemp1
		clc
		lda 	EXTAddress
		adc 	EXTScreenWidth
		sta 	zTemp1
		lda 	EXTAddress+1
		adc 	#0
		sta 	zTemp1+1
		;
		; Check room (last char of next row must be space)
		lda 	#2
		sta 	1
		ldy 	EXTScreenWidth
		dey
		lda 	(zTemp1),y
		cmp 	#' '
		bne 	_EILDOFail
		;
		; Shift next row right by 1 (text plane)
_EILDOShift:
		dey
		bmi 	_EILDOWrite
		dey
		lda 	(zTemp1),y
		iny
		sta 	(zTemp1),y
		bra 	_EILDOShift
_EILDOWrite:
		; Write overflow char at column 0
		ldy 	#0
		lda 	lwOverflowChar
		sta 	(zTemp1),y
		;
		; Shift color plane right by 1
		lda 	#3
		sta 	1
		ldy 	EXTScreenWidth
		dey
_EILDOShiftC:
		dey
		bmi 	_EILDOWriteC
		dey
		lda 	(zTemp1),y
		iny
		sta 	(zTemp1),y
		bra 	_EILDOShiftC
_EILDOWriteC:
		; Copy color from column 1 to column 0
		ldy 	#1
		lda 	(zTemp1),y
		dey
		sta 	(zTemp1),y
		;
		sec
		rts
_EILDOFail:
		clc
		rts
;
;		Check wrap flag for row number in A.
;		Returns: Z flag clear if wrapped, Z flag set if not wrapped.
;		Clobbers: A, X, Y
;
EILCheckWrap:
		pha
		lsr 	a
		lsr 	a
		lsr 	a 							; byte index
		tax
		pla
		and 	#7 							; bit index
		tay
		lda 	lwWrapFlags,x
		and 	EILBitTable,y
		rts
;
;		Bit lookup table for wrap flags (local copy)
;
EILBitTable:
		.byte 	1, 2, 4, 8, 16, 32, 64, 128

		.send code

; ************************************************************************************************
;
;									Changes and Updates
;
; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;		27/11/22 		Added Ctrl+D Delete at character
;		22/12/22 		When trimming if first character was non-space got erased so deleting
;						lines 1-9 did not work.
;		30/01/23 		Moved out of hardware module into normal space.
;		04/03/23 		Code at _EILLoop when inserting pre-checks for space.
;		19/02/26 		Wrap-aware input: collect across wrapped rows, insert
;						overflow to next row, extracted EILCheckWrap helper.
;
; ************************************************************************************************
