; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		getkey.asm
;		Purpose:	Get one keystroke, synchronising sound
;		Created:	7th January 2023
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
		jsr 	KNLCheckKeyPressed
		cmp 	#0 							; loop back if none pressed.
		beq 	_EISCWait
		ply
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
