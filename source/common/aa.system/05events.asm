; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		05events.asm
;		Purpose:	Event processing
;		Created:	5th January 2023
;		Reviewed: 	No.
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;							Code to process events in check break loop.
;
; ************************************************************************************************

		.section code

ProcessEvents:
		lda     #<event 					; tell kernel where events go.
		sta     kernel.args.events+0
		lda     #>event
		sta     kernel.args.events+1
		   
		jsr     kernel.NextEvent 			; get next event
		bcs 	_PEExitZ 					; nothing left to process.

		lda 	event.type 					; go back if event not key.pressed.
		cmp 	#kernel.event.key.PRESSED
		bne 	ProcessEvents

		lda	 	event.key.flags 			; is event.key.flags = 0 ?
		bne 	ProcessEvents
		lda 	event.key.ascii 			; is it Ctrl+C
		cmp 	#3
		bne 	ProcessEvents  				; no, keep going.

		lda 	#255 						; return with NZ state
		rts

_PEExitZ:									; return with Z flag set, e.g. no more events, no Ctrl+C
		lda 	#0
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
