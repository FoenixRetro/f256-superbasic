; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		setup.asm
;		Purpose:	Reset the BASIC stack
;		Created:	1st October 2022
;		Reviewed: 	28th November 2022
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;			Reset the BASIC stack. Return in A the MSB of the bottom of stack space
;
; ************************************************************************************************

StackReset:
											; reset the basic stack pointer.
		.set16 	basicStack,BasicStackBase+BasicStackSize-1 		

		lda 	#$F0 						; impossible frame marker - cannot have one with 0 bytes.
		sta 	(basicStack) 				; puts a dummy marker at TOS which will never match things like NEXT/RETURN
											; any attempt to pop it will cause an error
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
