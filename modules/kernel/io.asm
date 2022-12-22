; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		io.asm
;		Purpose:	Input/Output kernel commands
;		Created:	22nd December 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

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
		jsr 	CheckKeyPressed
		cmp 	#0 							; loop back if none pressed.
		beq 	_EISCWait
		ply
		plx
		rts

; ************************************************************************************************
;
;									Check if keyboard pressed.
;
; ************************************************************************************************

CheckKeyPressed:
	jmp 	$FFE4

        jsr     kernel.NextEvent
        bcs     CheckKeyPressed
;        lda     event.type
 ;       cmp     #kernel.event.key.PRESSED
  		bne 	CheckKeyPressed
 ;		lda     event.key.ascii
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
;
; ************************************************************************************************
