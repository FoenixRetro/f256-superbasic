; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		events.asm
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
		   
		jsr     GetNextEvent 				; get next event
		bcs 	_PEExitZ 					; nothing left to process.

		lda 	KNLEvent.type 				; go back if event not key.pressed.
		cmp 	#kernel.event.key.PRESSED
		bne 	ProcessEvents

		lda	 	KNLEvent.key.flags 			; is KNLEvent.key.flags = 0 ?
		bmi 	_PEIsRaw
		bne 	ProcessEvents
		lda 	KNLEvent.key.ascii 			; is it Ctrl+C
		cmp 	#3
		beq 	_PEReturnBreak  			; no, keep going.
		bra 	_PEQueueA
_PEIsRaw:
		lda 	KNLEvent.key.raw 			; return raw key if F1-F12
		cmp 	#129
		bcc		ProcessEvents
		cmp 	#140+1
		bcs 	ProcessEvents
_PEQueueA:
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
;								Pop head of keyboard queue
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

; ************************************************************************************************
;
;							Check to see if keystroke events pending
;
; ************************************************************************************************

KNLGetKeyPressed:
		.tickcheck TickHandler  			; if time elapsed call the tick handler.
		lda 	KeyboardQueueEntries 		; something in the queue
		bne 	PopKeyboardQueue 			; if so, pop and return it
		jsr 	ProcessEvents 				; process any outstanding events
		lda 	#0
		rts		

; ************************************************************************************************
;
;								 Get a single character press
;
; ************************************************************************************************
		
KNLGetSingleCharacter:
		jsr 	KNLGetKeyPressed
		cmp 	#0
		beq 	KNLGetSingleCharacter
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
;		12/02/23 		Returns function keys as chr$(128+fn)
;
; ************************************************************************************************
