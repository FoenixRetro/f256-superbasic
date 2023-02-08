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
		jsr 	PMKAdjustTotal
		jsr 	PMKAddSubtract
		lda 	KNLEvent.mouse.delta.y
		jsr 	PMKAdjustTotal
		jsr 	PMKAddSubtract
		lda 	KNLEvent.mouse.delta.z
		jsr 	PMKAdjustTotal
		jsr 	PMKAddSubtract

		lda 	KNLEvent.mouse.delta.buttons
		ldx 	#MouseStatusX-GNEBegin
		jsr 	PMKOutputButton
		jsr 	PMKOutputButton
		jsr 	PMKOutputButton

		jsr 	PMKClipMouseCoord
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
;						 Output bit in LSB of A as button status
;
; ************************************************************************************************

PMKOutputButton:
		stz 	GNEBegin,x 					; button to zero
		stz 	GNEBegin+1,x
		ror 	a 							; shift LSB into carry
		bcc 	_PMKOBExit
		dec 	GNEBegin,x 					; if set then set to -1
		dec 	GNEBegin+1,x
_PMKOBExit:
		inx  								; next button
		inx
		rts

; ************************************************************************************************
;
;							Adjust the totals final position by A
;
; ************************************************************************************************

PMKAdjustTotal:
		pha 								; save offset A index X
		phx

		pha 								; point X to the position
		txa
		clc
		adc 	#MousePosX-MouseDeltaX
		tax
		pla

		jsr 	PMKAddSubtract 				; reuse the addition code.

		plx 								; restore XA
		pla
		rts

; ************************************************************************************************
;
;									Clip mouse position to screen
;
; ************************************************************************************************

PMKClipMouseCoord:
		ldx 	#0
_PCMCLoop:
		lda 	MousePosX+1,x 				; check if -ve
		bpl 	_PCMCNotNeg
		stz 	MousePosX,x 				; if so zero position.
		stz 	MousePosX+1,x
_PCMCNotNeg:
		lda 	MousePosX,x 				; compare pos vs extent
		cmp 	_PCMCExtent,x
		lda 	MousePosX+1,x
		sbc 	_PCMCExtent+1,x
		bcc 	_PCMCNotOver 				; in range ?

		lda 	_PCMCExtent,x 				; no, set to X limit.
		sta 	MousePosX,x
		lda 	_PCMCExtent+1,x
		sta 	MousePosX+1,x
_PCMCNotOver:

		inx
		inx
		cpx 	#3*2
		bne 	_PCMCLoop
		rts		

_PCMCExtent: 								; extents of the three
		.word 	319,239,255

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
		clc
		adc 	GNEBegin,x
		sta 	GNEBegin,x
		lda 	GNEBegin+1,x
		adc 	#$FF
		sta 	GNEBegin+1,x
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

CMDMouseFlag: 								; $FF if mouse, $00 if mdelta.
		.fill 	1

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

MouseCountInner: 							; mouse buttons (L M B) click count
		.fill 	2 
MouseCountMiddle:
		.fill 	2		
MouseCountOuter:
		.fill 	2				

MousePosX: 									; mouse positions.
		.fill 	2	
MousePosY:
		.fill 	2	
MousePosZ:
		.fill 	2	

MouseStatusX: 								; mouse (L M B) status.
		.fill 	2	
MouseStatusY:
		.fill 	2	
MouseStatusZ:
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
