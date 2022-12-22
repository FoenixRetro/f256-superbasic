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

Export_KNLInputSingleCharacter:
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

Export_KNLInkey:
CheckKeyPressed:
;		jmp 	$FFE4						; *** remove to use kernel functionality ***

		lda     #<event 					; tell kernel where events go.
		sta     kernel.args.events+0
		lda     #>event
		sta     kernel.args.events+1
		   
		jsr     kernel.NextEvent 			; get next event
		bcs 	_CKPNoEvent 				; no event
		lda     event.type
		cmp     #kernel.event.key.PRESSED 	; must be a pressed event.
		bne 	_CKPNoEvent
		lda     event.key.ascii		
		rts
_CKPNoEvent:
		lda 	#0
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

		.section storage
event       .dstruct    kernel.event.event_t   
		.send storage

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
