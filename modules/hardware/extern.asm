; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		extern.asm
;		Purpose:	External functions
;		Created:	29th September 2022
;		Reviewed: 	27th November 2022
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;									Any required initialisation
;
; ************************************************************************************************

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

		jsr 	EXTClearScreenCode 			; clear the screen

_EXMoveDown: 								; move down past prompt 
		lda 	#13
		jsr 	PAGEDPrintCharacter
		lda 	EXTRow
		cmp 	#Header_Height+1
		bne 	_EXMoveDown
		jsr 	EXTShowHeader
		stz 	1
		rts				

; ************************************************************************************************
;
;											Get Character
;
;	Returns:
;			8 		Backspace, if not far left
;			9 		Tab spacing (Ctrl+I)
;			13 		CR/LF with scrolling if required
;			32..127	Corresponding ASCII character
;
; ************************************************************************************************

Export_EXTInputSingleCharacter:
PagedInputSingleCharacter:
		phx
		phy
_EISCWait:	
		.tickcheck PagedSNDUpdate 			; sound processing carries on.
		jsr 	$FFE4 						; get a key
		cmp 	#0 							; loop back if none pressed.
		beq 	_EISCWait
		ply
		plx
		rts

; ************************************************************************************************
;
;				Break Check. Checks Ctrl+C, Escape or whatever. Returns Z if pressed
;
; ************************************************************************************************

Export_EXTBreakCheck:
		jmp		$FFE1

; ************************************************************************************************
;
;						Read Game Controller A -> A (Fire/Up/Down/Left/Right)
;
; ************************************************************************************************

ifpressed .macro
		lda 	#KP_\1_ROW
		jsr 	$FFE7
		and 	#KP_\1_COL
		beq 	_NoSet1
		txa
		ora 	#\2
		tax
_NoSet1:		
		.endm


KP_Z_ROW = 3
KP_Z_COL = $04
KP_X_ROW = 4
KP_X_COL = $04
KP_K_ROW = 8
KP_K_COL = $04
KP_M_ROW = 7
KP_M_COL = $04
KP_L_ROW = 9
KP_L_COL = $08

Export_EXTReadController:
		phx
	ldx 	#0
		.ifpressed X,1 				; X right
		.ifpressed Z,2 				; Z left
		.ifpressed M,4 				; M down
		.ifpressed K,8 				; K up
		.ifpressed L,16 			; L fire#1
		txa
		plx
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
;		27/11/22 		Rather than clearing screen, it now goes to line 6 after initialising.
;
; ************************************************************************************************
