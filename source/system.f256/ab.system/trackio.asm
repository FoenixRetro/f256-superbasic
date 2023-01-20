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
		jsr 	ProcessKeyboardEvent
_GNECheckMouseEvent:		

		ply 								; restore registers
		plx
		pla
_GNEExit:
		plp
		rts		

; ************************************************************************************************
;
;				Process a key PRESSED/RELEASED, updating key status bit array
;
; ************************************************************************************************

ProcessKeyboardEvent:
		lda 	KNLEvent.key.ascii 			; raw key code.
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
