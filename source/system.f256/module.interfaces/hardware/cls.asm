; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		cls.asm
;		Purpose:	Clear Screen
;		Created:	13th October 2022
;		Reviewed: 	17th November 2022
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

ClearScreen: ;; [cls]
		phy
		lda 	#12 						; char code 12 clears the screen.
		jsr 	EXTPrintCharacter
		ply
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