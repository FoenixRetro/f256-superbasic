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

; ************************************************************************************************
;
;									Any required initialisation
;
; ************************************************************************************************

EXTInitialise:
		stz 	1 							; Access I/O
		stz 	$D004 						; Disable border
		stz 	$D008
		stz 	$D009
		lda 	#1+8						; Timer On at 70Hz counting up.
		sta 	$D658
		rts

; ************************************************************************************************
;
;										Clear Screen
;
; ************************************************************************************************
				
EXTClearScreen:
		jmp 	$FFEA
						
; ************************************************************************************************
;
;								Print Character in A to display
;
;	Handles:
;			8 		Backspace, if not far left
;			9 		Tab spacing
;			13 		CR/LF with scrolling if required
;			32..127	Corresponding ASCII out.	
;
; ************************************************************************************************

EXTPrintCharacter:
		pha
		phx
		phy
		jsr 	$FFD2
		ply
		plx
		pla
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


EXTInputSingleCharacter:
		phx
		phy
_EISCWait:		
		jsr 	$FFE4
		cmp 	#0
		beq 	_EISCWait
		ply
		plx
		rts

; ************************************************************************************************
;
;									Input line into lineBuffer
;
;		This can use ExtInputSingleCharacter *or* $FFCF, the screen editor or similar.
;
; ************************************************************************************************

EXTInputLine:
		ldx 	#0 							; position in line <- start of line
_ILLoop:		
		phx 								; read character in
		jsr 	$FFCF
		plx
		cmp 	#8 							; backspace, CBM doesn't need this.
		beq 	_ILBackspace
		cmp 	#13							; exit ?
		beq 	_ILExit
		cmp 	#32 						; ignore other control
		bcc 	_ILLoop
		cpx 	#MaxLineSize 				; already full buffer
		beq 	_ILLoop
		sta 	lineBuffer,x 				; save it
		inx
		bra 	_ILLoop

_ILBackspace:
		cpx 	#0  						; can't backspace, start of line.
		beq 	_ILLoop		
		dex 								; back one.
		bra 	_ILLoop

_ILExit:
		jsr 	EXTPrintCharacter 	
		stz 	lineBuffer,x 				; make ASCIIZ and exit with address in XA
		rts

; ************************************************************************************************
;
;				Break Check. Checks Ctrl+C, Escape or whatever. Returns Z if pressed
;
; ************************************************************************************************

EXTBreakCheck:
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

EXTReadController:
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
