; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		shifts.asm
;		Purpose:	Handle binary shift operations
;		Created:	21st September 2022
;		Reviewed: 	27th November 2022
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;					Left/Right shift - difference is result on entry
;
; ************************************************************************************************


ShiftLeft: ;; [<<]
		sec 								; common code, carry determines which way.
		bra 	ShiftMain
ShiftRight: ;; [>>]		
		clc
ShiftMain:		
		plx 								; restore X
		php 								; save direction
		.dispatchintegeronly 				; preprocess for integers.
		;
		lda 	NSMantissa0+1,x 			; check number < 32
		and 	#$E0
		ora 	NSMantissa1+1,x
		ora 	NSMantissa2+1,x
		ora 	NSMantissa3+1,x
		bne 	_SMExit0 					; if >= 32 it will always return zero.
_SMLoop:
		dec 	NSMantissa0+1,x 			; predecrement, could do << 0
		bmi 	_SMExit 					; exit if done.
		plp 								; restore direction setting
		php		
		bcc 	_SMRight
		jsr 	NSMShiftLeft 				; shift left if CS
		bra 	_SMLoop
_SMRight:		
		jsr 	NSMShiftRight 				; shift right if CC
		bra 	_SMLoop
		;
_SMExit0:
		jsr 	NSMSetZero 					; return zero.
_SMExit:
		plp 								; throw direction
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
