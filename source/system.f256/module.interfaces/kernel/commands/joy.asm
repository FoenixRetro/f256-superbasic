; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		joy.asm
;		Purpose:	Joystick/Joypad interface
;		Created:	13th October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;							Simplified joystick/joypad functions
;
; ************************************************************************************************

UnaryJoyX: ;; [joyx(]
		clc
		bra 	JoyMain
UnaryJoyY: ;; [joyy(]
		sec
JoyMain:
		plx 								; get pos
		php 								; save carry (set for Y)
		jsr 	Evaluate8BitInteger 		; ignore the parameter
		jsr 	CheckRightBracket
		;
		jsr 	KNLReadController 			; read the controller.
		plp
		bcs 	_JMNoShift 					; if X then shift bits 3,2 -> 1,0
		lsr 	a
		lsr 	a
_JMNoShift:
		lsr 	a 							; if bit 0 set then left/up e.g. -1
		bcs 	JMIsLeft
		lsr 	a 							; if bit 1 set then right/down e.g. +1
		bcs 	JMIsRight
		jsr 	NSMSetZero 					; zero result
		rts
JMIsLeft:
		jmp 	ReturnTrue
JMIsRight:
		lda 	#1
		jsr 	NSMSetByte
		rts				

UnaryJoyB: ;; [joyb(]
		plx 								; get pos
		jsr 	Evaluate8BitInteger 		; ignore the parameter
		jsr 	CheckRightBracket
		jsr 	KNLReadController 			; read the controller.
		and 	#$10
		bne 	JMIsLeft
		jsr 	NSMSetZero
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
;		20/12/22 		Fixed for controller changes $DC00 layout different.
;
; ************************************************************************************************
