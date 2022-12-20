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
;						Read Game Controller A -> A (Button1/Right/Left/Down/Up)
;
; ************************************************************************************************

Export_EXTReadController:
		phx
		ldx 	1 							; save current I/O in X
		stz 	1 							; switch to I/O 0
		lda 	$DC00  						; read VIA register
		stx 	1 							; repair old I/O and exit
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
; 		20/12/22 		Joystick data now read from $DC00
;
; ************************************************************************************************
