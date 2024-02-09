; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		events.asm
;		Purpose:	Event processing
;		Created:	5th January 2023
;		Reviewed: 	No.
;		Author:		Paul Robson (paul@robsons.org.uk)
;		Author:		Jessie Oberreuter <gadget@moselle.com> (key repeat)
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
                cmp     #kernel.event.timer.EXPIRED
                beq     _PEIsTimer
		cmp     #kernel.event.key.RELEASED
		beq     _PEIsRelease
		cmp 	#kernel.event.key.PRESSED
		bne 	ProcessEvents

		lda	KNLEvent.key.flags 			; is KNLEvent.key.flags = 0 ?
    ; Just report the pseudo-ascii values for meta keys
		;bmi 	_PEIsRaw
		bne 	ProcessEvents
		lda 	KNLEvent.key.ascii 			; is it Ctrl+C
		cmp 	#3
		beq 	_PEReturnBreak  			; no, keep going.

              ; Schedule repeats for keys from CBM/K keyboards.
		phx
                ldx     KNLEvent.key.keyboard
                bne     +
                tax
                jsr     StartRepeatTimerForKey
                txa
+               plx

		bra 	_PEQueueA
_PEIsTimer:
                jsr     HandleRepeatTimerEvent
                bcs     ProcessEvents
                bra     _PEQueueA
_PEIsRelease:
              ; We would normally "jsr StopRepeat" here, but 
              ; this function is no longer the central place
              ; where events are pulled from the kernel queue;
              ; that functionality has been moved to trackio.asm,
              ; and all calls to get events now call GetNextEvent
              ; in that file.  The key code decoding is here, so
              ; we must request repeats here, but this code might
              ; not see the matching key release, as it can occur
              ; during, say, disk operations.  Alas, this means
              ; that the release processing must be handled in
              ; trackio.asm rather than here.
              ;
              ; These two different types of key processing should
              ; not have been split into two different files, but
              ; here we are.  Until  someone chooses to improve
              ; the factoring, the call to StopRepeat must move to
              ; trackio.asm.
              
                bra     ProcessEvents
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

; ************************************************************************************************
;
;								 Key Repeat structs and functions
;
; ************************************************************************************************

repeat_t        .struct
key             .byte   ?   ; Key-code to repeat.
cookie          .byte   ?   ; Timer ID.
                .ends


StartRepeatTimerForKey
    ; IN: key code in A.

              ; Key to repeat.
                sta     repeat.key

              ; New timer ID.
                inc     repeat.cookie

              ; Get the current frame counter.
                lda     #kernel.args.timer.FRAMES | kernel.args.timer.QUERY
                sta     kernel.args.timer.units
                jsr     kernel.Clock.SetTimer

              ; Schedule a timer approx 0.5s in the future (repeat delay).
                adc     #30
                bra     ScheduleRepeatEvent

StopRepeat
                inc     repeat.cookie
                rts

ScheduleRepeatEvent
    ; IN:   A = abs frame count of requested next event.

                sta     kernel.args.timer.absolute

                lda     #kernel.args.timer.FRAMES
                sta     kernel.args.timer.units

                lda     repeat.cookie
                sta     kernel.args.timer.cookie

                jmp     kernel.Clock.SetTimer


HandleRepeatTimerEvent
    ; OUT:  Carry Set if event has been silently handled.
    ;       Carry Clear and A = key code if event resulted in a repeat.

              ; Ignore retired timers.
                lda     KNLEvent.timer.cookie
                cmp     repeat.cookie
                beq     _repeat
                sec
                rts
_repeat
              ; Schedule the next repeat for ~0.05s from now.
                lda     KNLEvent.timer.value
                clc
                adc     #3
                jsr     ScheduleRepeatEvent

              ; Return the key being repeated.
                lda     repeat.key
                clc
                rts

		.send code

		.section storage

repeat:         .dstruct    repeat_t

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
;               12/27/23                Adds last key repeat.
;
; ************************************************************************************************
