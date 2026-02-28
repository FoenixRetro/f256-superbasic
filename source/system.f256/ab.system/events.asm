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
		bcc 	_PEHaveEvent 				; have an event to process
		jmp 	_PEExitZ 					; nothing left to process
_PEHaveEvent:

		lda 	KNLEvent.type 				; go back if event not key.pressed.
                cmp     #kernel.event.timer.EXPIRED
                bne 	_PENotTimer
                jmp     _PEIsTimer
_PENotTimer:
		cmp     #kernel.event.key.RELEASED
		bne 	_PENotRelease
		jmp     _PEIsRelease
_PENotRelease:
		cmp 	#kernel.event.key.PRESSED
		bne 	ProcessEvents

		lda	KNLEvent.key.flags 			; is KNLEvent.key.flags = 0 ?
		bpl 	_PENotRaw
		jmp		_PEIsRaw
_PENotRaw:
		beq 	_PECheckNormal 				; flags=0, normal processing
		;
		; 		flags != 0, check for FNX+arrow or shift+backspace
		;
		lda 	KNLEvent.key.ascii
		cmp 	#$10 						; Up arrow
		beq 	_PEFlagsArrowUD
		cmp 	#$0E 						; Down arrow
		beq 	_PEFlagsArrowUD
		cmp 	#$08 						; Backspace (Shift+DEL = insert line)
		beq 	_PEShiftBackspace 			; queue it, input.asm handles shift detection
		cmp 	#$B5 						; INS key (Shift+Backspace)
		beq 	_PEDoInsertLine
		bra 	ProcessEvents 				; other modified keys, ignore

_PEFlagsArrowUD:
		pha
		jsr 	IsFnxPressed
		beq 	_PEFlagsNoFnx
		pla
		cmp 	#$10
		beq 	_PEFnxUp
		bra 	_PEFnxDown
_PEFlagsNoFnx:
		pla
		jmp 	ProcessEvents 				; non-FNX modified arrow, ignore

_PEDoInsertLine:
		lda 	#$B5 						; queue INS code for input.asm to handle
		jmp 	_PEQueueA

_PEShiftBackspace:
		jmp 	_PEQueueA

_PEFnxUp:
		jsr 	HandleShiftUp
		; Schedule repeat for FNX+up (CBM/K keyboards only)
		phx
		ldx 	KNLEvent.key.keyboard
		bne 	_PEFnxUpDone
		lda 	#$90 					; special code for FNX+up
		jsr 	StartRepeatTimerForKey
_PEFnxUpDone:
		plx
		jmp 	ProcessEvents
_PEFnxDown:
		jsr 	HandleShiftDown
		; Schedule repeat for FNX+down (CBM/K keyboards only)
		phx
		ldx 	KNLEvent.key.keyboard
		bne 	_PEFnxDownDone
		lda 	#$8E 					; special code for FNX+down
		jsr 	StartRepeatTimerForKey
_PEFnxDownDone:
		plx
		jmp 	ProcessEvents

_PECheckNormal:
		lda 	KNLEvent.key.ascii 			; check for arrow keys
		cmp 	#$10 						; Up arrow?
		beq 	_PECheckModArrow
		cmp 	#$0E 						; Down arrow?
		beq 	_PECheckModArrow
		cmp 	#$02 						; Left arrow?
		beq 	_PECheckModArrow
		cmp 	#$06 						; Right arrow?
		beq 	_PECheckModArrow
		cmp 	#$B5 						; INS key (Shift+Backspace)?
		beq 	_PEDoInsertLine
		bra 	_PECheckCtrlC
_PECheckModArrow:
		pha 								; save arrow key
		jsr 	IsAltPressed 				; check if Alt held
		beq 	_PENoAltArrow 				; Z set = no Alt
		pla 								; restore arrow key
		cmp 	#$10
		beq 	_PEAltUp
		cmp 	#$0E
		beq 	_PEAltDown
		; Must be Left ($02) or Right ($06) - do word jump
		cmp 	#$06 						; C=1 if right, C=0 if left
		jsr 	EXTWordJump
		jmp 	ProcessEvents
_PEAltUp:
		lda 	#$01 						; Ctrl+A = beginning of line
		jmp 	_PEQueueA
_PEAltDown:
		lda 	#$05 						; Ctrl+E = end of line
		jmp 	_PEQueueA
_PENoAltArrow:
		; Check FNX for Up/Down scroll
		jsr 	IsFnxPressed
		beq 	_PENoModArrow
		pla 								; restore arrow key
		cmp 	#$10
		beq 	_PEFnxUp
		cmp 	#$0E
		beq 	_PEFnxDown
		bra 	_PEScheduleRepeat 			; FNX+Left/Right = plain arrow
_PENoModArrow:
		pla 								; restore arrow key, continue to repeat scheduling
		bra 	_PEScheduleRepeat
_PECheckCtrlC:
		lda 	KNLEvent.key.ascii 			; is it Ctrl+C
		cmp 	#3
		beq 	_PEReturnBreak  			; no, keep going.

_PEScheduleRepeat:
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
                bcc     _PETimerValid
                jmp     ProcessEvents
_PETimerValid:
                ; Check for FNX+arrow repeat codes
                cmp 	#$90 				; FNX+up?
                beq 	_PERepeatFnxUp
                cmp 	#$8E 				; FNX+down?
                beq 	_PERepeatFnxDown
                bra     _PEQueueA
_PERepeatFnxUp:
                jsr 	HandleShiftUp
                jmp 	ProcessEvents
_PERepeatFnxDown:
                jsr 	HandleShiftDown
                jmp 	ProcessEvents
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

                jmp     ProcessEvents
_PEIsRaw:
		lda 	KNLEvent.key.ascii 			; check for FNX+arrow in raw mode too
		cmp 	#$10 						; Up arrow
		beq 	_PERawArrow
		cmp 	#$0E 						; Down arrow
		beq 	_PERawArrow
		bra 	_PERawNotArrow
_PERawArrow:
		pha 								; save arrow key code
		jsr 	IsFnxPressed 				; check if FNX is held
		beq 	_PERawNoFnx 				; Z set = no FNX
		pla 								; restore arrow code
		cmp 	#$10
		bne 	_PERawFnxDown
		jmp 	_PEFnxUp
_PERawFnxDown:
		jmp 	_PEFnxDown
_PERawNoFnx:
		pla 								; restore arrow code, continue to queue
		bra 	_PEQueueA
_PERawNotArrow:
		cmp 	#$08 						; Backspace (Shift+Backspace = insert line)
		beq 	_PEQueueA 					; queue it, input.asm handles shift detection
		cmp 	#$B5 						; INS key (Shift+Backspace on F256K2)
		beq 	_PEInsertLine 				; handle insert line directly
		cmp 	#129 						; return pseudo ascii value if F1-F12
		bcs 	_PERawCheckF12
		jmp		ProcessEvents

_PEInsertLine:
		lda 	#$B5 						; queue INS code for input.asm to handle
		jmp 	_PEQueueA
_PERawCheckF12:
		cmp 	#140+1
		bcc 	_PEQueueA
		jmp 	ProcessEvents
_PEQueueA:
		phx
		ldx 	KeyboardQueueEntries 		; get keyboard queue size into X
		cpx 	#KBDQueueSize 				; if full, then ignore
		beq 	_PENoQueue
		sta 	KeyboardQueue,x 			; write into queue
		inc 	KeyboardQueueEntries 		; bump count
_PENoQueue:
		plx
		jmp 	ProcessEvents

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

; ************************************************************************************************
;
;		Check if either shift key is currently pressed
;		Returns: Z clear if shift pressed, Z set if not pressed
;		Preserves: X, Y
;
; ************************************************************************************************

IsShiftPressed:
		pha
		phx
		phy
		;
		; LSHIFT = 0, RSHIFT = 1 (from keys.asm)
		;
		lda 	#0
		ldy 	#1
		bra 	CheckModPair

; ************************************************************************************************
;
;		Check if either Alt key is currently pressed
;		Returns: Z clear if Alt pressed, Z set if not pressed
;		Preserves: X, Y
;
; ************************************************************************************************

IsAltPressed:
		pha
		phx
		phy
		;
		; LALT = 4, RALT = 5 (from keys.asm)
		;
		lda 	#4
		ldy 	#5
		bra 	CheckModPair

; ************************************************************************************************
;
;		Check if either FNX/Meta key is currently pressed
;		Returns: Z clear if FNX pressed, Z set if not pressed
;		Preserves: X, Y
;
; ************************************************************************************************

IsFnxPressed:
		pha
		phx
		phy
		;
		; LMETA/FNX = 6, RMETA/FNX = 7 (from keys.asm)
		;
		lda 	#6
		ldy 	#7
		;
		; Fall through to CheckModPair
		;

; ************************************************************************************************
;
;		Shared: check a pair of modifier keys (raw codes in A and Y)
;		Called with A=left raw code, Y=right raw code
;		Returns: Z clear if either pressed, Z set if neither
;		Preserves: X, Y
;
; ************************************************************************************************

CheckModPair:
		jsr 	KeyboardConvertXA
		and 	KeyStatus,x
		bne 	_CMPFound
		tya 								; try right-key code
		jsr 	KeyboardConvertXA
		and 	KeyStatus,x
		bne 	_CMPFound
		;
		; Not pressed - return with Z set
		ply
		plx
		pla
		lda 	#0 							; sets Z flag
		rts
_CMPFound:
		ply
		plx
		pla
		lda 	#1 							; clears Z flag
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
;		19/02/26 		Added GetNextEvent for non-dispatching event read,
;						IsShiftPressed helper for keyboard status check.
;		20/02/26 		Added Shift+Left/Right word jump dispatch as $B6/$B7.
;		28/02/26 		Remapped to macOS conventions: Alt+arrow=word jump/home/end,
;						FNX+Up/Down=scroll. Added IsAltPressed, IsFnxPressed helpers.
;
; ************************************************************************************************
