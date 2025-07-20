;;
; [screen] and [screen$] functions implementation
;;

		.section code

;;
; Handle the [screen] function.
;
; Parses row and column coordinates and retrieves the character at the
; specified screen position. Both coordinates are range-checked against
; screen dimensions before accessing screen memory. Returns the character
; code.
;
; \in Y         Relative offset to function arguments.
; \out A        Character at the specified screen position (as numeric value).
; \out Y        Updated parsing position after consuming arguments.
; \sideeffects  - Modifies registers `A` and `X`.
;               - Uses stack for temporary storage.
; \see          ScreenAtStr, EXTScreenAt, Evaluate8BitInteger, CheckComma,
;               CheckRightBracket, NSMSetByte, RangeError
;;
ScreenAt: ;; [screen(]
		plx 								; restore stack pos

ScreenAtImpl:
		; parse row coordinate
		jsr		Evaluate8BitInteger         ; parse row into `A`
		cmp		EXTScreenHeight				; check if row is within valid range
		bcs		_range_error
		pha									; save it on the stack

		jsr		CheckComma					; ensure the next character is a comma

		; parse column coordinate
		jsr		Evaluate8BitInteger			; parse column into `A`
		cmp		EXTScreenWidth				; check if column is within valid range
		bcs		_range_error
		sta     zTemp0						; save column to `zTemp0`

		jsr 	CheckRightBracket

		; successfully parsed row and column, can set the cursor position now
		pla									; restore row into `A`
		phy									; save `Y`
		ldy     zTemp0						; restore column into `Y`
		jsr 	EXTScreenAt					; get screen character at (row, column)
		ply									; restore `Y`

		jsr 	NSMSetByte					; set return type to byte
		rts

_range_error:
		jmp 	RangeError 					; branch to range error handler

;;
; Handle the [screen$] function.
;
; Retrieves the character at the specified screen coordinates and returns
; it as a single-character string.
;
; \in Y         Relative offset to function arguments.
; \out A        Character at screen position as string value.
; \sideeffects  - See `ScreenAt` side effects.
;               - Calls `ChrToString` for string conversion.
; \see          ScreenAt, ChrToString
;;
ScreenAtStr: ;; [screen$(]
		plx 								; restore stack pos
		jsr 	ScreenAtImpl
		jmp 	ChrToString					; convert character in `A` to string

		.send code
