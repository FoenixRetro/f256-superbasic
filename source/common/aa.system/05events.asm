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
		jsr 	KNLSetEventPointer
		   
		jsr     kernel.NextEvent 			; get next event
		bcs 	_PEExitZ 					; nothing left to process.

		lda 	KNLEvent.type 				; go back if event not key.pressed.
		cmp 	#kernel.event.key.PRESSED
		bne 	ProcessEvents

		lda	 	KNLEvent.key.flags 			; is KNLEvent.key.flags = 0 ?
		bne 	ProcessEvents
		lda 	KNLEvent.key.ascii 			; is it Ctrl+C
		cmp 	#3
		beq 	_PEReturnBreak  			; no, keep going.

		phx
		ldx 	KeyboardQueueEntries 		; get keyboard queue size into X
		cpx 	#KBDQueueSize 				; if full, then ignore
		beq 	_PENoQueue
		sta 	KeyboardQueue,x 			; write into queue
		inc 	KeyboardQueueEntries 		; bump count
_PENoQueue:
		plx 			
		bra 	ProcessEvents

_PEReturnBreak:
		lda 	#255 						; return with NZ state
		rts

_PEExitZ:									; return with Z flag set, e.g. no more events, no Ctrl+C
		lda 	#0
		rts

; ************************************************************************************************
;
;								Pop head of event queue
;
; ************************************************************************************************

PopKeyboardQueue:
		lda 	KeyboardQueueEntries 		; get keyboard queue entries.
		beq 	_PKQExit 					; zero, then exit.
		;
		lda 	KeyboardQueue 				; save head of keyboard queue
		pha
		;
		phx 								; drop head of queue
		ldx 	#0
_PKQLoop:
		lda 	KeyboardQueue+1,x 			; shift everything back one. 
		sta 	KeyboardQueue,x  			; not efficient but doesn't matter.
		inx
		cpx 	#7
		bne 	_PKQLoop
		plx

		dec 	KeyboardQueueEntries 		; one fewer in queue.
		pla 								; restore head of queue.
_PKQExit:
		rts
		.send code

		.section storage

KBDQueueSize = 8

KeyboardQueue:
		.fill 	KBDQueueSize
KeyboardQueueEntries:
		.fill 	1

		.send 	storage

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
