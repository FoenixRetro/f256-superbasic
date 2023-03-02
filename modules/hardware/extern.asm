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
;		02/03/23 		Cursor on/character moved here.
;
; ************************************************************************************************
