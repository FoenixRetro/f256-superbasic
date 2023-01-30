; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		trackio.asm
;		Purpose:	Wrapper for kernel.nextEvent
;		Created:	20th January 2023
;		Reviewed: 	No.
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;									Clear I/O Tracking
;
; ************************************************************************************************

ResetIOTracking:
		ldx 	#GNEEnd-GNEBegin-1
_RIOLoop:
		stz 	GNEBegin,x
		dex
		bpl 	_RIOLoop
		rts

; ************************************************************************************************
;
;			Effectively calls kernel.nextEvent but also updates keyboard state 
;			and mouse events.
;
;			This is not called from the emulator because it does not update the queue.
;			However, the functions like keydown() do invoke it so they will still work.
;			In the emulator keyboard joystick support is provided through $DC00 emulation
;
; ************************************************************************************************

GetNextEvent:
		jsr 	kernel.NextEvent 			; get event
		php									; save yes/no flag.
		bcs 	_GNEExit
		pha 								; save registers
		phx
		phy
		;
		;		Key pressed/released update the key state bit array.
		;
		lda 	KNLEvent.type	 			; check for PRESSED or RELEASED
		cmp 	#kernel.event.key.PRESSED
		beq 	_GNEKeyEvent
		cmp 	#kernel.event.key.RELEASED 
		bne 	_GNECheckMouseEvent
_GNEKeyEvent:
		jsr 	ProcessKeyboardEvent 		; process keyboard up/down.
		jsr 	UpdateKeyboardJoystick 		; update the keyboard-joystick.
		bra 	_GNEEventExit

_GNECheckMouseEvent:		
		cmp 	#kernel.event.mouse.DELTA 	; check for move events
		bne 	_GNENotDelta
		jsr 	ProcessMouseDeltaEvent 		; process them.
		bra 	_GNEEventExit
_GNENotDelta:
		cmp 	#kernel.event.mouse.CLICKS 	; check for click events
		bne 	_GNEEventExit
		jsr 	ProcessMouseClickEvent 		; process them.
_GNEEventExit:		
		ply 								; restore registers
		plx
		pla
_GNEExit:
		plp
		rts		

; ************************************************************************************************
;
;								Process mouse DELTA event
;
; ************************************************************************************************

ProcessMouseDeltaEvent:
		ldx 	#MouseDeltaX-GNEBegin
		lda 	KNLEvent.mouse.delta.x
		jsr 	PMKAddSubtract
		lda 	KNLEvent.mouse.delta.y
		jsr 	PMKAddSubtract
		lda 	KNLEvent.mouse.delta.z
		jsr 	PMKAddSubtract
		rts

; ************************************************************************************************
;
;								Process mouse CLICK event
;
; ************************************************************************************************

ProcessMouseClickEvent:
		ldx 	#MouseCountInner-GNEBegin
		lda 	KNLEvent.mouse.clicks.inner
		jsr 	PMKAdd
		lda 	KNLEvent.mouse.clicks.middle
		jsr 	PMKAdd
		lda 	KNLEvent.mouse.clicks.outer
		jsr 	PMKAdd
		rts

; ************************************************************************************************
;
;								Adjust value,X (2 bytes) by A
;
; ************************************************************************************************

PMKAddSubtract:
		cmp 	#0 							; subtracting ?
		bmi 	PMKSubtract
PMKAdd: 									; add A to Value.W,X
		clc 
		adc 	GNEBegin,x
		sta 	GNEBegin,x
		bcc 	PMKExit
		inc 	GNEBegin+1,x
		bra 	PMKExit
PMKSubtract: 								; sub A from Value.W,X
		sec
		eor 	#$FF
		adc 	GNEBegin,x
		sta 	GNEBegin,x
		bcs 	PMKExit
		dec 	GNEBegin+1,x
PMKExit:
		inx 								; next slot ?		
		inx		
		rts

; ************************************************************************************************
;
;				Process a key PRESSED/RELEASED, updating key status bit array
;
; ************************************************************************************************

ProcessKeyboardEvent:
		lda 	KNLEvent.key.raw 			; raw key code.
		jsr 	KeyboardConvertXA  			; convert to index in X, mask in A
		ldy 	KNLEvent.type
		cpy 	#kernel.event.key.RELEASED 	; check if pressed/released
		beq 	_PKERelease
		ora 	KeyStatus,x 				; set bit
		sta 	KeyStatus,x
		rts
_PKERelease:
		eor 	#$FF						; clear bit
		and 	KeyStatus,x
		sta 	KeyStatus,x
		rts


; ************************************************************************************************
;
;							Update the keyboard-joystick byte (ZX KM L)
;
; ************************************************************************************************

UpdateKeyboardJoystick:
		stz 	KeyJoystick
		ldx 	#0
_UKJLoop:
		lda 	_UKJKeys,x 					; which key
		and 	#$1F
		tay
		lda 	KeyStatus,y 				; get status
		and 	#$10 						; letters always bit 4 (actually ASCII of L/C)
		clc  								; set C if bit set
		adc 	#$FF
		rol 	KeyJoystick 				; shift into place
		inx
		cpx 	#5 							; do all 5
		bne 	_UKJLoop
		rts
;	
;		This mapping may change if raw changes ?
;
_UKJKeys:
		.byte	'L','X','Z','M','K'		

; ************************************************************************************************
;
;				Convert Raw Scan code A to index in X, mask in A
;
; ************************************************************************************************

KeyboardConvertXA:
		ldx 	#1 							; set the mask temp to %00000001
		stx 	KeyMaskTemp
_KCCALoop:
		clc
		adc 	#$20 						; upper 3 bits are the mask, if causes CS A will be in the range 00-1F		
		bcs 	_KCCADone
		asl 	KeyMaskTemp 				; shift the mask temp
		bra 	_KCCALoop
_KCCADone:
		tax 								; table entry in X
		lda 	KeyMaskTemp 				; mask temp in A.
		rts

		.send code


		.section storage
GNEBegin:

KeyStatus: 									; 8 x 32 = 256 bits, keyboard status.
		.fill 	32
KeyMaskTemp:
		.fill 	1
KeyJoystick:
		.fill 	1		
MouseDeltaX: 								; mouse Deltas
		.fill 	2
MouseDeltaY:
		.fill 	2				
MouseDeltaZ:
		.fill 	2				
MouseCountInner: 							; mouse buttons (L M B)
		.fill 	2 
MouseCountMiddle:
		.fill 	2		
MouseCountOuter:
		.fill 	2				
GNEEnd:

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