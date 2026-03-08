; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		scrollnav.asm
;		Purpose:	Screen scroll navigation using Shift+Up/Down to browse listings
;		Created:	22nd January 2026
;		Reviewed: 	No
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;						Handle Shift+Up - scroll to show previous line at top
;
; ************************************************************************************************

HandleShiftUp:
		pha
		phx
		phy

		; Default to 1 row scroll
		lda 	#1
		sta 	snLineRowCount

		; Try to find previous line to display
		stz 	snHaveLine 					; assume no line to display
		jsr 	FindFirstScreenLineNumber 	; get first visible line number into snLineNum
		bcc 	_HSUHaveLine

		; No line on screen - find last line in program
		lda 	#$FF
		sta 	snLineNum
		sta 	snLineNum+1
		jsr 	FindPreviousLine 			; find last line (before $FFFF)
		bra 	_HSUCheckResult

_HSUHaveLine:
		jsr 	FindPreviousLine 			; find the line before it
_HSUCheckResult:
		bcs 	_HSUDoScroll 				; no line found, just scroll 1

		lda 	#1
		sta 	snHaveLine 					; we have a line to display

		; Calculate how many rows this line needs
		jsr 	CalculateLineRowCount 		; result in snLineRowCount

_HSUDoScroll:
		; Save I/O page
		lda 	1
		pha

		; Scroll snLineRowCount times
		ldx 	snLineRowCount
_HSUScrollLoop:
		phx

		lda 	#2 							; text page
		sta 	1
		lda 	#32 						; fill with space
		jsr 	EXTScrollDown

		lda 	#3 							; colour page
		sta 	1
		lda 	EXTTextColour
		jsr 	EXTScrollDown

		; Shift wrap flags down (inline) - row N becomes row N+1 (bits shift left)
		; Use Y as down-counter since DEY doesn't affect carry flag
		ldy 	#8
		clc
		ldx 	#0
_HSUShiftWrap:
		lda 	lwWrapFlags,x
		rol 	a
		sta 	lwWrapFlags,x
		inx
		dey 								; DEY doesn't affect carry!
		bne 	_HSUShiftWrap

		plx
		dex
		bne 	_HSUScrollLoop

		pla 								; restore I/O page
		sta 	1

		; Display line at row 0 if we have one
		lda 	snHaveLine
		beq 	_HSUExit
		jsr 	DisplayLineAtRow0Multi 		; uses snLineRowCount

_HSUExit:
		ply
		plx
		pla
		rts

; ************************************************************************************************
;
;						Handle Shift+Down - scroll to show next line at bottom
;
; ************************************************************************************************

HandleShiftDown:
		pha
		phx
		phy

		; Default to 1 row scroll
		lda 	#1
		sta 	snLineRowCount

		; Try to find next line to display
		stz 	snHaveLine 					; assume no line to display
		jsr 	FindLastScreenLineNumber 	; get last visible line number into snLineNum
		bcc 	_HSDHaveLine

		; No line on screen - find first line in program
		stz 	snLineNum
		stz 	snLineNum+1
		jsr 	FindNextLine 				; find first line (after 0)
		bra 	_HSDCheckResult

_HSDHaveLine:
		jsr 	FindNextLine 				; find the line after it
_HSDCheckResult:
		bcs 	_HSDDoScroll 				; no line found, just scroll 1

		lda 	#1
		sta 	snHaveLine 					; we have a line to display

		; Calculate how many rows this line needs
		jsr 	CalculateLineRowCount 		; result in snLineRowCount

_HSDDoScroll:
		; Save I/O page and EXTAddress (EXTScrollFill uses it for last row)
		lda 	1
		pha
		lda 	EXTAddress
		pha
		lda 	EXTAddress+1
		pha

		; Set EXTAddress to last row for EXTScrollFill
		lda 	EXTScreenHeight
		dec 	a
		asl 	a 							; multiply by 2 for table index
		tay
		clc
		lda 	#<EXTMemory
		adc 	EXTScreenRowOffsets,y
		sta 	EXTAddress
		lda 	#>EXTMemory
		adc 	EXTScreenRowOffsets+1,y
		sta 	EXTAddress+1

		; Scroll snLineRowCount times
		ldx 	snLineRowCount
_HSDScrollLoop:
		phx

		lda 	#2 							; text page
		sta 	1
		lda 	#32 						; fill with space
		jsr 	EXTScrollFill

		lda 	#3 							; colour page
		sta 	1
		lda 	EXTTextColour
		jsr 	EXTScrollFill

		; Shift wrap flags up (inline) - row N becomes row N-1 (bits shift right)
		; Use Y as down-counter since DEY doesn't affect carry flag
		ldy 	#8
		clc
		ldx 	#7
_HSDShiftWrap:
		lda 	lwWrapFlags,x
		ror 	a
		sta 	lwWrapFlags,x
		dex
		dey 								; DEY doesn't affect carry!
		bne 	_HSDShiftWrap

		plx
		dex
		bne 	_HSDScrollLoop

		pla 								; restore EXTAddress and I/O page
		sta 	EXTAddress+1
		pla
		sta 	EXTAddress
		pla
		sta 	1

		; Display line at appropriate row if we have one
		lda 	snHaveLine
		beq 	_HSDExit
		jsr 	DisplayLineAtLastRowMulti 	; uses snLineRowCount

_HSDExit:
		ply
		plx
		pla
		rts

; ************************************************************************************************
;
;		Find the first line number visible on screen
;		Returns: snLineNum = line number, CS if not found, CC if found
;
; ************************************************************************************************

FindFirstScreenLineNumber:
		stz 	snCurrentRow 				; start from row 0
_FFSLNLoop:
		lda 	snCurrentRow
		cmp 	EXTScreenHeight 			; past end of screen?
		bcs 	_FFSLNNotFound

		; Check if this row is a wrapped continuation (inline check)
		lda 	snCurrentRow
		lsr 	a
		lsr 	a
		lsr 	a 							; byte index = row / 8
		tax
		lda 	snCurrentRow
		and 	#7 							; bit index = row & 7
		tay
		lda 	lwWrapFlags,x
		and 	snWrapBitTable,y
		bne 	_FFSLNNext 					; wrapped row, skip it

		jsr 	ParseLineNumberAtRow 		; try to parse line number at this row
		bcc 	_FFSLNFound 				; found one!

_FFSLNNext:
		inc 	snCurrentRow 				; try next row
		bra 	_FFSLNLoop

_FFSLNNotFound:
		sec 								; not found
		rts

_FFSLNFound:
		clc 								; found, line number in snLineNum
		rts

; ************************************************************************************************
;
;		Find the last line number visible on screen
;		Returns: snLineNum = line number, CS if not found, CC if found
;
; ************************************************************************************************

FindLastScreenLineNumber:
		lda 	EXTScreenHeight 			; start from last row
		dec 	a
		sta 	snCurrentRow
_FLSLNLoop:
		lda 	snCurrentRow
		bmi 	_FLSLNNotFound 				; past row 0?

		; Check if this row is a wrapped continuation (inline check)
		lda 	snCurrentRow
		lsr 	a
		lsr 	a
		lsr 	a 							; byte index = row / 8
		tax
		lda 	snCurrentRow
		and 	#7 							; bit index = row & 7
		tay
		lda 	lwWrapFlags,x
		and 	snWrapBitTable,y
		bne 	_FLSLNNext 					; wrapped row, skip it

		jsr 	ParseLineNumberAtRow 		; try to parse line number at this row
		bcc 	_FLSLNFound 				; found one!

_FLSLNNext:
		dec 	snCurrentRow 				; try previous row
		bra 	_FLSLNLoop

_FLSLNNotFound:
		sec 								; not found
		rts

_FLSLNFound:
		clc 								; found, line number in snLineNum
		rts

; ************************************************************************************************
;
;		Parse line number at given row
;		Input: snCurrentRow = row to check
;		Output: snLineNum = line number (if found), CC if found, CS if not
;
; ************************************************************************************************

ParseLineNumberAtRow:
		lda 	1 							; save I/O page
		pha
		lda 	#2 							; switch to text page
		sta 	1

		; Calculate row address using row offset table
		; Use zTemp0 for indirect addressing (zero page)
		lda 	snCurrentRow
		asl 	a 							; multiply by 2 for table index
		tay
		clc
		lda 	#<EXTMemory
		adc 	EXTScreenRowOffsets,y
		sta 	zTemp0
		lda 	#>EXTMemory
		adc 	EXTScreenRowOffsets+1,y
		sta 	zTemp0+1

		; Now parse digits at start of line
		stz 	snLineNum 					; clear result
		stz 	snLineNum+1
		ldy 	#0 							; column index
		stz 	snDigitCount 				; count of digits found

_PLNLoop:
		cpy 	#7 							; max 7 characters to check (5 digit number + space + more)
		bcs 	_PLNCheckResult

		lda 	(zTemp0),y 					; get character
		bmi 	_PLNSkip 					; skip color codes (>= $80)

		cmp 	#' ' 						; space?
		beq 	_PLNCheckSpace

		cmp 	#'0' 						; check if digit
		bcc 	_PLNCheckResult 			; < '0', not a digit
		cmp 	#'9'+1
		bcs 	_PLNCheckResult 			; > '9', not a digit

		; It's a digit - multiply result by 10 and add
		and 	#$0F 						; convert ASCII to value
		pha 								; save digit

		; Multiply snLineNum by 10
		; snLineNum = snLineNum * 8 + snLineNum * 2
		lda 	snLineNum
		sta 	snTemp
		lda 	snLineNum+1
		sta 	snTemp+1

		; *2
		asl 	snLineNum
		rol 	snLineNum+1
		; *4
		asl 	snLineNum
		rol 	snLineNum+1
		; + original = *5
		clc
		lda 	snLineNum
		adc 	snTemp
		sta 	snLineNum
		lda 	snLineNum+1
		adc 	snTemp+1
		sta 	snLineNum+1
		; *10
		asl 	snLineNum
		rol 	snLineNum+1

		; Add the digit
		pla
		clc
		adc 	snLineNum
		sta 	snLineNum
		bcc 	_PLNNoCarry
		inc 	snLineNum+1
_PLNNoCarry:
		inc 	snDigitCount
		iny
		bra 	_PLNLoop

_PLNSkip:
		iny 								; skip color code
		bra 	_PLNLoop

_PLNCheckSpace:
		; Space found - if we've seen digits, we're done
		lda 	snDigitCount
		bne 	_PLNSuccess
		iny 								; leading space, continue
		bra 	_PLNLoop

_PLNCheckResult:
		lda 	snDigitCount 				; did we find any digits?
		beq 	_PLNFail

_PLNSuccess:
		pla 								; restore I/O page
		sta 	1
		clc 								; success
		rts

_PLNFail:
		pla 								; restore I/O page
		sta 	1
		sec 								; failure
		rts

; ************************************************************************************************
;
;		Find the previous line before snLineNum
;		Sets codePtr to point to it
;		Returns: CS if not found (already at first line), CC if found
;
; ************************************************************************************************

FindPreviousLine:
		; We need to scan from start and find line before snLineNum
		.cresetcodepointer 					; start from beginning

		; Save current target
		lda 	snLineNum
		sta 	snTemp
		lda 	snLineNum+1
		sta 	snTemp+1

		; Clear "previous line" tracker
		stz 	snPrevPtr
		stz 	snPrevPtr+1
		lda 	#$FF 						; marker for "no previous"
		sta 	snHavePrev

_FPLLoop:
		.cget0 								; get offset
		beq 	_FPLCheckPrev 				; end of program

		; Get current line number
		ldy 	#1
		.cget
		sta 	snLineNum
		iny
		.cget
		sta 	snLineNum+1

		; Compare current line >= target?
		lda 	snLineNum+1
		cmp 	snTemp+1
		bcc 	_FPLSavePrev 				; current < target, save as prev
		bne 	_FPLCheckPrev 				; current > target, use prev
		lda 	snLineNum
		cmp 	snTemp
		bcs 	_FPLCheckPrev 				; current >= target, use prev

_FPLSavePrev:
		; Save current as previous (including page index)
		lda 	codePtr
		sta 	snPrevPtr
		lda 	codePtr+1
		sta 	snPrevPtr+1
		lda 	codePtr+2
		sta 	snPrevPage
		stz 	snHavePrev 					; mark that we have a prev

		.cnextline 							; advance to next line
		bra 	_FPLLoop

_FPLCheckPrev:
		lda 	snHavePrev 					; do we have a previous?
		bne 	_FPLNotFound

		; Set codePtr to previous line (including page)
		lda 	snPrevPage
		sta 	codePtr+2
		lda 	snPrevPtr
		sta 	codePtr
		lda 	snPrevPtr+1
		sta 	codePtr+1
		.cresync

		; Get its line number
		ldy 	#1
		.cget
		sta 	snLineNum
		iny
		.cget
		sta 	snLineNum+1

		clc 								; found
		rts

_FPLNotFound:
		sec 								; not found
		rts

; ************************************************************************************************
;
;		Find the next line after snLineNum
;		Sets codePtr to point to it
;		Returns: CS if not found (already at last line), CC if found
;
; ************************************************************************************************

FindNextLine:
		; Use MemorySearch to find line >= snLineNum
		lda 	snLineNum
		ldx 	snLineNum+1
		jsr 	MemorySearch 				; find line >= XA
		bcc 	_FNLNotFound 				; no line found at all

		; If we found exact match, advance to next
		bne 	_FNLHaveNext 				; Z not set means we found greater line

		; Found exact match, need next line
		.cget0 								; get offset
		beq 	_FNLNotFound 				; end of program
		.cnextline

_FNLHaveNext:
		.cget0 								; check if this is end
		beq 	_FNLNotFound

		; Get line number
		ldy 	#1
		.cget
		sta 	snLineNum
		iny
		.cget
		sta 	snLineNum+1

		clc 								; found
		rts

_FNLNotFound:
		sec 								; not found
		rts

; ************************************************************************************************
;
;		Calculate the absolute indent for the line at codePtr
;		Scans from program start and accumulates indent changes
;		Sets listIndent to the correct value before displaying the line
;
; ************************************************************************************************

CalculateAbsoluteIndent:
		; Save the target codePtr (including page)
		lda 	codePtr
		sta 	snTargetPtr
		lda 	codePtr+1
		sta 	snTargetPtr+1
		lda 	codePtr+2
		sta 	snTargetPage

		; Reset to program start and clear indent
		.cresetcodepointer
		stz 	listIndent

_CAILoop:
		; Check for end of program (may advance page at boundary)
		.cget0
		beq 	_CAIDone

		; Check if we've reached the target line (page + address)
		; Done AFTER .cget0 because it may cross a page boundary
		lda 	codePtr+2
		cmp 	snTargetPage
		bne 	_CAINotTarget
		lda 	codePtr
		cmp 	snTargetPtr
		bne 	_CAINotTarget
		lda 	codePtr+1
		cmp 	snTargetPtr+1
		beq 	_CAIDone 					; reached target, listIndent is now correct

_CAINotTarget:
		; Replicate TKListConvertLine's exact listIndent adjustment
		jsr 	ScanGetCurrentLineStep 		; returns step in A, sets listElseFound

		; 1. ELSE pre-adjust: dec listIndent (only if > 0)
		pha
		lda 	listElseFound
		beq 	_CAINoElsePre
		lda 	listIndent
		beq 	_CAINoElsePre
		dec 	listIndent
_CAINoElsePre:
		pla 								; restore step
		; 2. Apply step (negative before, positive after — same net effect)
		bmi 	_CAINegative
		clc
		adc 	listIndent
		sta 	listIndent
		bra 	_CAIElsePost
_CAINegative:
		clc
		adc 	listIndent
		bpl 	_CAIStoreNeg
		lda 	#0
_CAIStoreNeg:
		sta 	listIndent
_CAIElsePost:
		; 3. ELSE post-adjust: inc listIndent
		lda 	listElseFound
		beq 	_CAINext
		inc 	listIndent

_CAINext:
		.cnextline
		bra 	_CAILoop

_CAIDone:
		; Restore the target codePtr (including page)
		lda 	snTargetPage
		sta 	codePtr+2
		lda 	snTargetPtr
		sta 	codePtr
		lda 	snTargetPtr+1
		sta 	codePtr+1
		.cresync
		rts

; ************************************************************************************************
;
;		Display line at codePtr starting at row 0
;		For multi-row lines that may span multiple screen rows
;		Requires: snLineRowCount already set to number of rows this line uses
;
; ************************************************************************************************

DisplayLineAtRow0Multi:
		; Save cursor state and suppress hardware cursor updates
		lda 	EXTRow
		pha
		lda 	EXTColumn
		pha
		lda 	EXTAddress
		pha
		lda 	EXTAddress+1
		pha
		lda 	#1
		sta 	EXTSuppressCursor 			; suppress hardware cursor updates

		; Recalculate indent (may have been modified by CalculateLineRowCount)
		jsr 	CalculateAbsoluteIndent

		; Set cursor to row 0, column 0
		stz 	EXTRow
		stz 	EXTColumn
		lda 	#<EXTMemory
		sta 	EXTAddress
		lda 	#>EXTMemory
		sta 	EXTAddress+1

		jsr 	DisplayCurrentLine

		; Restore cursor state and re-enable hardware cursor
		stz 	EXTSuppressCursor 			; re-enable hardware cursor updates
		pla
		sta 	EXTAddress+1
		pla
		sta 	EXTAddress
		pla
		sta 	EXTColumn
		pla
		sta 	EXTRow
		rts

; ************************************************************************************************
;
;		Display line at codePtr, ending at last screen row
;		Accounts for multi-row lines by positioning cursor appropriately
;		Requires: snLineRowCount already set to number of rows this line uses
;
; ************************************************************************************************

DisplayLineAtLastRowMulti:
		; Save cursor state and suppress hardware cursor updates
		lda 	EXTRow
		pha
		lda 	EXTColumn
		pha
		lda 	EXTAddress
		pha
		lda 	EXTAddress+1
		pha
		lda 	#1
		sta 	EXTSuppressCursor 			; suppress hardware cursor updates

		; Recalculate indent (may have been modified by CalculateLineRowCount)
		jsr 	CalculateAbsoluteIndent

		; Calculate starting row: lastRow - (rowCount - 1) = screenHeight - rowCount
		lda 	EXTScreenHeight
		sec
		sbc 	snLineRowCount
		sta 	EXTRow
		stz 	EXTColumn

		; Calculate address for that row
		asl 	a 							; multiply by 2 for table
		tay
		clc
		lda 	#<EXTMemory
		adc 	EXTScreenRowOffsets,y
		sta 	EXTAddress
		lda 	#>EXTMemory
		adc 	EXTScreenRowOffsets+1,y
		sta 	EXTAddress+1

		jsr 	DisplayCurrentLine

		; Restore cursor state and re-enable hardware cursor
		stz 	EXTSuppressCursor 			; re-enable hardware cursor updates
		pla
		sta 	EXTAddress+1
		pla
		sta 	EXTAddress
		pla
		sta 	EXTColumn
		pla
		sta 	EXTRow
		rts

; ************************************************************************************************
;
;		Display the current line (at codePtr) at current cursor position
;
; ************************************************************************************************

DisplayCurrentLine:
		; Convert line to text using same method as LIST command
		jsr 	ScanGetCurrentLineStep 		; get indent adjust (also clears listElseFound)
		jsr 	TKListConvertLine 			; convert line into tokenBuffer

		; Print the string
		ldx 	#(tokenBuffer >> 8)
		lda 	#(tokenBuffer & $FF)
		jmp 	PrintStringXA

; ************************************************************************************************
;
;		Calculate row count for line at codePtr
;		Input: codePtr = line, listIndent = current indent
;		Output: snLineRowCount = number of rows (1+)
;
; ************************************************************************************************

CalculateLineRowCount:
		jsr 	ScanGetCurrentLineStep 		; set up indent
		jsr 	TKListConvertLine 			; convert to tokenBuffer

		; Count visible characters (skip color codes $80-$9F)
		ldy 	#0
		stz 	snTemp 						; character count low
		stz 	snTemp+1 					; character count high
_CLRCLoop:
		lda 	tokenBuffer,y
		beq 	_CLRCDone 					; null terminator
		bmi 	_CLRCSkip 					; skip color codes ($80+)
		inc 	snTemp
		bne 	_CLRCSkip
		inc 	snTemp+1
_CLRCSkip:
		iny
		bne 	_CLRCLoop

_CLRCDone:
		; Handle empty line (at least 1 row)
		lda 	snTemp
		ora 	snTemp+1
		bne 	_CLRCNotEmpty
		lda 	#1
		sta 	snLineRowCount
		rts

_CLRCNotEmpty:
		; Divide by screen width, round up: (count + width - 1) / width
		; First: count = count + width - 1
		clc
		lda 	snTemp
		adc 	EXTScreenWidth
		sta 	snTemp
		bcc 	+
		inc 	snTemp+1
+		sec
		lda 	snTemp
		sbc 	#1
		sta 	snTemp
		bcs 	+
		dec 	snTemp+1
+
		; Divide by width by repeated subtraction
		stz 	snLineRowCount
_CLRCDivLoop:
		sec
		lda 	snTemp
		sbc 	EXTScreenWidth
		tax
		lda 	snTemp+1
		sbc 	#0
		bcc 	_CLRCDivDone 				; went negative, done
		stx 	snTemp
		sta 	snTemp+1
		inc 	snLineRowCount
		bra 	_CLRCDivLoop
_CLRCDivDone:
		rts

; Bit lookup table for wrap flag checking
snWrapBitTable:
		.byte 	1, 2, 4, 8, 16, 32, 64, 128

		.send code

; ************************************************************************************************
;
;								Storage for scroll navigation
;
; ************************************************************************************************

		.section storage

snLineNum: 									; current line number being searched
		.fill 	2
snCurrentRow: 								; current row being scanned
		.fill 	1
snDigitCount: 								; count of digits found
		.fill 	1
snTemp: 									; temporary storage
		.fill 	2
snPrevPtr: 									; pointer to previous line
		.fill 	2
snPrevPage:									; page index of previous line
		.fill 	1
snHavePrev: 								; flag: have we found a previous line?
		.fill 	1
snHaveLine:									; flag: do we have a line to display after scroll?
		.fill 	1
snTargetPtr:								; saved target codePtr for indent calculation
		.fill 	2
snTargetPage:								; saved target page for indent calculation
		.fill 	1
snLineRowCount:								; calculated row count for a line
		.fill 	1

		.send storage

; ************************************************************************************************
;
;									Changes and Updates
;
; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;		22/01/26 		Created. Shift+Up/Down scroll navigation with wrap
;						flag awareness and line number parsing.
;
; ************************************************************************************************
