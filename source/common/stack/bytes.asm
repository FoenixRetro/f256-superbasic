; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		bytes.asm
;		Purpose:	Push/Pull single bytes on the stack
;		Created:	5th October 2022
;		Reviewed: 	28th November 2022
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;								Push A on the BASIC stack
;
; ************************************************************************************************

StackPushByte:
		pha 								; save byte on stack
		lda 	BasicStack 					; decrement basic stack pointer
		bne 	_SPBNoBorrow
		dec 	BasicStack+1 				; borrow
		lda 	BasicStack+1 				; check range.
		cmp 	#BasicStackBase >> 8
		bcc 	_SPBMemory
_SPBNoBorrow:
		dec 	BasicStack

		pla 								; get back and write
		sta 	(BasicStack)
		rts				

_SPBMemory:
		.error_stack
		
; ************************************************************************************************
;
;								Pop A off the BASIC stack
;
; ************************************************************************************************				

StackPopByte:
		lda 	(BasicStack) 				; bump the stack pointer.
		inc 	BasicStack
		bne 	_SPBNoCarry
		inc 	BasicStack+1
_SPBNoCarry:
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
;		28/11/22 		Removed spurious PHA after dec BasicStack+1. Not actually caused an error
;						probably because never pushed the stack hard enough.
;
; ************************************************************************************************
