; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		event.asm
;		Purpose:	Event trigger function.
;		Created:	13th October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;				event(tracker,rate) when tracker >= 0 returns true every rate ticks
;
; ************************************************************************************************

UnaryEvent: ;; [event(]
		plx
		;
		jsr 	TimerToStackX 				; timer in +0
		inx  								; put reference into +1
		jsr 	EvaluateTerm
		lda 	NSStatus,x 					; check if is integer reference
		cmp 	#NSTInteger+NSBIsReference 
		bne 	_UEType
		;
		inx 								; put the step in +2
		jsr 	CheckComma
		jsr 	Evaluate16BitInteger
		jsr 	CheckRightBracket
		;
		dex
		dex
		;
		lda 	NSMantissa0+1,x 			; copy reference to zTemp0
		sta 	zTemp0
		lda 	NSMantissa1+1,x
		sta 	zTemp0+1
		;
		phy
		;
		ldy 	#3 							; check bit 7 of last bit, the packed sign bit
		lda 	(zTemp0),y
		bmi 	_UEFalse 					; exit if signed.
		;
		ldy 	#0 							; has it timed out (24 bit)
		lda 	NSMantissa0,x
		cmp 	(zTemp0),y
		iny
		lda 	NSMantissa1,x
		sbc		(zTemp0),y
		iny
		lda 	NSMantissa2,x
		sbc		(zTemp0),y
		bcc 	_UEFalse 					; no, return FALSE.
		;
		clc
		ldy 	#0 							; work out new value as timer() + step
		lda 	NSMantissa0,x
		adc 	NSMantissa0+2,x
		sta 	(zTemp0),y
		iny
		lda 	NSMantissa1,x
		adc 	NSMantissa1+2,x
		sta 	(zTemp0),y
		iny
		lda 	NSMantissa2,x
		adc 	NSMantissa2+2,x
		sta 	(zTemp0),y
		;
		ply
		jmp 	ReturnTrue

_UEFalse:
		ply 								; restore Y
		jmp 	ReturnFalse 				; and return False


_UEType:
		jmp 	TypeError

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
