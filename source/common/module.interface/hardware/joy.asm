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
		jsr 	EXTReadController 			; read the controller.
		plp
		bcc 	_JMNoShift 					; if Y then shift bits 3,2 -> 1,0
		lsr 	a
		lsr 	a
_JMNoShift:
		lsr 	a 							; if bit 0 set then right/down e.g. +1
		bcs 	_JMIsRight
		lsr 	a 							; if bit 1 set then left/up e.g. -1
		bcs 	_JMIsLeft
		jsr 	NSMSetZero 					; zero result
		rts
_JMIsLeft:
		jmp 	ReturnTrue
_JMIsRight:
		lda 	#1
		jsr 	NSMSetByte
		rts				

UnaryJoyB: ;; [joyb(]
		plx 								; get pos
		jsr 	Evaluate8BitInteger 		; ignore the parameter
		jsr 	CheckRightBracket
		jsr 	EXTReadController 			; read the controller.
		lsr 	a
		lsr 	a
		lsr 	a
		lsr 	a
		and 	#1
		jsr 	NSMSetByte
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
