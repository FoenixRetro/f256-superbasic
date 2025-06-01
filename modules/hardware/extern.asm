;;
; External hardware functions
;;

		.section code

;;
; Initialize hardware display system.
;
; Performs initialization of the F256 display hardware and text console
; system. Sets up screen dimensions, cursor, colors, and clears the display.
; This function must be called before using any other display functions.
;
; \out EXTTextColour    0x52
; \out EXTScreenWidth   80
; \out EXTScreenHeight  60
;
; \sideeffects  - Sets `EXTTextColour` to $52 (default color).
;               - Sets screen dimensions to 80×60 characters.
;               - Enables hardware cursor with character 214.
;               - Clears screen and positions cursor below header.
;               - Modifies hardware registers $D004, $D008, $D009, $D010, $D012, and $D658.
;               - Calls `EXTClearScreenCode` and `EXTShowHeader`.
;
; \see          EXTClearScreenCode, EXTShowHeader, EXTScreenWidth, EXTScreenHeight
;;
Export_EXTInitialise:
		stz 	1 							; Access I/O page 0
		stz 	$D004 						; Disable border
		stz 	$D008
		stz 	$D009
		lda 	#1+8						; Timer On at 70Hz counting up.
		sta 	$D658
		;
		lda 	#$52
		sta 	EXTTextColour
		;
		lda 	#80 						; set screen dimensions.
		sta 	EXTScreenWidth
		lda 	#60
		sta 	EXTScreenHeight

		lda 	#1+4 						; enable cursor
		sta 	$D010 				
		lda 	#214 						; cursor character
		sta 	$D012

		jsr 	EXTClearScreenCode 			; clear the screen

_EXMoveDown: 								; move down past prompt 
		lda 	#13
		jsr 	PAGEDPrintCharacter
		lda 	EXTRow
		cmp 	#Header_Height-4
		bne 	_EXMoveDown
		jsr 	EXTShowHeader
		stz 	1
		rts				



		.send code
