; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		extern.asm
;		Purpose:	External functions
;		Created:	29th September 2022
;		Reviewed: 	
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
		stz 	1 							; Access I/O
		stz 	$D004 						; Disable border
		stz 	$D008
		stz 	$D009
		lda 	#1+8						; Timer On at 70Hz counting up.
		sta 	$D658
		;
		lda 	#3 							; get current text colour
		sta 	1
		lda 	$C000
		sta 	EXTTextColour
		;
		lda 	#80 						; set screen dimensions.
		sta 	EXTScreenWidth
		lda 	#60
		sta 	EXTScreenHeight

		jsr 	EXTHomeCursor 				; home cursor 
_EXMoveDown: 								; move down past prompt.
		lda 	#13
		jsr 	PAGEDPrintCharacter
		lda 	EXTRow
		cmp 	#6
		bne 	_EXMoveDown

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
		.tickcheck PagedSNDUpdate
		jsr 	$FFE4
		cmp 	#0
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
		lda 	#((\1) >> 3)
		jsr 	$FFE7
		and 	#($01 << ((\1) & 7))
		beq 	_NoSet1
		txa
		ora 	#\2
		tax
_NoSet1:		
		.endm

Export_EXTReadController:
		phx
		ldx 	#0
		.ifpressed $2D,1 				; X right
		.ifpressed $2C,2 				; Z left
		.ifpressed $32,4 				; M down
		.ifpressed $25,8 				; K up
		.ifpressed $26,16 				; L fire#1
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
